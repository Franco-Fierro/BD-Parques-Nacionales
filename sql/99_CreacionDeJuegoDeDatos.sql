--Universidad Nacional de La Matanza
--MATERIA: BASES DE DATOS APLICADA
--COMISION: 5600
--GRUPO: 03
--FIERRO, FRANCO EZEQUIEL
--GISMONDI, FRANCISCO

--Objetivo: poblar la base de datos con datos de prueba
--          cumpliendo los requisitos minimos establecidos:
--          - Al menos 10 parques provinciales
--          - Al menos 30 actividades/tours
--          - Al menos 20 guias
--          - Al menos 20 guardaparques
--          - Al menos 10 concesiones

USE COM5600_G03;
GO

-- ============================================================
-- BLOQUE 0: TABLAS DE REFERENCIA / LOOKUP
-- ============================================================

-- Tipos de parque
DECLARE @tp1 tinyint, @tp2 tinyint, @tp3 tinyint;
EXEC Parques.SP_AgregarTipoParque 'Parque Provincial', @id_tipo_parque = @tp1 OUTPUT;
EXEC Parques.SP_AgregarTipoParque 'Parque Nacional',   @id_tipo_parque = @tp2 OUTPUT;
EXEC Parques.SP_AgregarTipoParque 'Reserva Natural', @id_tipo_parque = @tp3 OUTPUT;

-- Tipos de actividad
DECLARE @ta1 tinyint, @ta2 tinyint, @ta3 tinyint, @ta4 tinyint, @ta5 tinyint;
EXEC Actividades.SP_AgregarTipoActividad 'Senderismo',      @id_tipo_actividad = @ta1 OUTPUT;
EXEC Actividades.SP_AgregarTipoActividad 'Avistaje fauna',  @id_tipo_actividad = @ta2 OUTPUT;
EXEC Actividades.SP_AgregarTipoActividad 'Kayak / Rafting', @id_tipo_actividad = @ta3 OUTPUT;
EXEC Actividades.SP_AgregarTipoActividad 'Cabalgata',       @id_tipo_actividad = @ta4 OUTPUT;
EXEC Actividades.SP_AgregarTipoActividad 'Fotografia',      @id_tipo_actividad = @ta5 OUTPUT;

-- Tipos de visitante
DECLARE @tv1 tinyint, @tv2 tinyint, @tv3 tinyint, @tv4 tinyint;
EXEC Comercial.SP_AgregarTipoVisitante 'General',           @id_tipo_visitante = @tv1 OUTPUT;
EXEC Comercial.SP_AgregarTipoVisitante 'Jubilado',          @id_tipo_visitante = @tv2 OUTPUT;
EXEC Comercial.SP_AgregarTipoVisitante 'Menor',             @id_tipo_visitante = @tv3 OUTPUT;
EXEC Comercial.SP_AgregarTipoVisitante 'Investigador',      @id_tipo_visitante = @tv4 OUTPUT;

-- Puntos de venta
DECLARE @pv1 tinyint, @pv2 tinyint, @pv3 tinyint;
EXEC Comercial.SP_AgregarPuntoDeVenta 'Administracion central', @id_punto_de_venta = @pv1 OUTPUT;
EXEC Comercial.SP_AgregarPuntoDeVenta 'Portal de acceso',       @id_punto_de_venta = @pv2 OUTPUT;
EXEC Comercial.SP_AgregarPuntoDeVenta 'Venta online',           @id_punto_de_venta = @pv3 OUTPUT;

-- Formas de pago
DECLARE @fp1 tinyint, @fp2 tinyint, @fp3 tinyint;
EXEC Comercial.SP_AgregarFormaDePago 'Efectivo',         @id_forma_de_pago = @fp1 OUTPUT;
EXEC Comercial.SP_AgregarFormaDePago 'Tarjeta debito',   @id_forma_de_pago = @fp2 OUTPUT;
EXEC Comercial.SP_AgregarFormaDePago 'Transferencia',    @id_forma_de_pago = @fp3 OUTPUT;

-- Estados de concesion
DECLARE @ec1 tinyint, @ec2 tinyint, @ec3 tinyint;
EXEC Concesiones.SP_AgregarEstadoConcesion 'Vigente',    @id_estado_concesion = @ec1 OUTPUT;
EXEC Concesiones.SP_AgregarEstadoConcesion 'Vencida',    @id_estado_concesion = @ec2 OUTPUT;
EXEC Concesiones.SP_AgregarEstadoConcesion 'Suspendida', @id_estado_concesion = @ec3 OUTPUT;

-- Estados de pago canon
DECLARE @ep1 tinyint, @ep2 tinyint, @ep3 tinyint;
EXEC Concesiones.SP_AgregarEstadoPago 'Pagado',    @id_estado_pago = @ep1 OUTPUT;
EXEC Concesiones.SP_AgregarEstadoPago 'Pendiente', @id_estado_pago = @ep2 OUTPUT;
EXEC Concesiones.SP_AgregarEstadoPago 'Vencido',   @id_estado_pago = @ep3 OUTPUT;

GO

-- ============================================================
-- BLOQUE 1: UBICACIONES (una por parque)
-- ============================================================

DECLARE
    @u1  int, @u2  int, @u3  int, @u4  int, @u5  int,
    @u6  int, @u7  int, @u8  int, @u9  int, @u10 int,
    @u11 int, @u12 int;

EXEC Parques.SP_AgregarUbicacion 'Buenos Aires',    'Cuenca del Salado',          -36.524200, -57.142300, @id_ubicacion = @u1  OUTPUT;
EXEC Parques.SP_AgregarUbicacion 'Buenos Aires',    'Sierra de la Ventana',       -38.129700, -61.878900, @id_ubicacion = @u2  OUTPUT;
EXEC Parques.SP_AgregarUbicacion 'Cordoba',         'Sierras Grandes',            -31.865000, -64.736000, @id_ubicacion = @u3  OUTPUT;
EXEC Parques.SP_AgregarUbicacion 'Mendoza',         'Precordillera',              -32.880000, -69.020000, @id_ubicacion = @u4  OUTPUT;
EXEC Parques.SP_AgregarUbicacion 'Neuquen',         'Patagonia Norte',            -40.175000, -71.320000, @id_ubicacion = @u5  OUTPUT;
EXEC Parques.SP_AgregarUbicacion 'Salta',           'Yungas',                     -24.700000, -65.400000, @id_ubicacion = @u6  OUTPUT;
EXEC Parques.SP_AgregarUbicacion 'Misiones',        'Selva Paranaense',           -26.330000, -54.010000, @id_ubicacion = @u7  OUTPUT;
EXEC Parques.SP_AgregarUbicacion 'Santa Cruz',      'Patagonia Sur',              -49.300000, -72.860000, @id_ubicacion = @u8  OUTPUT;
EXEC Parques.SP_AgregarUbicacion 'Chaco',           'Chaco Humedo',               -26.530000, -59.780000, @id_ubicacion = @u9  OUTPUT;
EXEC Parques.SP_AgregarUbicacion 'Tucuman',         'Valles Calchaquies',         -26.180000, -65.680000, @id_ubicacion = @u10 OUTPUT;
EXEC Parques.SP_AgregarUbicacion 'Rio Negro',       'Comarca Andina',             -41.130000, -71.410000, @id_ubicacion = @u11 OUTPUT;
EXEC Parques.SP_AgregarUbicacion 'Entre Rios',      'Delta del Parana',           -32.450000, -60.930000, @id_ubicacion = @u12 OUTPUT;

GO

-- ============================================================
-- BLOQUE 2: PARQUES (12 parques, 10 provinciales + 2 nacionales)
-- ============================================================

DECLARE
    @p1  smallint, @p2  smallint, @p3  smallint, @p4  smallint, @p5  smallint,
    @p6  smallint, @p7  smallint, @p8  smallint, @p9  smallint, @p10 smallint,
    @p11 smallint, @p12 smallint;

-- Recuperar los IDs de tipo_parque y ubicacion ya insertados
DECLARE @tp_prov tinyint, @tp_nac tinyint, @tp_res tinyint;
SELECT @tp_prov = id_tipo_parque FROM Parques.tipo_parque WHERE descripcion = 'Parque Provincial';
SELECT @tp_nac  = id_tipo_parque FROM Parques.tipo_parque WHERE descripcion = 'Parque Nacional';
SELECT @tp_res  = id_tipo_parque FROM Parques.tipo_parque WHERE descripcion = 'Reserva Natural';

DECLARE @ub1 int, @ub2 int, @ub3 int, @ub4 int, @ub5 int,
        @ub6 int, @ub7 int, @ub8 int, @ub9 int, @ub10 int,
        @ub11 int, @ub12 int;

SELECT @ub1  = id_ubicacion FROM Parques.Ubicacion WHERE provincia = 'Buenos Aires' AND region = 'Cuenca del Salado';
SELECT @ub2  = id_ubicacion FROM Parques.Ubicacion WHERE provincia = 'Buenos Aires' AND region = 'Sierra de la Ventana';
SELECT @ub3  = id_ubicacion FROM Parques.Ubicacion WHERE provincia = 'Cordoba';
SELECT @ub4  = id_ubicacion FROM Parques.Ubicacion WHERE provincia = 'Mendoza';
SELECT @ub5  = id_ubicacion FROM Parques.Ubicacion WHERE provincia = 'Neuquen';
SELECT @ub6  = id_ubicacion FROM Parques.Ubicacion WHERE provincia = 'Salta';
SELECT @ub7  = id_ubicacion FROM Parques.Ubicacion WHERE provincia = 'Misiones';
SELECT @ub8  = id_ubicacion FROM Parques.Ubicacion WHERE provincia = 'Santa Cruz';
SELECT @ub9  = id_ubicacion FROM Parques.Ubicacion WHERE provincia = 'Chaco';
SELECT @ub10 = id_ubicacion FROM Parques.Ubicacion WHERE provincia = 'Tucuman';
SELECT @ub11 = id_ubicacion FROM Parques.Ubicacion WHERE provincia = 'Rio Negro';
SELECT @ub12 = id_ubicacion FROM Parques.Ubicacion WHERE provincia = 'Entre Rios';

-- 10 Parques provinciales
EXEC Parques.SP_AgregarParque @ub1,  @tp_prov, 'Parque Provincial Punta Lara',          3720.00,  @id_parque_nuevo = @p1  OUTPUT;
EXEC Parques.SP_AgregarParque @ub2,  @tp_prov, 'Parque Provincial Ernesto Tornquist',   6700.00,  @id_parque_nuevo = @p2  OUTPUT;
EXEC Parques.SP_AgregarParque @ub3,  @tp_prov, 'Parque Provincial Quebrada del Condorito', 37000.00, @id_parque_nuevo = @p3 OUTPUT;
EXEC Parques.SP_AgregarParque @ub4,  @tp_prov, 'Parque Provincial Aconcagua',           71000.00, @id_parque_nuevo = @p4  OUTPUT;
EXEC Parques.SP_AgregarParque @ub5,  @tp_prov, 'Parque Provincial Copahue',             82000.00, @id_parque_nuevo = @p5  OUTPUT;
EXEC Parques.SP_AgregarParque @ub6,  @tp_prov, 'Parque Provincial El Rey',              44162.00, @id_parque_nuevo = @p6  OUTPUT;
EXEC Parques.SP_AgregarParque @ub7,  @tp_prov, 'Parque Provincial Moconá',               999.00, @id_parque_nuevo = @p7  OUTPUT;
EXEC Parques.SP_AgregarParque @ub8,  @tp_prov, 'Parque Provincial Perito Moreno',      115000.00, @id_parque_nuevo = @p8  OUTPUT;
EXEC Parques.SP_AgregarParque @ub9,  @tp_prov, 'Parque Provincial Pampa del Indio',      18000.00, @id_parque_nuevo = @p9  OUTPUT;
EXEC Parques.SP_AgregarParque @ub10, @tp_prov, 'Parque Provincial Los Alisos',           10000.00, @id_parque_nuevo = @p10 OUTPUT;
-- 2 Parques no provinciales (para mayor variedad)
EXEC Parques.SP_AgregarParque @ub11, @tp_nac,  'Parque Nacional Nahuel Huapi',         710000.00, @id_parque_nuevo = @p11 OUTPUT;
EXEC Parques.SP_AgregarParque @ub12, @tp_res,  'Reserva Natural Pre-Delta',              2458.00, @id_parque_nuevo = @p12 OUTPUT;

GO

-- ============================================================
-- BLOQUE 3: GUARDAPARQUES (20)
-- ============================================================

DECLARE
    @g1  int, @g2  int, @g3  int, @g4  int, @g5  int,
    @g6  int, @g7  int, @g8  int, @g9  int, @g10 int,
    @g11 int, @g12 int, @g13 int, @g14 int, @g15 int,
    @g16 int, @g17 int, @g18 int, @g19 int, @g20 int;

EXEC Parques.SP_AgregarGuardaparque '28456123', 'Carlos',    'Mendez',     '2010-03-15', 'Activo',   @id_guardaparque = @g1  OUTPUT;
EXEC Parques.SP_AgregarGuardaparque '31987654', 'Laura',     'Gimenez',    '2012-07-01', 'Activo',   @id_guardaparque = @g2  OUTPUT;
EXEC Parques.SP_AgregarGuardaparque '25874123', 'Roberto',   'Fernandez',  '2008-11-20', 'Activo',   @id_guardaparque = @g3  OUTPUT;
EXEC Parques.SP_AgregarGuardaparque '34561298', 'Maria',     'Lopez',      '2015-04-10', 'Activo',   @id_guardaparque = @g4  OUTPUT;
EXEC Parques.SP_AgregarGuardaparque '29632145', 'Diego',     'Castillo',   '2011-09-05', 'Activo',   @id_guardaparque = @g5  OUTPUT;
EXEC Parques.SP_AgregarGuardaparque '36741258', 'Valeria',   'Torres',     '2018-01-22', 'Activo',   @id_guardaparque = @g6  OUTPUT;
EXEC Parques.SP_AgregarGuardaparque '27963258', 'Hugo',      'Soria',      '2009-06-14', 'Activo',   @id_guardaparque = @g7  OUTPUT;
EXEC Parques.SP_AgregarGuardaparque '38521478', 'Natalia',   'Pereyra',    '2019-03-30', 'Activo',   @id_guardaparque = @g8  OUTPUT;
EXEC Parques.SP_AgregarGuardaparque '22159874', 'Jorge',     'Villareal',  '2005-08-17', 'Inactivo', @id_guardaparque = @g9  OUTPUT;
EXEC Parques.SP_AgregarGuardaparque '33698521', 'Claudia',   'Rios',       '2016-12-03', 'Activo',   @id_guardaparque = @g10 OUTPUT;
EXEC Parques.SP_AgregarGuardaparque '30147852', 'Marcelo',   'Acosta',     '2013-05-28', 'Activo',   @id_guardaparque = @g11 OUTPUT;
EXEC Parques.SP_AgregarGuardaparque '37485296', 'Silvia',    'Herrera',    '2017-10-11', 'Activo',   @id_guardaparque = @g12 OUTPUT;
EXEC Parques.SP_AgregarGuardaparque '26598413', 'Pablo',     'Navarro',    '2007-02-19', 'Inactivo', @id_guardaparque = @g13 OUTPUT;
EXEC Parques.SP_AgregarGuardaparque '35269874', 'Andrea',    'Molina',     '2016-07-07', 'Activo',   @id_guardaparque = @g14 OUTPUT;
EXEC Parques.SP_AgregarGuardaparque '24856321', 'Eduardo',   'Quiroga',    '2006-04-25', 'Activo',   @id_guardaparque = @g15 OUTPUT;
EXEC Parques.SP_AgregarGuardaparque '39654123', 'Florencia', 'Medina',     '2020-08-01', 'Activo',   @id_guardaparque = @g16 OUTPUT;
EXEC Parques.SP_AgregarGuardaparque '32145698', 'Gustavo',   'Ruiz',       '2014-11-15', 'Activo',   @id_guardaparque = @g17 OUTPUT;
EXEC Parques.SP_AgregarGuardaparque '40123654', 'Carolina',  'Blanco',     '2021-02-10', 'Activo',   @id_guardaparque = @g18 OUTPUT;
EXEC Parques.SP_AgregarGuardaparque '23698745', 'Ramon',     'Gutierrez',  '2004-09-30', 'Inactivo', @id_guardaparque = @g19 OUTPUT;
EXEC Parques.SP_AgregarGuardaparque '41236985', 'Lucia',     'Vidal',      '2022-06-05', 'Activo',   @id_guardaparque = @g20 OUTPUT;

GO

-- ============================================================
-- BLOQUE 4: ASIGNACION DE GUARDAPARQUES A PARQUES
-- ============================================================

DECLARE
    @ag1 int, @ag2 int, @ag3 int, @ag4 int, @ag5 int,
    @ag6 int, @ag7 int, @ag8 int;

-- Recuperar IDs de guardaparques y parques
DECLARE @gp1 int, @gp2 int, @gp3 int, @gp4 int, @gp5 int,
        @gp6 int, @gp7 int, @gp8 int, @gp9 int, @gp10 int,
        @gp11 int, @gp12 int, @gp13 int, @gp14 int, @gp15 int,
        @gp16 int, @gp17 int, @gp18 int, @gp19 int, @gp20 int;

SELECT @gp1  = id_guardaparque FROM Parques.Guardaparque WHERE dni = '28456123';
SELECT @gp2  = id_guardaparque FROM Parques.Guardaparque WHERE dni = '31987654';
SELECT @gp3  = id_guardaparque FROM Parques.Guardaparque WHERE dni = '25874123';
SELECT @gp4  = id_guardaparque FROM Parques.Guardaparque WHERE dni = '34561298';
SELECT @gp5  = id_guardaparque FROM Parques.Guardaparque WHERE dni = '29632145';
SELECT @gp6  = id_guardaparque FROM Parques.Guardaparque WHERE dni = '36741258';
SELECT @gp7  = id_guardaparque FROM Parques.Guardaparque WHERE dni = '27963258';
SELECT @gp8  = id_guardaparque FROM Parques.Guardaparque WHERE dni = '38521478';
SELECT @gp9  = id_guardaparque FROM Parques.Guardaparque WHERE dni = '22159874';
SELECT @gp10 = id_guardaparque FROM Parques.Guardaparque WHERE dni = '33698521';
SELECT @gp11 = id_guardaparque FROM Parques.Guardaparque WHERE dni = '30147852';
SELECT @gp12 = id_guardaparque FROM Parques.Guardaparque WHERE dni = '37485296';
SELECT @gp13 = id_guardaparque FROM Parques.Guardaparque WHERE dni = '26598413';
SELECT @gp14 = id_guardaparque FROM Parques.Guardaparque WHERE dni = '35269874';
SELECT @gp15 = id_guardaparque FROM Parques.Guardaparque WHERE dni = '24856321';
SELECT @gp16 = id_guardaparque FROM Parques.Guardaparque WHERE dni = '39654123';
SELECT @gp17 = id_guardaparque FROM Parques.Guardaparque WHERE dni = '32145698';
SELECT @gp18 = id_guardaparque FROM Parques.Guardaparque WHERE dni = '40123654';
SELECT @gp19 = id_guardaparque FROM Parques.Guardaparque WHERE dni = '23698745';
SELECT @gp20 = id_guardaparque FROM Parques.Guardaparque WHERE dni = '41236985';

DECLARE @pk1 smallint, @pk2 smallint, @pk3 smallint, @pk4 smallint, @pk5 smallint,
        @pk6 smallint, @pk7 smallint, @pk8 smallint, @pk9 smallint, @pk10 smallint,
        @pk11 smallint, @pk12 smallint;

SELECT @pk1  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Punta Lara';
SELECT @pk2  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Ernesto Tornquist';
SELECT @pk3  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Quebrada del Condorito';
SELECT @pk4  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Aconcagua';
SELECT @pk5  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Copahue';
SELECT @pk6  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial El Rey';
SELECT @pk7  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Moconá';
SELECT @pk8  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Perito Moreno';
SELECT @pk9  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Pampa del Indio';
SELECT @pk10 = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Los Alisos';
SELECT @pk11 = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Nacional Nahuel Huapi';
SELECT @pk12 = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Reserva Natural Pre-Delta';

-- Asignaciones activas (sin fecha fin)
EXEC Parques.SP_AgregarGuardaparqueAParque @gp1,  @pk1,  '2020-01-10', NULL, NULL, @id_asignacion = @ag1 OUTPUT;
EXEC Parques.SP_AgregarGuardaparqueAParque @gp2,  @pk2,  '2019-03-05', NULL, NULL, @id_asignacion = @ag2 OUTPUT;
EXEC Parques.SP_AgregarGuardaparqueAParque @gp3,  @pk3,  '2018-06-15', NULL, NULL, @id_asignacion = @ag3 OUTPUT;
EXEC Parques.SP_AgregarGuardaparqueAParque @gp4,  @pk4,  '2021-02-20', NULL, NULL, @id_asignacion = @ag4 OUTPUT;
EXEC Parques.SP_AgregarGuardaparqueAParque @gp5,  @pk5,  '2017-09-01', NULL, NULL, @id_asignacion = @ag5 OUTPUT;
EXEC Parques.SP_AgregarGuardaparqueAParque @gp6,  @pk6,  '2022-04-12', NULL, NULL, @id_asignacion = @ag6 OUTPUT;
EXEC Parques.SP_AgregarGuardaparqueAParque @gp7,  @pk7,  '2016-08-30', NULL, NULL, @id_asignacion = @ag7 OUTPUT;
EXEC Parques.SP_AgregarGuardaparqueAParque @gp8,  @pk8,  '2023-01-15', NULL, NULL, @id_asignacion = @ag8 OUTPUT;
EXEC Parques.SP_AgregarGuardaparqueAParque @gp10, @pk9,  '2020-07-07', NULL, NULL, @id_asignacion = @ag1 OUTPUT;
EXEC Parques.SP_AgregarGuardaparqueAParque @gp11, @pk10, '2019-11-11', NULL, NULL, @id_asignacion = @ag2 OUTPUT;
EXEC Parques.SP_AgregarGuardaparqueAParque @gp12, @pk11, '2021-05-20', NULL, NULL, @id_asignacion = @ag3 OUTPUT;
EXEC Parques.SP_AgregarGuardaparqueAParque @gp14, @pk12, '2022-10-03', NULL, NULL, @id_asignacion = @ag4 OUTPUT;
EXEC Parques.SP_AgregarGuardaparqueAParque @gp15, @pk1,  '2015-03-18', NULL, NULL, @id_asignacion = @ag5 OUTPUT;
EXEC Parques.SP_AgregarGuardaparqueAParque @gp16, @pk2,  '2023-08-01', NULL, NULL, @id_asignacion = @ag6 OUTPUT;
EXEC Parques.SP_AgregarGuardaparqueAParque @gp17, @pk3,  '2020-12-10', NULL, NULL, @id_asignacion = @ag7 OUTPUT;
EXEC Parques.SP_AgregarGuardaparqueAParque @gp18, @pk5,  '2024-02-14', NULL, NULL, @id_asignacion = @ag8 OUTPUT;
EXEC Parques.SP_AgregarGuardaparqueAParque @gp20, @pk6,  '2024-06-01', NULL, NULL, @id_asignacion = @ag1 OUTPUT;
-- Asignaciones cerradas (inactivos o rotaciones)
EXEC Parques.SP_AgregarGuardaparqueAParque @gp9,  @pk4,  '2012-01-01', '2022-12-31', 'Jubilacion', @id_asignacion = @ag2 OUTPUT;
EXEC Parques.SP_AgregarGuardaparqueAParque @gp13, @pk7,  '2010-05-01', '2020-04-30', 'Renuncia',   @id_asignacion = @ag3 OUTPUT;
EXEC Parques.SP_AgregarGuardaparqueAParque @gp19, @pk8,  '2008-03-01', '2023-06-30', 'Jubilacion', @id_asignacion = @ag4 OUTPUT;

GO

-- ============================================================
-- BLOQUE 5: GUIAS (20)
-- ============================================================

DECLARE
    @gu1  int, @gu2  int, @gu3  int, @gu4  int, @gu5  int,
    @gu6  int, @gu7  int, @gu8  int, @gu9  int, @gu10 int,
    @gu11 int, @gu12 int, @gu13 int, @gu14 int, @gu15 int,
    @gu16 int, @gu17 int, @gu18 int, @gu19 int, @gu20 int;

EXEC Actividades.SP_AgregarGuia '20365874', 'Santiago',  'Bernal',     'Guia de Montaña',       'Alta Montana',            '2027-12-31', @id_guia = @gu1  OUTPUT;
EXEC Actividades.SP_AgregarGuia '30145263', 'Gabriela',  'Suarez',     'Biologo',               'Avifauna pampeana',       '2026-11-30', @id_guia = @gu2  OUTPUT;
EXEC Actividades.SP_AgregarGuia '27896541', 'Tomas',     'Ibañez',     'Instructor de Kayak',   'Aguas blancas',           '2027-03-15', @id_guia = @gu3  OUTPUT;
EXEC Actividades.SP_AgregarGuia '33541287', 'Marina',    'Godoy',      'Licenciada en Turismo', 'Ecoturismo',              '2026-09-20', @id_guia = @gu4  OUTPUT;
EXEC Actividades.SP_AgregarGuia '25478963', 'Ariel',     'Paz',        'Guia de Trekking',      'Patagonia',               '2027-06-01', @id_guia = @gu5  OUTPUT;
EXEC Actividades.SP_AgregarGuia '38741256', 'Cecilia',   'Alvarado',   'Fotografa Naturaleza',  'Fauna silvestre',         '2028-01-01', @id_guia = @gu6  OUTPUT;
EXEC Actividades.SP_AgregarGuia '29654123', 'Rodrigo',   'Mansilla',   'Guia de Aventura',      'Espeleologia',            '2026-08-15', @id_guia = @gu7  OUTPUT;
EXEC Actividades.SP_AgregarGuia '40256987', 'Belen',     'Cabrera',    'Interprete Ambiental',  'Humedales',               '2027-05-20', @id_guia = @gu8  OUTPUT;
EXEC Actividades.SP_AgregarGuia '26987415', 'Nicolas',   'Salazar',    'Instructor Equitacion', 'Cabalgata patagonica',    '2026-12-10', @id_guia = @gu9  OUTPUT;
EXEC Actividades.SP_AgregarGuia '35698741', 'Alejandra', 'Vera',       'Guia Senior',           'Selva subtropical',       '2027-10-31', @id_guia = @gu10 OUTPUT;
EXEC Actividades.SP_AgregarGuia '31458963', 'Emilio',    'Leal',       'Guia de Naturaleza',    'Bosque andino-patagonico','2027-04-30', @id_guia = @gu11 OUTPUT;
EXEC Actividades.SP_AgregarGuia '37852146', 'Patricia',  'Dominguez',  'Licenciada Biologia',   'Macroinvertebrados',      '2026-07-15', @id_guia = @gu12 OUTPUT;
EXEC Actividades.SP_AgregarGuia '23145698', 'Matias',    'Escalante',  'Guia Espeleologico',    'Cavernas andinas',        '2028-03-01', @id_guia = @gu13 OUTPUT;
EXEC Actividades.SP_AgregarGuia '39854123', 'Antonella', 'Bustos',     'Interprete Ambiental',  'Chaco semiarido',         '2027-08-20', @id_guia = @gu14 OUTPUT;
EXEC Actividades.SP_AgregarGuia '28965412', 'Federico',  'Orozco',     'Biologo Marino',        'Ecosistemas acuaticos',   '2026-10-05', @id_guia = @gu15 OUTPUT;
EXEC Actividades.SP_AgregarGuia '41257896', 'Julieta',   'Pineda',     'Guia de Fotografia',    'Astrofotografia',         '2027-09-15', @id_guia = @gu16 OUTPUT;
EXEC Actividades.SP_AgregarGuia '32654789', 'Leandro',   'Romero',     'Guia Aventura Senior',  'Rapel y escalada',        '2026-06-30', @id_guia = @gu17 OUTPUT;
EXEC Actividades.SP_AgregarGuia '36987452', 'Valeria',   'Aguilar',    'Guia Trekking',         'Yungas y quebradas',      '2028-02-01', @id_guia = @gu18 OUTPUT;
EXEC Actividades.SP_AgregarGuia '24785136', 'Hernan',    'Montenegro', 'Instructor Acuatico',   'Canoas y kayak fluvial',  '2027-07-10', @id_guia = @gu19 OUTPUT;
EXEC Actividades.SP_AgregarGuia '42365874', 'Sabrina',   'Cortez',     'Guia de Naturaleza',    'Humedales del Delta',     '2028-05-25', @id_guia = @gu20 OUTPUT;

GO

-- ============================================================
-- BLOQUE 6: ACTIVIDADES (32 actividades)
-- ============================================================

DECLARE
    @a1  int, @a2  int, @a3  int, @a4  int, @a5  int,
    @a6  int, @a7  int, @a8  int, @a9  int, @a10 int,
    @a11 int, @a12 int, @a13 int, @a14 int, @a15 int,
    @a16 int, @a17 int, @a18 int, @a19 int, @a20 int,
    @a21 int, @a22 int, @a23 int, @a24 int, @a25 int,
    @a26 int, @a27 int, @a28 int, @a29 int, @a30 int,
    @a31 int, @a32 int;

DECLARE @tid1 tinyint, @tid2 tinyint, @tid3 tinyint, @tid4 tinyint, @tid5 tinyint;
SELECT @tid1 = id_tipo_actividad FROM Actividades.Tipo_actividad WHERE descripcion = 'Senderismo';
SELECT @tid2 = id_tipo_actividad FROM Actividades.Tipo_actividad WHERE descripcion = 'Avistaje fauna';
SELECT @tid3 = id_tipo_actividad FROM Actividades.Tipo_actividad WHERE descripcion = 'Kayak / Rafting';
SELECT @tid4 = id_tipo_actividad FROM Actividades.Tipo_actividad WHERE descripcion = 'Cabalgata';
SELECT @tid5 = id_tipo_actividad FROM Actividades.Tipo_actividad WHERE descripcion = 'Fotografia';

DECLARE @qk1 smallint, @qk2 smallint, @qk3 smallint, @qk4 smallint, @qk5 smallint,
        @qk6 smallint, @qk7 smallint, @qk8 smallint, @qk9 smallint, @qk10 smallint,
        @qk11 smallint, @qk12 smallint;

SELECT @qk1  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Punta Lara';
SELECT @qk2  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Ernesto Tornquist';
SELECT @qk3  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Quebrada del Condorito';
SELECT @qk4  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Aconcagua';
SELECT @qk5  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Copahue';
SELECT @qk6  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial El Rey';
SELECT @qk7  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Moconá';
SELECT @qk8  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Perito Moreno';
SELECT @qk9  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Pampa del Indio';
SELECT @qk10 = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Los Alisos';
SELECT @qk11 = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Nacional Nahuel Huapi';
SELECT @qk12 = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Reserva Natural Pre-Delta';

-- Parque 1 - Punta Lara
EXEC Actividades.SP_AgregarActividad @tid1, @qk1, 'Sendero del Bosque Ribereño',       120, 20, 2500.00,  @id_actividad = @a1  OUTPUT;
EXEC Actividades.SP_AgregarActividad @tid2, @qk1, 'Avistaje de aves acuáticas',         90, 15, 3000.00,  @id_actividad = @a2  OUTPUT;
EXEC Actividades.SP_AgregarActividad @tid5, @qk1, 'Fotografía de amanecer en humedal', 180, 10, 4500.00,  @id_actividad = @a3  OUTPUT;
-- Parque 2 - Ernesto Tornquist
EXEC Actividades.SP_AgregarActividad @tid1, @qk2, 'Trekking Cerro Ventana',            240, 25, 3500.00,  @id_actividad = @a4  OUTPUT;
EXEC Actividades.SP_AgregarActividad @tid1, @qk2, 'Circuito Las Grutas',               180, 30, 2800.00,  @id_actividad = @a5  OUTPUT;
EXEC Actividades.SP_AgregarActividad @tid4, @qk2, 'Cabalgata serrana',                 150, 12, 5500.00,  @id_actividad = @a6  OUTPUT;
-- Parque 3 - Quebrada del Condorito
EXEC Actividades.SP_AgregarActividad @tid2, @qk3, 'Avistaje de cóndores',              300, 18, 4000.00,  @id_actividad = @a7  OUTPUT;
EXEC Actividades.SP_AgregarActividad @tid1, @qk3, 'Sendero La Quebrada',               240, 20, 3200.00,  @id_actividad = @a8  OUTPUT;
EXEC Actividades.SP_AgregarActividad @tid5, @qk3, 'Tour fotográfico al atardecer',     180, 10, 5000.00,  @id_actividad = @a9  OUTPUT;
-- Parque 4 - Aconcagua
EXEC Actividades.SP_AgregarActividad @tid1, @qk4, 'Trekking Base Camp Aconcagua',      480, 15, 12000.00, @id_actividad = @a10 OUTPUT;
EXEC Actividades.SP_AgregarActividad @tid1, @qk4, 'Circuito Confluencia',              360, 20, 8000.00,  @id_actividad = @a11 OUTPUT;
EXEC Actividades.SP_AgregarActividad @tid4, @qk4, 'Cabalgata Horcones - Confluencia',  420, 10, 14000.00, @id_actividad = @a12 OUTPUT;
-- Parque 5 - Copahue
EXEC Actividades.SP_AgregarActividad @tid1, @qk5, 'Trekking Volcán Copahue',           300, 16, 6500.00,  @id_actividad = @a13 OUTPUT;
EXEC Actividades.SP_AgregarActividad @tid3, @qk5, 'Kayak en Lago Caviahue',            180, 14, 7000.00,  @id_actividad = @a14 OUTPUT;
-- Parque 6 - El Rey
EXEC Actividades.SP_AgregarActividad @tid2, @qk6, 'Safari fotográfico fauna chaqueña', 240, 12, 5500.00,  @id_actividad = @a15 OUTPUT;
EXEC Actividades.SP_AgregarActividad @tid1, @qk6, 'Sendero del Tapir',                 180, 20, 3800.00,  @id_actividad = @a16 OUTPUT;
-- Parque 7 - Moconá
EXEC Actividades.SP_AgregarActividad @tid3, @qk7, 'Kayak a Saltos del Moconá',         240, 10, 8500.00,  @id_actividad = @a17 OUTPUT;
EXEC Actividades.SP_AgregarActividad @tid2, @qk7, 'Avistaje de yaguaretés',            360, 8,  9000.00,  @id_actividad = @a18 OUTPUT;
EXEC Actividades.SP_AgregarActividad @tid5, @qk7, 'Fotografía selva paranaense',       180, 12, 6000.00,  @id_actividad = @a19 OUTPUT;
-- Parque 8 - Perito Moreno
EXEC Actividades.SP_AgregarActividad @tid1, @qk8, 'Trekking Lago Belgrano',            360, 20, 7000.00,  @id_actividad = @a20 OUTPUT;
EXEC Actividades.SP_AgregarActividad @tid4, @qk8, 'Cabalgata Patagonia Sur',           300, 10, 10000.00, @id_actividad = @a21 OUTPUT;
-- Parque 9 - Pampa del Indio
EXEC Actividades.SP_AgregarActividad @tid2, @qk9, 'Avistaje de aves del Chaco',        180, 25, 3000.00,  @id_actividad = @a22 OUTPUT;
EXEC Actividades.SP_AgregarActividad @tid1, @qk9, 'Sendero Bosque Chaqueño',           120, 30, 2200.00,  @id_actividad = @a23 OUTPUT;
-- Parque 10 - Los Alisos
EXEC Actividades.SP_AgregarActividad @tid1, @qk10, 'Trekking Yungas Tucumanas',        270, 18, 4500.00,  @id_actividad = @a24 OUTPUT;
EXEC Actividades.SP_AgregarActividad @tid2, @qk10, 'Avistaje de monos carayá',         180, 15, 4000.00,  @id_actividad = @a25 OUTPUT;
-- Parque 11 - Nahuel Huapi
EXEC Actividades.SP_AgregarActividad @tid3, @qk11, 'Kayak en Lago Nahuel Huapi',       240, 20, 9000.00,  @id_actividad = @a26 OUTPUT;
EXEC Actividades.SP_AgregarActividad @tid1, @qk11, 'Trekking Refugio Frey',            360, 25, 7500.00,  @id_actividad = @a27 OUTPUT;
EXEC Actividades.SP_AgregarActividad @tid4, @qk11, 'Cabalgata Valle Encantado',        300, 12, 11000.00, @id_actividad = @a28 OUTPUT;
EXEC Actividades.SP_AgregarActividad @tid5, @qk11, 'Astrofotografía nocturna',         240, 8,  7000.00,  @id_actividad = @a29 OUTPUT;
-- Parque 12 - Pre-Delta
EXEC Actividades.SP_AgregarActividad @tid3, @qk12, 'Canoas en el Delta del Paraná',    180, 16, 4800.00,  @id_actividad = @a30 OUTPUT;
EXEC Actividades.SP_AgregarActividad @tid2, @qk12, 'Avistaje de nutrias y carpinchos', 120, 20, 3500.00,  @id_actividad = @a31 OUTPUT;
EXEC Actividades.SP_AgregarActividad @tid5, @qk12, 'Fotografía del Delta',             150, 14, 4000.00,  @id_actividad = @a32 OUTPUT;

GO

-- ============================================================
-- BLOQUE 7: GUIAS POR ACTIVIDAD
-- (Al menos 1 guia por actividad; algunos comparten guia)
-- ============================================================

DECLARE @gid1 int, @gid2 int, @gid3 int, @gid4 int, @gid5 int,
        @gid6 int, @gid7 int, @gid8 int, @gid9 int, @gid10 int,
        @gid11 int, @gid12 int, @gid13 int, @gid14 int, @gid15 int,
        @gid16 int, @gid17 int, @gid18 int, @gid19 int, @gid20 int;

SELECT @gid1  = id_guia FROM Actividades.Guia WHERE dni = '20365874';
SELECT @gid2  = id_guia FROM Actividades.Guia WHERE dni = '30145263';
SELECT @gid3  = id_guia FROM Actividades.Guia WHERE dni = '27896541';
SELECT @gid4  = id_guia FROM Actividades.Guia WHERE dni = '33541287';
SELECT @gid5  = id_guia FROM Actividades.Guia WHERE dni = '25478963';
SELECT @gid6  = id_guia FROM Actividades.Guia WHERE dni = '38741256';
SELECT @gid7  = id_guia FROM Actividades.Guia WHERE dni = '29654123';
SELECT @gid8  = id_guia FROM Actividades.Guia WHERE dni = '40256987';
SELECT @gid9  = id_guia FROM Actividades.Guia WHERE dni = '26987415';
SELECT @gid10 = id_guia FROM Actividades.Guia WHERE dni = '35698741';
SELECT @gid11 = id_guia FROM Actividades.Guia WHERE dni = '31458963';
SELECT @gid12 = id_guia FROM Actividades.Guia WHERE dni = '37852146';
SELECT @gid13 = id_guia FROM Actividades.Guia WHERE dni = '23145698';
SELECT @gid14 = id_guia FROM Actividades.Guia WHERE dni = '39854123';
SELECT @gid15 = id_guia FROM Actividades.Guia WHERE dni = '28965412';
SELECT @gid16 = id_guia FROM Actividades.Guia WHERE dni = '41257896';
SELECT @gid17 = id_guia FROM Actividades.Guia WHERE dni = '32654789';
SELECT @gid18 = id_guia FROM Actividades.Guia WHERE dni = '36987452';
SELECT @gid19 = id_guia FROM Actividades.Guia WHERE dni = '24785136';
SELECT @gid20 = id_guia FROM Actividades.Guia WHERE dni = '42365874';

DECLARE @aid1  int, @aid2  int, @aid3  int, @aid4  int, @aid5  int,
        @aid6  int, @aid7  int, @aid8  int, @aid9  int, @aid10 int,
        @aid11 int, @aid12 int, @aid13 int, @aid14 int, @aid15 int,
        @aid16 int, @aid17 int, @aid18 int, @aid19 int, @aid20 int,
        @aid21 int, @aid22 int, @aid23 int, @aid24 int, @aid25 int,
        @aid26 int, @aid27 int, @aid28 int, @aid29 int, @aid30 int,
        @aid31 int, @aid32 int;

SELECT @aid1  = id_actividad FROM Actividades.Actividad WHERE nombre = 'Sendero del Bosque Ribereño';
SELECT @aid2  = id_actividad FROM Actividades.Actividad WHERE nombre = 'Avistaje de aves acuáticas';
SELECT @aid3  = id_actividad FROM Actividades.Actividad WHERE nombre = 'Fotografía de amanecer en humedal';
SELECT @aid4  = id_actividad FROM Actividades.Actividad WHERE nombre = 'Trekking Cerro Ventana';
SELECT @aid5  = id_actividad FROM Actividades.Actividad WHERE nombre = 'Circuito Las Grutas';
SELECT @aid6  = id_actividad FROM Actividades.Actividad WHERE nombre = 'Cabalgata serrana';
SELECT @aid7  = id_actividad FROM Actividades.Actividad WHERE nombre = 'Avistaje de cóndores';
SELECT @aid8  = id_actividad FROM Actividades.Actividad WHERE nombre = 'Sendero La Quebrada';
SELECT @aid9  = id_actividad FROM Actividades.Actividad WHERE nombre = 'Tour fotográfico al atardecer';
SELECT @aid10 = id_actividad FROM Actividades.Actividad WHERE nombre = 'Trekking Base Camp Aconcagua';
SELECT @aid11 = id_actividad FROM Actividades.Actividad WHERE nombre = 'Circuito Confluencia';
SELECT @aid12 = id_actividad FROM Actividades.Actividad WHERE nombre = 'Cabalgata Horcones - Confluencia';
SELECT @aid13 = id_actividad FROM Actividades.Actividad WHERE nombre = 'Trekking Volcán Copahue';
SELECT @aid14 = id_actividad FROM Actividades.Actividad WHERE nombre = 'Kayak en Lago Caviahue';
SELECT @aid15 = id_actividad FROM Actividades.Actividad WHERE nombre = 'Safari fotográfico fauna chaqueña';
SELECT @aid16 = id_actividad FROM Actividades.Actividad WHERE nombre = 'Sendero del Tapir';
SELECT @aid17 = id_actividad FROM Actividades.Actividad WHERE nombre = 'Kayak a Saltos del Moconá';
SELECT @aid18 = id_actividad FROM Actividades.Actividad WHERE nombre = 'Avistaje de yaguaretés';
SELECT @aid19 = id_actividad FROM Actividades.Actividad WHERE nombre = 'Fotografía selva paranaense';
SELECT @aid20 = id_actividad FROM Actividades.Actividad WHERE nombre = 'Trekking Lago Belgrano';
SELECT @aid21 = id_actividad FROM Actividades.Actividad WHERE nombre = 'Cabalgata Patagonia Sur';
SELECT @aid22 = id_actividad FROM Actividades.Actividad WHERE nombre = 'Avistaje de aves del Chaco';
SELECT @aid23 = id_actividad FROM Actividades.Actividad WHERE nombre = 'Sendero Bosque Chaqueño';
SELECT @aid24 = id_actividad FROM Actividades.Actividad WHERE nombre = 'Trekking Yungas Tucumanas';
SELECT @aid25 = id_actividad FROM Actividades.Actividad WHERE nombre = 'Avistaje de monos carayá';
SELECT @aid26 = id_actividad FROM Actividades.Actividad WHERE nombre = 'Kayak en Lago Nahuel Huapi';
SELECT @aid27 = id_actividad FROM Actividades.Actividad WHERE nombre = 'Trekking Refugio Frey';
SELECT @aid28 = id_actividad FROM Actividades.Actividad WHERE nombre = 'Cabalgata Valle Encantado';
SELECT @aid29 = id_actividad FROM Actividades.Actividad WHERE nombre = 'Astrofotografía nocturna';
SELECT @aid30 = id_actividad FROM Actividades.Actividad WHERE nombre = 'Canoas en el Delta del Paraná';
SELECT @aid31 = id_actividad FROM Actividades.Actividad WHERE nombre = 'Avistaje de nutrias y carpinchos';
SELECT @aid32 = id_actividad FROM Actividades.Actividad WHERE nombre = 'Fotografía del Delta';

EXEC Actividades.SP_AgregarGuiaPorActividad @gid4,  @aid1,  '2024-01-10', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid8,  @aid1,  '2024-01-10', 'Asistente';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid2,  @aid2,  '2024-01-12', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid6,  @aid3,  '2024-02-01', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid1,  @aid4,  '2024-01-15', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid17, @aid4,  '2024-01-15', 'Asistente';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid7,  @aid5,  '2024-02-10', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid9,  @aid6,  '2024-03-01', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid2,  @aid7,  '2024-02-20', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid12, @aid7,  '2024-02-20', 'Asistente';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid4,  @aid8,  '2024-03-05', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid6,  @aid9,  '2024-03-15', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid16, @aid9,  '2024-03-15', 'Asistente';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid1,  @aid10, '2024-01-20', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid13, @aid10, '2024-01-20', 'Asistente';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid5,  @aid11, '2024-02-01', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid9,  @aid12, '2024-02-15', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid5,  @aid13, '2024-03-10', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid3,  @aid14, '2024-03-20', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid19, @aid14, '2024-03-20', 'Asistente';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid6,  @aid15, '2024-04-01', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid14, @aid15, '2024-04-01', 'Asistente';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid18, @aid16, '2024-04-05', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid3,  @aid17, '2024-04-10', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid10, @aid18, '2024-04-15', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid16, @aid19, '2024-04-20', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid5,  @aid20, '2024-05-01', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid9,  @aid21, '2024-05-05', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid14, @aid22, '2024-05-10', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid8,  @aid23, '2024-05-15', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid18, @aid24, '2024-05-20', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid10, @aid25, '2024-05-25', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid3,  @aid26, '2024-06-01', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid19, @aid26, '2024-06-01', 'Asistente';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid11, @aid27, '2024-06-05', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid9,  @aid28, '2024-06-10', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid16, @aid29, '2024-06-15', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid15, @aid30, '2024-06-20', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid20, @aid31, '2024-06-25', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid6,  @aid32, '2024-07-01', 'Principal';
EXEC Actividades.SP_AgregarGuiaPorActividad @gid20, @aid32, '2024-07-01', 'Asistente';

GO

-- ============================================================
-- BLOQUE 8: TARIFARIOS DE PARQUE
-- ============================================================

DECLARE @tvg tinyint, @tvj tinyint, @tvm tinyint, @tvi tinyint;
SELECT @tvg = id_tipo_visitante FROM Comercial.Tipo_visitante WHERE descripcion = 'General';
SELECT @tvj = id_tipo_visitante FROM Comercial.Tipo_visitante WHERE descripcion = 'Jubilado';
SELECT @tvm = id_tipo_visitante FROM Comercial.Tipo_visitante WHERE descripcion = 'Menor';
SELECT @tvi = id_tipo_visitante FROM Comercial.Tipo_visitante WHERE descripcion = 'Investigador';

DECLARE @rk1 smallint, @rk2 smallint, @rk3 smallint, @rk4 smallint,
        @rk5 smallint, @rk6 smallint, @rk7 smallint, @rk8 smallint,
        @rk9 smallint, @rk10 smallint, @rk11 smallint, @rk12 smallint;

SELECT @rk1  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Punta Lara';
SELECT @rk2  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Ernesto Tornquist';
SELECT @rk3  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Quebrada del Condorito';
SELECT @rk4  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Aconcagua';
SELECT @rk5  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Copahue';
SELECT @rk6  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial El Rey';
SELECT @rk7  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Moconá';
SELECT @rk8  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Perito Moreno';
SELECT @rk9  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Pampa del Indio';
SELECT @rk10 = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Los Alisos';
SELECT @rk11 = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Nacional Nahuel Huapi';
SELECT @rk12 = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Reserva Natural Pre-Delta';

DECLARE @tar int;
-- Punta Lara
EXEC Comercial.SP_AgregarTarifarioParque @rk1, @tvg, 1500.00, @id_tarifario = @tar OUTPUT;
EXEC Comercial.SP_AgregarTarifarioParque @rk1, @tvj,  750.00, @id_tarifario = @tar OUTPUT;
EXEC Comercial.SP_AgregarTarifarioParque @rk1, @tvm,  500.00, @id_tarifario = @tar OUTPUT;
EXEC Comercial.SP_AgregarTarifarioParque @rk1, @tvi,    0.00, @id_tarifario = @tar OUTPUT;
-- Ernesto Tornquist
EXEC Comercial.SP_AgregarTarifarioParque @rk2, @tvg, 2000.00, @id_tarifario = @tar OUTPUT;
EXEC Comercial.SP_AgregarTarifarioParque @rk2, @tvj, 1000.00, @id_tarifario = @tar OUTPUT;
EXEC Comercial.SP_AgregarTarifarioParque @rk2, @tvm,  700.00, @id_tarifario = @tar OUTPUT;
EXEC Comercial.SP_AgregarTarifarioParque @rk2, @tvi,    0.00, @id_tarifario = @tar OUTPUT;
-- Quebrada del Condorito
EXEC Comercial.SP_AgregarTarifarioParque @rk3, @tvg, 2500.00, @id_tarifario = @tar OUTPUT;
EXEC Comercial.SP_AgregarTarifarioParque @rk3, @tvj, 1200.00, @id_tarifario = @tar OUTPUT;
EXEC Comercial.SP_AgregarTarifarioParque @rk3, @tvm,  800.00, @id_tarifario = @tar OUTPUT;
-- Aconcagua
EXEC Comercial.SP_AgregarTarifarioParque @rk4, @tvg, 5000.00, @id_tarifario = @tar OUTPUT;
EXEC Comercial.SP_AgregarTarifarioParque @rk4, @tvj, 2500.00, @id_tarifario = @tar OUTPUT;
EXEC Comercial.SP_AgregarTarifarioParque @rk4, @tvm, 1500.00, @id_tarifario = @tar OUTPUT;
-- Copahue
EXEC Comercial.SP_AgregarTarifarioParque @rk5, @tvg, 3000.00, @id_tarifario = @tar OUTPUT;
EXEC Comercial.SP_AgregarTarifarioParque @rk5, @tvj, 1500.00, @id_tarifario = @tar OUTPUT;
-- El Rey
EXEC Comercial.SP_AgregarTarifarioParque @rk6, @tvg, 2800.00, @id_tarifario = @tar OUTPUT;
EXEC Comercial.SP_AgregarTarifarioParque @rk6, @tvj, 1400.00, @id_tarifario = @tar OUTPUT;
EXEC Comercial.SP_AgregarTarifarioParque @rk6, @tvm,  900.00, @id_tarifario = @tar OUTPUT;
-- Moconá
EXEC Comercial.SP_AgregarTarifarioParque @rk7, @tvg, 3500.00, @id_tarifario = @tar OUTPUT;
EXEC Comercial.SP_AgregarTarifarioParque @rk7, @tvj, 1750.00, @id_tarifario = @tar OUTPUT;
-- Perito Moreno
EXEC Comercial.SP_AgregarTarifarioParque @rk8, @tvg, 4000.00, @id_tarifario = @tar OUTPUT;
EXEC Comercial.SP_AgregarTarifarioParque @rk8, @tvj, 2000.00, @id_tarifario = @tar OUTPUT;
EXEC Comercial.SP_AgregarTarifarioParque @rk8, @tvm, 1200.00, @id_tarifario = @tar OUTPUT;
-- Pampa del Indio
EXEC Comercial.SP_AgregarTarifarioParque @rk9, @tvg, 1800.00, @id_tarifario = @tar OUTPUT;
EXEC Comercial.SP_AgregarTarifarioParque @rk9, @tvj,  900.00, @id_tarifario = @tar OUTPUT;
-- Los Alisos
EXEC Comercial.SP_AgregarTarifarioParque @rk10, @tvg, 2200.00, @id_tarifario = @tar OUTPUT;
EXEC Comercial.SP_AgregarTarifarioParque @rk10, @tvj, 1100.00, @id_tarifario = @tar OUTPUT;
-- Nahuel Huapi
EXEC Comercial.SP_AgregarTarifarioParque @rk11, @tvg, 4500.00, @id_tarifario = @tar OUTPUT;
EXEC Comercial.SP_AgregarTarifarioParque @rk11, @tvj, 2250.00, @id_tarifario = @tar OUTPUT;
EXEC Comercial.SP_AgregarTarifarioParque @rk11, @tvm, 1500.00, @id_tarifario = @tar OUTPUT;
EXEC Comercial.SP_AgregarTarifarioParque @rk11, @tvi,    0.00, @id_tarifario = @tar OUTPUT;
-- Pre-Delta
EXEC Comercial.SP_AgregarTarifarioParque @rk12, @tvg, 1600.00, @id_tarifario = @tar OUTPUT;
EXEC Comercial.SP_AgregarTarifarioParque @rk12, @tvj,  800.00, @id_tarifario = @tar OUTPUT;

GO

-- ============================================================
-- BLOQUE 9: EMPRESAS Y CONCESIONES (10 concesiones)
-- ============================================================

DECLARE
    @emp1 int, @emp2 int, @emp3 int, @emp4 int, @emp5 int,
    @emp6 int, @emp7 int, @emp8 int, @emp9 int, @emp10 int;

EXEC Concesiones.SP_AgregarEmpresa 'Aventura Patagonica S.A.',       '30698741258', 'Turismo aventura',         @id_empresa = @emp1  OUTPUT;
EXEC Concesiones.SP_AgregarEmpresa 'Gastronomia Verde S.R.L.',       '33412589630', 'Gastronomia y catering',   @id_empresa = @emp2  OUTPUT;
EXEC Concesiones.SP_AgregarEmpresa 'EcoLodge del Norte S.A.',        '27896541230', 'Hoteleria y hospedaje',    @id_empresa = @emp3  OUTPUT;
EXEC Concesiones.SP_AgregarEmpresa 'Andinismo y Trekkings S.R.L.',   '30145263147', 'Guias de montana',         @id_empresa = @emp4  OUTPUT;
EXEC Concesiones.SP_AgregarEmpresa 'Servicios Parques S.A.',         '34785296310', 'Mantenimiento e infraestructura', @id_empresa = @emp5 OUTPUT;
EXEC Concesiones.SP_AgregarEmpresa 'Kayak & Rios del Sur S.R.L.',    '31258974100', 'Deportes nauticos',        @id_empresa = @emp6  OUTPUT;
EXEC Concesiones.SP_AgregarEmpresa 'Fotografias Silvestres S.A.',    '29654123780', 'Turismo fotografico',      @id_empresa = @emp7  OUTPUT;
EXEC Concesiones.SP_AgregarEmpresa 'Alimentos Naturales S.R.L.',     '36987452100', 'Alimentos y bebidas',      @id_empresa = @emp8  OUTPUT;
EXEC Concesiones.SP_AgregarEmpresa 'Caballos de la Pampa S.A.',      '28741258963', 'Cabalgatas y equitacion',  @id_empresa = @emp9  OUTPUT;
EXEC Concesiones.SP_AgregarEmpresa 'Senderos Educativos S.R.L.',     '40123654780', 'Educacion ambiental',      @id_empresa = @emp10 OUTPUT;

DECLARE @ec_vig tinyint, @ec_ven tinyint, @ec_sus tinyint;
SELECT @ec_vig = id_estado_concesion FROM Concesiones.Estado_concesion WHERE descripcion = 'Vigente';
SELECT @ec_ven = id_estado_concesion FROM Concesiones.Estado_concesion WHERE descripcion = 'Vencida';
SELECT @ec_sus = id_estado_concesion FROM Concesiones.Estado_concesion WHERE descripcion = 'Suspendida';

DECLARE @sk1 smallint, @sk2 smallint, @sk3 smallint, @sk4 smallint, @sk5 smallint,
        @sk6 smallint, @sk7 smallint, @sk8 smallint, @sk9 smallint, @sk10 smallint,
        @sk11 smallint, @sk12 smallint;

SELECT @sk1  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Punta Lara';
SELECT @sk2  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Ernesto Tornquist';
SELECT @sk3  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Quebrada del Condorito';
SELECT @sk4  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Aconcagua';
SELECT @sk5  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Copahue';
SELECT @sk6  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial El Rey';
SELECT @sk7  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Moconá';
SELECT @sk8  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Perito Moreno';
SELECT @sk9  = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Pampa del Indio';
SELECT @sk10 = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Los Alisos';
SELECT @sk11 = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Nacional Nahuel Huapi';
SELECT @sk12 = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Reserva Natural Pre-Delta';

DECLARE @con1 int, @con2 int, @con3 int, @con4 int, @con5 int,
        @con6 int, @con7 int, @con8 int, @con9 int, @con10 int, @con11 int;

EXEC Concesiones.SP_AgregarConcesion @ec_vig, @sk2,  @emp1, '2023-01-01', '2025-12-31', 180000.00, @id_concesion = @con1  OUTPUT;
EXEC Concesiones.SP_AgregarConcesion @ec_vig, @sk4,  @emp4, '2022-06-01', '2025-05-31', 350000.00, @id_concesion = @con2  OUTPUT;
EXEC Concesiones.SP_AgregarConcesion @ec_vig, @sk7,  @emp6, '2023-03-01', '2026-02-28', 220000.00, @id_concesion = @con3  OUTPUT;
EXEC Concesiones.SP_AgregarConcesion @ec_vig, @sk11, @emp2, '2022-09-01', '2025-08-31', 500000.00, @id_concesion = @con4  OUTPUT;
EXEC Concesiones.SP_AgregarConcesion @ec_vig, @sk3,  @emp7, '2024-01-01', '2026-12-31', 150000.00, @id_concesion = @con5  OUTPUT;
EXEC Concesiones.SP_AgregarConcesion @ec_vig, @sk5,  @emp3, '2023-07-01', '2026-06-30', 280000.00, @id_concesion = @con6  OUTPUT;
EXEC Concesiones.SP_AgregarConcesion @ec_vig, @sk8,  @emp9, '2023-10-01', '2025-09-30', 200000.00, @id_concesion = @con7  OUTPUT;
EXEC Concesiones.SP_AgregarConcesion @ec_vig, @sk12, @emp8, '2024-03-01', '2026-02-28', 120000.00, @id_concesion = @con8  OUTPUT;
EXEC Concesiones.SP_AgregarConcesion @ec_ven, @sk1,  @emp5, '2020-01-01', '2023-12-31', 95000.00,  @id_concesion = @con9  OUTPUT;
EXEC Concesiones.SP_AgregarConcesion @ec_ven, @sk6,  @emp10,'2019-05-01', '2024-04-30', 160000.00, @id_concesion = @con10 OUTPUT;
EXEC Concesiones.SP_AgregarConcesion @ec_sus, @sk9,  @emp8, '2022-01-01', '2024-12-31', 110000.00, @id_concesion = @con11 OUTPUT;

GO

-- ============================================================
-- BLOQUE 10: PAGOS DE CANON
-- ============================================================

DECLARE @ep_pag tinyint, @ep_pen tinyint, @ep_ven tinyint;
SELECT @ep_pag = id_estado_pago FROM Concesiones.Estado_pago WHERE descripcion = 'Pagado';
SELECT @ep_pen = id_estado_pago FROM Concesiones.Estado_pago WHERE descripcion = 'Pendiente';
SELECT @ep_ven = id_estado_pago FROM Concesiones.Estado_pago WHERE descripcion = 'Vencido';

DECLARE @c1 int, @c2 int, @c3 int, @c4 int, @c5 int,
        @c6 int, @c7 int, @c8 int;

SELECT @c1 = id_concesion FROM Concesiones.Concesion WHERE monto_alquiler = 180000.00;
SELECT @c2 = id_concesion FROM Concesiones.Concesion WHERE monto_alquiler = 350000.00;
SELECT @c3 = id_concesion FROM Concesiones.Concesion WHERE monto_alquiler = 220000.00;
SELECT @c4 = id_concesion FROM Concesiones.Concesion WHERE monto_alquiler = 500000.00;
SELECT @c5 = id_concesion FROM Concesiones.Concesion WHERE monto_alquiler = 150000.00;
SELECT @c6 = id_concesion FROM Concesiones.Concesion WHERE monto_alquiler = 280000.00;

DECLARE @ip int;
EXEC Concesiones.SP_AgregarPagoCanon @c1, @ep_pag, '2024-01-10', 15000.00, 1, 2024, @id_pago = @ip OUTPUT;
EXEC Concesiones.SP_AgregarPagoCanon @c1, @ep_pag, '2024-02-10', 15000.00, 2, 2024, @id_pago = @ip OUTPUT;
EXEC Concesiones.SP_AgregarPagoCanon @c1, @ep_pag, '2024-03-10', 15000.00, 3, 2024, @id_pago = @ip OUTPUT;
EXEC Concesiones.SP_AgregarPagoCanon @c1, @ep_pen, '2024-04-10', 15000.00, 4, 2024, @id_pago = @ip OUTPUT;
EXEC Concesiones.SP_AgregarPagoCanon @c2, @ep_pag, '2024-01-05', 29167.00, 1, 2024, @id_pago = @ip OUTPUT;
EXEC Concesiones.SP_AgregarPagoCanon @c2, @ep_pag, '2024-02-05', 29167.00, 2, 2024, @id_pago = @ip OUTPUT;
EXEC Concesiones.SP_AgregarPagoCanon @c2, @ep_pag, '2024-03-05', 29167.00, 3, 2024, @id_pago = @ip OUTPUT;
EXEC Concesiones.SP_AgregarPagoCanon @c3, @ep_pag, '2024-01-08', 18333.00, 1, 2024, @id_pago = @ip OUTPUT;
EXEC Concesiones.SP_AgregarPagoCanon @c3, @ep_pag, '2024-02-08', 18333.00, 2, 2024, @id_pago = @ip OUTPUT;
EXEC Concesiones.SP_AgregarPagoCanon @c3, @ep_ven, '2024-03-08', 18333.00, 3, 2024, @id_pago = @ip OUTPUT;
EXEC Concesiones.SP_AgregarPagoCanon @c4, @ep_pag, '2024-01-03', 41667.00, 1, 2024, @id_pago = @ip OUTPUT;
EXEC Concesiones.SP_AgregarPagoCanon @c4, @ep_pag, '2024-02-03', 41667.00, 2, 2024, @id_pago = @ip OUTPUT;
EXEC Concesiones.SP_AgregarPagoCanon @c5, @ep_pag, '2024-01-15', 12500.00, 1, 2024, @id_pago = @ip OUTPUT;
EXEC Concesiones.SP_AgregarPagoCanon @c5, @ep_pen, '2024-02-15', 12500.00, 2, 2024, @id_pago = @ip OUTPUT;
EXEC Concesiones.SP_AgregarPagoCanon @c6, @ep_pag, '2024-01-20', 23333.00, 1, 2024, @id_pago = @ip OUTPUT;
EXEC Concesiones.SP_AgregarPagoCanon @c6, @ep_pag, '2024-02-20', 23333.00, 2, 2024, @id_pago = @ip OUTPUT;

GO

-- ============================================================
-- BLOQUE 11: VENTAS / ENTRADAS DE MUESTRA
-- ============================================================

DECLARE @vpv1 tinyint, @vfp1 tinyint, @vfp2 tinyint;
SELECT @vpv1 = id_punto_de_venta FROM Comercial.Punto_de_venta WHERE descripcion = 'Portal de acceso';
SELECT @vfp1 = id_forma_de_pago  FROM Comercial.Forma_de_pago  WHERE descripcion = 'Efectivo';
SELECT @vfp2 = id_forma_de_pago  FROM Comercial.Forma_de_pago  WHERE descripcion = 'Tarjeta debito';

DECLARE @vta1 int, @vta2 int, @vta3 int, @vta4 int, @vta5 int;
EXEC Comercial.SP_AgregarVenta @vpv1, @vfp1, '0001-00000001', '2024-03-10 09:15:00', 4500.00,  @id_venta = @vta1 OUTPUT;
EXEC Comercial.SP_AgregarVenta @vpv1, @vfp2, '0001-00000002', '2024-03-11 10:30:00', 6000.00,  @id_venta = @vta2 OUTPUT;
EXEC Comercial.SP_AgregarVenta @vpv1, @vfp1, '0001-00000003', '2024-03-12 11:00:00', 15000.00, @id_venta = @vta3 OUTPUT;
EXEC Comercial.SP_AgregarVenta @vpv1, @vfp2, '0001-00000004', '2024-03-15 14:45:00', 7000.00,  @id_venta = @vta4 OUTPUT;
EXEC Comercial.SP_AgregarVenta @vpv1, @vfp1, '0001-00000005', '2024-03-20 08:00:00', 3000.00,  @id_venta = @vta5 OUTPUT;

-- Entradas
DECLARE @tvgid tinyint, @tvjid tinyint;
SELECT @tvgid = id_tipo_visitante FROM Comercial.Tipo_visitante WHERE descripcion = 'General';
SELECT @tvjid = id_tipo_visitante FROM Comercial.Tipo_visitante WHERE descripcion = 'Jubilado';

DECLARE @ek1 smallint, @ek2 smallint, @ek3 smallint, @ek4 smallint, @ek5 smallint;
SELECT @ek1 = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Ernesto Tornquist';
SELECT @ek2 = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Provincial Aconcagua';
SELECT @ek3 = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Nacional Nahuel Huapi';
SELECT @ek4 = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Nacional Iguazú';
SELECT @ek5 = id_parque FROM Parques.Parque_nacional WHERE nombre = 'Parque Nacional Los Alerces';


DECLARE @ent1 int, @ent2 int, @ent3 int, @ent4 int, @ent5 int;
EXEC Comercial.SP_AgregarEntrada @ek1, @tvgid, '2024-03-10', @id_entrada = @ent1 OUTPUT;
EXEC Comercial.SP_AgregarEntrada @ek1, @tvjid, '2024-03-10', @id_entrada = @ent2 OUTPUT;
EXEC Comercial.SP_AgregarEntrada @ek2, @tvgid, '2024-03-11', @id_entrada = @ent3 OUTPUT;
EXEC Comercial.SP_AgregarEntrada @ek3, @tvgid, '2024-03-12', @id_entrada = @ent4 OUTPUT;
EXEC Comercial.SP_AgregarEntrada @ek3, @tvjid, '2024-03-15', @id_entrada = @ent5 OUTPUT;
EXEC Comercial.SP_AgregarEntrada @ek4, @tvgid, '2024-03-15', @id_entrada = @ent1 OUTPUT;
EXEC Comercial.SP_AgregarEntrada @ek5, @tvgid, '2024-03-20', @id_entrada = @ent2 OUTPUT;
EXEC Comercial.SP_AgregarEntrada @ek5, @tvjid, '2024-03-20', @id_entrada = @ent3 OUTPUT;

EXEC Comercial.SP_AgregarEntrada @ek1, @tvgid, '2025-09-10', @id_entrada = @ent1 OUTPUT;
EXEC Comercial.SP_AgregarEntrada @ek1, @tvjid, '2025-01-10', @id_entrada = @ent2 OUTPUT;
EXEC Comercial.SP_AgregarEntrada @ek1, @tvgid, '2025-02-11', @id_entrada = @ent3 OUTPUT;
EXEC Comercial.SP_AgregarEntrada @ek1, @tvgid, '2025-06-12', @id_entrada = @ent4 OUTPUT;
EXEC Comercial.SP_AgregarEntrada @ek3, @tvjid, '2025-12-09', @id_entrada = @ent5 OUTPUT;
EXEC Comercial.SP_AgregarEntrada @ek4, @tvgid, '2025-03-15', @id_entrada = @ent1 OUTPUT;
EXEC Comercial.SP_AgregarEntrada @ek5, @tvgid, '2025-03-20', @id_entrada = @ent2 OUTPUT;
EXEC Comercial.SP_AgregarEntrada @ek5, @tvjid, '2025-03-20', @id_entrada = @ent3 OUTPUT;

EXEC Comercial.SP_AgregarEntrada @ek1, @tvgid, '2026-01-10', @id_entrada = @ent1 OUTPUT;
EXEC Comercial.SP_AgregarEntrada @ek2, @tvjid, '2026-01-11', @id_entrada = @ent2 OUTPUT;
EXEC Comercial.SP_AgregarEntrada @ek2, @tvgid, '2026-05-14', @id_entrada = @ent3 OUTPUT;
EXEC Comercial.SP_AgregarEntrada @ek2, @tvgid, '2026-06-12', @id_entrada = @ent4 OUTPUT;
EXEC Comercial.SP_AgregarEntrada @ek3, @tvjid, '2026-07-09', @id_entrada = @ent5 OUTPUT;
EXEC Comercial.SP_AgregarEntrada @ek2, @tvgid, '2026-08-15', @id_entrada = @ent1 OUTPUT;
EXEC Comercial.SP_AgregarEntrada @ek5, @tvgid, '2026-09-20', @id_entrada = @ent2 OUTPUT;
EXEC Comercial.SP_AgregarEntrada @ek4, @tvjid, '2026-10-20', @id_entrada = @ent3 OUTPUT;

-- Items vendibles (entradas)
DECLARE @itm1 int, @itm2 int, @itm3 int, @itm4 int, @itm5 int;
EXEC Comercial.SP_AgregarItemVendible @ent1, NULL, 'Entrada', @id_item = @itm1 OUTPUT;
EXEC Comercial.SP_AgregarItemVendible @ent2, NULL, 'Entrada', @id_item = @itm2 OUTPUT;
EXEC Comercial.SP_AgregarItemVendible @ent3, NULL, 'Entrada', @id_item = @itm3 OUTPUT;
EXEC Comercial.SP_AgregarItemVendible @ent4, NULL, 'Entrada', @id_item = @itm4 OUTPUT;
EXEC Comercial.SP_AgregarItemVendible @ent5, NULL, 'Entrada', @id_item = @itm5 OUTPUT;

-- Detalles de venta
DECLARE @dv int;
EXEC Comercial.SP_AgregarDetalleVenta @vta1, @itm1, 2000.00, @id_detalle_venta = @dv OUTPUT;
EXEC Comercial.SP_AgregarDetalleVenta @vta2, @itm2, 1000.00, @id_detalle_venta = @dv OUTPUT;
EXEC Comercial.SP_AgregarDetalleVenta @vta3, @itm3, 5000.00, @id_detalle_venta = @dv OUTPUT;
EXEC Comercial.SP_AgregarDetalleVenta @vta4, @itm4, 4500.00, @id_detalle_venta = @dv OUTPUT;
EXEC Comercial.SP_AgregarDetalleVenta @vta5, @itm5, 2250.00, @id_detalle_venta = @dv OUTPUT;

GO

PRINT '================================================';
PRINT 'Dataset cargado exitosamente.';
PRINT '12 parques | 32 actividades | 20 guias | 20 guardaparques | 11 concesiones';
PRINT '================================================';