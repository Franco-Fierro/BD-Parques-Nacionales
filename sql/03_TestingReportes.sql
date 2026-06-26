--Universidad Nacional de La Matanza
--MATERIA: BASES DE DATOS APLICADA
--COMISION: 5600
--GRUPO: 03
--FIERRO, FRANCO EZEQUIEL
--GISMONDI, FRANCISCO


USE COM5600_G03;
GO

SET NOCOUNT ON;

BEGIN TRAN;
BEGIN TRY
    DECLARE @id_ubicacion int, @id_tipo_parque int,
            @id_parque_a int, @id_parque_b int, @id_parque_c int,
            @id_tipo_visitante int, @id_entrada int, @ok int;

    EXEC Parques.SP_AgregarUbicacion @provincia='Neuquen', @region='Andina',
         @latitud=-40.7, @longitud=-71.6, @id_ubicacion=@id_ubicacion OUTPUT;
    EXEC Parques.SP_AgregarTipoParque @descripcion='Parque Nacional', @id_tipo_parque=@id_tipo_parque OUTPUT;
    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='Lanin', @superficie=3790, @id_parque_nuevo=@id_parque_a OUTPUT;
    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='Lago Puelo', @superficie=270, @id_parque_nuevo=@id_parque_b OUTPUT;
    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='Tierra del Fuego', @superficie=685, @id_parque_nuevo=@id_parque_c OUTPUT;
    SELECT @id_tipo_visitante = id_tipo_visitante
    FROM Comercial.Tipo_visitante WHERE descripcion = 'Residente';
    IF @id_tipo_visitante IS NULL
        EXEC Comercial.SP_AgregarTipoVisitante @descripcion='Residente', @id_tipo_visitante=@id_tipo_visitante OUTPUT;

    -- Lanin: 3 entradas en una semana de enero, 2 en otra semana de enero, 1 en marzo (todas 2025)
    EXEC Comercial.SP_AgregarEntrada @id_parque=@id_parque_a, @id_tipo_visitante=@id_tipo_visitante, @fecha_acceso='2025-01-06', @id_entrada=@id_entrada OUTPUT;
    EXEC Comercial.SP_AgregarEntrada @id_parque=@id_parque_a, @id_tipo_visitante=@id_tipo_visitante, @fecha_acceso='2025-01-07', @id_entrada=@id_entrada OUTPUT;
    EXEC Comercial.SP_AgregarEntrada @id_parque=@id_parque_a, @id_tipo_visitante=@id_tipo_visitante, @fecha_acceso='2025-01-08', @id_entrada=@id_entrada OUTPUT;
    EXEC Comercial.SP_AgregarEntrada @id_parque=@id_parque_a, @id_tipo_visitante=@id_tipo_visitante, @fecha_acceso='2025-01-20', @id_entrada=@id_entrada OUTPUT;
    EXEC Comercial.SP_AgregarEntrada @id_parque=@id_parque_a, @id_tipo_visitante=@id_tipo_visitante, @fecha_acceso='2025-01-21', @id_entrada=@id_entrada OUTPUT;
    EXEC Comercial.SP_AgregarEntrada @id_parque=@id_parque_a, @id_tipo_visitante=@id_tipo_visitante, @fecha_acceso='2025-03-15', @id_entrada=@id_entrada OUTPUT;

    -- Lago Puelo: 1 entrada en enero 2025, 2 en febrero 2024
    EXEC Comercial.SP_AgregarEntrada @id_parque=@id_parque_b, @id_tipo_visitante=@id_tipo_visitante, @fecha_acceso='2025-01-07', @id_entrada=@id_entrada OUTPUT;
    EXEC Comercial.SP_AgregarEntrada @id_parque=@id_parque_b, @id_tipo_visitante=@id_tipo_visitante, @fecha_acceso='2024-02-10', @id_entrada=@id_entrada OUTPUT;
    EXEC Comercial.SP_AgregarEntrada @id_parque=@id_parque_b, @id_tipo_visitante=@id_tipo_visitante, @fecha_acceso='2024-02-11', @id_entrada=@id_entrada OUTPUT;
    -- Tierra del Fuego: sin entradas

    
    EXEC Comercial.SP_ReporteVisitasPorPeriodo @Periodo='ANIO';                 
    EXEC Comercial.SP_ReporteVisitasPorPeriodo @Periodo='MES';                          
    EXEC Comercial.SP_ReporteVisitasPorPeriodo @Periodo='SEMANA';                        
    EXEC Comercial.SP_ReporteVisitasPorPeriodo @Periodo='MES', @id_parque=@id_parque_a;  
    EXEC Comercial.SP_ReporteVisitasPorPeriodo @Periodo='MES', @id_parque=@id_parque_c; 
    --tiene que dar Lanin 2025=6 ; Lago Puelo 2024=2, 2025=1
    --Lanin 2025-01=5, 2025-03=1
    --enero de Lanin separado en 2 semanas (3 y 2)
    --solo Lanin
    --vacio (sin visitas)

END TRY
BEGIN CATCH PRINT 'FALLO INESPERADO: ' + ERROR_MESSAGE(); END CATCH
IF @@TRANCOUNT > 0 ROLLBACK;
GO



BEGIN TRAN;
BEGIN TRY
    DECLARE @id_ubicacion int, @id_tipo_parque int, @id_parque int, @id_parque_b int,
            @id_tipo_visitante int, @id_tarifario int, @id_tarifario_b int,
            @id_punto int, @id_forma int,
            @id_empresa int, @id_estado_concesion int, @id_estado_pago int, @id_concesion int, @id_pago int,
            @v1 int, @v2 int, @v3 int, @v4 int, @v5 int;

  
    EXEC Parques.SP_AgregarUbicacion @provincia='Neuquen', @region='Andina',
         @latitud=-40.7, @longitud=-71.6, @id_ubicacion=@id_ubicacion OUTPUT;

    EXEC Parques.SP_AgregarTipoParque @descripcion='Parque Nacional', @id_tipo_parque=@id_tipo_parque OUTPUT;

    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='Lanin', @superficie=3790, @id_parque_nuevo=@id_parque OUTPUT;

    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='Lago Puelo', @superficie=270, @id_parque_nuevo=@id_parque_b OUTPUT;

    EXEC Comercial.SP_AgregarTipoVisitante @descripcion='Residente', @id_tipo_visitante=@id_tipo_visitante OUTPUT;

    EXEC Comercial.SP_AgregarTarifarioParque @id_parque=@id_parque, @id_tipo_visitante=@id_tipo_visitante,
         @precio_actual=1000, @id_tarifario=@id_tarifario OUTPUT;           

    EXEC Comercial.SP_AgregarTarifarioParque @id_parque=@id_parque_b, @id_tipo_visitante=@id_tipo_visitante,
         @precio_actual=800, @id_tarifario=@id_tarifario_b OUTPUT;          

    EXEC Comercial.SP_AgregarPuntoDeVenta @descripcion='Boleteria', @id_punto_de_venta=@id_punto OUTPUT;
    EXEC Comercial.SP_AgregarFormaDePago @descripcion='Efectivo', @id_forma_de_pago=@id_forma OUTPUT;

    DECLARE @items Comercial.TipoItemsVenta;

    DELETE FROM @items; INSERT INTO @items (tipo_item, id_parque, id_tipo_visitante, cantidad) VALUES ('Entrada', @id_parque, @id_tipo_visitante, 2);
    EXEC Comercial.SP_RegistrarVenta @items=@items, @id_punto_de_venta=@id_punto, @id_forma_de_pago=@id_forma, @numero_factura='L-001', @id_venta_generada=@v1 OUTPUT;
    UPDATE Comercial.Venta SET fecha_emision='2025-01-06' WHERE id_venta=@v1;

    DELETE FROM @items; INSERT INTO @items (tipo_item, id_parque, id_tipo_visitante, cantidad) VALUES ('Entrada', @id_parque, @id_tipo_visitante, 1);
    EXEC Comercial.SP_RegistrarVenta @items=@items, @id_punto_de_venta=@id_punto, @id_forma_de_pago=@id_forma, @numero_factura='L-002', @id_venta_generada=@v2 OUTPUT;
    UPDATE Comercial.Venta SET fecha_emision='2025-01-20' WHERE id_venta=@v2;

    DELETE FROM @items; INSERT INTO @items (tipo_item, id_parque, id_tipo_visitante, cantidad) VALUES ('Entrada', @id_parque, @id_tipo_visitante, 3);
    EXEC Comercial.SP_RegistrarVenta @items=@items, @id_punto_de_venta=@id_punto, @id_forma_de_pago=@id_forma, @numero_factura='L-003', @id_venta_generada=@v3 OUTPUT;
    UPDATE Comercial.Venta SET fecha_emision='2025-03-15' WHERE id_venta=@v3;

    DELETE FROM @items; INSERT INTO @items (tipo_item, id_parque, id_tipo_visitante, cantidad) VALUES ('Entrada', @id_parque, @id_tipo_visitante, 4);
    EXEC Comercial.SP_RegistrarVenta @items=@items, @id_punto_de_venta=@id_punto, @id_forma_de_pago=@id_forma, @numero_factura='L-004', @id_venta_generada=@v4 OUTPUT;
    UPDATE Comercial.Venta SET fecha_emision='2024-02-10' WHERE id_venta=@v4;


    DELETE FROM @items; INSERT INTO @items (tipo_item, id_parque, id_tipo_visitante, cantidad) VALUES ('Entrada', @id_parque_b, @id_tipo_visitante, 5);
    EXEC Comercial.SP_RegistrarVenta @items=@items, @id_punto_de_venta=@id_punto, @id_forma_de_pago=@id_forma, @numero_factura='LP-001', @id_venta_generada=@v5 OUTPUT;
    UPDATE Comercial.Venta SET fecha_emision='2025-01-07' WHERE id_venta=@v5;

    EXEC Concesiones.SP_AgregarEmpresa @razon_social='Sur SA', @cuit='30712345678', @rubro_principal='Gastronomia', @id_empresa=@id_empresa OUTPUT;
    EXEC Concesiones.SP_AgregarEstadoConcesion @descripcion='Vigente', @id_estado_concesion=@id_estado_concesion OUTPUT;
    EXEC Concesiones.SP_AgregarEstadoPago @descripcion='Pagado', @id_estado_pago=@id_estado_pago OUTPUT;
    EXEC Concesiones.SP_AgregarConcesion @id_estado_concesion=@id_estado_concesion, @id_parque=@id_parque,
         @id_empresa=@id_empresa, @fecha_inicio='2025-01-01', @fecha_fin='2026-01-01', @monto_alquiler=50000, @id_concesion=@id_concesion OUTPUT;
    EXEC Concesiones.SP_RegistrarPagoCanon @id_concesion=@id_concesion, @fecha_pago='2025-03-18',
         @monto=50000, @periodo_mes=3, @periodo_anio=2025, @id_pago_generado=@id_pago OUTPUT;


    -- deberia dar
    --     Lanin 2024 -> Entradas 4000,  Total 4000
    --     Lanin 2025 -> Entradas 6000 (2+1+3 ventas), Concesiones 50000, Total 56000
    --     Lago Puelo 2025 -> Entradas 4000, Total 4000

    --     Lanin 2024-02 -> 4000
    --     Lanin 2025-01 -> 3000 (venta v1=2000 + v2=1000)
    --     Lanin 2025-03 -> Entradas 3000 + Concesiones 50000 = 53000
    --     Lago Puelo 2025-01 -> 4000

    --     Lanin 2025 sem~2 -> 2000   |   Lanin 2025 sem~4 -> 1000   |   Lanin 2025-03 ... ; etc.

    EXEC Comercial.SP_ReporteIngresosPorParque @Periodo='ANIO';
    EXEC Comercial.SP_ReporteIngresosPorParque @Periodo='MES';
    EXEC Comercial.SP_ReporteIngresosPorParque @Periodo='SEMANA';

    -- solo lanin por mes
    EXEC Comercial.SP_ReporteIngresosPorParque @Periodo='MES', @id_parque=@id_parque;

END TRY
BEGIN CATCH PRINT 'FALLO: ' + ERROR_MESSAGE(); END CATCH
IF @@TRANCOUNT > 0 ROLLBACK;
GO




BEGIN TRAN;
BEGIN TRY
    DECLARE @id_ubicacion int, @id_tipo_parque int, @id_parque int,
            @id_empresa_a int, @id_empresa_b int, @id_empresa_c int,
            @id_estado_concesion int, @id_estado_pago int,
            @con_a int, @con_b int, @con_c int, @id_pago int,
            @hoy date = CAST(GETDATE() AS DATE);

    -- inicio = primer dia del mes, hace 5 meses como ejemplo
    DECLARE @inicio date = DATEADD(MONTH, -5, DATEFROMPARTS(YEAR(@hoy), MONTH(@hoy), 1));


    EXEC Parques.SP_AgregarUbicacion @provincia='Neuquen', @region='Andina',
         @latitud=-40.7, @longitud=-71.6, @id_ubicacion=@id_ubicacion OUTPUT;

    EXEC Parques.SP_AgregarTipoParque @descripcion='Parque Nacional', @id_tipo_parque=@id_tipo_parque OUTPUT;

    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='Lanin', @superficie=3790, @id_parque_nuevo=@id_parque OUTPUT;
    
     SELECT @id_estado_concesion = id_estado_concesion
    FROM Concesiones.Estado_concesion WHERE descripcion = 'Vigente';

    IF @id_estado_concesion IS NULL
        EXEC Concesiones.SP_AgregarEstadoConcesion @descripcion='Vigente', @id_estado_concesion=@id_estado_concesion OUTPUT;

    
    SELECT @id_estado_pago = id_estado_pago
    FROM Concesiones.Estado_pago WHERE descripcion = 'Pagado';
    IF @id_estado_pago IS NULL
        EXEC Concesiones.SP_AgregarEstadoPago @descripcion='Pagado', @id_estado_pago=@id_estado_pago OUTPUT;

    EXEC Concesiones.SP_AgregarEmpresa @razon_social='Empresa A', @cuit='30111111119', @rubro_principal='Gastronomia', @id_empresa=@id_empresa_a OUTPUT;
    EXEC Concesiones.SP_AgregarEmpresa @razon_social='Empresa B', @cuit='30222222227', @rubro_principal='Comercio', @id_empresa=@id_empresa_b OUTPUT;
    EXEC Concesiones.SP_AgregarEmpresa @razon_social='Empresa C', @cuit='30333333335', @rubro_principal='Hoteleria', @id_empresa=@id_empresa_c OUTPUT;

    EXEC Concesiones.SP_AgregarConcesion @id_estado_concesion=@id_estado_concesion, @id_parque=@id_parque,
         @id_empresa=@id_empresa_a, @fecha_inicio=@inicio, @fecha_fin='2027-01-01', @monto_alquiler=10000, @id_concesion=@con_a OUTPUT;

    EXEC Concesiones.SP_AgregarConcesion @id_estado_concesion=@id_estado_concesion, @id_parque=@id_parque,
         @id_empresa=@id_empresa_b, @fecha_inicio=@inicio, @fecha_fin='2027-01-01', @monto_alquiler=20000, @id_concesion=@con_b OUTPUT;

    EXEC Concesiones.SP_AgregarConcesion @id_estado_concesion=@id_estado_concesion, @id_parque=@id_parque,
         @id_empresa=@id_empresa_c, @fecha_inicio=@inicio, @fecha_fin='2027-01-01', @monto_alquiler=30000, @id_concesion=@con_c OUTPUT;


    DECLARE @cuota date, @mes int, @anio int, @i int;

    
    SET @i = 0;
    WHILE @i <= 1
    BEGIN
        SET @cuota = DATEADD(MONTH, @i, @inicio);
        SET @mes = MONTH(@cuota); SET @anio = YEAR(@cuota);
        EXEC Concesiones.SP_RegistrarPagoCanon @id_concesion=@con_a, @fecha_pago=@cuota, @monto=10000,
             @periodo_mes=@mes, @periodo_anio=@anio, @id_pago_generado=@id_pago OUTPUT;
        SET @i = @i + 1;
    END

    
    SET @i = 0;
    WHILE @i <= 5
    BEGIN
        SET @cuota = DATEADD(MONTH, @i, @inicio);
        SET @mes = MONTH(@cuota); SET @anio = YEAR(@cuota);
        EXEC Concesiones.SP_RegistrarPagoCanon @id_concesion=@con_b, @fecha_pago=@cuota, @monto=20000,
             @periodo_mes=@mes, @periodo_anio=@anio, @id_pago_generado=@id_pago OUTPUT;
        SET @i = @i + 1;
    END

    

  
    -- deberia dar
    --   Empresa A 4 filas meses 2,3,4 y 5
    --   Empresa B nada porque pago todo
    --   Empresa C 6 filas meses 1,2,3,4,5 y 6 

    --Tiene que devolver xml
    EXEC Concesiones.SP_ReporteDeudoresXML;

END TRY
BEGIN CATCH PRINT 'FALLO: ' + ERROR_MESSAGE(); END CATCH
IF @@TRANCOUNT > 0 ROLLBACK;
GO




BEGIN TRAN;
BEGIN TRY
    DECLARE @id_ubicacion int, @id_tipo_parque int,
            @id_parque_a int, @id_parque_b int, @id_parque_c int,
            @id_tipo_visitante int, @id_entrada int;

  
    EXEC Parques.SP_AgregarUbicacion @provincia='Neuquen', @region='Andina',
         @latitud=-40.7, @longitud=-71.6, @id_ubicacion=@id_ubicacion OUTPUT;

    EXEC Parques.SP_AgregarTipoParque @descripcion='Parque Nacional', @id_tipo_parque=@id_tipo_parque OUTPUT;

    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='Lanin', @superficie=3790, @id_parque_nuevo=@id_parque_a OUTPUT;

    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='Lago Puelo', @superficie=270, @id_parque_nuevo=@id_parque_b OUTPUT;

    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='Tierra del Fuego', @superficie=685, @id_parque_nuevo=@id_parque_c OUTPUT;
         
    EXEC Comercial.SP_AgregarTipoVisitante @descripcion='Residente', @id_tipo_visitante=@id_tipo_visitante OUTPUT;


    
    -- Lanin - enero 3
    EXEC Comercial.SP_AgregarEntrada @id_parque=@id_parque_a, @id_tipo_visitante=@id_tipo_visitante, @fecha_acceso='2025-01-05', @id_entrada=@id_entrada OUTPUT;
    EXEC Comercial.SP_AgregarEntrada @id_parque=@id_parque_a, @id_tipo_visitante=@id_tipo_visitante, @fecha_acceso='2025-01-12', @id_entrada=@id_entrada OUTPUT;
    EXEC Comercial.SP_AgregarEntrada @id_parque=@id_parque_a, @id_tipo_visitante=@id_tipo_visitante, @fecha_acceso='2025-01-25', @id_entrada=@id_entrada OUTPUT;
    -- Lanin - marzo 2
    EXEC Comercial.SP_AgregarEntrada @id_parque=@id_parque_a, @id_tipo_visitante=@id_tipo_visitante, @fecha_acceso='2025-03-10', @id_entrada=@id_entrada OUTPUT;
    EXEC Comercial.SP_AgregarEntrada @id_parque=@id_parque_a, @id_tipo_visitante=@id_tipo_visitante, @fecha_acceso='2025-03-20', @id_entrada=@id_entrada OUTPUT;
    -- Lanin - diciembre 1
    EXEC Comercial.SP_AgregarEntrada @id_parque=@id_parque_a, @id_tipo_visitante=@id_tipo_visitante, @fecha_acceso='2025-12-15', @id_entrada=@id_entrada OUTPUT;

    -- Lago Puelo - enero 1
    EXEC Comercial.SP_AgregarEntrada @id_parque=@id_parque_b, @id_tipo_visitante=@id_tipo_visitante, @fecha_acceso='2025-01-08', @id_entrada=@id_entrada OUTPUT;
    -- Lago Puelo - julio 4
    EXEC Comercial.SP_AgregarEntrada @id_parque=@id_parque_b, @id_tipo_visitante=@id_tipo_visitante, @fecha_acceso='2025-07-01', @id_entrada=@id_entrada OUTPUT;
    EXEC Comercial.SP_AgregarEntrada @id_parque=@id_parque_b, @id_tipo_visitante=@id_tipo_visitante, @fecha_acceso='2025-07-09', @id_entrada=@id_entrada OUTPUT;
    EXEC Comercial.SP_AgregarEntrada @id_parque=@id_parque_b, @id_tipo_visitante=@id_tipo_visitante, @fecha_acceso='2025-07-18', @id_entrada=@id_entrada OUTPUT;
    EXEC Comercial.SP_AgregarEntrada @id_parque=@id_parque_b, @id_tipo_visitante=@id_tipo_visitante, @fecha_acceso='2025-07-27', @id_entrada=@id_entrada OUTPUT;

    -- Tierra del Fuego - marzo 2
    EXEC Comercial.SP_AgregarEntrada @id_parque=@id_parque_c, @id_tipo_visitante=@id_tipo_visitante, @fecha_acceso='2025-03-03', @id_entrada=@id_entrada OUTPUT;
    EXEC Comercial.SP_AgregarEntrada @id_parque=@id_parque_c, @id_tipo_visitante=@id_tipo_visitante, @fecha_acceso='2025-03-30', @id_entrada=@id_entrada OUTPUT;

    EXEC Comercial.SP_AgregarEntrada @id_parque=@id_parque_c, @id_tipo_visitante=@id_tipo_visitante, @fecha_acceso='2024-03-15', @id_entrada=@id_entrada OUTPUT;
    EXEC Comercial.SP_ReporteMatrizVisitas @anio=2025;

    -- Control: la matriz de 2024 deberia mostrar SOLO Tierra del Fuego con 1 en marzo
    EXEC Comercial.SP_ReporteMatrizVisitas @anio=2024;

END TRY
BEGIN CATCH PRINT 'FALLO: ' + ERROR_MESSAGE(); END CATCH
IF @@TRANCOUNT > 0 ROLLBACK;
GO



BEGIN TRAN;
BEGIN TRY
    DECLARE @id_ubicacion int, @id_tipo_parque int,
            @id_parque_a int, @id_parque_b int, @id_parque_c int,
            @id_empresa_1 int, @id_empresa_2 int, @id_empresa_3 int,
            @id_estado_concesion int, @id_con int;

   
    EXEC Parques.SP_AgregarUbicacion @provincia='Neuquen', @region='Andina',
         @latitud=-40.7, @longitud=-71.6, @id_ubicacion=@id_ubicacion OUTPUT;

    EXEC Parques.SP_AgregarTipoParque @descripcion='Parque Nacional', @id_tipo_parque=@id_tipo_parque OUTPUT;

    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='Lanin', @superficie=3790, @id_parque_nuevo=@id_parque_a OUTPUT;

    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='Lago Puelo', @superficie=270, @id_parque_nuevo=@id_parque_b OUTPUT;

    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='Tierra del Fuego', @superficie=685, @id_parque_nuevo=@id_parque_c OUTPUT;

    EXEC Concesiones.SP_AgregarEmpresa @razon_social='Sur SA', @cuit='30111111119', @rubro_principal='Gastronomia', @id_empresa=@id_empresa_1 OUTPUT;
    EXEC Concesiones.SP_AgregarEmpresa @razon_social='Aventura SA', @cuit='30222222227', @rubro_principal='Turismo', @id_empresa=@id_empresa_2 OUTPUT;
    EXEC Concesiones.SP_AgregarEmpresa @razon_social='Kiosco SRL', @cuit='30333333335', @rubro_principal='Comercio', @id_empresa=@id_empresa_3 OUTPUT;

    EXEC Concesiones.SP_AgregarEstadoConcesion @descripcion='Vigente', @id_estado_concesion=@id_estado_concesion OUTPUT;


    
    EXEC Concesiones.SP_AgregarConcesion @id_estado_concesion=@id_estado_concesion, @id_parque=@id_parque_a,
         @id_empresa=@id_empresa_1, @fecha_inicio='2025-01-01', @fecha_fin='2026-01-01', @monto_alquiler=50000, @id_concesion=@id_con OUTPUT;
  
    EXEC Concesiones.SP_AgregarConcesion @id_estado_concesion=@id_estado_concesion, @id_parque=@id_parque_a,
         @id_empresa=@id_empresa_2, @fecha_inicio='2025-03-01', @fecha_fin='2027-03-01', @monto_alquiler=80000, @id_concesion=@id_con OUTPUT;

    EXEC Concesiones.SP_AgregarConcesion @id_estado_concesion=@id_estado_concesion, @id_parque=@id_parque_b,
         @id_empresa=@id_empresa_3, @fecha_inicio='2025-06-01', @fecha_fin='2026-06-01', @monto_alquiler=30000, @id_concesion=@id_con OUTPUT;


    EXEC Concesiones.SP_ReporteParquesConcesionesXML;


--deberia dar 
    --   Lanin  2 concesiones (Sur SA + Aventura SA)
    --   Lago Puelo 1 concesion  (Kiosco SRL)
    --   Tierra del Fuego  0 concesiones
END TRY
BEGIN CATCH PRINT 'FALLO: ' + ERROR_MESSAGE(); END CATCH
IF @@TRANCOUNT > 0 ROLLBACK;
GO