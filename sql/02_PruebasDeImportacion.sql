------------------------------------------------------------------
--Universidad Nacional de La Matanza
--MATERIA: BASES DE DATOS APLICADA
--COMISION: 5600
--GRUPO: 03
--FIERRO, FRANCO EZEQUIEL
--GISMONDI, FRANCISCO
--QUISPE BARJA, SERGIO DANIEL
----------------------------------------------------------------
-- Nombre del archivo: 02_PruebasDeImportacion.sql
-- Descripcion: casos de uso para la importacion de datos desde archivos CSV
-- Objetivo: validar la correcta importacion de datos y el manejo de errores
----------------------------------------------------------------
USE Pruebas_Parques
GO
----------------------------------------------------------------


EXEC Parques.SP_ImportarParques_CSV 
    @RutaArchivo = 'C:\CompletarRuta\data\Parques_Nacionales_-_con_WKT.csv';


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


EXEC Actividades.SP_ImportarGuiasTurismo_CSV 
    @RutaArchivo = 'C:\CompletarRuta\data\registro-de-guias-de-turismo.csv';

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
ORDER BY apellido, nombre;

SELECT 
    archivo AS [Archivo Origen],
    motivo_error AS [Motivo del Rechazo],
    COUNT(*) AS [Cantidad de Registros Fallidos]
FROM Parques.Log_Errores_Importacion
GROUP BY archivo, motivo_error;
