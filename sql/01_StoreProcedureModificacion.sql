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
     @id_tipo_parque INT,  
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
    @id_parque INT,
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
    @dni CHAR(8),
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

CREATE OR ALTER PROCEDURE Parques.SP_Cambiar_Estado_Guardaparque
    @id_guardaparque INT,
    @nuevo_estado CHAR(20)
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
    @id_parque INT,
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
    @cuit VARCHAR(11),
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

CREATE OR ALTER PROCEDURE Concesiones.SP_Modificar_Estado_concesion
     @id_estado_concesion INT,
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
     @id_estado_pago INT,
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

CREATE OR ALTER PROCEDURE Concesiones.SP_Cambiar_Estado_Concesion
    @id_concesion INT,
    @id_estado_concesion INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY

        IF NOT EXISTS (SELECT 1 FROM Concesiones.Concesion WHERE id_concesion = @id_concesion)
            THROW 50001, 'No existe una concesion con el Id proporcionado.', 1;

        IF NOT EXISTS (SELECT 1 FROM Concesiones.Estado_concesion WHERE id_concesion = @id_concesion)
            THROW 50002, 'El estado de concesion indicado no existe en el sistema.', 1;

        UPDATE Concesiones.Concesion
        SET 
            id_estado_concesion = @id_estado_concesion
        WHERE 
            id_concesion = @id_concesion;

        PRINT('Estado de concesion actualizado correctamente.');
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO


CREATE OR ALTER PROCEDURE Concesiones.SP_Cambiar_Estado_Pago_Canon
    @id_pago INT,
    @id_estado_pago INT
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