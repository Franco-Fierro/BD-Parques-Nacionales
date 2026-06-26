------------------------------------------------------------------
--Universidad Nacional de La Matanza
--MATERIA: BASES DE DATOS APLICADA
--COMISION: 5600
--GRUPO: 03
--FIERRO, FRANCO EZEQUIEL
--GISMONDI, FRANCISCO
----------------------------------------------------------------
--ARCHIVO: 01_StoreProcedureBorrado.sql
--PROPOSITO: Contiene los procedimientos almacenados para eliminar registros de las tablas, con validaciones de integridad referencial.
---------------------------------------------------------------- 

USE COM5600_G03
GO

------------- CREACION DE STORE PROCEDURE -------------

--- SCHEMA Parques ---

/*
Nombre: Parques.Borrar_Ubicacion
Propósito: Eliminar una ubicación, verificando que no existan parques nacionales vinculados a ella.
Parámetros: @id_ubicacion (INT) - ID de la ubicación a eliminar.
*/
CREATE OR ALTER PROCEDURE Parques.SP_Borrar_Ubicacion
	@id_ubicacion INT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;

			IF NOT EXISTS (SELECT 1 FROM Parques.Ubicacion WHERE id_ubicacion = @id_ubicacion)
				THROW 50001, 'No existe la Ubicación solicitada.', 1;
			
			IF EXISTS (SELECT 1 FROM Parques.Parque_nacional WHERE id_ubicacion = @id_ubicacion)
				THROW 50002, 'No se puede borrar: hay un Parque Nacional vinculado a esta ubicación.', 1;

		DELETE FROM Parques.Ubicacion WHERE id_ubicacion = @id_ubicacion;
		PRINT('Ubicación eliminada correctamente.')
		COMMIT TRANSACTION;

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
		END;
		
		THROW;
	END CATCH
END
GO

/*
Nombre: Parques.Borrar_Tipo_Parque
Propósito: Eliminar un tipo de parque, verificando que no existan parques nacionales vinculados a él.
Parámetros: @id_tipo_parque (INT) - ID del tipo de parque a eliminar.
*/
CREATE OR ALTER PROCEDURE Parques.SP_Borrar_Tipo_Parque
	@id_tipo_parque TINYINT -- Optimizado a TINYINT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;

			IF NOT EXISTS (SELECT 1 FROM Parques.Tipo_parque WHERE id_tipo_parque = @id_tipo_parque)
				THROW 50003, 'No existe el Tipo de Parque solicitado.', 1;

			IF EXISTS (SELECT 1 FROM Parques.Parque_nacional WHERE id_tipo_parque = @id_tipo_parque)
				THROW 50004, 'No se puede borrar: hay un Parque Nacional vinculado a este Tipo de Parque.', 1;

		DELETE FROM Parques.Tipo_parque WHERE id_tipo_parque = @id_tipo_parque;
		PRINT('Tipo de Parque eliminado correctamente.')
		COMMIT TRANSACTION;

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
		END;
		
		THROW;
	END CATCH
END
GO

--- SCHEMA Actividades ---

/*
Nombre: Actividades.Borrar_Tipo_Actividad
Propósito: Eliminar un tipo de actividad, verificando que no existan actividades vinculadas a él.
Parámetros: @id_tipo_actividad (INT) - ID del tipo de actividad a eliminar.
*/
CREATE OR ALTER PROCEDURE Actividades.SP_Borrar_Tipo_Actividad
	@id_tipo_actividad TINYINT -- Optimizado a TINYINT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

			IF NOT EXISTS (SELECT 1 FROM Actividades.Tipo_actividad WHERE id_tipo_actividad = @id_tipo_actividad)
				THROW 50005, 'No existe el Tipo de Actividad solicitado.', 1;

			IF EXISTS (SELECT 1 FROM Actividades.Actividad WHERE id_tipo_actividad = @id_tipo_actividad)
				THROW 50006, 'No se puede borrar: hay una Actividad vinculada a este Tipo de Actividad.', 1;

		DELETE FROM Actividades.Tipo_actividad WHERE id_tipo_actividad = @id_tipo_actividad;
		PRINT('Tipo de Actividad eliminado correctamente.')
		COMMIT TRANSACTION;

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
		END;
		
		THROW;
	END CATCH
END
GO

/*
Nombre: Actividades.Borrar_Guia_Por_Actividad
Propósito: Eliminar la asignación de un guía a una actividad, verificando que exista la asignación.
Parámetros: @id_guia (INT) - ID del guía a eliminar de la actividad.
           @id_actividad (INT) - ID de la actividad de la cual eliminar el guía.
*/
CREATE OR ALTER PROCEDURE Actividades.SP_Borrar_Guia_Por_Actividad
    @id_guia INT, @id_actividad INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(800) = '';

    BEGIN TRY
    BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Actividades.Guia WHERE id_guia = @id_guia)
            SET @MensajeError += '- El Guia indicado no existe en el sistema.' + CHAR(13);

        IF NOT EXISTS (SELECT 1 FROM Actividades.Actividad WHERE id_actividad = @id_actividad)
            SET @MensajeError += '- La Actividad indicada no existe en el sistema.' + CHAR(13);
		ELSE
			IF NOT EXISTS (SELECT 1 FROM Actividades.Guias_por_actividad WHERE id_guia = @id_guia AND id_actividad = @id_actividad)
				SET @MensajeError += '- El Guia no esta asignado a esa Actividad.' + CHAR(13);

        IF LEN(@MensajeError) > 0
            THROW 50007, @MensajeError, 1;

        DELETE FROM Actividades.Guias_por_actividad 
        WHERE id_guia = @id_guia AND id_actividad = @id_actividad;

        PRINT('Guia eliminado de la actividad correctamente.')
        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

/*
Nombre: Actividades.Borrar_Turno_Actividad
Propósito: Eliminar un turno de actividad, verificando que no existan tickets vendidos asociados a ese turno.
Parámetros: @id_turno (INT) - ID del turno de actividad a eliminar.
*/
CREATE OR ALTER PROCEDURE Actividades.SP_Borrar_Turno_Actividad
    @id_turno INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    BEGIN TRANSACTION

        IF NOT EXISTS (SELECT 1 FROM Actividades.Turno_actividad WHERE id_turno = @id_turno)
			THROW 50008, 'No existe el turno indicado.', 1;

        IF EXISTS (SELECT 1 FROM Comercial.Ticket_actividad WHERE id_turno = @id_turno)
			THROW 50009,'No se puede borrar: el turno tiene tickets vendidos asociados.',1;

        DELETE FROM Actividades.Turno_actividad WHERE id_turno = @id_turno;
        PRINT('Turno eliminado correctamente.')
        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

--- SCHEMA Comercial ---
/*
Nombre: Comercial.Borrar_Punto_de_venta
Propósito: Eliminar un punto de venta, verificando que no existan ventas asociadas a ese punto de venta.
Parámetros: @id_punto_de_venta (INT) - ID del punto de venta a eliminar.
*/
CREATE OR ALTER PROCEDURE Comercial.SP_Borrar_Punto_de_venta
	@id_punto_de_venta TINYINT -- Optimizado a TINYINT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
	BEGIN TRANSACTION
		
		IF NOT EXISTS (SELECT 1 FROM Comercial.Punto_de_venta WHERE @id_punto_de_venta = id_punto_de_venta)
			THROW 50010, 'No existe el Punto de venta indicado.', 1;

		IF EXISTS (SELECT 1 FROM Comercial.Venta WHERE id_punto_de_venta = @id_punto_de_venta)
			THROW 50011,'No se puede borrar: el Punto de venta tiene Ventas asociadas.',1;
		
		DELETE FROM Comercial.Punto_de_venta WHERE @id_punto_de_venta = id_punto_de_venta;
        PRINT('Punto de venta eliminado correctamente.')
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

/*
Nombre: Comercial.Borrar_Forma_de_pago
Propósito: Eliminar una forma de pago, verificando que no existan ventas asociadas a esa forma de pago.
Parámetros: @id_forma_de_pago (INT) - ID de la forma de pago a eliminar.
*/
CREATE OR ALTER PROCEDURE Comercial.SP_Borrar_Forma_de_pago
	@id_forma_de_pago TINYINT -- Optimizado a TINYINT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
	BEGIN TRANSACTION
		IF NOT EXISTS (SELECT 1 FROM Comercial.Forma_de_pago WHERE @id_forma_de_pago = id_forma_de_pago)
			THROW 50012, 'No existe la Forma de pago indicada.', 1;
		IF EXISTS (SELECT 1 FROM Comercial.Venta WHERE id_forma_de_pago = @id_forma_de_pago)
			THROW 50011,'No se puede borrar: la Forma de pago tiene Ventas asociadas.',1;
		
		DELETE FROM Comercial.Forma_de_pago WHERE @id_forma_de_pago = id_forma_de_pago;
        PRINT('Forma de pago eliminada correctamente.')
        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

/*
Nombre: Comercial.Borrar_Tipo_visitante
Propósito: Eliminar un tipo de visitante, verificando que no existan entradas o tarifarios asociados a ese tipo de visitante.
Parámetros: @id_tipo_visitante (INT) - ID del tipo de visitante a eliminar.
*/
CREATE OR ALTER PROCEDURE Comercial.SP_Borrar_Tipo_visitante
	@id_tipo_visitante TINYINT -- Optimizado a TINYINT
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @MensajeError VARCHAR(800) = '';
	BEGIN TRY
	BEGIN TRANSACTION
	
		IF NOT EXISTS (SELECT 1 FROM Comercial.Tipo_visitante WHERE id_tipo_visitante = @id_tipo_visitante)
			THROW 50013, 'No existe el tipo de visitante indicado.', 1;
		ELSE
		BEGIN
			IF EXISTS (SELECT 1 FROM Comercial.Entrada WHERE id_tipo_visitante = @id_tipo_visitante)
				SET @MensajeError += '- No se puede eliminar: el tipo de visitante tiene entradas asociadas.' + CHAR(13);

			IF EXISTS (SELECT 1 FROM Comercial.Tarifario_parque WHERE id_tipo_visitante = @id_tipo_visitante)
				SET @MensajeError += '- No se puede eliminar: el tipo de visitante tiene tarifarios asociados.' + CHAR(13);
		END
    
		IF LEN(@MensajeError) > 0
			THROW 50014, @MensajeError, 1;

		DELETE FROM Comercial.Tipo_visitante WHERE id_tipo_visitante = @id_tipo_visitante;
        PRINT('Tipo de visitante eliminado correctamente.')
        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

/*
Nombre: Comercial.Borrar_Tarifario_parque
Propósito: Eliminar un tarifario de parque, verificando que no existan entradas asociadas a ese tarifario.
Parámetros: @id_tarifario (INT) - ID del tarifario de parque a eliminar.
*/
CREATE OR ALTER PROCEDURE Comercial.SP_Borrar_Tarifario_parque
    @id_tarifario INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    BEGIN TRANSACTION

        IF NOT EXISTS (SELECT 1 FROM Comercial.Tarifario_parque WHERE id_tarifario = @id_tarifario)
            THROW 50015, 'No existe el tarifario indicado.', 1;

        DELETE FROM Comercial.Tarifario_parque WHERE id_tarifario = @id_tarifario;
        PRINT('Tarifario eliminado correctamente.')
        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO
/*
Nombre: Comercial.Borrar_Item_vendible
Propósito: Eliminar un item vendible, verificando que no existan detalles de venta asociados.
Parámetros: @id_item (INT) - ID del item vendible a eliminar.
*/
CREATE OR ALTER PROCEDURE Comercial.SP_Borrar_Item_vendible
    @id_item INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    BEGIN TRANSACTION

        IF NOT EXISTS (SELECT 1 FROM Comercial.Item_vendible WHERE id_item = @id_item)
			THROW 50016, 'No existe el item indicado.', 1;


        IF EXISTS (SELECT 1 FROM Comercial.Detalle_venta WHERE id_item = @id_item)
            THROW 50017, 'No se puede eliminar: el item tiene detalles de venta asociados.', 1;

        DELETE FROM Comercial.Item_vendible WHERE id_item = @id_item;
        PRINT('Item vendible eliminado correctamente.')
        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

--- SCHEMA Conseciones ---
/*
Nombre: Concesiones.Borrar_Estado_concesion
Propósito: Eliminar un estado de concesion, verificando que no existan concesiones asociadas a ese estado.
Parámetros: @id_estado_concesion (INT) - ID del estado de concesion a eliminar.
*/
CREATE OR ALTER PROCEDURE Concesiones.SP_Borrar_Estado_concesion
    @id_estado_concesion TINYINT -- Optimizado a TINYINT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;
    BEGIN TRY

        IF NOT EXISTS (SELECT 1 FROM Concesiones.Estado_concesion WHERE id_estado_concesion = @id_estado_concesion)
            THROW 50018, 'No existe el estado de concesion indicado.', 1;

        IF EXISTS (SELECT 1 FROM Concesiones.Concesion WHERE id_estado_concesion = @id_estado_concesion)
            THROW 50019, 'No se puede eliminar: el estado tiene concesiones asociadas.',1;


        DELETE FROM Concesiones.Estado_concesion WHERE id_estado_concesion = @id_estado_concesion;
        PRINT('Estado de concesion eliminado correctamente.')
        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

/*
Nombre: Concesiones.Borrar_Estado_pago
Propósito: Eliminar un estado de pago, verificando que no existan pagos asociados a ese estado.
Parámetros: @id_estado_pago (INT) - ID del estado de pago a eliminar.
*/
CREATE OR ALTER PROCEDURE Concesiones.SP_Borrar_Estado_pago
    @id_estado_pago TINYINT -- Optimizado a TINYINT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;
    BEGIN TRY

        IF NOT EXISTS (SELECT 1 FROM Concesiones.Estado_pago WHERE id_estado_pago = @id_estado_pago)
             THROW 50020, 'No existe el estado de pago indicado.',1;

        IF EXISTS (SELECT 1 FROM Concesiones.Pago_canon WHERE id_estado_pago = @id_estado_pago)
             THROW 50021, 'No se puede eliminar: el estado tiene pagos asociados.',1;

        DELETE FROM Concesiones.Estado_pago WHERE id_estado_pago = @id_estado_pago;
        PRINT('Estado de pago eliminado correctamente.')
        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO
