--Universidad Nacional de La Matanza
--MATERIA: BASES DE DATOS APLICADA
--COMISION: 5600
--GRUPO: 03
--FIERRO, FRANCO EZEQUIEL
--GISMONDI, FRANCISCO


--Objetivo: hacer testing de los store procedures ABM y logica de negocio

USE COM5600_G03;
GO
 
SET NOCOUNT ON;
GO


DECLARE @id_ubicacion int, @id_tipo_parque tinyint, @id_tipo_visitante tinyint,
        @id_punto tinyint, @id_forma tinyint, @id_tipo_actividad tinyint,
        @id_empresa int, @id_estado_concesion tinyint, @id_estado_pago tinyint,
        @id_guardaparque int, @id_guia int, @id_parque smallint,
        @id_tarifario int, @id_asignacion int, @id_actividad int,
        @id_turno int, @id_entrada int, @id_venta int,
        @id_ticket int, @id_item_entrada int, @id_item_ticket int,
        @id_detalle int, @id_concesion int, @id_pago int;

DECLARE @hoy    date = CAST(GETDATE() AS DATE);
DECLARE @futuro date = DATEADD(YEAR, 1, CAST(GETDATE() AS DATE));
DECLARE @semana date = DATEADD(DAY, 7, CAST(GETDATE() AS DATE));
DECLARE @anio   int  = YEAR(GETDATE());


BEGIN TRY
    BEGIN TRAN;
 
    EXEC Parques.SP_AgregarUbicacion @provincia='Neuquen', @region='Villa La Angostura',
         @latitud=-40.766, @longitud=-71.640, @id_ubicacion=@id_ubicacion OUTPUT;
 
    EXEC Parques.SP_AgregarTipoParque @descripcion='Parque Nacional',
         @id_tipo_parque=@id_tipo_parque OUTPUT;
 
    EXEC Comercial.SP_AgregarTipoVisitante @descripcion='Residente',
         @id_tipo_visitante=@id_tipo_visitante OUTPUT;
 
    EXEC Comercial.SP_AgregarPuntoDeVenta @descripcion='Boleteria Centro',
         @id_punto_de_venta=@id_punto OUTPUT;
 
    EXEC Comercial.SP_AgregarFormaDePago @descripcion='Efectivo',
         @id_forma_de_pago=@id_forma OUTPUT;
 
    EXEC Actividades.SP_AgregarTipoActividad @descripcion='Tour guiado',
         @id_tipo_actividad=@id_tipo_actividad OUTPUT;
 
    EXEC Concesiones.SP_AgregarEmpresa @razon_social='Servicios del Sur SA',
         @cuit='30712345678', @rubro_principal='Gastronomia', @id_empresa=@id_empresa OUTPUT;
 
    EXEC Concesiones.SP_AgregarEstadoConcesion @descripcion='Vigente',
         @id_estado_concesion=@id_estado_concesion OUTPUT;
 
    EXEC Concesiones.SP_AgregarEstadoPago @descripcion='Pagado',
         @id_estado_pago=@id_estado_pago OUTPUT;
 
    EXEC Parques.SP_AgregarGuardaparque @dni='30111222', @nombre='Juan', @apellido='Perez',
         @fecha_ingreso='2020-03-01', @estado='Activo', @id_guardaparque=@id_guardaparque OUTPUT;
 
    EXEC Actividades.SP_AgregarGuia @dni='28999111', @nombre='Ana', @apellido='Gomez',
         @titulo='Guia de montania', @especialidad='Trekking',
         @vigencia_autorizacion=@futuro, @id_guia=@id_guia OUTPUT;
 
    
    SELECT COUNT(*) AS parques_antes FROM Parques.Parque_nacional;
 
    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='Nahuel Huapi', @superficie=7050.00, @id_parque_nuevo=@id_parque OUTPUT;
 
    
    SELECT @id_parque AS id_parque_generado;
    SELECT COUNT(*) AS parques_despues FROM Parques.Parque_nacional;
    SELECT * FROM Parques.Parque_nacional WHERE id_parque = @id_parque;
 
    EXEC Comercial.SP_AgregarTarifarioParque @id_parque=@id_parque,
         @id_tipo_visitante=@id_tipo_visitante, @precio_actual=1500.00,
         @id_tarifario=@id_tarifario OUTPUT;
   
    SELECT * FROM Comercial.Tarifario_parque WHERE id_tarifario = @id_tarifario;
 
    EXEC Parques.SP_AgregarGuardaparqueAParque @id_guardaparque=@id_guardaparque,
         @id_parque=@id_parque, @fecha_inicio=@hoy, @fecha_fin=NULL,
         @motivo_egreso='Asignacion inicial', @id_asignacion=@id_asignacion OUTPUT;
 
    EXEC Actividades.SP_AgregarActividad @id_tipo_actividad=@id_tipo_actividad,
         @id_parque=@id_parque, @nombre='Trekking al Cerro', @duracion_minutos=180,
         @cupo_maximo=20, @costo=500.00, @id_actividad=@id_actividad OUTPUT;
    
    SELECT * FROM Actividades.Actividad WHERE id_actividad = @id_actividad;
 
    
    EXEC Actividades.SP_AgregarGuiaPorActividad @id_guia=@id_guia, @id_actividad=@id_actividad,
         @fecha_asignacion=@hoy, @rol='Guia principal';
 
    EXEC Actividades.SP_AgregarTurnoActividad @id_actividad=@id_actividad, @fecha=@semana,
         @hora_inicio='09:00', @id_turno=@id_turno OUTPUT;
 
    EXEC Comercial.SP_AgregarEntrada @id_parque=@id_parque, @id_tipo_visitante=@id_tipo_visitante,
         @fecha_acceso=@hoy, @id_entrada=@id_entrada OUTPUT;
 
    EXEC Comercial.SP_AgregarVenta @id_punto_de_venta=@id_punto, @id_forma_de_pago=@id_forma,
         @numero_factura='0001-00000001', @fecha_emision=@hoy, @total=3000.00,
         @id_venta=@id_venta OUTPUT;
 
    EXEC Comercial.SP_AgregarTicketActividad @id_turno=@id_turno, @id_ticket=@id_ticket OUTPUT;
 
    EXEC Comercial.SP_AgregarItemVendible @id_entrada=@id_entrada, @id_ticket=NULL,
         @tipo_item='Entrada', @id_item=@id_item_entrada OUTPUT;
 
    EXEC Comercial.SP_AgregarItemVendible @id_entrada=NULL, @id_ticket=@id_ticket,
         @tipo_item='Ticket', @id_item=@id_item_ticket OUTPUT;
 
    EXEC Comercial.SP_AgregarDetalleVenta @id_venta=@id_venta, @id_item=@id_item_entrada,
         @subtotal=1500.00, @id_detalle_venta=@id_detalle OUTPUT;
 
    
    EXEC Concesiones.SP_AgregarConcesion @id_estado_concesion=@id_estado_concesion,
         @id_parque=@id_parque, @id_empresa=@id_empresa, @fecha_inicio=@hoy,
         @fecha_fin=@futuro, @monto_alquiler=50000.00, @id_concesion=@id_concesion OUTPUT;
 
    EXEC Concesiones.SP_AgregarPagoCanon @id_concesion=@id_concesion,
         @id_estado_pago=@id_estado_pago, @fecha_pago=@hoy, @monto=50000.00,
         @periodo_mes=6, @periodo_anio=@anio, @id_pago=@id_pago OUTPUT;
 
    PRINT 'las 24 altas se ejecutaron sin errores.';
    PRINT '(Se hace ROLLBACK: la evidencia ya se mostro, no queda nada persistido)';
    ROLLBACK;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    PRINT 'FALLO INESPERADO EN PARTE 1: ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO



--Testing que deben fallar.

PRINT '';

DECLARE @dummy int;
 
-- (1) Ubicacion: provincia vacia
BEGIN TRY
    EXEC Parques.SP_AgregarUbicacion @provincia='', @region='X',
         @latitud=-40, @longitud=-71, @id_ubicacion=@dummy OUTPUT;
    PRINT '(1) FALLO DEL TEST: se esperaba error por provincia vacia';
END TRY
BEGIN CATCH PRINT '(1) OK: ' + ERROR_MESSAGE(); END CATCH
 
-- (2) Ubicacion: latitud fuera de rango (-90..90)
BEGIN TRY
    EXEC Parques.SP_AgregarUbicacion @provincia='Salta', @region='Cafayate',
         @latitud=95, @longitud=-71, @id_ubicacion=@dummy OUTPUT;
    PRINT '(2) FALLO DEL TEST: se esperaba error por latitud invalida';
END TRY
BEGIN CATCH PRINT '(2) OK: ' + ERROR_MESSAGE(); END CATCH
 
-- (3) TipoParque: descripcion vacia
BEGIN TRY
    EXEC Parques.SP_AgregarTipoParque @descripcion='', @id_tipo_parque=@dummy OUTPUT;
    PRINT '(3) FALLO DEL TEST: se esperaba error por descripcion vacia';
END TRY
BEGIN CATCH PRINT '(3) OK: ' + ERROR_MESSAGE(); END CATCH
 
-- (4) Parque: FK ubicacion inexistente
BEGIN TRY
    EXEC Parques.SP_AgregarParque @id_Ubicacion=999999, @id_Tipo_parque=999999,
         @nombre='Test', @superficie=100, @id_parque_nuevo=@dummy OUTPUT;
    PRINT '(4) FALLO DEL TEST: se esperaba error por FK inexistente';
END TRY
BEGIN CATCH PRINT '(4) OK: ' + ERROR_MESSAGE(); END CATCH
 
-- (5) Parque: TEST ACUMULADO -> 4 errores deben volver en UN SOLO mensaje
--     (FK ubicacion + FK tipo + nombre vacio + superficie <= 0)
BEGIN TRY
    EXEC Parques.SP_AgregarParque @id_Ubicacion=999999, @id_Tipo_parque=999999,
         @nombre='', @superficie=-5, @id_parque_nuevo=@dummy OUTPUT;
    PRINT '(5) FALLO DEL TEST: se esperaba un error acumulado';
END TRY
BEGIN CATCH PRINT '(5) OK: ' + ERROR_MESSAGE(); END CATCH
 
-- (6) Guardaparque: DNI mal formado (no son 8 digitos)
BEGIN TRY
    EXEC Parques.SP_AgregarGuardaparque @dni='123', @nombre='Pedro', @apellido='Lopez',
         @fecha_ingreso='2021-01-01', @estado='Activo', @id_guardaparque=@dummy OUTPUT;
    PRINT '(6) FALLO DEL TEST: se esperaba error por DNI invalido';
END TRY
BEGIN CATCH PRINT '(6) OK: ' + ERROR_MESSAGE(); END CATCH
 
-- (7) Guardaparque: fecha de ingreso futura
BEGIN TRY
    EXEC Parques.SP_AgregarGuardaparque @dni='40555666', @nombre='Pedro', @apellido='Lopez',
         @fecha_ingreso='2099-01-01', @estado='Activo', @id_guardaparque=@dummy OUTPUT;
    PRINT '(7) FALLO DEL TEST: se esperaba error por fecha futura';
END TRY
BEGIN CATCH PRINT '(7) OK: ' + ERROR_MESSAGE(); END CATCH
 
-- (8) Guia: nombre vacio
BEGIN TRY
    EXEC Actividades.SP_AgregarGuia @dni='27888999', @nombre='', @apellido='Diaz',
         @titulo='Guia', @especialidad='Aves',
         @vigencia_autorizacion='2099-01-01', @id_guia=@dummy OUTPUT;
    PRINT '(8) FALLO DEL TEST: se esperaba error por nombre vacio';
END TRY
BEGIN CATCH PRINT '(8) OK: ' + ERROR_MESSAGE(); END CATCH
 
-- (9) TarifarioParque: FK parque inexistente
BEGIN TRY
    EXEC Comercial.SP_AgregarTarifarioParque @id_parque=999999, @id_tipo_visitante=999999,
         @precio_actual=100, @id_tarifario=@dummy OUTPUT;
    PRINT '(9) FALLO DEL TEST: se esperaba error por FK inexistente';
END TRY
BEGIN CATCH PRINT '(9) OK: ' + ERROR_MESSAGE(); END CATCH
 
-- (10) Actividad: FK tipo_actividad / parque inexistentes
BEGIN TRY
    EXEC Actividades.SP_AgregarActividad @id_tipo_actividad=999999, @id_parque=999999,
         @nombre='X', @duracion_minutos=60, @cupo_maximo=10, @costo=100,
         @id_actividad=@dummy OUTPUT;
    PRINT '(10) FALLO DEL TEST: se esperaba error por FK inexistente';
END TRY
BEGIN CATCH PRINT '(10) OK: ' + ERROR_MESSAGE(); END CATCH
 
-- (11) Concesion: fecha_fin anterior a fecha_inicio
BEGIN TRY
    EXEC Concesiones.SP_AgregarConcesion @id_estado_concesion=999999, @id_parque=999999,
         @id_empresa=999999, @fecha_inicio='2025-01-01', @fecha_fin='2024-01-01',
         @monto_alquiler=1000, @id_concesion=@dummy OUTPUT;
    PRINT '(11) FALLO DEL TEST: se esperaba error por rango de fechas';
END TRY
BEGIN CATCH PRINT '(11) OK: ' + ERROR_MESSAGE(); END CATCH
 
-- (12) PagoCanon: periodo_mes invalido (13)
BEGIN TRY
    EXEC Concesiones.SP_AgregarPagoCanon @id_concesion=999999, @id_estado_pago=999999,
         @fecha_pago='2025-06-01', @monto=1000, @periodo_mes=13, @periodo_anio=2025,
         @id_pago=@dummy OUTPUT;
    PRINT '(12) FALLO DEL TEST: se esperaba error por mes invalido';
END TRY
BEGIN CATCH PRINT '(12) OK: ' + ERROR_MESSAGE(); END CATCH
 
-- (13) Empresa: CUIT duplicado (se inserta una y se intenta otra con el mismo CUIT)
--      Se usa una transaccion local para no persistir nada.
BEGIN TRAN;
BEGIN TRY
    DECLARE @e1 int;
    EXEC Concesiones.SP_AgregarEmpresa @razon_social='Empresa A', @cuit='30999888777',
         @rubro_principal='Comercio', @id_empresa=@e1 OUTPUT;
    -- segunda con el MISMO cuit -> debe fallar
    EXEC Concesiones.SP_AgregarEmpresa @razon_social='Empresa B', @cuit='30999888777',
         @rubro_principal='Comercio', @id_empresa=@dummy OUTPUT;
    PRINT '(13) FALLO DEL TEST: se esperaba error por CUIT duplicado';
END TRY
BEGIN CATCH PRINT '(13) OK: ' + ERROR_MESSAGE(); END CATCH
IF @@TRANCOUNT > 0 ROLLBACK;
GO



------------
--TESTING BORRADO
------------

PRINT 'BAJAS EXITOSAS ';
 
DECLARE @id_tipo_parque int, @id_tipo_actividad int, @id_tipo_visitante int,
        @id_punto int, @id_forma int, @id_estado_concesion int, @id_estado_pago int,
        @id_ubicacion int;
 
BEGIN TRY
    BEGIN TRAN;
 
    -- (1) Tipo_parque: alta + baja
    EXEC Parques.SP_AgregarTipoParque @descripcion='Monumento Natural',
         @id_tipo_parque=@id_tipo_parque OUTPUT;
    SELECT COUNT(*) AS tipos_parque_antes FROM Parques.Tipo_parque;
    EXEC Parques.SP_Borrar_Tipo_Parque @id_tipo_parque=@id_tipo_parque;
    SELECT COUNT(*) AS tipos_parque_despues FROM Parques.Tipo_parque;            -- baja en 1
    SELECT COUNT(*) AS debe_ser_cero FROM Parques.Tipo_parque
        WHERE id_tipo_parque = @id_tipo_parque;                                  -- ya no existe
 
    -- (2) Tipo_actividad: alta + baja
    EXEC Actividades.SP_AgregarTipoActividad @descripcion='Avistaje',
         @id_tipo_actividad=@id_tipo_actividad OUTPUT;
    EXEC Actividades.SP_Borrar_Tipo_Actividad @id_tipo_actividad=@id_tipo_actividad;
    SELECT COUNT(*) AS tipo_act_debe_ser_cero FROM Actividades.Tipo_actividad
        WHERE id_tipo_actividad = @id_tipo_actividad;
 
    -- (3) Tipo_visitante: alta + baja
    EXEC Comercial.SP_AgregarTipoVisitante @descripcion='Jubilado',
         @id_tipo_visitante=@id_tipo_visitante OUTPUT;
    EXEC Comercial.SP_Borrar_Tipo_visitante @id_tipo_visitante=@id_tipo_visitante;
    SELECT COUNT(*) AS tipo_vis_debe_ser_cero FROM Comercial.Tipo_visitante
        WHERE id_tipo_visitante = @id_tipo_visitante;
 
    -- (4) Punto_de_venta: alta + baja
    EXEC Comercial.SP_AgregarPuntoDeVenta @descripcion='Boleteria Norte',
         @id_punto_de_venta=@id_punto OUTPUT;
    EXEC Comercial.SP_Borrar_Punto_de_venta @id_punto_de_venta=@id_punto;
    SELECT COUNT(*) AS punto_debe_ser_cero FROM Comercial.Punto_de_venta
        WHERE id_punto_de_venta = @id_punto;
 
    -- (5) Forma_de_pago: alta + baja
    EXEC Comercial.SP_AgregarFormaDePago @descripcion='Tarjeta',
         @id_forma_de_pago=@id_forma OUTPUT;
    EXEC Comercial.SP_Borrar_Forma_de_pago @id_forma_de_pago=@id_forma;
    SELECT COUNT(*) AS forma_debe_ser_cero FROM Comercial.Forma_de_pago
        WHERE id_forma_de_pago = @id_forma;
 
    -- (6) Estado_concesion: alta + baja
    EXEC Concesiones.SP_AgregarEstadoConcesion @descripcion='Suspendida',
         @id_estado_concesion=@id_estado_concesion OUTPUT;
    EXEC Concesiones.SP_Borrar_Estado_concesion @id_estado_concesion=@id_estado_concesion;
    SELECT COUNT(*) AS est_conc_debe_ser_cero FROM Concesiones.Estado_concesion
        WHERE id_estado_concesion = @id_estado_concesion;
 
    -- (7) Estado_pago: alta + baja
    EXEC Concesiones.SP_AgregarEstadoPago @descripcion='Vencido',
         @id_estado_pago=@id_estado_pago OUTPUT;
    EXEC Concesiones.SP_Borrar_Estado_pago @id_estado_pago=@id_estado_pago;
    SELECT COUNT(*) AS est_pago_debe_ser_cero FROM Concesiones.Estado_pago
        WHERE id_estado_pago = @id_estado_pago;
 
    -- (8) Ubicacion: alta + baja (sin parque vinculado, debe poder Borrarse)
    EXEC Parques.SP_AgregarUbicacion @provincia='Cordoba', @region='Sierras Chicas',
         @latitud=-31.0, @longitud=-64.3, @id_ubicacion=@id_ubicacion OUTPUT;
    EXEC Parques.SP_Borrar_Ubicacion @id_ubicacion=@id_ubicacion;
    SELECT COUNT(*) AS ubic_debe_ser_cero FROM Parques.Ubicacion
        WHERE id_ubicacion = @id_ubicacion;
 
    PRINT 'OK: las bajas exitosas se ejecutaron (cada conteo tiene que dar 0).';
    ROLLBACK;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    PRINT 'FALLO INESPERADO EN PARTE 1: ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO
PRINT '';
PRINT 'BAJAS BLOQUEADAS / INEXISTENTES';
GO

-- (1) Borrar inexistente: id que no existe -> "no existe ..."
BEGIN TRY
    EXEC Parques.SP_Borrar_Tipo_Parque @id_tipo_parque=999999;
    PRINT '(1) FALLO DEL TEST: se esperaba error por tipo de parque inexistente';
END TRY
BEGIN CATCH PRINT '(1) OK: ' + ERROR_MESSAGE(); END CATCH
GO

-- (2) Ubicacion con parque vinculado -> no se puede borrar
BEGIN TRAN;
BEGIN TRY
    DECLARE @id_ubicacion int, @id_tipo_parque int, @id_parque int;
    EXEC Parques.SP_AgregarUbicacion @provincia='Rio Negro', @region='Andina',
         @latitud=-41.1, @longitud=-71.3, @id_ubicacion=@id_ubicacion OUTPUT;
    EXEC Parques.SP_AgregarTipoParque @descripcion='Reserva', @id_tipo_parque=@id_tipo_parque OUTPUT;
    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='Los Arrayanes', @superficie=1700, @id_parque_nuevo=@id_parque OUTPUT;
    -- intento borrar la ubicacion con el parque colgando -> debe frenar
    EXEC Parques.SP_Borrar_Ubicacion @id_ubicacion=@id_ubicacion;
    PRINT '(2) FALLO DEL TEST: se esperaba bloqueo por parque vinculado';
END TRY
BEGIN CATCH PRINT '(2) OK: ' + ERROR_MESSAGE(); END CATCH
IF @@TRANCOUNT > 0 ROLLBACK;
GO

-- (3) Tipo_parque con parque vinculado -> no se puede borrar
BEGIN TRAN;
BEGIN TRY
    DECLARE @id_ubicacion int, @id_tipo_parque int, @id_parque int;
    EXEC Parques.SP_AgregarUbicacion @provincia='Chubut', @region='Cordillera',
         @latitud=-42.9, @longitud=-71.3, @id_ubicacion=@id_ubicacion OUTPUT;
    EXEC Parques.SP_AgregarTipoParque @descripcion='Parque Nacional', @id_tipo_parque=@id_tipo_parque OUTPUT;
    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='Los Alerces', @superficie=2630, @id_parque_nuevo=@id_parque OUTPUT;
    EXEC Parques.SP_Borrar_Tipo_Parque @id_tipo_parque=@id_tipo_parque;
    PRINT '(3) FALLO DEL TEST: se esperaba bloqueo por parque vinculado';
END TRY
BEGIN CATCH PRINT '(3) OK: ' + ERROR_MESSAGE(); END CATCH
IF @@TRANCOUNT > 0 ROLLBACK;
GO

-- (4) Tipo_actividad con actividad vinculada -> no se puede borrar
BEGIN TRAN;
BEGIN TRY
    DECLARE @id_ubicacion int, @id_tipo_parque int, @id_parque int, @id_tipo_actividad int, @id_actividad int;
    EXEC Parques.SP_AgregarUbicacion @provincia='Misiones', @region='Selva',
         @latitud=-25.6, @longitud=-54.5, @id_ubicacion=@id_ubicacion OUTPUT;
    EXEC Parques.SP_AgregarTipoParque @descripcion='Parque Nacional', @id_tipo_parque=@id_tipo_parque OUTPUT;
    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='Iguazu', @superficie=6700, @id_parque_nuevo=@id_parque OUTPUT;
    EXEC Actividades.SP_AgregarTipoActividad @descripcion='Excursion', @id_tipo_actividad=@id_tipo_actividad OUTPUT;
    EXEC Actividades.SP_AgregarActividad @id_tipo_actividad=@id_tipo_actividad, @id_parque=@id_parque,
         @nombre='Paseo Garganta', @duracion_minutos=120, @cupo_maximo=30, @costo=800,
         @id_actividad=@id_actividad OUTPUT;
    EXEC Actividades.SP_Borrar_Tipo_Actividad @id_tipo_actividad=@id_tipo_actividad;
    PRINT '(4) FALLO DEL TEST: se esperaba bloqueo por actividad vinculada';
END TRY
BEGIN CATCH PRINT '(4) OK: ' + ERROR_MESSAGE(); END CATCH
IF @@TRANCOUNT > 0 ROLLBACK;
GO

-- (5) Tipo_visitante con tarifario vinculado -> no se puede borrar
BEGIN TRAN;
BEGIN TRY
    DECLARE @id_ubicacion int, @id_tipo_parque int, @id_parque int, @id_tipo_visitante int, @id_tarifario int;
    EXEC Parques.SP_AgregarUbicacion @provincia='Jujuy', @region='Puna',
         @latitud=-23.6, @longitud=-65.4, @id_ubicacion=@id_ubicacion OUTPUT;
    EXEC Parques.SP_AgregarTipoParque @descripcion='Reserva', @id_tipo_parque=@id_tipo_parque OUTPUT;
    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='Calilegua', @superficie=760, @id_parque_nuevo=@id_parque OUTPUT;
    EXEC Comercial.SP_AgregarTipoVisitante @descripcion='Extranjero', @id_tipo_visitante=@id_tipo_visitante OUTPUT;
    EXEC Comercial.SP_AgregarTarifarioParque @id_parque=@id_parque, @id_tipo_visitante=@id_tipo_visitante,
         @precio_actual=2000, @id_tarifario=@id_tarifario OUTPUT;
    EXEC Comercial.SP_Borrar_Tipo_visitante @id_tipo_visitante=@id_tipo_visitante;
    PRINT '(5) FALLO DEL TEST: se esperaba bloqueo por tarifario vinculado';
END TRY
BEGIN CATCH PRINT '(5) OK: ' + ERROR_MESSAGE(); END CATCH
IF @@TRANCOUNT > 0 ROLLBACK;
GO

-- (6) Estado_pago con pago vinculado -> no se puede borrar
BEGIN TRAN;
BEGIN TRY
    DECLARE @id_ubicacion int, @id_tipo_parque int, @id_parque int, @id_empresa int,
            @id_estado_concesion int, @id_estado_pago int, @id_concesion int, @id_pago int;
    EXEC Parques.SP_AgregarUbicacion @provincia='Mendoza', @region='Cuyo',
         @latitud=-32.9, @longitud=-68.8, @id_ubicacion=@id_ubicacion OUTPUT;
    EXEC Parques.SP_AgregarTipoParque @descripcion='Parque Provincial', @id_tipo_parque=@id_tipo_parque OUTPUT;
    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='Aconcagua', @superficie=710, @id_parque_nuevo=@id_parque OUTPUT;
    EXEC Concesiones.SP_AgregarEmpresa @razon_social='Refugios SA', @cuit='30717778889',
         @rubro_principal='Hoteleria', @id_empresa=@id_empresa OUTPUT;
    EXEC Concesiones.SP_AgregarEstadoConcesion @descripcion='Vigente', @id_estado_concesion=@id_estado_concesion OUTPUT;
    EXEC Concesiones.SP_AgregarEstadoPago @descripcion='Pagado', @id_estado_pago=@id_estado_pago OUTPUT;
    EXEC Concesiones.SP_AgregarConcesion @id_estado_concesion=@id_estado_concesion, @id_parque=@id_parque,
         @id_empresa=@id_empresa, @fecha_inicio='2025-01-01', @fecha_fin='2026-01-01',
         @monto_alquiler=40000, @id_concesion=@id_concesion OUTPUT;
    EXEC Concesiones.SP_AgregarPagoCanon @id_concesion=@id_concesion, @id_estado_pago=@id_estado_pago,
         @fecha_pago='2025-02-01', @monto=40000, @periodo_mes=2, @periodo_anio=2025,
         @id_pago=@id_pago OUTPUT;
    EXEC Concesiones.SP_Borrar_Estado_pago @id_estado_pago=@id_estado_pago;
    PRINT '(6) FALLO DEL TEST: se esperaba bloqueo por pago vinculado';
END TRY
BEGIN CATCH PRINT '(6) OK: ' + ERROR_MESSAGE(); END CATCH
IF @@TRANCOUNT > 0 ROLLBACK;
GO



---------
--Test Modificaciones
---------

PRINT 'MODIFICACIONES EXITOSAS';
 
DECLARE @id_ubicacion int, @id_tipo_parque int, @id_parque int,
        @id_tipo_visitante int, @id_tarifario int, @id_empresa int,
        @id_guardaparque int, @id_tipo_actividad int, @id_actividad int;
 
BEGIN TRY
    BEGIN TRAN;
 
    -- (1) Tipo_parque: cambia la descripcion
    EXEC Parques.SP_AgregarTipoParque @descripcion='Reserva', @id_tipo_parque=@id_tipo_parque OUTPUT;
    SELECT descripcion AS tipo_parque_antes FROM Parques.Tipo_parque WHERE id_tipo_parque=@id_tipo_parque;
    EXEC Parques.SP_Modificar_Tipo_parque @id_tipo_parque=@id_tipo_parque, @descripcion='Reserva Natural';
    SELECT descripcion AS tipo_parque_despues FROM Parques.Tipo_parque WHERE id_tipo_parque=@id_tipo_parque;
 
    -- (2) Ubicacion: cambia provincia y region (update parcial: solo lo que se pasa)
    EXEC Parques.SP_AgregarUbicacion @provincia='Cordoba', @region='Sierras',
         @latitud=-31.0, @longitud=-64.3, @id_ubicacion=@id_ubicacion OUTPUT;
    SELECT provincia, region AS region_antes FROM Parques.Ubicacion WHERE id_ubicacion=@id_ubicacion;
    EXEC Parques.SP_Modificar_Ubicacion @id_ubicacion=@id_ubicacion, @region='Sierras Grandes';
    SELECT provincia, region AS region_despues FROM Parques.Ubicacion WHERE id_ubicacion=@id_ubicacion;
 
    -- (3) Parque_nacional: cambia nombre y superficie
    EXEC Parques.SP_AgregarTipoParque @descripcion='Parque Nacional', @id_tipo_parque=@id_tipo_parque OUTPUT;
    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='Quebrada', @superficie=1000, @id_parque_nuevo=@id_parque OUTPUT;
    SELECT nombre AS parque_antes, superficie FROM Parques.Parque_nacional WHERE id_parque=@id_parque;
    EXEC Parques.SP_Modificar_Parque_nacional @id_parque=@id_parque,
         @nombre='Quebrada del Condorito', @superficie=1250.50;
    SELECT nombre AS parque_despues, superficie FROM Parques.Parque_nacional WHERE id_parque=@id_parque;
 
    -- (4) Guardaparque: cambia datos personales
    EXEC Parques.SP_AgregarGuardaparque @dni='31222333', @nombre='Carlos', @apellido='Ruiz',
         @fecha_ingreso='2019-05-01', @estado='Activo', @id_guardaparque=@id_guardaparque OUTPUT;
    SELECT nombre AS gp_antes, apellido FROM Parques.Guardaparque WHERE id_guardaparque=@id_guardaparque;
    EXEC Parques.SP_Modificar_Datos_Guardaparque @id_guardaparque=@id_guardaparque,
         @dni='31222333', @nombre='Carlos Alberto', @apellido='Ruiz Diaz';
    SELECT nombre AS gp_despues, apellido FROM Parques.Guardaparque WHERE id_guardaparque=@id_guardaparque;
 
    -- (5) Tarifario_parque: cambia el precio
    EXEC Comercial.SP_AgregarTipoVisitante @descripcion='Residente', @id_tipo_visitante=@id_tipo_visitante OUTPUT;
    EXEC Comercial.SP_AgregarTarifarioParque @id_parque=@id_parque, @id_tipo_visitante=@id_tipo_visitante,
         @precio_actual=1500, @id_tarifario=@id_tarifario OUTPUT;
    SELECT precio_actual AS precio_antes FROM Comercial.Tarifario_parque
        WHERE id_parque=@id_parque AND id_tipo_visitante=@id_tipo_visitante;
    EXEC Comercial.SP_Modificar_Tarifario_parque @id_parque=@id_parque,
         @id_tipo_visitante=@id_tipo_visitante, @precio_actual=1800;
    SELECT precio_actual AS precio_despues FROM Comercial.Tarifario_parque
        WHERE id_parque=@id_parque AND id_tipo_visitante=@id_tipo_visitante;
 
    -- (6) Actividad: cambia nombre y costo (update parcial con FK validadas)
    EXEC Actividades.SP_AgregarTipoActividad @descripcion='Tour', @id_tipo_actividad=@id_tipo_actividad OUTPUT;
    EXEC Actividades.SP_AgregarActividad @id_tipo_actividad=@id_tipo_actividad, @id_parque=@id_parque,
         @nombre='Caminata', @duracion_minutos=90, @cupo_maximo=15, @costo=400,
         @id_actividad=@id_actividad OUTPUT;
    SELECT nombre AS act_antes, costo FROM Actividades.Actividad WHERE id_actividad=@id_actividad;
    EXEC Actividades.SP_Modificar_Actividad @id_actividad=@id_actividad,
         @nombre='Caminata Interpretativa', @costo=600;
    SELECT nombre AS act_despues, costo FROM Actividades.Actividad WHERE id_actividad=@id_actividad;
 
    -- (7) Empresa: cambia razon social y rubro
    EXEC Concesiones.SP_AgregarEmpresa @razon_social='Sur SA', @cuit='30766554433',
         @rubro_principal='Comercio', @id_empresa=@id_empresa OUTPUT;
    SELECT razon_social AS emp_antes, rubro_principal FROM Concesiones.Empresa WHERE id_empresa=@id_empresa;
    EXEC Concesiones.SP_Modificar_Empresa @id_empresa=@id_empresa,
         @razon_social='Sur Servicios SA', @cuit='30766554433', @rubro_principal='Gastronomia';
    SELECT razon_social AS emp_despues, rubro_principal FROM Concesiones.Empresa WHERE id_empresa=@id_empresa;
 
    PRINT 'OK: las modificaciones exitosas se ejecutaron (comparar cada "antes" vs "despues").';
    ROLLBACK;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    PRINT 'FALLO INESPERADO EN PARTE 1: ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO
 

PRINT '';
PRINT 'VALIDACIONES (deben fallar)';
 
DECLARE @dummy int;
 
-- (1) Modificar un id inexistente
BEGIN TRY
    EXEC Parques.SP_Modificar_Tipo_parque @id_tipo_parque=999999, @descripcion='X';
    PRINT '(1) FALLO DEL TEST: se esperaba error por id inexistente';
END TRY
BEGIN CATCH PRINT '(1) OK:' + ERROR_MESSAGE(); END CATCH
 
-- (2) Tarifario: precio negativo
BEGIN TRY
    EXEC Comercial.SP_Modificar_Tarifario_parque @id_parque=999999,
         @id_tipo_visitante=999999, @precio_actual=-100;
    PRINT '(2) FALLO DEL TEST: se esperaba error por tarifario inexistente o precio negativo';
END TRY
BEGIN CATCH PRINT '(2) OK: ' + ERROR_MESSAGE(); END CATCH
 
-- (3) Actividad: FK tipo_actividad inexistente al modificar
BEGIN TRY
    EXEC Actividades.SP_Modificar_Actividad @id_actividad=999999, @id_tipo_actividad=999999;
    PRINT '(3) FALLO DEL TEST: se esperaba error por actividad/FK inexistente';
END TRY
BEGIN CATCH PRINT '(3) OK: ' + ERROR_MESSAGE(); END CATCH
 
-- (4) Concesion: fecha_inicio posterior a fecha_fin
BEGIN TRY
    EXEC Concesiones.SP_Modificar_Datos_Concesion @id_concesion=999999,
         @fecha_inicio='2026-01-01', @fecha_fin='2025-01-01';
    PRINT '(4) FALLO DEL TEST: se esperaba error por id inexistente o rango de fechas';
END TRY
BEGIN CATCH PRINT '(4) OK: ' + ERROR_MESSAGE(); END CATCH
 
-- (5) Empresa: CUIT duplicado contra OTRA empresa (clave unica, excluir self)
--     Se crean dos empresas y se intenta ponerle a la segunda el CUIT de la primera.
BEGIN TRAN;
BEGIN TRY
    DECLARE @e1 int, @e2 int;
    EXEC Concesiones.SP_AgregarEmpresa @razon_social='Empresa Uno', @cuit='30111111119',
         @rubro_principal='Comercio', @id_empresa=@e1 OUTPUT;
    EXEC Concesiones.SP_AgregarEmpresa @razon_social='Empresa Dos', @cuit='30222222227',
         @rubro_principal='Comercio', @id_empresa=@e2 OUTPUT;
    -- intento dejar la Empresa Dos con el CUIT de la Uno -> debe fallar
    EXEC Concesiones.SP_Modificar_Empresa @id_empresa=@e2,
         @razon_social='Empresa Dos', @cuit='30111111119', @rubro_principal='Comercio';
    PRINT '(5) FALLO DEL TEST: se esperaba error por CUIT duplicado';
END TRY
BEGIN CATCH PRINT '(5) OK: ' + ERROR_MESSAGE(); END CATCH
IF @@TRANCOUNT > 0 ROLLBACK;
 
-- (6) Guardaparque: DNI duplicado contra OTRO guardaparque (excluir self)
BEGIN TRAN;
BEGIN TRY
    DECLARE @g1 int, @g2 int;
    EXEC Parques.SP_AgregarGuardaparque @dni='32100100', @nombre='Luis', @apellido='Gomez',
         @fecha_ingreso='2020-01-01', @estado='Activo', @id_guardaparque=@g1 OUTPUT;
    EXEC Parques.SP_AgregarGuardaparque @dni='32200200', @nombre='Mario', @apellido='Sosa',
         @fecha_ingreso='2020-01-01', @estado='Activo', @id_guardaparque=@g2 OUTPUT;
    -- intento dejar el segundo con el DNI del primero -> debe fallar
    EXEC Parques.SP_Modificar_Datos_Guardaparque @id_guardaparque=@g2,
         @dni='32100100', @nombre='Mario', @apellido='Sosa';
    PRINT '(6) FALLO DEL TEST: se esperaba error por DNI duplicado';
END TRY
BEGIN CATCH PRINT '(6) OK: ' + ERROR_MESSAGE(); END CATCH
IF @@TRANCOUNT > 0 ROLLBACK;
GO






-------
--Test logica de negocio
-------

PRINT 'A) VENTA MULTI-ITEM';
BEGIN TRAN;
BEGIN TRY
    DECLARE @id_ubicacion int, @id_tipo_parque int, @id_parque int, @id_tipo_visitante int, @id_tarifario int,
            @id_tipo_actividad int, @id_actividad int, @id_turno int, @id_punto_venta int, @id_forma_pago int, @id_venta int,
            @fecha_turno date = DATEADD(DAY,7,CAST(GETDATE() AS DATE));
 

    EXEC Parques.SP_AgregarUbicacion @provincia='Neuquen', @region='Andina',
         @latitud=-40.7, @longitud=-71.6, @id_ubicacion=@id_ubicacion OUTPUT;

    EXEC Parques.SP_AgregarTipoParque @descripcion='Parque Nacional', @id_tipo_parque=@id_tipo_parque OUTPUT;

    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='Lanin', @superficie=3790, @id_parque_nuevo=@id_parque OUTPUT;

    EXEC Comercial.SP_AgregarTipoVisitante @descripcion='Residente', @id_tipo_visitante=@id_tipo_visitante OUTPUT;

    EXEC Comercial.SP_AgregarTarifarioParque @id_parque=@id_parque, @id_tipo_visitante=@id_tipo_visitante,
         @precio_actual=1000, @id_tarifario=@id_tarifario OUTPUT;

    EXEC Actividades.SP_AgregarTipoActividad @descripcion='Tour', @id_tipo_actividad=@id_tipo_actividad OUTPUT;

    EXEC Actividades.SP_AgregarActividad @id_tipo_actividad=@id_tipo_actividad, @id_parque=@id_parque,
         @nombre='Ascenso', @duracion_minutos=240, @cupo_maximo=10, @costo=2500,
         @id_actividad=@id_actividad OUTPUT;

    EXEC Actividades.SP_AgregarTurnoActividad @id_actividad=@id_actividad,
         @fecha=@fecha_turno, @hora_inicio='08:00', @id_turno=@id_turno OUTPUT;

    EXEC Comercial.SP_AgregarPuntoDeVenta @descripcion='Boleteria', @id_punto_de_venta=@id_punto_venta OUTPUT;

    EXEC Comercial.SP_AgregarFormaDePago @descripcion='Efectivo', @id_forma_de_pago=@id_forma_pago OUTPUT;

 
    DECLARE @items Comercial.TipoItemsVenta;
    INSERT INTO @items (tipo_item, id_parque, id_tipo_visitante, fecha_acceso, id_turno, cantidad)
    VALUES ('Entrada', @id_parque, @id_tipo_visitante, NULL, NULL, 2),
           ('Ticket',  NULL, NULL, NULL, @id_turno, 1);
 
    EXEC Comercial.SP_RegistrarVenta @items=@items, @id_punto_de_venta=@id_punto_venta,
         @id_forma_de_pago=@id_forma_pago, @numero_factura='A-0001', @id_venta_generada=@id_venta OUTPUT;
 
    
    SELECT @id_venta AS id_venta_generada;
    SELECT id_venta, numero_factura, total FROM Comercial.Venta WHERE id_venta=@id_venta;
    SELECT id_detalle_venta, id_item, subtotal FROM Comercial.Detalle_venta WHERE id_venta=@id_venta;
    SELECT total AS total_cabecera,
           (SELECT SUM(subtotal) FROM Comercial.Detalle_venta WHERE id_venta=@id_venta) AS suma_subtotales,
           CASE WHEN total = (SELECT SUM(subtotal) FROM Comercial.Detalle_venta WHERE id_venta=@id_venta)
                THEN 'OK: total = suma de subtotales' ELSE 'ERROR: no coinciden' END AS verificacion
    FROM Comercial.Venta WHERE id_venta=@id_venta;
    
END TRY
BEGIN CATCH PRINT 'FALLO INESPERADO EN A: ' + ERROR_MESSAGE(); END CATCH
IF @@TRANCOUNT > 0 ROLLBACK;
GO
 
-- ============================================================================
-- B) SP_RegistrarVenta: TOUR CON CUPO COMPLETO (caso obligatorio)
--    Turno con cupo_maximo=2; se piden 3 tickets -> debe rechazar y NO dejar venta.
-- ============================================================================
PRINT '';
PRINT 'B) CUPO COMPLETO';
BEGIN TRAN;
BEGIN TRY
    DECLARE @id_ubicacion int, @id_tipo_parque int, @id_parque int, @id_tipo_actividad int, @id_actividad int, @id_turno int, @id_punto_venta int, @id_forma_pago int, @id_venta int,
            @fecha_turno date = DATEADD(DAY,7,CAST(GETDATE() AS DATE));

    EXEC Parques.SP_AgregarUbicacion @provincia='Salta', @region='Norte',
         @latitud=-24.7, @longitud=-65.4, @id_ubicacion=@id_ubicacion OUTPUT;

    EXEC Parques.SP_AgregarTipoParque @descripcion='Parque Nacional', @id_tipo_parque=@id_tipo_parque OUTPUT;

    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='El Rey', @superficie=440, @id_parque_nuevo=@id_parque OUTPUT;

    EXEC Actividades.SP_AgregarTipoActividad @descripcion='Tour', @id_tipo_actividad=@id_tipo_actividad OUTPUT;

    -- cupo_maximo = 2
    EXEC Actividades.SP_AgregarActividad @id_tipo_actividad=@id_tipo_actividad, @id_parque=@id_parque,
         @nombre='Safari', @duracion_minutos=120, @cupo_maximo=2, @costo=1500, @id_actividad=@id_actividad OUTPUT;
         
    EXEC Actividades.SP_AgregarTurnoActividad @id_actividad=@id_actividad,
         @fecha=@fecha_turno, @hora_inicio='10:00', @id_turno=@id_turno OUTPUT;

    EXEC Comercial.SP_AgregarPuntoDeVenta @descripcion='Boleteria', @id_punto_de_venta=@id_punto_venta OUTPUT;

    EXEC Comercial.SP_AgregarFormaDePago @descripcion='Efectivo', @id_forma_de_pago=@id_forma_pago OUTPUT;
 
    -- pido 3 tickets de un turno con cupo 2
    DECLARE @items Comercial.TipoItemsVenta;
    INSERT INTO @items (tipo_item, id_turno, cantidad)
    VALUES ('Ticket', @id_turno, 3);
 
    EXEC Comercial.SP_RegistrarVenta @items=@items, @id_punto_de_venta=@id_punto_venta,
         @id_forma_de_pago=@id_forma_pago, @numero_factura='B-0001', @id_venta_generada=@id_venta OUTPUT;

    PRINT '(B) FALLO DEL TEST: se esperaba rechazo por cupo completo';
END TRY
BEGIN CATCH
    PRINT '(B) OK (esperado): ' + ERROR_MESSAGE();
    -- evidencia de atomicidad: no debe haber quedado la venta B-0001
    IF NOT EXISTS (SELECT 1 FROM Comercial.Venta WHERE numero_factura='B-0001')
        PRINT '(B) OK: la venta no quedo registrada (rollback interno del SP)';
END CATCH
IF @@TRANCOUNT > 0 ROLLBACK;
GO
 
-- ============================================================================
-- C) SP_RegistrarVenta: ATOMICIDAD
--    Renglon 1 valido (entrada) + renglon 2 invalido (turno inexistente).
--    Debe deshacerse la venta ENTERA: ni cabecera ni el primer item.
-- ============================================================================
PRINT '';
PRINT 'ATOMICIDAD';
BEGIN TRAN;
BEGIN TRY
    DECLARE @id_ubicacion int, @id_tipo_parque int, @id_parque int, @id_tipo_visitante int, @id_tarifario int, @id_punto_venta int, @id_forma_pago int, @id_venta int;

    EXEC Parques.SP_AgregarUbicacion @provincia='Chubut', @region='Sur',
         @latitud=-42.9, @longitud=-71.3, @id_ubicacion=@id_ubicacion OUTPUT;

    EXEC Parques.SP_AgregarTipoParque @descripcion='Parque Nacional', @id_tipo_parque=@id_tipo_parque OUTPUT;

    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='Lago Puelo', @superficie=270, @id_parque_nuevo=@id_parque OUTPUT;

    EXEC Comercial.SP_AgregarTipoVisitante @descripcion='Residente', @id_tipo_visitante=@id_tipo_visitante OUTPUT;

    EXEC Comercial.SP_AgregarTarifarioParque @id_parque=@id_parque, @id_tipo_visitante=@id_tipo_visitante,
         @precio_actual=1000, @id_tarifario=@id_tarifario OUTPUT;
         
    EXEC Comercial.SP_AgregarPuntoDeVenta @descripcion='Boleteria', @id_punto_de_venta=@id_punto_venta OUTPUT;

    EXEC Comercial.SP_AgregarFormaDePago @descripcion='Efectivo', @id_forma_de_pago=@id_forma_pago OUTPUT;
 
    -- renglon 1 OK, renglon 2 con turno inexistente (999999)
    DECLARE @items Comercial.TipoItemsVenta;
    INSERT INTO @items (tipo_item, id_parque, id_tipo_visitante, id_turno, cantidad)
    VALUES ('Entrada', @id_parque, @id_tipo_visitante, NULL, 1),
           ('Ticket',  NULL, NULL, 999999, 1);
 
    EXEC Comercial.SP_RegistrarVenta @items=@items, @id_punto_de_venta=@id_punto_venta,
         @id_forma_de_pago=@id_forma_pago, @numero_factura='C-0001', @id_venta_generada=@id_venta OUTPUT;

    PRINT '(C) FALLO DEL TEST: se esperaba rechazo por turno inexistente';
END TRY
BEGIN CATCH
    PRINT '(C) OK (esperado): ' + ERROR_MESSAGE();
    -- la prueba clave de atomicidad: NO debe existir la venta NI la entrada del renglon 1
    IF NOT EXISTS (SELECT 1 FROM Comercial.Venta WHERE numero_factura='C-0001')
        PRINT '(C) OK: la cabecera no quedo (venta deshecha entera)';
END CATCH
IF @@TRANCOUNT > 0 ROLLBACK;
GO
 
-- ============================================================================
-- D) SP_RegistrarVenta: numero_factura duplicado
-- ============================================================================
PRINT '';
PRINT 'D) FACTURA DUPLICADA';
BEGIN TRAN;
BEGIN TRY
    DECLARE @id_ubicacion int, @id_tipo_parque int, @id_parque int, @id_tipo_visitante int, @id_tarifario int, @id_punto_venta int, @id_forma_pago int, @id_venta_1 int, @id_venta_2 int;
    EXEC Parques.SP_AgregarUbicacion @provincia='Rio Negro', @region='Andina',
         @latitud=-41.1, @longitud=-71.3, @id_ubicacion=@id_ubicacion OUTPUT;

    EXEC Parques.SP_AgregarTipoParque @descripcion='Parque Nacional', @id_tipo_parque=@id_tipo_parque OUTPUT;

    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='Nahuel Huapi', @superficie=7050, @id_parque_nuevo=@id_parque OUTPUT;

    EXEC Comercial.SP_AgregarTipoVisitante @descripcion='Residente', @id_tipo_visitante=@id_tipo_visitante OUTPUT;
    
    EXEC Comercial.SP_AgregarTarifarioParque @id_parque=@id_parque, @id_tipo_visitante=@id_tipo_visitante,
         @precio_actual=1000, @id_tarifario=@id_tarifario OUTPUT;

    EXEC Comercial.SP_AgregarPuntoDeVenta @descripcion='Boleteria', @id_punto_de_venta=@id_punto_venta OUTPUT;

    EXEC Comercial.SP_AgregarFormaDePago @descripcion='Efectivo', @id_forma_de_pago=@id_forma_pago OUTPUT;
 
    DECLARE @items Comercial.TipoItemsVenta;
    INSERT INTO @items (tipo_item, id_parque, id_tipo_visitante, cantidad)
    VALUES ('Entrada', @id_parque, @id_tipo_visitante, 1);
 
    -- primera venta OK
    EXEC Comercial.SP_RegistrarVenta @items=@items, @id_punto_de_venta=@id_punto_venta,
         @id_forma_de_pago=@id_forma_pago, @numero_factura='D-0001', @id_venta_generada=@id_venta_1 OUTPUT;
         
    -- segunda con el MISMO numero_factura -> debe fallar
    EXEC Comercial.SP_RegistrarVenta @items=@items, @id_punto_de_venta=@id_punto_venta,
         @id_forma_de_pago=@id_forma_pago, @numero_factura='D-0001', @id_venta_generada=@id_venta_2 OUTPUT;

    PRINT '(D) FALLO DEL TEST: se esperaba rechazo por factura duplicada';
END TRY
BEGIN CATCH PRINT '(D) OK (esperado): ' + ERROR_MESSAGE(); END CATCH
IF @@TRANCOUNT > 0 ROLLBACK;
GO
 
-- ============================================================================
-- E) SP_AsignarGuiaConValidacion: autorizacion VENCIDA (debe fallar)
-- ============================================================================
PRINT '';
PRINT 'E) GUIA CON AUTORIZACION VENCIDA';
BEGIN TRAN;
BEGIN TRY
    DECLARE @id_ubicacion int, @id_tipo_parque int, @id_parque int, @id_tipo_actividad int, @id_actividad int, @id_guia int,
            @hoy date = CAST(GETDATE() AS DATE);
    EXEC Parques.SP_AgregarUbicacion @provincia='Cordoba', @region='Sierras',
         @latitud=-31.0, @longitud=-64.3, @id_ubicacion=@id_ubicacion OUTPUT;

    EXEC Parques.SP_AgregarTipoParque @descripcion='Reserva', @id_tipo_parque=@id_tipo_parque OUTPUT;

    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='Condorito', @superficie=370, @id_parque_nuevo=@id_parque OUTPUT;

    EXEC Actividades.SP_AgregarTipoActividad @descripcion='Tour', @id_tipo_actividad=@id_tipo_actividad OUTPUT;

    EXEC Actividades.SP_AgregarActividad @id_tipo_actividad=@id_tipo_actividad, @id_parque=@id_parque,
         @nombre='Avistaje', @duracion_minutos=90, @cupo_maximo=10, @costo=500, @id_actividad=@id_actividad OUTPUT;

    -- guia con vigencia VENCIDA (fecha pasada)
    EXEC Actividades.SP_AgregarGuia @dni='25888777', @nombre='Raul', @apellido='Vera',
         @titulo='Guia', @especialidad='Aves', @vigencia_autorizacion='2020-01-01', @id_guia=@id_guia OUTPUT;

 
    EXEC Actividades.SP_AsignarGuiaConValidacion @id_guia=@id_guia, @id_actividad=@id_actividad,
         @fecha_asignacion=@hoy, @rol='Principal';
    PRINT '(E) FALLO DEL TEST: se esperaba rechazo por autorizacion vencida';
END TRY
BEGIN CATCH PRINT '(E) OK (esperado): ' + ERROR_MESSAGE(); END CATCH
IF @@TRANCOUNT > 0 ROLLBACK;
GO
 
-- ============================================================================
-- F) SP_AsignarGuiaConValidacion: asignacion OK (guia vigente)
-- ============================================================================
PRINT '';
PRINT 'F) ASIGNACION DE GUIA';
BEGIN TRAN;
BEGIN TRY
    DECLARE @id_ubicacion int, @id_tipo_parque int, @id_parque int, @id_tipo_actividad int, @id_actividad int, @id_guia int,
            @hoy date = CAST(GETDATE() AS DATE),
            @fecha_futura date = DATEADD(YEAR,1,CAST(GETDATE() AS DATE));

    EXEC Parques.SP_AgregarUbicacion @provincia='Tucuman', @region='Yungas',
         @latitud=-26.8, @longitud=-65.2, @id_ubicacion=@id_ubicacion OUTPUT;

    EXEC Parques.SP_AgregarTipoParque @descripcion='Parque Nacional', @id_tipo_parque=@id_tipo_parque OUTPUT;

    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='Campo de los Alisos', @superficie=100, @id_parque_nuevo=@id_parque OUTPUT;

    EXEC Actividades.SP_AgregarTipoActividad @descripcion='Tour', @id_tipo_actividad=@id_tipo_actividad OUTPUT;

    EXEC Actividades.SP_AgregarActividad @id_tipo_actividad=@id_tipo_actividad, @id_parque=@id_parque,
         @nombre='Sendero', @duracion_minutos=60, @cupo_maximo=10, @costo=300, @id_actividad=@id_actividad OUTPUT;

    EXEC Actividades.SP_AgregarGuia @dni='26777666', @nombre='Sofia', @apellido='Luna',
         @titulo='Guia', @especialidad='Flora',
         @vigencia_autorizacion=@fecha_futura, @id_guia=@id_guia OUTPUT;
 
    EXEC Actividades.SP_AsignarGuiaConValidacion @id_guia=@id_guia, @id_actividad=@id_actividad,
         @fecha_asignacion=@hoy, @rol='Principal';
    -- EVIDENCIA: la asignacion quedo registrada
    SELECT * FROM Actividades.Guias_por_actividad WHERE id_guia=@id_guia AND id_actividad=@id_actividad;
END TRY
BEGIN CATCH PRINT 'FALLO INESPERADO EN F: ' + ERROR_MESSAGE(); END CATCH
IF @@TRANCOUNT > 0 ROLLBACK;
GO
 
-- ============================================================================
-- G) SP_RegistrarPagoCanon: periodo ya pagado (debe fallar en el 2do pago)
-- ============================================================================
PRINT '';
PRINT 'G) PERIODO YA PAGADO';
BEGIN TRAN;
BEGIN TRY
    DECLARE @id_ubicacion int, @id_tipo_parque int, @id_parque int, @id_empresa int, @id_estado_concesion int, @id_estado_pago int, @id_concesion int, @id_pago_1 int, @id_pago_2 int;
    EXEC Parques.SP_AgregarUbicacion @provincia='Mendoza', @region='Cuyo',
         @latitud=-32.9, @longitud=-68.8, @id_ubicacion=@id_ubicacion OUTPUT;

    EXEC Parques.SP_AgregarTipoParque @descripcion='Parque Provincial', @id_tipo_parque=@id_tipo_parque OUTPUT;

    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='Aconcagua', @superficie=710, @id_parque_nuevo=@id_parque OUTPUT;

    EXEC Concesiones.SP_AgregarEmpresa @razon_social='Refugios SA', @cuit='30717778889',
         @rubro_principal='Hoteleria', @id_empresa=@id_empresa OUTPUT;

    EXEC Concesiones.SP_AgregarEstadoConcesion @descripcion='Vigente', @id_estado_concesion=@id_estado_concesion OUTPUT;

    EXEC Concesiones.SP_AgregarEstadoPago @descripcion='Pagado', @id_estado_pago=@id_estado_pago OUTPUT;

    EXEC Concesiones.SP_AgregarConcesion @id_estado_concesion=@id_estado_concesion, @id_parque=@id_parque,
         @id_empresa=@id_empresa, @fecha_inicio='2025-01-01', @fecha_fin='2026-01-01',
         @monto_alquiler=40000, @id_concesion=@id_concesion OUTPUT;

 
    -- primer pago del periodo 3/2025 -> OK
    EXEC Concesiones.SP_RegistrarPagoCanon @id_concesion=@id_concesion, @fecha_pago='2025-03-05',
         @monto=40000, @periodo_mes=3, @periodo_anio=2025, @id_pago_generado=@id_pago_1 OUTPUT;

    -- segundo pago del MISMO periodo -> debe fallar
    EXEC Concesiones.SP_RegistrarPagoCanon @id_concesion=@id_concesion, @fecha_pago='2025-03-10',
         @monto=40000, @periodo_mes=3, @periodo_anio=2025, @id_pago_generado=@id_pago_2 OUTPUT;

    PRINT '(G) FALLO DEL TEST: se esperaba rechazo por periodo ya pagado';
END TRY
BEGIN CATCH PRINT '(G) OK (esperado): ' + ERROR_MESSAGE(); END CATCH
IF @@TRANCOUNT > 0 ROLLBACK;
GO
 
-- ============================================================================
-- H) SP_ReasignarGuardaparque: cierra la asignacion vieja Y abre la nueva
-- ============================================================================
PRINT '';
PRINT 'H) REASIGNACION DE GUARDAPARQUE';
BEGIN TRAN;
BEGIN TRY
    DECLARE @id_ubicacion int, @id_tipo_parque int, @id_parque_a int, @id_parque_b int, @id_guardaparque int, @id_asignacion int,
            @hoy date = CAST(GETDATE() AS DATE);

    EXEC Parques.SP_AgregarUbicacion @provincia='Santa Cruz', @region='Patagonia',
         @latitud=-50.0, @longitud=-73.0, @id_ubicacion=@id_ubicacion OUTPUT;

    EXEC Parques.SP_AgregarTipoParque @descripcion='Parque Nacional', @id_tipo_parque=@id_tipo_parque OUTPUT;

    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='Los Glaciares', @superficie=7269, @id_parque_nuevo=@id_parque_a OUTPUT;

    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='Perito Moreno', @superficie=1150, @id_parque_nuevo=@id_parque_b OUTPUT;

    EXEC Parques.SP_AgregarGuardaparque @dni='33444555', @nombre='Diego', @apellido='Maza',
         @fecha_ingreso='2021-01-01', @estado='Activo', @id_guardaparque=@id_guardaparque OUTPUT;

    -- asignacion inicial al parque A (abierta)
    EXEC Parques.SP_AgregarGuardaparqueAParque @id_guardaparque=@id_guardaparque, @id_parque=@id_parque_a,
         @fecha_inicio='2021-01-10', @fecha_fin=NULL, @motivo_egreso='Asignacion inicial',
         @id_asignacion=@id_asignacion OUTPUT;
 
    PRINT 'Antes de reasignar:';
    SELECT id_parque, fecha_inicio, fecha_fin, motivo_egreso
    FROM Parques.Asignacion_guardaparque WHERE id_guardaparque=@id_guardaparque;
 
    -- reasignar al parque B
    EXEC Parques.SP_ReasignarGuardaparque @id_guardaparque=@id_guardaparque, @id_parque_nuevo=@id_parque_b,
         @fecha_reasignacion=@hoy;
 
    PRINT 'Despues de reasignar (debe haber 2 filas: la de A cerrada con fecha_fin, la de B abierta):';
    SELECT id_parque, fecha_inicio, fecha_fin, motivo_egreso
    FROM Parques.Asignacion_guardaparque WHERE id_guardaparque=@id_guardaparque ORDER BY fecha_inicio;
    -- evidencia puntual: 1 activa (fecha_fin NULL) y 1 cerrada
    SELECT
        SUM(CASE WHEN fecha_fin IS NULL THEN 1 ELSE 0 END) AS activas,
        SUM(CASE WHEN fecha_fin IS NOT NULL THEN 1 ELSE 0 END) AS cerradas
    FROM Parques.Asignacion_guardaparque WHERE id_guardaparque=@id_guardaparque;
END TRY
BEGIN CATCH PRINT 'FALLO INESPERADO EN H: ' + ERROR_MESSAGE(); END CATCH
IF @@TRANCOUNT > 0 ROLLBACK;
GO
 
-- ============================================================================
-- I) SP_RenovarConcesion: la nueva fecha NO extiende la actual (debe fallar)
-- ============================================================================
PRINT '';
PRINT 'I) RENOVACION CON FECHA INVALIDA';
BEGIN TRAN;
BEGIN TRY
    DECLARE @id_ubicacion int, @id_tipo_parque int, @id_parque int, @id_empresa int, @id_estado_concesion int, @id_concesion int;
    EXEC Parques.SP_AgregarUbicacion @provincia='Formosa', @region='Chaco',
         @latitud=-24.9, @longitud=-60.0, @id_ubicacion=@id_ubicacion OUTPUT;
    EXEC Parques.SP_AgregarTipoParque @descripcion='Reserva', @id_tipo_parque=@id_tipo_parque OUTPUT;
    EXEC Parques.SP_AgregarParque @id_Ubicacion=@id_ubicacion, @id_Tipo_parque=@id_tipo_parque,
         @nombre='Rio Pilcomayo', @superficie=520, @id_parque_nuevo=@id_parque OUTPUT;
    EXEC Concesiones.SP_AgregarEmpresa @razon_social='Kiosco SA', @cuit='30733444556',
         @rubro_principal='Comercio', @id_empresa=@id_empresa OUTPUT;
    EXEC Concesiones.SP_AgregarEstadoConcesion @descripcion='Vigente', @id_estado_concesion=@id_estado_concesion OUTPUT;
    -- concesion con fecha_fin 2026-12-31
    EXEC Concesiones.SP_AgregarConcesion @id_estado_concesion=@id_estado_concesion, @id_parque=@id_parque,
         @id_empresa=@id_empresa, @fecha_inicio='2025-01-01', @fecha_fin='2026-12-31',
         @monto_alquiler=30000, @id_concesion=@id_concesion OUTPUT;
 
    -- intento "renovar" a una fecha ANTERIOR a la actual -> debe fallar
    EXEC Concesiones.SP_RenovarConcesion @id_concesion=@id_concesion, @nueva_fecha_fin='2026-06-01';
    PRINT '(I) FALLO DEL TEST: se esperaba rechazo por fecha que no extiende';
END TRY
BEGIN CATCH PRINT '(I) OK (esperado): ' + ERROR_MESSAGE(); END CATCH
IF @@TRANCOUNT > 0 ROLLBACK;
GO
 
PRINT '';
PRINT '################ FIN DEL TESTING DE LOGICA DE NEGOCIO ################';
GO