--Universidad Nacional de La Matanza
--MATERIA: BASES DE DATOS APLICADA
--COMISION: 5600
--GRUPO: 03
--FIERRO, FRANCO EZEQUIEL
--GISMONDI, FRANCISCO
----------------------------------------------------------------
-- Nombre del archivo: 06_PruebasAPI.sql
-- Descripción: Script de pruebas de la API
--------------------------------------------------------------
USE COM5600_G03;
GO

EXEC Parques.SP_ConsultarClimaParque @id_parque = 1;
EXEC Parques.SP_ConsultarClimaParque @id_parque = 2;
EXEC Parques.SP_ConsultarClimaParque @id_parque = 10;


EXEC Comercial.SP_CotizarItemMonedaExtranjera  @id_tarifario = 1, @id_actividad = 3;
EXEC Comercial.SP_CotizarItemMonedaExtranjera @id_tarifario = 1;
EXEC Comercial.SP_CotizarItemMonedaExtranjera @id_actividad = 3;
EXEC Comercial.SP_CotizarItemMonedaExtranjera @id_actividad = 5;