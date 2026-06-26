--Universidad Nacional de La Matanza
--MATERIA: BASES DE DATOS APLICADA
--COMISION: 5600
--GRUPO: 03
--FIERRO, FRANCO EZEQUIEL
--GISMONDI, FRANCISCO

-- Objetivo: Script para la aplicacion externa.

USE COM5600_G03
GO

CREATE OR ALTER PROCEDURE Parques.SP_Listar_TipoParque
AS
BEGIN
	SELECT * FROM Parques.Tipo_parque;
END