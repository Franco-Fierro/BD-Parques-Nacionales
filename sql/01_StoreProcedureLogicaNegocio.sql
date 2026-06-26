--Universidad Nacional de La Matanza
--MATERIA: BASES DE DATOS APLICADA
--COMISION: 5600
--GRUPO: 03
--FIERRO, FRANCO EZEQUIEL
--GISMONDI, FRANCISCO

--Proposito: Implementar los Store Procedures para la logica de negocio

USE COM5600_G03;
GO


CREATE TYPE Comercial.TipoItemsVenta AS TABLE (
    tipo_item VARCHAR(20) NOT NULL,     
    id_parque SMALLINT NULL,            -- Optimizado a SMALLINT
    id_tipo_visitante TINYINT NULL,     -- Optimizado a TINYINT
    fecha_acceso DATE NULL,             
    id_turno INT NULL,                  
    cantidad INT NOT NULL DEFAULT 1     
);
GO

CREATE OR ALTER PROCEDURE Comercial.SP_RegistrarVenta
    @items Comercial.TipoItemsVenta READONLY,
    @id_punto_de_venta TINYINT, -- Optimizado a TINYINT
    @id_forma_de_pago TINYINT, -- Optimizado a TINYINT
    @numero_factura VARCHAR(20),
    @id_venta_generada INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 1, @max INT, @u INT;
    DECLARE @tipo VARCHAR(20), @id_parque SMALLINT, @id_tv TINYINT, @fecha DATE, @id_turno INT, @cantidad INT; -- Variables Optimizadas
    DECLARE @precio DECIMAL(10,2), @id_entrada INT, @id_ticket INT, @id_item INT, @cupo_max SMALLINT, @ocupados INT; -- @cupo_max a SMALLINT

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Comercial.Punto_de_venta WHERE id_punto_de_venta = @id_punto_de_venta)
            THROW 50001, 'El punto de venta indicado no existe.', 1;

        IF NOT EXISTS (SELECT 1 FROM Comercial.Forma_de_pago WHERE id_forma_de_pago = @id_forma_de_pago)
            THROW 50002, 'La forma de pago indicada no existe.', 1;

        IF @numero_factura IS NULL OR LEN(TRIM(@numero_factura)) = 0
            THROW 50003, 'El número de factura es obligatorio.', 1;

        IF EXISTS (SELECT 1 FROM Comercial.Venta WHERE numero_factura = @numero_factura)
            THROW 50004, 'Ya existe una venta con ese número de factura.', 1;

        IF NOT EXISTS (SELECT 1 FROM @items)
            THROW 50005, 'La venta debe tener al menos un ítem.', 1;


        INSERT INTO Comercial.Venta (id_punto_de_venta, id_forma_de_pago, numero_factura, fecha_emision, total)
        VALUES (@id_punto_de_venta, @id_forma_de_pago, @numero_factura, GETDATE(), 0);

        SET @id_venta_generada = SCOPE_IDENTITY();

        DECLARE @cola TABLE (
            rn INT IDENTITY(1,1),
            tipo_item VARCHAR(20),
            id_parque SMALLINT, id_tipo_visitante TINYINT, fecha_acceso DATE, -- Tipos actualizados
            id_turno INT, cantidad INT
        );

        INSERT INTO @cola (tipo_item, id_parque, id_tipo_visitante, fecha_acceso, id_turno, cantidad)
        SELECT tipo_item, id_parque, id_tipo_visitante,
               ISNULL(fecha_acceso, CAST(GETDATE() AS DATE)),
               id_turno, ISNULL(cantidad, 1)
        FROM @items;

        SET @max = (SELECT MAX(rn) FROM @cola);

        WHILE @i <= @max
        BEGIN
            SELECT @tipo = tipo_item, @id_parque = id_parque, @id_tv = id_tipo_visitante,
                   @fecha = fecha_acceso, @id_turno = id_turno, @cantidad = cantidad
            FROM @cola WHERE rn = @i;

            SET @precio = NULL;
            SET @cupo_max = NULL;

            IF @cantidad < 1
                THROW 50007, 'La cantidad de cada ítem debe ser al menos 1.', 1;

            IF @tipo = 'Entrada'
            BEGIN
                IF @id_parque IS NULL OR @id_tv IS NULL
                    THROW 50008, 'Para una Entrada se requieren id_parque e id_tipo_visitante.', 1;

                SET @precio = (SELECT precio_actual
                               FROM Comercial.Tarifario_parque
                               WHERE id_parque = @id_parque AND id_tipo_visitante = @id_tv);

                IF @precio IS NULL
                    THROW 50009, 'No existe tarifario para ese parque y tipo de visitante.', 1;

                SET @u = 1;
                WHILE @u <= @cantidad
                BEGIN
                    INSERT INTO Comercial.Entrada (id_parque, id_tipo_visitante, fecha_acceso)
                    VALUES (@id_parque, @id_tv, @fecha);
                    SET @id_entrada = SCOPE_IDENTITY();

                    INSERT INTO Comercial.Item_vendible (tipo_item, id_entrada, id_ticket)
                    VALUES ('Entrada', @id_entrada, NULL);
                    SET @id_item = SCOPE_IDENTITY();

                    INSERT INTO Comercial.Detalle_venta (id_venta, id_item, subtotal)
                    VALUES (@id_venta_generada, @id_item, @precio);

                    SET @u = @u + 1;
                END
            END
            ELSE
            BEGIN
                IF @id_turno IS NULL
                    THROW 50010, 'Para un Ticket se requiere id_turno.', 1;

                SELECT @precio = a.costo, @cupo_max = a.cupo_maximo
                FROM Actividades.Turno_actividad ta
                INNER JOIN Actividades.Actividad a ON ta.id_actividad = a.id_actividad
                WHERE ta.id_turno = @id_turno;

                IF @precio IS NULL
                    THROW 50011, 'El turno indicado no existe.', 1;

                SET @u = 1;
                WHILE @u <= @cantidad
                BEGIN
                    IF @cupo_max IS NOT NULL
                    BEGIN
                        SET @ocupados = (SELECT COUNT(*) FROM Comercial.Ticket_actividad WHERE id_turno = @id_turno);
                        IF @ocupados >= @cupo_max
                            THROW 50012, 'El cupo máximo del turno ya fue alcanzado.', 1;
                    END

                    INSERT INTO Comercial.Ticket_actividad (id_turno)
                    VALUES (@id_turno);
                    SET @id_ticket = SCOPE_IDENTITY();

                    INSERT INTO Comercial.Item_vendible (tipo_item, id_entrada, id_ticket)
                    VALUES ('Ticket Actividad', NULL, @id_ticket);
                    SET @id_item = SCOPE_IDENTITY();

                    INSERT INTO Comercial.Detalle_venta (id_venta, id_item, subtotal)
                    VALUES (@id_venta_generada, @id_item, @precio);

                    SET @u = @u + 1;
                END
            END

            SET @i = @i + 1;
        END

        UPDATE Comercial.Venta
        SET total = (SELECT SUM(subtotal) FROM Comercial.Detalle_venta WHERE id_venta = @id_venta_generada)
        WHERE id_venta = @id_venta_generada;

        COMMIT TRANSACTION;
        PRINT 'Venta registrada exitosamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Actividades.SP_AsignarGuiaConValidacion
    @id_guia INT,
    @id_actividad INT,
    @fecha_asignacion DATE,
    @rol VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @vigencia DATE;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Actividades.Guia WHERE id_guia = @id_guia)
            THROW 50001, 'El guía no existe.', 1;

        IF NOT EXISTS (SELECT 1 FROM Actividades.Actividad WHERE id_actividad = @id_actividad)
            THROW 50002, 'La actividad no existe.', 1;

        IF @rol IS NULL OR LEN(TRIM(@rol)) = 0
            THROW 50003, 'El rol del guía es obligatorio.', 1;

        -- Vigencia de la autorización
        SELECT @vigencia = vigencia_autorizacion
        FROM Actividades.Guia WHERE id_guia = @id_guia;

        IF @vigencia IS NULL OR @vigencia < CAST(GETDATE() AS DATE)
            THROW 50004, 'La autorización del guía no está vigente.', 1;

        IF EXISTS (SELECT 1 FROM Actividades.Guias_por_actividad
                   WHERE id_guia = @id_guia AND id_actividad = @id_actividad)
            THROW 50005, 'El guía ya está asignado a esta actividad.', 1;

        IF EXISTS (
            SELECT 1
            FROM Actividades.Guias_por_actividad gpa
            INNER JOIN Actividades.Turno_actividad ta1 ON gpa.id_actividad = ta1.id_actividad
            INNER JOIN Actividades.Turno_actividad ta2 ON ta2.id_actividad = @id_actividad
            WHERE gpa.id_guia = @id_guia
              AND ta1.fecha = ta2.fecha
              AND ta1.hora_inicio = ta2.hora_inicio
        )
            THROW 50006, 'El guía ya tiene otra actividad en la misma fecha y hora.', 1;

        INSERT INTO Actividades.Guias_por_actividad (id_guia, id_actividad, fecha_asignacion, rol)
        VALUES (@id_guia, @id_actividad, @fecha_asignacion, @rol);

        COMMIT TRANSACTION;
        PRINT 'Guía asignado correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Concesiones.SP_RegistrarPagoCanon
    @id_concesion INT,
    @fecha_pago DATE,
    @monto DECIMAL(12,2),
    @periodo_mes TINYINT, -- Optimizado a TINYINT
    @periodo_anio SMALLINT, -- Optimizado a SMALLINT
    @id_estado_pago TINYINT = NULL, -- Optimizado a TINYINT
    @id_pago_generado INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Concesiones.Concesion WHERE id_concesion = @id_concesion)
            THROW 50001, 'La concesión no existe.', 1;

        IF @monto IS NULL OR @monto <= 0
            THROW 50002, 'El monto del pago debe ser mayor a cero.', 1;

        IF @periodo_mes IS NULL OR @periodo_mes < 1 OR @periodo_mes > 12
            THROW 50003, 'El mes del período debe estar entre 1 y 12.', 1;

        IF @periodo_anio IS NULL OR @periodo_anio < 2000
            THROW 50004, 'El año del período no es válido.', 1;

        IF @id_estado_pago IS NULL
            SELECT @id_estado_pago = id_estado_pago
            FROM Concesiones.Estado_pago WHERE descripcion = 'Pagado';

        IF @id_estado_pago IS NULL
            THROW 50005, 'No se encontró el estado de pago "Pagado".', 1;

        IF NOT EXISTS (SELECT 1 FROM Concesiones.Estado_pago WHERE id_estado_pago = @id_estado_pago)
            THROW 50006, 'El estado de pago indicado no existe.', 1;

        IF EXISTS (SELECT 1 FROM Concesiones.Pago_canon
                   WHERE id_concesion = @id_concesion
                     AND periodo_mes = @periodo_mes
                     AND periodo_anio = @periodo_anio)
            THROW 50007, 'Ya existe un pago registrado para ese período.', 1;

        INSERT INTO Concesiones.Pago_canon (id_concesion, id_estado_pago, fecha_pago, monto, periodo_mes, periodo_anio)
        VALUES (@id_concesion, @id_estado_pago, @fecha_pago, @monto, @periodo_mes, @periodo_anio);

        SET @id_pago_generado = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
        PRINT 'Pago de canon registrado correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Concesiones.SP_RenovarConcesion
    @id_concesion INT,
    @nueva_fecha_fin DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @fecha_fin_actual DATE;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Concesiones.Concesion WHERE id_concesion = @id_concesion)
            THROW 50001, 'La concesión no existe.', 1;

        IF @nueva_fecha_fin IS NULL
            THROW 50002, 'Debe indicar la nueva fecha de fin.', 1;

        SELECT @fecha_fin_actual = fecha_fin
        FROM Concesiones.Concesion WHERE id_concesion = @id_concesion;

        -- Renovar = extender: la nueva fecha debe ser posterior a la vigente
        IF @fecha_fin_actual IS NOT NULL AND @nueva_fecha_fin <= @fecha_fin_actual
            THROW 50003, 'La nueva fecha de fin debe ser posterior a la fecha de fin actual.', 1;

        UPDATE Concesiones.Concesion
        SET fecha_fin = @nueva_fecha_fin
        WHERE id_concesion = @id_concesion;

        COMMIT TRANSACTION;
        PRINT 'Concesión renovada correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Parques.SP_ReasignarGuardaparque
    @id_guardaparque INT,
    @id_parque_nuevo SMALLINT, -- Optimizado a SMALLINT
    @fecha_reasignacion DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @id_asignacion_actual INT, @id_parque_actual SMALLINT; -- Optimizado a SMALLINT

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Parques.Guardaparque WHERE id_guardaparque = @id_guardaparque)
            THROW 50001, 'El guardaparque no existe.', 1;

        IF NOT EXISTS (SELECT 1 FROM Parques.Parque_nacional WHERE id_parque = @id_parque_nuevo)
            THROW 50002, 'El parque de destino no existe.', 1;

        IF @fecha_reasignacion IS NULL OR @fecha_reasignacion > CAST(GETDATE() AS DATE)
            THROW 50003, 'La fecha de reasignación no es válida.', 1;

        -- Asignación activa = la que no tiene fecha de fin
        SELECT @id_asignacion_actual = id_asignacion, @id_parque_actual = id_parque
        FROM Parques.Asignacion_guardaparque
        WHERE id_guardaparque = @id_guardaparque AND fecha_fin IS NULL;

        IF @id_asignacion_actual IS NULL
            THROW 50004, 'El guardaparque no tiene una asignación activa para reasignar.', 1;

        IF @id_parque_actual = @id_parque_nuevo
            THROW 50005, 'El guardaparque ya está asignado a ese parque.', 1;

        -- (1) Cerrar la asignación actual
        UPDATE Parques.Asignacion_guardaparque
        SET fecha_fin = @fecha_reasignacion,
            motivo_egreso = 'Reasignación de parque'
        WHERE id_asignacion = @id_asignacion_actual;

        -- (2) Abrir la nueva (activa, sin fecha de fin)
        INSERT INTO Parques.Asignacion_guardaparque (id_guardaparque, id_parque, fecha_inicio, fecha_fin, motivo_egreso)
        VALUES (@id_guardaparque, @id_parque_nuevo, @fecha_reasignacion, NULL, NULL);

        COMMIT TRANSACTION;
        PRINT 'Guardaparque reasignado correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO