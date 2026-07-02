------------------------------------------------------------------
--Universidad Nacional de La Matanza
--MATERIA: BASES DE DATOS APLICADA
--COMISION: 5600
--GRUPO: 03
--FIERRO, FRANCO EZEQUIEL
--GISMONDI, FRANCISCO
----------------------------------------------------------------
-- Nombre del archivo: 02_StoredProceduresAPI.sql
-- Objetivo: Procedimientos almacenados para la API de cotizaci�n de moneda extranjera y consulta de clima
------------------------------------------------------------------


USE COM5600_G03;
GO
------------------------------------------------------------------
-- Habilitar procedimientos de automatizacion OLE para permitir llamadas a APIs externas
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'Ole Automation Procedures', 1;
GO
RECONFIGURE;
GO
--------------------------------------------------------------------
-- Este procedimiento permite cotizar un item (tarifario o actividad) en moneda extranjera (USD, EUR, BRL) utilizando la API de DolarAPI y devuelve el precio en ARS y su equivalente en las monedas extranjeras.
CREATE OR ALTER PROCEDURE Comercial.SP_CotizarItemMonedaExtranjera
    @id_tarifario INT = NULL,
    @id_actividad INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @PrecioARS DECIMAL(18,2);
    DECLARE @Concepto VARCHAR(100);
    DECLARE @Parque VARCHAR(100);
    DECLARE @errores VARCHAR(1000) = '';

    IF @id_tarifario IS NOT NULL
    BEGIN
        SELECT 
            @PrecioARS = tp.precio_actual,
            @Concepto = CAST('Entrada - ' + tv.descripcion AS VARCHAR(100)),
            @Parque = p.nombre
        FROM Comercial.Tarifario_parque tp
        INNER JOIN Comercial.Tipo_visitante tv ON tp.id_tipo_visitante = tv.id_tipo_visitante
        INNER JOIN Parques.Parque_nacional p ON tp.id_parque = p.id_parque
        WHERE tp.id_tarifario = @id_tarifario;
        
        IF @PrecioARS IS NULL
            SET @errores = 'El tarifario indicado no existe.';
    END
    ELSE IF @id_actividad IS NOT NULL
    BEGIN
        SELECT 
            @PrecioARS = a.costo,
            @Concepto = CAST('Actividad - ' + a.nombre AS VARCHAR(100)),
            @Parque = p.nombre
        FROM Actividades.Actividad a
        INNER JOIN Parques.Parque_nacional p ON a.id_parque = p.id_parque
        WHERE a.id_actividad = @id_actividad;

        IF @PrecioARS IS NULL
            SET @errores = 'La actividad indicada no existe.';
    END
    ELSE
    BEGIN
        SET @errores = 'Debe especificar un @id_tarifario o un @id_actividad.';
    END

    IF @errores <> ''
        THROW 50001, @errores, 1;
        
    IF @PrecioARS = 0
        THROW 50001, 'El item es gratuito (Costo 0). No requiere cotizacion.', 1;

    DECLARE @UrlDolares NVARCHAR(MAX) = 'https://dolarapi.com/v1/dolares';
    DECLARE @UrlCotizaciones NVARCHAR(MAX) = 'https://dolarapi.com/v1/cotizaciones';
    
    DECLARE @Object INT;
    DECLARE @HResult INT;
    DECLARE @ResponseDolares NVARCHAR(MAX);
    DECLARE @ResponseCotizaciones NVARCHAR(MAX);

    EXEC @HResult = sp_OACreate 'WinHttp.WinHttpRequest.5.1', @Object OUT;
    IF @HResult <> 0
    BEGIN
        RAISERROR('Error al crear el objeto HTTP. Verifique "Ole Automation".', 16, 1);
        RETURN;
    END

    CREATE TABLE #JsonData (ResponseText NVARCHAR(MAX));

    EXEC sp_OAMethod @Object, 'Open', NULL, 'GET', @UrlDolares, 'false';
    EXEC sp_OAMethod @Object, 'Send';
    INSERT INTO #JsonData (ResponseText) EXEC sp_OAGetProperty @Object, 'ResponseText';
    SELECT TOP 1 @ResponseDolares = ResponseText FROM #JsonData;
    TRUNCATE TABLE #JsonData;

    EXEC sp_OAMethod @Object, 'Open', NULL, 'GET', @UrlCotizaciones, 'false';
    EXEC sp_OAMethod @Object, 'Send';
    INSERT INTO #JsonData (ResponseText) EXEC sp_OAGetProperty @Object, 'ResponseText';
    SELECT TOP 1 @ResponseCotizaciones = ResponseText FROM #JsonData;
    
    EXEC sp_OADestroy @Object;
    DROP TABLE #JsonData;

    SET @ResponseDolares = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@ResponseDolares, 
        'á', 'a'), 'é', 'e'), 'í', 'i'), 'ó', 'o'), 'ú', 'u'), 'ñ', 'n');

    SET @ResponseCotizaciones = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@ResponseCotizaciones, 
        'á', 'a'), 'é', 'e'), 'í', 'i'), 'ó', 'o'), 'ú', 'u'), 'ñ', 'n');

    IF ISJSON(@ResponseDolares) > 0 AND ISJSON(@ResponseCotizaciones) > 0
    BEGIN
        SELECT 
            CAST(@Parque AS VARCHAR(100)) COLLATE database_default AS [Area Protegida],
            @Concepto AS Item_A_Pagar,
            @PrecioARS AS Precio_Base_ARS,
            CAST('USD' AS VARCHAR(10)) AS Moneda_Pago,
            CAST(JSON_VALUE(value, '$.nombre') AS VARCHAR(100)) COLLATE database_default AS Tipo_Cotizacion,
            CAST(JSON_VALUE(value, '$.venta') AS DECIMAL(18,2)) AS Valor_Cotizacion_Venta,
            CAST(@PrecioARS / NULLIF(CAST(JSON_VALUE(value, '$.venta') AS DECIMAL(18,2)), 0) AS DECIMAL(18,2)) AS Costo_Moneda_Extranjera
        FROM OPENJSON(@ResponseDolares)
        
        UNION ALL
        
        SELECT 
            CAST(@Parque AS VARCHAR(100)) COLLATE database_default,
            @Concepto,
            @PrecioARS,
            CAST(JSON_VALUE(value, '$.moneda') AS VARCHAR(10)),
            CAST(JSON_VALUE(value, '$.nombre') AS VARCHAR(100)) COLLATE database_default,
            CAST(JSON_VALUE(value, '$.venta') AS DECIMAL(18,2)),
            CAST(@PrecioARS / NULLIF(CAST(JSON_VALUE(value, '$.venta') AS DECIMAL(18,2)), 0) AS DECIMAL(18,2))
        FROM OPENJSON(@ResponseCotizaciones)
        WHERE JSON_VALUE(value, '$.moneda') IN ('EUR', 'BRL');
    END
    ELSE
    BEGIN
        RAISERROR('La respuesta de la API no es un JSON v�lido o una de las peticiones fall�.', 16, 1);
    END
END
GO





-- Este procedimiento permite consultar el clima actual de un parque nacional utilizando la API de Open-Meteo y devuelve informacion sobre temperatura, precipitacion y estado del clima.


CREATE OR ALTER PROCEDURE Parques.SP_ConsultarClimaParque
    @id_parque SMALLINT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Latitud DECIMAL(8,6);
    DECLARE @Longitud DECIMAL(9,6);
    DECLARE @NombreParque VARCHAR(100);
    DECLARE @Url NVARCHAR(MAX);
    DECLARE @errores VARCHAR(1000) = '';

    SELECT 
        @Latitud = u.latitud,
        @Longitud = u.longitud,
        @NombreParque = p.nombre
    FROM Parques.Parque_nacional p
    INNER JOIN Parques.Ubicacion u ON p.id_ubicacion = u.id_ubicacion
    WHERE p.id_parque = @id_parque;

    IF @Latitud IS NULL OR @Longitud IS NULL
    BEGIN
        SET @errores = 'El parque indicado no existe o no tiene una ubicacion valida con latitud/longitud.';
        THROW 50001, @errores, 1;
    END

    SET @Url = 'https://api.open-meteo.com/v1/forecast?latitude=' + 
               CAST(@Latitud AS VARCHAR(20)) + '&longitude=' + 
               CAST(@Longitud AS VARCHAR(20)) + 
               '&current=temperature_2m,precipitation,weather_code';

    DECLARE @Object INT;
    DECLARE @HResult INT;
    DECLARE @ResponseText NVARCHAR(MAX);

    EXEC @HResult = sp_OACreate 'WinHttp.WinHttpRequest.5.1', @Object OUT;
    IF @HResult <> 0
    BEGIN
        RAISERROR('Error al crear el objeto HTTP. Asegurate de tener "Ole Automation" habilitado.', 16, 1);
        RETURN;
    END

    CREATE TABLE #JsonData (ResponseText NVARCHAR(MAX));

    EXEC sp_OAMethod @Object, 'Open', NULL, 'GET', @Url, 'false';
    EXEC sp_OAMethod @Object, 'Send';
    INSERT INTO #JsonData (ResponseText) EXEC sp_OAGetProperty @Object, 'ResponseText';
    
    SELECT TOP 1 @ResponseText = ResponseText FROM #JsonData;
    
    EXEC sp_OADestroy @Object;
    DROP TABLE #JsonData;

    IF ISJSON(@ResponseText) > 0
    BEGIN
 
        SELECT 
            @NombreParque AS Parque_Nacional,
            CAST(JSON_VALUE(@ResponseText, '$.current.temperature_2m') AS DECIMAL(5,2)) AS Temperatura_C,
            CAST(JSON_VALUE(@ResponseText, '$.current.precipitation') AS DECIMAL(5,2)) AS Precipitacion_mm,
            
            CASE 
                WHEN CAST(JSON_VALUE(@ResponseText, '$.current.weather_code') AS INT) BETWEEN 0 AND 3 THEN 'Despejado / Parcialmente Nublado'
                WHEN CAST(JSON_VALUE(@ResponseText, '$.current.weather_code') AS INT) BETWEEN 45 AND 48 THEN 'Niebla / Bruma'
                WHEN CAST(JSON_VALUE(@ResponseText, '$.current.weather_code') AS INT) BETWEEN 51 AND 69 THEN 'Llovizna / Lluvia'
                WHEN CAST(JSON_VALUE(@ResponseText, '$.current.weather_code') AS INT) BETWEEN 71 AND 79 THEN 'Nieve'
                WHEN CAST(JSON_VALUE(@ResponseText, '$.current.weather_code') AS INT) >= 80 THEN 'Tormenta / Lluvia Fuerte'
                ELSE 'Desconocido'
            END AS Estado_Del_Clima,
            
            CASE 
                WHEN CAST(JSON_VALUE(@ResponseText, '$.current.weather_code') AS INT) < 50 THEN 'Si'
                ELSE 'No'
            END AS Condiciones_Favorables_Visita
    END
    ELSE
    BEGIN
        RAISERROR('La respuesta de la API no es un JSON valido o la peticion fallo.', 16, 1);
    END
END
GO
