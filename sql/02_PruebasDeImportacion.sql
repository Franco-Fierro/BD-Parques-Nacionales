------------------------------------------------------------------
--Universidad Nacional de La Matanza
--MATERIA: BASES DE DATOS APLICADA
--COMISION: 5600
--GRUPO: 03
--FIERRO, FRANCO EZEQUIEL
--GISMONDI, FRANCISCO
----------------------------------------------------------------
-- Nombre del archivo: 02_PruebasDeImportacion.sql
-- Descripcion: casos de uso para la importacion de datos desde archivos CSV
-- Objetivo: validar la correcta importacion de datos y el manejo de errores
----------------------------------------------------------------
USE COM5600_G03
GO
----------------------------------------------------------------


EXEC Parques.SP_ImportarParques_CSV 
    @RutaArchivo = 'C:\data\Parques_Nacionales_-_con_WKT.csv';


SELECT 
    PN.id_parque,
    PN.nombre AS [Parque Nacional],
    PN.superficie AS [Superficie (Hectáreas)],
    U.provincia AS [Provincia],
    U.region AS [Región Geográfica],
    U.latitud AS [Latitud],
    U.longitud AS [Longitud],
    TP.descripcion AS [Tipo de Parque]
FROM Parques.Parque_nacional PN
INNER JOIN Parques.Ubicacion U 
    ON PN.id_ubicacion = U.id_ubicacion
INNER JOIN Parques.Tipo_parque TP 
    ON PN.id_tipo_parque = TP.id_tipo_parque
ORDER BY PN.nombre;

TRUNCATE TABLE  Actividades.Guia;

EXEC Actividades.SP_ImportarGuiasTurismo_CSV 
    @RutaArchivo = 'C:\data\registro-de-guias-de-turismo.csv';

SELECT 
    dni AS [DNI (Formateado)],
    apellido AS [Apellido],
    nombre AS [Nombre],
    titulo AS [Categoria / Titulo],
    vigencia_autorizacion AS [Fin de Vigencia],
    CASE 
        WHEN vigencia_autorizacion < GETDATE() THEN 'VENCIDA'
        ELSE 'ACTIVA'
    END AS [Estado Autorizacion]
FROM Actividades.Guia
ORDER BY dni;

SELECT 
    archivo AS [Archivo Origen],
    motivo_error AS [Motivo del Rechazo],
    COUNT(*) AS [Cantidad de Registros Fallidos]
FROM Parques.Log_Errores_Importacion
GROUP BY archivo, motivo_error;






--Prueba de importacion de Areas protetigas

--Para Su funcionamiento SE DEBE tener instalado el driver Microsoft.ACE.OLEDB.16.0 en su version x64



EXEC Parques.SP_ImportarAreasProtegidas_XLSX
    @RutaArchivo = 'C:\data\areas_protegidas_SIB.xlsx';
 
-- cuantas areas validas entraron y cuantos errores se loguearon
SELECT
    (SELECT COUNT(*) FROM Parques.Parque_nacional)                                       AS total_parques_en_la_base,
    (SELECT COUNT(*) FROM Parques.Log_Errores_Importacion
        WHERE archivo = 'C:\data\areas_protegidas_SIB.xlsx')                             AS registros_rechazados_logueados;
-- Esperado: 56 areas validas importadas y 52 registros rechazados en el log

 
-- Evidencia: muestra de lo importado, con el tipo derivado del nombre
SELECT TOP 20
    PN.nombre        AS [Area protegida],
    TP.descripcion   AS [Tipo (derivado)],
    U.provincia      AS [Provincia],
    U.region         AS [Region],
    PN.superficie    AS [Superficie (ha)]
FROM Parques.Parque_nacional PN
INNER JOIN Parques.Ubicacion   U  ON PN.id_ubicacion   = U.id_ubicacion
INNER JOIN Parques.Tipo_parque TP ON PN.id_tipo_parque = TP.id_tipo_parque
WHERE U.region = 'Sin especificar' OR TP.descripcion <> 'Parque Nacional'
ORDER BY PN.nombre;

 
-- Evidencia: detalle de los rechazos
SELECT registro_nombre AS [Area rechazada], motivo_error AS [Motivo]
FROM Parques.Log_Errores_Importacion
WHERE archivo = 'C:\data\areas_protegidas_SIB.xlsx'
ORDER BY registro_nombre;
-- Esperado: 52 filas (superficie/coordenadas incompletas).
 
--Reimportacion del MISMO archivo (no duplica)
DECLARE @antes int = (SELECT COUNT(*) FROM Parques.Parque_nacional);
EXEC Parques.SP_ImportarAreasProtegidas_XLSX
    @RutaArchivo = 'C:\data\areas_protegidas_SIB.xlsx';
SELECT @antes AS parques_antes_de_reimportar,
       (SELECT COUNT(*) FROM Parques.Parque_nacional) AS parques_despues;

GO