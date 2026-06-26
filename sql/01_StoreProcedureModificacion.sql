------------------------------------------------------------------
--Universidad Nacional de La Matanza
--MATERIA: BASES DE DATOS APLICADA
--COMISION: 5600
--GRUPO: 03
--FIERRO, FRANCO EZEQUIEL
--GISMONDI, FRANCISCO
----------------------------------------------------------------
-- Nombre del Archivo: 01_StoreProcedureModificacion.sql
-- Descripcion: Store Procedures para modificar datos en las tablas.
-- Objetivo: Permitir la modificacion de datos en las tablas, con validaciones para garantizar la integridad de los datos.   
----------------------------------------------------------------
USE COM5600_G03;
GO
----------------------------------------------------------------
                ------- SCHEMA PARQUES -------
----------------------------------------------------------------

CREATE OR ALTER PROCEDURE Parques.SP_Modificar_Ubicacion
    @id_ubicacion INT,
    @provincia    VARCHAR(60)   = NULL,
    @region       VARCHAR(80)   = NULL,
    @latitud      DECIMAL(8,6)  = NULL, 
    @longitud     DECIMAL(9,6)  = NULL 
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;
    BEGIN TRY

        IF NOT EXISTS (SELECT 1 FROM Parques.Ubicacion WHERE id_ubicacion = @id_ubicacion)
            THROW 50001, 'No existe una ubicación con el Id proporcionado.', 1;

        IF @provincia IS NOT NULL AND @provincia <> ''
        BEGIN
            SET @provincia = TRIM(@provincia);
            IF LEN(@provincia) > 60
                THROW 50002, 'La provincia no es válida.', 1;

            UPDATE Parques.Ubicacion
            SET provincia = @provincia
            WHERE id_ubicacion = @id_ubicacion;
        END

        IF @region IS NOT NULL AND @region <> ''
        BEGIN
            SET @region = TRIM(@region);
            IF LEN(@region) > 80
                THROW 50003, 'La región no es válida.', 1;

            UPDATE Parques.Ubicacion
            SET region = @region
            WHERE id_ubicacion = @id_ubicacion;
        END

        IF @latitud IS NOT NULL
        BEGIN
            IF @latitud < -90 OR @latitud > 90
                THROW 50004, 'La latitud no es válida.', 1;

            UPDATE Parques.Ubicacion
            SET latitud = @latitud
            WHERE id_ubicacion = @id_ubicacion;
        END

        IF @longitud IS NOT NULL
        BEGIN
            IF @longitud < -180 OR @longitud > 180
                THROW 50005, 'La longitud no es válida.', 1;

            UPDATE Parques.Ubicacion
            SET longitud = @longitud
            WHERE id_ubicacion = @id_ubicacion;
        END

        IF (@provincia IS NOT NULL OR @region IS NOT NULL)
        BEGIN
            IF EXISTS (
                SELECT 1 FROM Parques.Ubicacion u
                WHERE u.provincia = (SELECT provincia FROM Parques.Ubicacion WHERE id_ubicacion = @id_ubicacion)
                AND u.region = (SELECT region FROM Parques.Ubicacion WHERE id_ubicacion = @id_ubicacion)
                AND u.id_ubicacion <> @id_ubicacion
            )
                THROW 50006, 'Ya existe otra ubicación con esa provincia y región.', 1;
        END

        PRINT('Ubicación actualizada correctamente.');
        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Parques.SP_Modificar_Tipo_parque
     @id_tipo_parque TINYINT, -- Optimizado a TINYINT 
     @descripcion varchar(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION
    BEGIN TRY

        IF NOT EXISTS (SELECT 1 FROM Parques.Tipo_parque WHERE id_tipo_parque = @id_tipo_parque)
            THROW 50001, 'No existe un Tipo_parque con el Id proporcionado.', 1;

         IF @descripcion IS NULL OR LEN(TRIM(@descripcion)) = 0
            THROW 50002, 'La descripción es obligatoria.', 1;

        IF LEN(@descripcion) > 50
            THROW 50003, 'La descripción no puede superar los 50 caracteres.', 1;

        IF EXISTS (
            SELECT 1 FROM Parques.Tipo_parque
            WHERE descripcion   = @descripcion
            AND id_tipo_parque <> @id_tipo_parque
        )
            THROW 50004, 'Ya existe otro tipo de parque con esa descripción.', 1;

        UPDATE Parques.Tipo_parque
        SET descripcion = @descripcion
        WHERE id_tipo_parque = @id_tipo_parque;

        PRINT('Tipo_parque actualizado correctamente.');
        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO


CREATE OR ALTER PROCEDURE Parques.SP_Modificar_Parque_nacional
    @id_parque SMALLINT, -- Optimizado a SMALLINT
    @nombre VARCHAR(100) = NULL,
    @superficie decimal(12,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION
    BEGIN TRY

    IF NOT EXISTS(SELECT 1 FROM Parques.Parque_nacional WHERE @id_parque = id_parque)
        THROW 50001, 'No existe un Parque nacional o Área protegida con el Id proporcionado.', 1;

    IF @nombre IS NOT NULL AND @nombre <> ''
      BEGIN
            SET @nombre = TRIM(@nombre);
            IF LEN(@nombre) > 100
                THROW 50002, 'El nombre no es válido.', 1;
      END

      UPDATE Parques.Parque_nacional
      SET 
        nombre = ISNULL(@nombre, nombre),
        superficie = ISNULL(@superficie, superficie) 
      WHERE id_parque = @id_parque;

    PRINT('Parque Nacional actualizado correctamente.');
    COMMIT TRANSACTION;
    END TRY
     BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Parques.SP_Modificar_Datos_Guardaparque
    @id_guardaparque INT,
    @dni VARCHAR(10), -- Optimizado a VARCHAR(10)
    @nombre VARCHAR(50),
    @apellido VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION
    BEGIN TRY

        IF NOT EXISTS(SELECT 1 FROM Parques.Guardaparque WHERE id_guardaparque = @id_guardaparque)
            THROW 50001, 'El Guardaparque indicado no existe.', 1;

        IF EXISTS(SELECT 1 FROM Parques.Guardaparque WHERE dni = @dni AND id_guardaparque <> @id_guardaparque)
            THROW 50002, 'El DNI ingresado ya pertenece a otro Guardaparque.', 1;

        UPDATE Parques.Guardaparque
        SET 
            dni = @dni,
            nombre = TRIM(@nombre),
            apellido = TRIM(@apellido)
        WHERE 
            id_guardaparque = @id_guardaparque;

        PRINT('Datos del guardaparque actualizados correctamente.');
    COMMIT TRANSACTION
    END TRY
     BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Parques.SP_Modificar_Estado_Guardaparque
    @id_guardaparque INT,
    @nuevo_estado VARCHAR(10) -- Optimizado a VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION
    BEGIN TRY
        IF NOT EXISTS(SELECT 1 FROM Parques.Guardaparque WHERE id_guardaparque = @id_guardaparque)
            THROW 50001, 'El Guardaparque indicado no existe.', 1;

        IF TRIM(@nuevo_estado) = '' OR @nuevo_estado IS NULL
            THROW 50003, 'El nuevo estado no puede estar vacío.', 1;

        UPDATE Parques.Guardaparque
        SET 
            estado = TRIM(@nuevo_estado)
        WHERE 
            id_guardaparque = @id_guardaparque;

        PRINT('Estado actualizado correctamente.');
    COMMIT TRANSACTION;
    END TRY
     BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Parques.SP_Registrar_Egreso_guardaparque
    @id_parque SMALLINT, -- Optimizado a SMALLINT
    @id_guardaparque INT,
    @fecha_fin DATE,
    @motivo_egreso varchar(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION
    BEGIN TRY

        IF NOT EXISTS(SELECT 1 FROM Parques.Asignacion_guardaparque WHERE id_guardaparque = @id_guardaparque AND id_parque = @id_parque)
            THROW 50001, 'No existe un Guardaparque asignado con el Id proporcionado para este parque.', 1;
 
        IF @fecha_fin IS NULL
            THROW 50002, 'La fecha de fin no puede ser nula.', 1;

        IF @motivo_egreso IS NOT NULL AND @motivo_egreso <> ''
        BEGIN
            SET @motivo_egreso = TRIM(@motivo_egreso);
            IF LEN(@motivo_egreso) > 100
                THROW 50003, 'El motivo de egreso no es válido.', 1;
        END

        UPDATE Parques.Asignacion_guardaparque
        SET 
            fecha_fin = @fecha_fin,
            motivo_egreso = @motivo_egreso
        WHERE 
            id_guardaparque = @id_guardaparque
            AND id_parque = @id_parque;

        PRINT('Egreso registrado correctamente.');
        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

------------------------------------------------------------------
            ------- SCHEMA CONCESIONES -------
------------------------------------------------------------------
CREATE OR ALTER PROCEDURE Concesiones.SP_Modificar_Empresa
    @id_empresa INT,
    @razon_social VARCHAR(120),
    @cuit CHAR(11), -- Optimizado a CHAR(11)
    @rubro_principal VARCHAR(80)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION
    BEGIN TRY
    
        IF NOT EXISTS (SELECT 1 FROM Concesiones.Empresa WHERE id_empresa = @id_empresa)
            THROW 50001, 'No existe una empresa con ese id.', 1;

        IF EXISTS (SELECT 1 FROM Concesiones.Empresa WHERE cuit = @cuit AND id_empresa <> @id_empresa)
            THROW 50002, 'El CUIT ingresado ya se encuentra registrado en otra empresa.', 1;

        IF TRIM(@razon_social) = '' OR @razon_social IS NULL
            THROW 50003, 'La razón social no puede estar vacía.', 1;

        IF TRIM(@cuit) = '' OR @cuit IS NULL
            THROW 50004, 'El CUIT no puede estar vacío.', 1;

        UPDATE Concesiones.Empresa
        SET 
            razon_social = TRIM(@razon_social),
            cuit = TRIM(@cuit),
            rubro_principal = TRIM(@rubro_principal)
        WHERE 
            id_empresa = @id_empresa;

        PRINT('Empresa modificada correctamente.');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO


CREATE OR ALTER PROCEDURE Concesiones.SP_Modificar_Datos_Concesion
    @id_concesion INT,
    @fecha_inicio DATE = NULL,
    @fecha_fin DATE = NULL,
    @monto_alquiler DECIMAL(12,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION
    BEGIN TRY

        IF NOT EXISTS (SELECT 1 FROM Concesiones.Concesion WHERE id_concesion = @id_concesion)
            THROW 50001, 'No existe una concesión con el Id proporcionado.', 1;

        IF @fecha_inicio IS NOT NULL AND @fecha_fin IS NOT NULL AND @fecha_inicio > @fecha_fin
            THROW 50002, 'La fecha de inicio no puede ser posterior a la fecha de fin.', 1;

        IF @monto_alquiler IS NOT NULL AND @monto_alquiler < 0
            THROW 50003, 'El monto de alquiler no puede ser negativo.', 1;

        UPDATE Concesiones.Concesion
        SET 
            fecha_inicio = ISNULL(@fecha_inicio, fecha_inicio),
            fecha_fin = ISNULL(@fecha_fin, fecha_fin),
            monto_alquiler = ISNULL(@monto_alquiler, monto_alquiler)
        WHERE 
            id_concesion = @id_concesion;

        PRINT('Concesión modificada correctamente.');
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Concesiones.SP_Modificar_Descripcion_Estado_concesion
     @id_estado_concesion TINYINT, -- Optimizado a TINYINT
     @descripcion VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION
    BEGIN TRY

        IF NOT EXISTS (SELECT 1 FROM Concesiones.Estado_concesion WHERE id_estado_concesion = @id_estado_concesion)
            THROW 50001, 'No existe un Estado_concesion con el Id proporcionado.', 1;

         IF @descripcion IS NULL OR LEN(TRIM(@descripcion)) = 0
            THROW 50002, 'La descripción es obligatoria.', 1;

        IF LEN(@descripcion) > 50
            THROW 50003, 'La descripción no puede superar los 50 caracteres.', 1;

        IF EXISTS (
            SELECT 1 FROM Concesiones.Estado_concesion
            WHERE descripcion   = @descripcion
            AND id_estado_concesion <> @id_estado_concesion
        )
            THROW 50004, 'Ya existe otro estado de concesión con esa descripción.', 1;

        UPDATE Concesiones.Estado_concesion
        SET descripcion = @descripcion
        WHERE id_estado_concesion = @id_estado_concesion;

        PRINT('Estado concesión actualizado correctamente.');
        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Concesiones.SP_Modificar_Estado_pago
     @id_estado_pago TINYINT, -- Optimizado a TINYINT
     @descripcion VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION
    BEGIN TRY

        IF NOT EXISTS (SELECT 1 FROM Concesiones.Estado_pago WHERE id_estado_pago = @id_estado_pago)
            THROW 50001, 'No existe un Estado_pago con el Id proporcionado.', 1;

         IF @descripcion IS NULL OR LEN(TRIM(@descripcion)) = 0
            THROW 50002, 'La descripción es obligatoria.', 1;

        IF LEN(@descripcion) > 50
            THROW 50003, 'La descripción no puede superar los 50 caracteres.', 1;

        IF EXISTS (
            SELECT 1 FROM Concesiones.Estado_pago
            WHERE descripcion   = @descripcion
            AND id_estado_pago <> @id_estado_pago
        )
            THROW 50004, 'Ya existe otro estado de pago con esa descripción.', 1;

        UPDATE Concesiones.Estado_pago
        SET descripcion = @descripcion
        WHERE id_estado_pago = @id_estado_pago;

        PRINT('Estado pago actualizado correctamente.');
        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO


CREATE OR ALTER PROCEDURE Concesiones.SP_Modificar_Estado_Concesion
    @id_concesion INT,
    @id_estado_concesion TINYINT -- Optimizado a TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY

        IF NOT EXISTS (SELECT 1 FROM Concesiones.Concesion WHERE id_concesion = @id_concesion)
            THROW 50001, 'No existe una concesion con el Id proporcionado.', 1;

        IF NOT EXISTS (SELECT 1 FROM Concesiones.Estado_concesion WHERE id_estado_concesion = @id_estado_concesion)
            THROW 50002, 'El estado de concesion indicado no existe en el sistema.', 1;

        UPDATE Concesiones.Concesion
        SET id_estado_concesion = @id_estado_concesion
        WHERE id_concesion = @id_concesion;

        PRINT('Estado de concesion actualizado correctamente.');
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO


CREATE OR ALTER PROCEDURE Concesiones.SP_Modificar_Estado_Pago_Canon
    @id_pago INT,
    @id_estado_pago TINYINT -- Optimizado a TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY

        IF NOT EXISTS (SELECT 1 FROM Concesiones.Pago_canon WHERE id_pago = @id_pago)
            THROW 50001, 'No existe un registro de pago con el Id proporcionado.', 1;

        IF NOT EXISTS (SELECT 1 FROM Concesiones.Estado_pago WHERE id_estado_pago = @id_estado_pago)
            THROW 50002, 'El estado de pago indicado no existe en el sistema.', 1;

        UPDATE Concesiones.Pago_canon
        SET 
            id_estado_pago = @id_estado_pago
        WHERE 
            id_pago = @id_pago;

        PRINT('Estado de pago del canon actualizado correctamente.');
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- schema comercial
CREATE OR ALTER PROCEDURE Comercial.SP_Modificar_Tarifario_parque
    @id_parque SMALLINT, -- Optimizado a SMALLINT
    @id_tipo_visitante TINYINT, -- Optimizado a TINYINT
    @precio_actual decimal(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY

       IF NOT EXISTS (SELECT 1 FROM Comercial.Tarifario_parque
                   WHERE id_parque = @id_parque AND id_tipo_visitante = @id_tipo_visitante)
        THROW 50001, 'No existe un tarifario para ese parque y tipo visitante.', 1;

        IF @precio_actual IS NULL OR @precio_actual < 0
            THROW 50002, 'El precio actual no puede ser nulo ni negativo.', 1;

        UPDATE Comercial.Tarifario_parque
        SET precio_actual = @precio_actual
        WHERE id_parque = @id_parque AND id_tipo_visitante = @id_tipo_visitante;

        PRINT('Tarifario del parque actualizado correctamente.');
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Comercial.SP_Modificar_Tipo_visitante
    @id_tipo_visitante TINYINT, -- Optimizado a TINYINT
    @descripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY

        IF NOT EXISTS (SELECT 1 FROM Comercial.Tipo_visitante WHERE id_tipo_visitante = @id_tipo_visitante)
            THROW 50001, 'No existe un tipo de visitante con el Id proporcionado.', 1;

         IF @descripcion IS NULL OR LEN(TRIM(@descripcion)) = 0
            THROW 50002, 'La descripción es obligatoria.', 1;

        IF LEN(@descripcion) > 50
            THROW 50003, 'La descripción no puede superar los 50 caracteres.', 1;

        IF EXISTS (
            SELECT 1 FROM Comercial.Tipo_visitante
            WHERE descripcion   = @descripcion
            AND id_tipo_visitante <> @id_tipo_visitante
        )
            THROW 50004, 'Ya existe otro tipo de visitante con esa descripción.', 1;

        UPDATE Comercial.Tipo_visitante
        SET descripcion = @descripcion
        WHERE id_tipo_visitante = @id_tipo_visitante;

        PRINT('Tipo de visitante actualizado correctamente.');
        
        COMMIT TRANSACTION;
        END TRY

        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
            THROW;
        END CATCH
END
GO

CREATE OR ALTER PROCEDURE Comercial.SP_Modificar_Punto_de_venta
    @id_punto_de_venta TINYINT, -- Optimizado a TINYINT
    @descripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Comercial.Punto_de_venta WHERE id_punto_de_venta = @id_punto_de_venta)
            THROW 50001, 'No existe un punto de venta con el Id proporcionado.', 1;

        IF @descripcion IS NULL OR LEN(TRIM(@descripcion)) = 0
            THROW 50002, 'La descripción es obligatoria.', 1;

        IF LEN(@descripcion) > 50
            THROW 50003, 'La descripción no puede superar los 50 caracteres.', 1;

        IF EXISTS (SELECT 1 FROM Comercial.Punto_de_venta
                   WHERE descripcion = @descripcion AND id_punto_de_venta <> @id_punto_de_venta)
            THROW 50004, 'Ya existe otro punto de venta con esa descripción.', 1;

        UPDATE Comercial.Punto_de_venta
        SET descripcion = TRIM(@descripcion)
        WHERE id_punto_de_venta = @id_punto_de_venta;

        PRINT('Punto de venta actualizado correctamente.');
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Comercial.SP_Modificar_Forma_de_pago
    @id_forma_de_pago TINYINT, -- Optimizado a TINYINT
    @descripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Comercial.Forma_de_pago WHERE id_forma_de_pago = @id_forma_de_pago)
            THROW 50001, 'No existe una forma de pago con el Id proporcionado.', 1;

        IF @descripcion IS NULL OR LEN(TRIM(@descripcion)) = 0
            THROW 50002, 'La descripción es obligatoria.', 1;

        IF LEN(@descripcion) > 50
            THROW 50003, 'La descripción no puede superar los 50 caracteres.', 1;

        IF EXISTS (SELECT 1 FROM Comercial.Forma_de_pago
                   WHERE descripcion = @descripcion AND id_forma_de_pago <> @id_forma_de_pago)
            THROW 50004, 'Ya existe otra forma de pago con esa descripción.', 1;

        UPDATE Comercial.Forma_de_pago
        SET descripcion = TRIM(@descripcion)
        WHERE id_forma_de_pago = @id_forma_de_pago;

        PRINT('Forma de pago actualizada correctamente.');
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

--SCHEMAS Actividades

CREATE OR ALTER PROCEDURE Actividades.SP_Modificar_Guia
    @id_guia INT,
    @dni VARCHAR(10), -- Optimizado a VARCHAR(10)
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @titulo VARCHAR(80),
    @especialidad VARCHAR(80),
    @vigencia_autorizacion DATE
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        SET NOCOUNT ON;
        IF NOT EXISTS (SELECT 1 FROM Actividades.Guia WHERE id_guia = @id_guia)
            THROW 50001, 'No existe un guía con el Id proporcionado.', 1;

        IF EXISTS (SELECT 1 FROM Actividades.Guia WHERE dni = @dni AND id_guia <> @id_guia)
            THROW 50002, 'El DNI ingresado ya pertenece a otro guía.', 1;

        UPDATE Actividades.Guia
        SET 
            dni = @dni,
            nombre = TRIM(@nombre),
            apellido = TRIM(@apellido),
            titulo = TRIM(@titulo),
            especialidad = TRIM(@especialidad),
            vigencia_autorizacion = @vigencia_autorizacion
        WHERE id_guia = @id_guia;

        PRINT('Guía actualizado correctamente.');
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Actividades.SP_Modificar_Tipo_actividad
    @id_tipo_actividad TINYINT, -- Optimizado a TINYINT
    @descripcion VARCHAR(50)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        SET NOCOUNT ON;
        IF NOT EXISTS (SELECT 1 FROM Actividades.Tipo_actividad WHERE id_tipo_actividad = @id_tipo_actividad)
            THROW 50001, 'No existe un tipo de actividad con el Id proporcionado.', 1;

         IF @descripcion IS NULL OR LEN(TRIM(@descripcion)) = 0
            THROW 50002, 'La descripción es obligatoria.', 1;

        IF LEN(@descripcion) > 50
            THROW 50003, 'La descripción no puede superar los 50 caracteres.', 1;

        IF EXISTS (
            SELECT 1 FROM Actividades.Tipo_actividad
            WHERE descripcion   = @descripcion
            AND id_tipo_actividad <> @id_tipo_actividad
        )
            THROW 50004, 'Ya existe otro tipo de actividad con esa descripción.', 1;

        UPDATE Actividades.Tipo_actividad
        SET descripcion = @descripcion
        WHERE id_tipo_actividad = @id_tipo_actividad;

        PRINT('Tipo de actividad actualizado correctamente.');
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Actividades.SP_Modificar_Actividad
    @id_actividad INT,
    @id_tipo_actividad TINYINT = NULL, -- Optimizado a TINYINT
    @id_parque SMALLINT = NULL, -- Optimizado a SMALLINT
    @nombre VARCHAR(80) = NULL,
    @duracion_minutos SMALLINT = NULL, -- Optimizado a SMALLINT
    @cupo_maximo SMALLINT = NULL, -- Optimizado a SMALLINT
    @costo DECIMAL(10,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Actividades.Actividad WHERE id_actividad = @id_actividad)
            THROW 50001, 'No existe una actividad con el Id proporcionado.', 1;

        IF @id_tipo_actividad IS NOT NULL
           AND NOT EXISTS (SELECT 1 FROM Actividades.Tipo_actividad WHERE id_tipo_actividad = @id_tipo_actividad)
            THROW 50002, 'El tipo de actividad indicado no existe.', 1;

        IF @id_parque IS NOT NULL
           AND NOT EXISTS (SELECT 1 FROM Parques.Parque_nacional WHERE id_parque = @id_parque)
            THROW 50003, 'El parque indicado no existe.', 1;

        IF @nombre IS NOT NULL AND LEN(TRIM(@nombre)) = 0
            THROW 50004, 'El nombre no puede estar vacío.', 1;

        IF @duracion_minutos IS NOT NULL AND @duracion_minutos <= 0
            THROW 50005, 'La duración debe ser un número positivo.', 1;

        IF @cupo_maximo IS NOT NULL AND @cupo_maximo < 0
            THROW 50006, 'El cupo máximo no puede ser negativo.', 1;

        IF @costo IS NOT NULL AND @costo < 0
            THROW 50007, 'El costo no puede ser negativo.', 1;

        UPDATE Actividades.Actividad
        SET id_tipo_actividad = ISNULL(@id_tipo_actividad, id_tipo_actividad),
            id_parque         = ISNULL(@id_parque, id_parque),
            nombre            = ISNULL(@nombre, nombre),
            duracion_minutos  = ISNULL(@duracion_minutos, duracion_minutos),
            cupo_maximo       = ISNULL(@cupo_maximo, cupo_maximo),
            costo             = ISNULL(@costo, costo)
        WHERE id_actividad = @id_actividad;

        PRINT('Actividad actualizada correctamente.');
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO


CREATE OR ALTER PROCEDURE Actividades.SP_Modificar_Guias_por_actividad
    @id_guia INT,
    @id_actividad INT,
    @rol VARCHAR(30) = NULL,
    @fecha_asignacion DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Actividades.Guias_por_actividad
                       WHERE id_guia = @id_guia AND id_actividad = @id_actividad)
            THROW 50001, 'No existe esa asignación de guía a la actividad.', 1;

        IF @rol IS NOT NULL AND LEN(TRIM(@rol)) = 0
            THROW 50002, 'El rol no puede estar vacío.', 1;

        UPDATE Actividades.Guias_por_actividad
        SET rol              = ISNULL(@rol, rol),
            fecha_asignacion = ISNULL(@fecha_asignacion, fecha_asignacion)
        WHERE id_guia = @id_guia AND id_actividad = @id_actividad;

        PRINT('Asignación de guía actualizada correctamente.');
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO


CREATE OR ALTER PROCEDURE Actividades.SP_Modificar_Turno_actividad
    @id_turno INT,
    @fecha DATE = NULL,
    @hora_inicio TIME(0) = NULL -- Optimizado a TIME(0)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Actividades.Turno_actividad WHERE id_turno = @id_turno)
            THROW 50001, 'No existe un turno con el Id proporcionado.', 1;

        IF @fecha IS NOT NULL AND @fecha < CAST(GETDATE() AS DATE)
            THROW 50002, 'La fecha del turno no puede ser pasada.', 1;

        UPDATE Actividades.Turno_actividad
        SET fecha       = ISNULL(@fecha, fecha),
            hora_inicio = ISNULL(@hora_inicio, hora_inicio)
        WHERE id_turno = @id_turno;

        PRINT('Turno actualizado correctamente.');
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO