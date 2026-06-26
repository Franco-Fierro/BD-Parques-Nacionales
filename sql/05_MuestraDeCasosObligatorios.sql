------------------------------------------------------------------
--Universidad Nacional de La Matanza
--MATERIA: BASES DE DATOS APLICADA
--COMISION: 5600
--GRUPO: 03
--FIERRO, FRANCO EZEQUIEL
--GISMONDI, FRANCISCO
----------------------------------------------------------------
-- Nombre del archivo: 05_MuestraDeCasosObligatorios.sql
-- Descripcion: Este script contiene consultas de ejemplo para mostrar la informacion de parques nacionales, ventas, concesiones y guardaparques.
-- Objetivo: El objetivo de este script es proporcionar ejemplos de consultas que pueden ser utilizadas para obtener informacion relevante de la base de datos COM5600_G03.
----------------------------------------------------------------
USE COM5600_G03;
------------------------------------------------------------------

-- LISTADO DE PARQUES NACIONALES CON SU UBICACION Y TIPO DE PARQUE
SELECT 
    PN.nombre AS Parque_Nacional,
    TP.descripcion AS Tipo_De_Parque,
    PN.superficie AS Superficie_Ha,
    U.provincia AS Provincia,
    U.region AS Region,
    U.latitud AS Latitud,
    U.longitud AS Longitud
FROM Parques.Parque_nacional PN
INNER JOIN Parques.Ubicacion U ON PN.id_ubicacion = U.id_ubicacion
INNER JOIN Parques.Tipo_parque TP ON PN.id_tipo_parque = TP.id_tipo_parque;

-- HISTORIAL DE VENTAS CON DETALLE DE ITEMS VENDIDOS, PUNTO DE VENTA Y FORMA DE PAGO
SELECT 
    V.numero_factura AS Factura,
    V.fecha_emision AS Fecha_Emision,
    PV.descripcion AS Punto_De_Venta,
    FP.descripcion AS Forma_De_Pago,
    DV.id_item AS ID_Item_Vendido,
    DV.subtotal AS Subtotal_Item,
    V.total AS Total_Factura
FROM Comercial.Venta V
INNER JOIN Comercial.Detalle_venta DV ON V.id_venta = DV.id_venta
INNER JOIN Comercial.Punto_de_venta PV ON V.id_punto_de_venta = PV.id_punto_de_venta
INNER JOIN Comercial.Forma_de_pago FP ON V.id_forma_de_pago = FP.id_forma_de_pago
ORDER BY V.fecha_emision DESC;

-- LISTADO DE CONCESIONES CON SU ESTADO, EMPRESA CONCESIONARIA, PARQUE OPERANDO Y PAGOS REALIZADOS
SELECT 
    E.razon_social AS Empresa_Concesionaria,
    PN.nombre AS Parque_Operando,
    C.fecha_inicio AS Inicio_Contrato,
    C.fecha_fin AS Fin_Contrato,
    EC.descripcion AS Estado_De_Concesion,
    C.monto_alquiler AS Canon_Mensual,
    PC.periodo_mes AS Mes_Abonado,
    PC.periodo_anio AS Anio_Abonado,
    EP.descripcion AS Estado_Del_Pago
FROM Concesiones.Concesion C
INNER JOIN Concesiones.Empresa E ON C.id_empresa = E.id_empresa
INNER JOIN Parques.Parque_nacional PN ON C.id_parque = PN.id_parque
INNER JOIN Concesiones.Estado_concesion EC ON C.id_estado_concesion = EC.id_estado_concesion
LEFT JOIN Concesiones.Pago_canon PC ON C.id_concesion = PC.id_concesion
LEFT JOIN Concesiones.Estado_pago EP ON PC.id_estado_pago = EP.id_estado_pago;

-- LISTADO DE GUARDAPARQUES CON SU ESTADO ACTUAL, PARQUE ASIGNADO Y PERIODOS DE ASIGNACION
SELECT 
    G.dni AS DNI_Guardaparque,
    G.nombre + ' ' + G.apellido AS Nombre_Completo,
    G.estado AS Estado_Actual,
    PN.nombre AS Parque_Asignado,
    AG.fecha_inicio AS Periodo_Desde,
    AG.fecha_fin AS Periodo_Hasta,
    AG.motivo_egreso AS Motivo_De_Egreso
FROM Parques.Guardaparque G
INNER JOIN Parques.Asignacion_guardaparque AG ON G.id_guardaparque = AG.id_guardaparque
INNER JOIN Parques.Parque_nacional PN ON AG.id_parque = PN.id_parque
ORDER BY G.dni, AG.fecha_inicio DESC;