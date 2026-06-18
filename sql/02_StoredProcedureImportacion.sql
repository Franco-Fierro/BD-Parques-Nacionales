------------------------------------------------------------------
--Universidad Nacional de La Matanza
--MATERIA: BASES DE DATOS APLICADA
--COMISION: 5600
--GRUPO: 03
--FIERRO, FRANCO EZEQUIEL
--GISMONDI, FRANCISCO
--QUISPE BARJA, SERGIO DANIEL
----------------------------------------------------------------
-- Nombre del archivo: 02_StoredProcedureImportacion.sql
-- Descripcion: procedimientos almacenados para la importacion de datos desde archivos, con validaciones, limpieza y manejo de errores.
-- Objetivo: definir la lógica de importación robusta para garantizar la integridad de los datos y registrar los errores de manera efectiva.
----------------------------------------------------------------

USE Pruebas_Parques
GO

----------------------------------------------------------------
-- Procedimiento para importar parques nacionales desde un archivo CSV, con validaciones de formato, limpieza de datos y manejo de duplicados.
CREATE OR ALTER PROCEDURE Parques.SP_ImportarParques_CSV
    @RutaArchivo VARCHAR(500)
AS
BEGIN
    BEGIN TRY
    SET NOCOUNT ON;
    IF OBJECT_ID('tempdb..#Temp_Parques') IS NOT NULL --Elimina la tabla temporal si ya existía en la sesión
        DROP TABLE #Temp_Parques;

    --Crea la tabla temporal con todas las columnas del CSV
    CREATE TABLE #Temp_Parques (

        [Organismo_Pertenencia] VARCHAR(200),
        [Anio_creacion] VARCHAR(10),
        [Instrumento_Legal] VARCHAR(200),
        [Nombre] VARCHAR(200) COLLATE DATABASE_DEFAULT, 
        [Superficie_km2] VARCHAR(50) ,
        [Region] VARCHAR(50) COLLATE DATABASE_DEFAULT,
        [Ecorregion] VARCHAR(200) ,
        [Url_Wikipedia] VARCHAR(500),
        [Latitud] VARCHAR(50) ,
        [Longitud] VARCHAR(50) ,
        [WKT_poligonos] VARCHAR(MAX) ,
        [Emblema_Imagen] VARCHAR(500) ,
        [Codigo_provincia] VARCHAR(MAX) ,
        [Nombre_provincia] VARCHAR(200) COLLATE DATABASE_DEFAULT,
        [Codigo_departamentos_comuna] VARCHAR(20) ,
        [Nombre_departamentos_comuna] VARCHAR(200) ,
        [Codigo_radio] VARCHAR(20) ,
        [Nombre_radio] VARCHAR(200) ,
        [Superficie_en_km2] VARCHAR(50) ,
        [Latitud_centroide] VARCHAR(50) ,
        [Longitud_centroide] VARCHAR(50) ,
        [Geometria_WKT] VARCHAR(MAX) 
    );

    --Construye dinámicamente la instrucción BULK INSERT para importar el archivo CSV
    DECLARE @SQL NVARCHAR(MAX);
    
    SET @SQL = '
    BULK INSERT #Temp_Parques
    FROM ''' + @RutaArchivo + '''
    WITH (
        FORMAT = ''CSV'',
        FIRSTROW = 2,
        FIELDQUOTE = ''"'',
        FIELDTERMINATOR = '','',
        CODEPAGE = ''65001'',
        TABLOCK
    );'

    EXEC sp_executesql @SQL;
    -- Registra en el log de errores los registros que no cumplen con las validaciones de conversión o valores obligatorios.
    INSERT INTO Parques.Log_Errores_Importacion (archivo, registro_nombre, motivo_error)
    SELECT 
        @RutaArchivo, 
        ISNULL(Nombre, 'SIN NOMBRE'), 
        'Error de conversión o ID de Región inválido (' + ISNULL(Region, 'NULO') + ')'
    FROM #Temp_Parques
    WHERE TRY_CAST(Superficie_km2 AS DECIMAL(12,2)) IS NULL
       OR TRY_CAST(Latitud AS DECIMAL(8,6)) IS NULL
       OR TRY_CAST(Longitud AS DECIMAL(9,6)) IS NULL
       OR LTRIM(RTRIM(Nombre)) = '' OR Nombre IS NULL
       OR LTRIM(RTRIM(Nombre_provincia)) = '' OR Nombre_provincia IS NULL
       OR TRY_CAST(Region AS INT) NOT IN (1,2,3,4,5,6) OR Region IS NULL;

    --Genera una tabla temporal con solo los registros válidos.
    SELECT 
        Nombre,
        TRY_CAST(Superficie_km2 AS DECIMAL(12,2)) * 100  AS Superficie, --Transforma de KM2 a Hectáreas 
        [Nombre_provincia] AS Provincia,
        CAST(
            CASE TRY_CAST(Region AS INT)
                WHEN 1 THEN 'Región Buenos Aires'
                WHEN 2 THEN 'Región Córdoba'
                WHEN 3 THEN 'Región Cuyo'
                WHEN 4 THEN 'Región Litoral'
                WHEN 5 THEN 'Región Norte'
                WHEN 6 THEN 'Región Patagonia'
            END AS VARCHAR(80)
        ) COLLATE DATABASE_DEFAULT AS RegionNombre,
        TRY_CAST(Latitud AS DECIMAL(8,6)) AS Latitud,
        TRY_CAST(Longitud AS DECIMAL(9,6)) AS Longitud,
        CAST('Parque Nacional' AS VARCHAR(50)) COLLATE DATABASE_DEFAULT AS TipoParqueDescripcion
    INTO #ParquesValidos
    FROM #Temp_Parques
    WHERE TRY_CAST(Superficie_km2 AS DECIMAL(12,2)) IS NOT NULL
      AND TRY_CAST(Latitud AS DECIMAL(8,6)) IS NOT NULL
      AND TRY_CAST(Longitud AS DECIMAL(9,6)) IS NOT NULL
      AND LTRIM(RTRIM(Nombre)) <> '' AND Nombre IS NOT NULL
      AND LTRIM(RTRIM(Nombre_provincia)) <> '' AND Nombre_provincia IS NOT NULL
      AND TRY_CAST(Region AS INT) IN (1,2,3,4,5,6);
    -- Inserta los nuevos tipos de parque y ubicaciones, evitando duplicados mediante NOT EXISTS.
    INSERT INTO Parques.Tipo_parque (descripcion)
    SELECT DISTINCT TipoParqueDescripcion 
    FROM #ParquesValidos PV
    WHERE NOT EXISTS (
        SELECT 1 FROM Parques.Tipo_parque TP WHERE TP.descripcion = PV.TipoParqueDescripcion
    );
    -- Inserta las ubicaciones, evitando duplicados mediante NOT EXISTS comparando provincia, región, latitud y longitud.
    INSERT INTO Parques.Ubicacion (provincia, region, latitud, longitud)
    SELECT DISTINCT Provincia, RegionNombre, Latitud, Longitud
    FROM #ParquesValidos PV
    WHERE NOT EXISTS (
        SELECT 1 FROM Parques.Ubicacion U 
        WHERE U.provincia = PV.Provincia 
          AND U.region = PV.RegionNombre 
          AND U.latitud = PV.Latitud 
          AND U.longitud = PV.Longitud
    );

    UPDATE PN
    SET 
        PN.id_ubicacion = U.id_ubicacion,
        PN.id_tipo_parque = TP.id_tipo_parque,
        PN.superficie = PV.Superficie
    FROM Parques.Parque_nacional PN
    INNER JOIN #ParquesValidos PV ON PN.nombre = PV.Nombre
    INNER JOIN Parques.Ubicacion U 
        ON U.provincia = PV.Provincia AND U.region = PV.RegionNombre AND U.latitud = PV.Latitud AND U.longitud = PV.Longitud
    INNER JOIN Parques.Tipo_parque TP 
        ON TP.descripcion = PV.TipoParqueDescripcion;

    INSERT INTO Parques.Parque_nacional (id_ubicacion, id_tipo_parque, nombre, superficie)
    SELECT 
        U.id_ubicacion, 
        TP.id_tipo_parque, 
        PV.Nombre, 
        PV.Superficie
    FROM #ParquesValidos PV
    INNER JOIN Parques.Ubicacion U 
        ON U.provincia = PV.Provincia AND U.region = PV.RegionNombre AND U.latitud = PV.Latitud AND U.longitud = PV.Longitud
    INNER JOIN Parques.Tipo_parque TP 
        ON TP.descripcion = PV.TipoParqueDescripcion
    WHERE NOT EXISTS (
        SELECT 1 FROM Parques.Parque_nacional PN 
        WHERE PN.nombre = PV.Nombre
    );

    DROP TABLE #ParquesValidos;
    DROP TABLE #Temp_Parques;
    PRINT 'Proceso completado exitosamente. Los registros correctos fueron importados y los erróneos logs mapeados.';
    END TRY
    BEGIN CATCH
        PRINT 'Error durante la importación: ' + ERROR_MESSAGE();
    END CATCH
END
GO

-- Procedimiento para importar guías de turismo desde un archivo CSV, con validaciones de formato, limpieza de datos y manejo de duplicados.
CREATE OR ALTER PROCEDURE Actividades.SP_ImportarGuiasTurismo_CSV
    @RutaArchivo VARCHAR(500)
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        IF OBJECT_ID('tempdb..#Temp_Guias') IS NOT NULL
            DROP TABLE #Temp_Guias;

        IF OBJECT_ID('tempdb..#GuiasValidos') IS NOT NULL
            DROP TABLE #GuiasValidos;

        -- Primera tabla temporal: Almacena la importación cruda del CSV
        CREATE TABLE #Temp_Guias (
            [periodo] VARCHAR(10),
            [apellido] VARCHAR(50),
            [nombre] VARCHAR(50),
            [tipo_doc] VARCHAR(50),
            [numero] VARCHAR(9),
            [n_registro] VARCHAR(50),
            [categoria] VARCHAR(50)
        );

        -- Segunda tabla temporal: Almacena los registros limpios y deduplicados
        CREATE TABLE #GuiasValidos (
            DNI CHAR(8) COLLATE DATABASE_DEFAULT,
            Nombre VARCHAR(50) COLLATE DATABASE_DEFAULT,
            Apellido VARCHAR(50) COLLATE DATABASE_DEFAULT,
            Titulo VARCHAR(80) COLLATE DATABASE_DEFAULT,
            Vigencia DATE
        );

        DECLARE @SQL NVARCHAR(MAX);
       
        SET @SQL = '
        BULK INSERT #Temp_Guias
        FROM ''' + @RutaArchivo + '''
        WITH (
            CODEPAGE = ''1252'',
            FIRSTROW = 2,
            FIELDTERMINATOR = '';'',
            ROWTERMINATOR = ''\n'',
            MAXERRORS = 1000,           -- CRÍTICO: Ignora la última fila vacía o filas rotas sin abortar
            TABLOCK
        );'
        EXEC sp_executesql @SQL;

        INSERT INTO Parques.Log_Errores_Importacion (archivo, registro_nombre, motivo_error)
        SELECT 
            @RutaArchivo, 
            ISNULL(nombre + ' ' + apellido, 'GUÍA SIN NOMBRE'), 
            'Error de validación: DNI vacío o no numérico'
        FROM #Temp_Guias
        WHERE LTRIM(RTRIM(REPLACE(numero, CHAR(13), ''))) = '' 
           OR numero IS NULL 
           OR TRY_CAST(REPLACE(numero, CHAR(13), '') AS INT) IS NULL;

        ;WITH CTE_GuiasLimpios AS (
            SELECT 
                CAST(RIGHT('00000000' + LTRIM(RTRIM(REPLACE([numero], CHAR(13), ''))), 8) AS CHAR(8)) COLLATE DATABASE_DEFAULT AS DNI,
                CAST(LEFT(LTRIM(RTRIM(REPLACE([nombre], CHAR(13), ''))), 50) AS VARCHAR(50)) COLLATE DATABASE_DEFAULT AS Nombre,
                CAST(LEFT(LTRIM(RTRIM(REPLACE([apellido], CHAR(13), ''))), 50) AS VARCHAR(50)) COLLATE DATABASE_DEFAULT AS Apellido,
                CAST(LEFT(LTRIM(RTRIM(REPLACE([categoria], CHAR(13), ''))), 80) AS VARCHAR(80)) COLLATE DATABASE_DEFAULT AS Titulo,
                DATEFROMPARTS(TRY_CAST(REPLACE([periodo], CHAR(13), '') AS INT), 12, 31) AS Vigencia,
                
                -- LÓGICA ANTI-DUPLICADOS: Numeramos cada fila agrupando por el DNI limpio
                -- Si hay dos DNIs iguales, el que tenga el periodo mayor (DESC) recibe el número 1.
                ROW_NUMBER() OVER(
                    PARTITION BY CAST(RIGHT('00000000' + LTRIM(RTRIM(REPLACE([numero], CHAR(13), ''))), 8) AS CHAR(8)) COLLATE DATABASE_DEFAULT
                    ORDER BY TRY_CAST(REPLACE([periodo], CHAR(13), '') AS INT) DESC
                ) AS Fila_Num

            FROM #Temp_Guias
            WHERE TRY_CAST(REPLACE([numero], CHAR(13), '') AS INT) IS NOT NULL
              AND TRY_CAST(REPLACE([periodo], CHAR(13), '') AS INT) IS NOT NULL
        )
        INSERT INTO #GuiasValidos (DNI, Nombre, Apellido, Titulo, Vigencia)
        SELECT 
            DNI, 
            Nombre, 
            Apellido, 
            Titulo, 
            Vigencia
        FROM CTE_GuiasLimpios
        WHERE Fila_Num = 1;
       
        UPDATE G
        SET 
            G.nombre = V.Nombre,
            G.apellido = V.Apellido,
            G.titulo = V.Titulo,
            G.vigencia_autorizacion = V.Vigencia
        FROM Actividades.Guia G
        INNER JOIN #GuiasValidos V 
            ON G.dni = V.DNI;

        INSERT INTO Actividades.Guia (
            dni, nombre, apellido, titulo, especialidad, vigencia_autorizacion
        )
        SELECT 
            V.DNI, 
            V.Nombre, 
            V.Apellido, 
            V.Titulo, 
            NULL, 
            V.Vigencia
        FROM #GuiasValidos V
        WHERE NOT EXISTS (
            SELECT 1 
            FROM Actividades.Guia G 
            WHERE G.dni = V.DNI
        );

        DROP TABLE #Temp_Guias;
        DROP TABLE #GuiasValidos;

        PRINT 'Proceso de importación en Actividades.Guia completado exitosamente.';
    END TRY
    BEGIN CATCH
        -- Asegurar la limpieza de tablas incluso si el proceso falla en el camino
        IF OBJECT_ID('tempdb..#Temp_Guias') IS NOT NULL DROP TABLE #Temp_Guias;
        IF OBJECT_ID('tempdb..#GuiasValidos') IS NOT NULL DROP TABLE #GuiasValidos;

        PRINT 'Error crítico. ' + ERROR_MESSAGE();
    END CATCH
END
GO
