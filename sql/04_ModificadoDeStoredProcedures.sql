------------------------------------------------------------------
--Universidad Nacional de La Matanza
--MATERIA: BASES DE DATOS APLICADA
--COMISION: 5600
--GRUPO: 03
--FIERRO, FRANCO EZEQUIEL
--GISMONDI, FRANCISCO
----------------------------------------------------------------
-- Nombre del archivo: ModificadoDeStoredProcedures.sql
-- Descripcion: El script contiene los procedimientos almacenados modificados para agregar cifrado y hash del DNI en las tablas Guardaparque y Guia.
-- Objetivo: El objetivo de este script es mejorar la seguridad de los datos sensibles, como el DNI, mediante el uso de cifrado y hash, garantizando la confidencialidad y la integridad de la información almacenada en la base de datos.
----------------------------------------------------------------
USE COM5600_G03
GO
----------------------------------------------------------------

-- Procedimientos modifcado para agregar cifrado y hash del DNI.

CREATE OR ALTER PROCEDURE Parques.SP_AgregarGuardaparque
    @dni             char(8),
    @nombre          varchar(50),
    @apellido        varchar(50),
    @fecha_ingreso   date,
    @estado          char(20),
    @id_guardaparque int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores varchar(1000) = '';
    
    -- Generar el Hash para validar unicidad sin exponer el texto plano
    DECLARE @dni_hash VARBINARY(32) = HASHBYTES('SHA2_256', TRIM(@dni));

    IF EXISTS (SELECT 1 FROM Parques.Guardaparque WHERE dni_hash = @dni_hash)
        SET @errores = @errores + 'Ya existe un guardaparque con el mismo DNI. ';

    IF @dni IS NULL OR LTRIM(RTRIM(@dni)) = '' OR LEN(@dni) <> 8
        SET @errores = @errores + 'El DNI del guardaparque debe ser un número de 8 dígitos. ';
    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errores = @errores + 'El nombre del guardaparque no puede ser vacío. ';
    IF @apellido IS NULL OR LTRIM(RTRIM(@apellido)) = ''
        SET @errores = @errores + 'El apellido del guardaparque no puede ser vacío. ';
    IF @fecha_ingreso > CAST(GETDATE() AS DATE)
        SET @errores = @errores + 'La fecha de ingreso no puede ser futura. ';
    IF @estado IS NULL OR LTRIM(RTRIM(@estado)) = '' OR @estado NOT IN ('Activo', 'Inactivo')
        SET @errores = @errores + 'El estado del guardaparque no puede ser vacío. ';
    
    IF @errores <> ''
        THROW 50001, @errores, 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Abrir la clave simétrica para el cifrado
        OPEN SYMMETRIC KEY Clave_Simetrica_DNI DECRYPTION BY CERTIFICATE Certificado_Parques;

        INSERT INTO Parques.Guardaparque (dni_cifrado, dni_hash, nombre, apellido, fecha_ingreso, estado)
        VALUES (
            EncryptByKey(Key_GUID('Clave_Simetrica_DNI'), TRIM(@dni)),
            @dni_hash,
            TRIM(@nombre),
            TRIM(@apellido),
            @fecha_ingreso,
            @estado
        );

        SET @id_guardaparque = SCOPE_IDENTITY();

        CLOSE SYMMETRIC KEY Clave_Simetrica_DNI;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'Clave_Simetrica_DNI')
            CLOSE SYMMETRIC KEY Clave_Simetrica_DNI;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Actividades.SP_AgregarGuia
    @dni             char(8),
    @nombre          varchar(50),
    @apellido        varchar(50),
    @titulo          varchar(80),
    @especialidad    varchar(80),
    @vigencia_autorizacion date,
    @id_guia int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores varchar(1000) = '';

    -- Generar el Hash para validar unicidad
    DECLARE @dni_hash VARBINARY(32) = HASHBYTES('SHA2_256', TRIM(@dni));

    IF EXISTS (SELECT 1 FROM Actividades.Guia WHERE dni_hash = @dni_hash)
        SET @errores = @errores + 'Ya existe un guía con el mismo DNI. ';

    IF @dni IS NULL OR LTRIM(RTRIM(@dni)) = '' OR LEN(@dni) <> 8
        SET @errores = @errores + 'El DNI del guía debe ser un número de 8 dígitos. ';
    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errores = @errores + 'El nombre del guía no puede ser vacío. ';
    IF @apellido IS NULL OR LTRIM(RTRIM(@apellido)) = ''
        SET @errores = @errores + 'El apellido del guía no puede ser vacío. ';
    IF @vigencia_autorizacion < CAST(GETDATE() AS DATE)
        SET @errores = @errores + 'La vigencia de la autorización no puede estar vencida. ';
    
    IF @errores <> ''
        THROW 50001, @errores, 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        OPEN SYMMETRIC KEY Clave_Simetrica_DNI DECRYPTION BY CERTIFICATE Certificado_Parques;

        INSERT INTO Actividades.Guia (dni_cifrado, dni_hash, nombre, apellido, titulo, especialidad, vigencia_autorizacion)
        VALUES (
            EncryptByKey(Key_GUID('Clave_Simetrica_DNI'), TRIM(@dni)),
            @dni_hash,
            TRIM(@nombre),
            TRIM(@apellido),
            TRIM(@titulo),
            TRIM(@especialidad),
            @vigencia_autorizacion
        );

        SET @id_guia = SCOPE_IDENTITY();

        CLOSE SYMMETRIC KEY Clave_Simetrica_DNI;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'Clave_Simetrica_DNI')
            CLOSE SYMMETRIC KEY Clave_Simetrica_DNI;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Actividades.SP_AgregarGuia
    @dni             char(8),
    @nombre          varchar(50),
    @apellido        varchar(50),
    @titulo          varchar(80),
    @especialidad    varchar(80),
    @vigencia_autorizacion date,
    @id_guia int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores varchar(1000) = '';

    -- Generar el Hash para validar unicidad
    DECLARE @dni_hash VARBINARY(32) = HASHBYTES('SHA2_256', TRIM(@dni));

    IF EXISTS (SELECT 1 FROM Actividades.Guia WHERE dni_hash = @dni_hash)
        SET @errores = @errores + 'Ya existe un guía con el mismo DNI. ';

    IF @dni IS NULL OR LTRIM(RTRIM(@dni)) = '' OR LEN(@dni) <> 8
        SET @errores = @errores + 'El DNI del guía debe ser un número de 8 dígitos. ';
    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errores = @errores + 'El nombre del guía no puede ser vacío. ';
    IF @apellido IS NULL OR LTRIM(RTRIM(@apellido)) = ''
        SET @errores = @errores + 'El apellido del guía no puede ser vacío. ';
    IF @vigencia_autorizacion < CAST(GETDATE() AS DATE)
        SET @errores = @errores + 'La vigencia de la autorización no puede estar vencida. ';
    
    IF @errores <> ''
        THROW 50001, @errores, 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        OPEN SYMMETRIC KEY Clave_Simetrica_DNI DECRYPTION BY CERTIFICATE Certificado_Parques;

        INSERT INTO Actividades.Guia (dni_cifrado, dni_hash, nombre, apellido, titulo, especialidad, vigencia_autorizacion)
        VALUES (
            EncryptByKey(Key_GUID('Clave_Simetrica_DNI'), TRIM(@dni)),
            @dni_hash,
            TRIM(@nombre),
            TRIM(@apellido),
            TRIM(@titulo),
            TRIM(@especialidad),
            @vigencia_autorizacion
        );

        SET @id_guia = SCOPE_IDENTITY();

        CLOSE SYMMETRIC KEY Clave_Simetrica_DNI;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'Clave_Simetrica_DNI')
            CLOSE SYMMETRIC KEY Clave_Simetrica_DNI;
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
    
    -- Calcular el hash del nuevo DNI enviado para contrastar
    DECLARE @dni_hash VARBINARY(32) = HASHBYTES('SHA2_256', TRIM(@dni));

    BEGIN TRANSACTION;
    BEGIN TRY

        IF NOT EXISTS(SELECT 1 FROM Parques.Guardaparque WHERE id_guardaparque = @id_guardaparque)
            THROW 50001, 'El Guardaparque indicado no existe.', 1;

        IF EXISTS(SELECT 1 FROM Parques.Guardaparque WHERE dni_hash = @dni_hash AND id_guardaparque <> @id_guardaparque)
            THROW 50002, 'El DNI ingresado ya pertenece a otro Guardaparque.', 1;

        OPEN SYMMETRIC KEY Clave_Simetrica_DNI DECRYPTION BY CERTIFICATE Certificado_Parques;

        UPDATE Parques.Guardaparque
        SET 
            dni_cifrado = EncryptByKey(Key_GUID('Clave_Simetrica_DNI'), TRIM(@dni)),
            dni_hash = @dni_hash,
            nombre = TRIM(@nombre),
            apellido = TRIM(@apellido)
        WHERE 
            id_guardaparque = @id_guardaparque;

        CLOSE SYMMETRIC KEY Clave_Simetrica_DNI;

        PRINT('Datos del guardaparque actualizados correctamente.');
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'Clave_Simetrica_DNI')
            CLOSE SYMMETRIC KEY Clave_Simetrica_DNI;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE Actividades.SP_Modificar_Guia
    @id_guia INT,
    @dni CHAR(8),
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @titulo VARCHAR(80),
    @especialidad VARCHAR(80),
    @vigencia_autorizacion DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @dni_hash VARBINARY(32) = HASHBYTES('SHA2_256', TRIM(@dni));

    BEGIN TRANSACTION;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Actividades.Guia WHERE id_guia = @id_guia)
            THROW 50001, 'No existe un guía con el Id proporcionado.', 1;

        IF EXISTS (SELECT 1 FROM Actividades.Guia WHERE dni_hash = @dni_hash AND id_guia <> @id_guia)
            THROW 50002, 'El DNI ingresado ya pertenece a otro guía.', 1;

        OPEN SYMMETRIC KEY Clave_Simetrica_DNI DECRYPTION BY CERTIFICATE Certificado_Parques;

        UPDATE Actividades.Guia
        SET 
            dni_cifrado = EncryptByKey(Key_GUID('Clave_Simetrica_DNI'), TRIM(@dni)),
            dni_hash = @dni_hash,
            nombre = TRIM(@nombre),
            apellido = TRIM(@apellido),
            titulo = TRIM(@titulo),
            especialidad = TRIM(@especialidad),
            vigencia_autorizacion = @vigencia_autorizacion
        WHERE id_guia = @id_guia;

        CLOSE SYMMETRIC KEY Clave_Simetrica_DNI;

        PRINT('Guía actualizado correctamente.');
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        IF EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = 'Clave_Simetrica_DNI')
            CLOSE SYMMETRIC KEY Clave_Simetrica_DNI;
        THROW;
    END CATCH
END
GO