------------------------------------------------------------------
--Universidad Nacional de La Matanza
--MATERIA: BASES DE DATOS APLICADA
--COMISION: 5600
--GRUPO: 03
--FIERRO, FRANCO EZEQUIEL
--GISMONDI, FRANCISCO
----------------------------------------------------------------
-- Nombre del archivo: SeguridadYCifrado.sql
-- Descripcion: El script contiene la creacion de la llave maestra, el certificado y la clave simetrica para el cifrado de los DNIs de las tablas Guardaparque y Guia.
-- Objetivo: El objetivo del script es proteger los datos sensibles de las tablas Guardaparque y Guia mediante el cifrado de los DNIs utilizando una clave simétrica y un certificado.
----------------------------------------------------------------
USE COM5600_G03
GO
----------------------------------------------------------------
/*
SELECT 
    *
FROM sys.symmetric_keys
WHERE name = '##MS_DatabaseMasterKey##';
*/

BEGIN TRY
    IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id = 101)
    BEGIN
        CREATE MASTER KEY ENCRYPTION BY PASSWORD = '#PasswordFuerte1911-1995!';
        PRINT 'Se creo la llave maestra correctamente';
    END
    ELSE
    BEGIN
        ;THROW 50001, 'Llave Maestra ya creada.', 1;
    END
END TRY
BEGIN CATCH
    THROW;
END CATCH
GO


BEGIN TRY
    IF NOT EXISTS (SELECT * FROM sys.certificates WHERE name = 'Certificado_Parques')
    BEGIN
        CREATE CERTIFICATE Certificado_Parques WITH SUBJECT = 
        'Proteccion de Datos Sensibles de Parques';
        PRINT 'Se creo el certificado correctamente.'
    END
    ELSE
    BEGIN
        ;THROW 50001, 'El certificado ya se encuentra creado.', 1;
    END
END TRY
BEGIN CATCH
    THROW;
END CATCH
GO

--Comprobacion de que existe
SELECT 
    name, 
    certificate_id, 
    pvt_key_encryption_type_desc AS tipo_cifrado, 
    start_date AS fecha_inicio, 
    issuer_name AS emisor,
    subject
FROM sys.certificates;
GO


BEGIN TRY
    IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'Clave_Simetrica_DNI')
    BEGIN
        CREATE SYMMETRIC KEY Clave_Simetrica_DNI
        WITH ALGORITHM = AES_256
        ENCRYPTION BY CERTIFICATE Certificado_Parques;
    END
    ELSE
    BEGIN
        ;THROW 50001, 'La clave simetrica ya se encuentra creada.', 1;
    END
END TRY
BEGIN CATCH
    THROW;
END CATCH
GO

SELECT 
    *
FROM sys.symmetric_keys
GO

-- Modificar la tabla Guardaparque para soportar el DNI Cifrado
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Parques.Guardaparque') AND name = 'dni_cifrado')
BEGIN
    ALTER TABLE Parques.Guardaparque ADD dni_cifrado VARBINARY(256);
END
ELSE
BEGIN
    PRINT 'La columna dni_cifrado no existe en la tabla Parques.Guardaparque. Se agregara la columna.';
END

OPEN SYMMETRIC KEY Clave_Simetrica_DNI DECRYPTION BY CERTIFICATE Certificado_Parques;

UPDATE Parques.Guardaparque
SET dni_cifrado = EncryptByKey(Key_GUID('Clave_Simetrica_DNI'), dni)
WHERE Dni IS NOT NULL;

CLOSE SYMMETRIC KEY Clave_Simetrica_DNI;
GO

ALTER TABLE Actividades.Guia DROP CONSTRAINT UQ__Guardapa__D87608A7B5942B26;
ALTER TABLE Parques.Guardaparque DROP COLUMN Dni;
EXEC sp_rename 'Parques.Guardaparque.dni_cifrado', 'Dni', 'COLUMN';
GO

-- Modificar la tabla Guia para soportar el DNI Cifrado
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Actividades.Guia') AND name = 'dni_cifrado')
BEGIN
    ALTER TABLE Actividades.Guia ADD dni_cifrado VARBINARY(256);
END
ELSE
BEGIN
    PRINT 'La columna dni_cifrado ya existe en la tabla Actividades.Guia';
END
GO

OPEN SYMMETRIC KEY Clave_Simetrica_DNI DECRYPTION BY CERTIFICATE Certificado_Parques;

UPDATE Actividades.Guia
SET dni_cifrado = EncryptByKey(Key_GUID('Clave_Simetrica_DNI'), dni)
WHERE Dni IS NOT NULL;

CLOSE SYMMETRIC KEY Clave_Simetrica_DNI;
GO

ALTER TABLE Actividades.Guia DROP CONSTRAINT UQ__Guia__D87608A7D10304B7;
ALTER TABLE Actividades.Guia DROP COLUMN Dni;
EXEC sp_rename 'Actividades.Guia.dni_cifrado', 'Dni', 'COLUMN';
GO

select * from Actividades.Guia