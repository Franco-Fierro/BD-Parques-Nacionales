--Universidad Nacional de La Matanza
--MATERIA: BASES DE DATOS APLICADA
--GRUPO: 03
--FIERRO, FRANCO EZEQUIEL
--GISMONDI, FRANCISCO
--QUISPE BARJA, SERGIO DANIEL

--Objetivo: definir los stored procedures para el agregado de datos a la base de datos

USE COM5600_G03;
GO

--Agregar Parque Nacional

CREATE OR ALTER PROCEDURE Parques.SP_AgregarParque
    @id_Ubicacion    int,
    @id_Tipo_parque  int,
    @nombre          varchar(100),
    @superficie      decimal(12,2),
    @id_parque_nuevo int OUTPUT          
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores varchar(1000) = '';

    IF NOT EXISTS (SELECT 1 FROM Parques.Ubicacion WHERE id_ubicacion = @id_Ubicacion)
        SET @errores = @errores + 'La ubicación indicada no existe. ';

    IF NOT EXISTS (SELECT 1 FROM Parques.tipo_parque WHERE id_tipo_parque = @id_Tipo_parque)
        SET @errores = @errores + 'El tipo de parque indicado no existe. ';
    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errores = @errores + 'El nombre del parque no puede ser vacío. ';
    IF @superficie <= 0
        SET @errores = @errores + 'La superficie del parque debe ser un número positivo. ';
    
    IF @errores <> ''
        THROW 50001, @errores, 1;

    INSERT INTO Parques.Parque_nacional (id_ubicacion, id_Tipo_parque, nombre, superficie)
    VALUES (@id_Ubicacion, @id_Tipo_parque, @nombre, @superficie);
    SET @id_parque_nuevo = SCOPE_IDENTITY();
END
GO


--Agregar Ubicacion

CREATE OR ALTER PROCEDURE Parques.SP_AgregarUbicacion
    @provincia       varchar(50),
    @localidad        varchar(80),
    @latitud           decimal(9,6) = NULL,
    @longitud          decimal(9,6) = NULL,
    @id_ubicacion int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores varchar(1000) = '';
    IF @provincia IS NULL OR LTRIM(RTRIM(@provincia)) = ''
        SET @errores = @errores + 'La provincia no puede ser vacía. ';
    IF @localidad IS NULL OR LTRIM(RTRIM(@localidad)) = ''
        SET @errores = @errores + 'La localidad no puede ser vacía. ';
    IF @latitud IS NULL OR @latitud < -90 OR @latitud > 90
        SET @errores = @errores + 'La latitud debe estar entre -90 y 90. ';
    IF @longitud IS NULL OR @longitud < -180 OR @longitud > 180
        SET @errores = @errores + 'La longitud debe estar entre -180 y 180. ';
        
    IF @errores <> ''
        THROW 50001, @errores, 1;

    INSERT INTO Parques.Ubicacion (provincia, localidad, latitud, longitud)
    VALUES (@provincia, @localidad, @latitud, @longitud);
    SET @id_ubicacion = SCOPE_IDENTITY();
END
GO

--Agregar Tipo de Parque

CREATE OR ALTER PROCEDURE Parques.SP_AgregarTipoParque
    @descripcion      varchar(50),
    @id_tipo_parque int OUTPUT  
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores varchar(1000) = '';
    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        SET @errores = @errores + 'La descripción del tipo de parque no puede ser vacía. ';
    IF @errores <> ''
        THROW 50001, @errores, 1;

    INSERT INTO Parques.tipo_parque (descripcion)
    VALUES (@descripcion);
    SET @id_tipo_parque = SCOPE_IDENTITY();
END
GO

--Agregar guardaparque
CREATE OR ALTER PROCEDURE Parques.SP_AgregarGuardaparque
    @dni             char(8),
    @nombre          varchar(50),
    @apellido        varchar(50),
    @fecha_ingreso      date,
    @estado          char(20),
    @id_guardaparque int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores varchar(1000) = '';
    IF EXISTS (SELECT 1 FROM Parques.Guardaparque WHERE dni = @dni)
        SET @errores = @errores + 'ya existe un guardaparque con el mismo DNI. ';

    IF @dni IS NULL OR LTRIM(RTRIM(@dni)) = '' OR LEN(@dni) <> 8
        SET @errores = @errores + 'El DNI del guardaparque debe ser un número de 8 dígitos. ';
    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errores = @errores + 'El nombre del guardaparque no puede ser vacío. ';
    IF @apellido IS NULL OR LTRIM(RTRIM(@apellido)) = ''
        SET @errores = @errores + 'El apellido del guardaparque no puede ser vacío. ';
    IF @fecha_ingreso > CAST(GETDATE() AS DATE)
        SET @errores = @errores + 'La fecha de ingreso no puede ser futura. ';
    IF @estado IS NULL OR LTRIM(RTRIM(@estado)) = '' OR @estado NOT IN ('Activo', 'Inactivo')
        SET @errores = @errores + 'El estado del guardaparque no puede ser vacío. ';
    
    IF @errores <> ''
        THROW 50001, @errores, 1;

    INSERT INTO Parques.Guardaparque (dni, nombre, apellido, fecha_ingreso, estado)
    VALUES (@dni, @nombre, @apellido, @fecha_ingreso, @estado);
    SET @id_guardaparque = SCOPE_IDENTITY();
END
GO

--Agregar Guardaparque a Parque

CREATE OR ALTER PROCEDURE Parques.SP_AgregarGuardaparqueAParque
    @id_guardaparque int,
    @id_parque int,
    @fecha_inicio date,
    @fecha_fin date,
    @motivo_egreso varchar(100) = NULL,
    @id_asignacion int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores varchar(1000) = '';
    IF NOT EXISTS (SELECT 1 FROM Parques.Guardaparque WHERE id_guardaparque = @id_guardaparque)
        SET @errores = @errores + 'El guardaparque indicado no existe. ';
    IF NOT EXISTS (SELECT 1 FROM Parques.Parque_nacional WHERE id_parque = @id_parque)
        SET @errores = @errores + 'El parque nacional indicado no existe. ';
    IF @fecha_inicio > CAST(GETDATE() AS DATE)
        SET @errores = @errores + 'La fecha de inicio no puede ser futura. ';
    IF @fecha_fin IS NOT NULL AND @fecha_fin < @fecha_inicio
        SET @errores = @errores + 'La fecha de fin no puede ser anterior a la fecha de inicio. ';
    IF @motivo_egreso IS NULL OR LTRIM(RTRIM(@motivo_egreso)) = ''
        SET @errores = @errores + 'El motivo de egreso de la asignación no puede ser vacío. ';
    
    IF @errores <> ''
        THROW 50001, @errores, 1;

    INSERT INTO Parques.Asignacion_guardaparque (id_guardaparque, id_parque, fecha_inicio, fecha_fin, motivo_egreso)
    VALUES (@id_guardaparque, @id_parque, @fecha_inicio, @fecha_fin, @motivo_egreso);
    SET @id_asignacion = SCOPE_IDENTITY();
END

GO


--Agregar Guia

CREATE OR ALTER PROCEDURE Actividades.SP_AgregarGuia
    @dni             char(8),
    @nombre          varchar(50),
    @apellido        varchar(50),
    @titulo           varchar(80),
    @especialidad       varchar(80),
    @vigencia_autorizacion date,
    @id_guia int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores varchar(1000) = '';
    IF EXISTS (SELECT 1 FROM Actividades.Guia WHERE dni = @dni)
        SET @errores = @errores + 'ya existe un guía con el mismo DNI. ';

    IF @dni IS NULL OR LTRIM(RTRIM(@dni)) = '' OR LEN(@dni) <> 8
        SET @errores = @errores + 'El DNI del guía debe ser un número de 8 dígitos. ';
    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errores = @errores + 'El nombre del guía no puede ser vacío. ';
    IF @apellido IS NULL OR LTRIM(RTRIM(@apellido)) = ''
        SET @errores = @errores + 'El apellido del guía no puede ser vacío. ';
    IF @vigencia_autorizacion < CAST(GETDATE() AS DATE)
        SET @errores = @errores + 'La vigencia de la autorización no puede estar vencida. ';
    
    IF @errores <> ''
        THROW 50001, @errores, 1;

    INSERT INTO Actividades.Guia (dni, nombre, apellido, titulo, especialidad, vigencia_autorizacion)
    VALUES (@dni, @nombre, @apellido, @titulo, @especialidad, @vigencia_autorizacion);
    SET @id_guia = SCOPE_IDENTITY();
END
GO


--Agregar Tipo de Actividad

CREATE OR ALTER PROCEDURE Actividades.SP_AgregarTipoActividad
    @descripcion      varchar(50),
    @id_tipo_actividad int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores varchar(1000) = '';
    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        SET @errores = @errores + 'La descripción del tipo de actividad no puede ser vacía. ';
    IF @errores <> ''
        THROW 50001, @errores, 1;

    INSERT INTO Actividades.Tipo_actividad (descripcion)
    VALUES (@descripcion);
    SET @id_tipo_actividad = SCOPE_IDENTITY();
END
GO


--Agregar Actividad
CREATE OR ALTER PROCEDURE Actividades.SP_AgregarActividad
    @id_tipo_actividad int,
    @id_parque int,
    @nombre varchar(80),
    @duracion_minutos int,
    @cupo_maximo int,
    @costo decimal(10,2),  
    @id_actividad int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores varchar(1000) = '';
    IF NOT EXISTS (SELECT 1 FROM Actividades.Tipo_actividad WHERE id_tipo_actividad = @id_tipo_actividad)
        SET @errores = @errores + 'El tipo de actividad indicado no existe. ';
    IF NOT EXISTS (SELECT 1 FROM Parques.Parque_nacional WHERE id_parque = @id_parque)
        SET @errores = @errores + 'El parque nacional indicado no existe. ';
    IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
        SET @errores = @errores + 'El nombre de la actividad no puede ser vacío. ';
    IF @duracion_minutos <= 0
        SET @errores = @errores + 'La duración de la actividad debe ser un número positivo. ';
    IF @cupo_maximo < 0
        SET @errores = @errores + 'El cupo máximo de la actividad debe ser un número positivo. ';
    IF @costo < 0
        SET @errores = @errores + 'El costo de la actividad debe ser un número positivo. ';
    
    IF @errores <> ''
        THROW 50001, @errores, 1;

    INSERT INTO Actividades.Actividad (id_tipo_actividad, id_parque, nombre, duracion_minutos, cupo_maximo, costo)
    VALUES (@id_tipo_actividad, @id_parque, @nombre, @duracion_minutos, @cupo_maximo, @costo);
    SET @id_actividad = SCOPE_IDENTITY();
END
GO


--Agregar Guia por activid

CREATE OR ALTER PROCEDURE Actividades.SP_AgregarGuiaPorActividad
    @id_guia int,
    @id_actividad int,
    @fecha_asignacion date,
    @rol varchar(30)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores varchar(1000) = '';
    IF NOT EXISTS (SELECT 1 FROM Actividades.Guia WHERE id_guia = @id_guia)
        SET @errores = @errores + 'El guía indicado no existe. ';
    IF NOT EXISTS (SELECT 1 FROM Actividades.Actividad WHERE id_actividad = @id_actividad)
        SET @errores = @errores + 'La actividad indicada no existe. ';
    IF EXISTS (SELECT 1 FROM Actividades.Guias_por_actividad WHERE id_guia = @id_guia AND id_actividad = @id_actividad)
        SET @errores = @errores + 'El guía ya está asignado a la actividad indicada. ';
    IF @fecha_asignacion > CAST(GETDATE() AS DATE)
        SET @errores = @errores + 'La fecha de asignación no puede ser futura. ';
    IF @rol IS NULL OR LTRIM(RTRIM(@rol)) = ''
        SET @errores = @errores + 'El rol del guía en la actividad no puede ser vacío. ';
    
    IF @errores <> ''
        THROW 50001, @errores, 1;

    INSERT INTO Actividades.Guias_por_actividad (id_guia, id_actividad, fecha_asignacion, rol)
    VALUES (@id_guia, @id_actividad, @fecha_asignacion, @rol);
END
GO

--agregar turno actividad

CREATE OR ALTER PROCEDURE Actividades.SP_AgregarTurnoActividad
    @id_actividad int,
    @fecha date,
    @hora_inicio time,
    @id_turno int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores varchar(1000) = '';
    IF NOT EXISTS (SELECT 1 FROM Actividades.Actividad WHERE id_actividad = @id_actividad)
        SET @errores = @errores + 'La actividad indicada no existe. ';
    IF @fecha < CAST(GETDATE() AS DATE)
        SET @errores = @errores + 'La fecha del turno no puede ser pasada. ';
    
    IF @errores <> ''
        THROW 50001, @errores, 1;

    INSERT INTO Actividades.Turno_actividad (id_actividad, fecha, hora_inicio)
    VALUES (@id_actividad, @fecha, @hora_inicio);
    SET @id_turno = SCOPE_IDENTITY();
END
GO


--Agregar Tipo Visitante
CREATE OR ALTER PROCEDURE Comercial.SP_AgregarTipoVisitante
    @descripcion varchar(50),
    @id_tipo_visitante int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores varchar(1000) = '';
    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        SET @errores = @errores + 'La descripción del tipo de visitante no puede ser vacía. ';
    IF @errores <> ''
        THROW 50001, @errores, 1;

    INSERT INTO Comercial.Tipo_visitante (descripcion)
    VALUES (@descripcion);
    SET @id_tipo_visitante = SCOPE_IDENTITY();
END
GO


--Agregar Tarifario del parque

CREATE OR ALTER PROCEDURE Comercial.SP_AgregarTarifarioParque
    @id_parque int,
    @id_tipo_visitante int,
    @precio_actual decimal(10,2),
    @id_tarifario int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores varchar(1000) = '';
    IF EXISTS (SELECT 1 FROM Comercial.Tarifario_parque WHERE id_parque = @id_parque AND id_tipo_visitante = @id_tipo_visitante)
        SET @errores = @errores + 'Ya existe un tarifario para ese parque y tipo de visitante. ';
    IF NOT EXISTS (SELECT 1 FROM Parques.Parque_nacional WHERE id_parque = @id_parque)
        SET @errores = @errores + 'El parque nacional indicado no existe. ';
    IF NOT EXISTS (SELECT 1 FROM Comercial.Tipo_visitante WHERE id_tipo_visitante = @id_tipo_visitante)
        SET @errores = @errores + 'El tipo de visitante indicado no existe. ';
    IF @precio_actual < 0
        SET @errores = @errores + 'El precio actual no puede ser negativo. ';
    
    IF @errores <> ''
        THROW 50001, @errores, 1;

    INSERT INTO Comercial.Tarifario_parque (id_parque, id_tipo_visitante, precio_actual)
    VALUES (@id_parque, @id_tipo_visitante, @precio_actual);
    SET @id_tarifario = SCOPE_IDENTITY();
END 
GO

--Agregar Punto de venta

CREATE OR ALTER PROCEDURE Comercial.SP_AgregarPuntoDeVenta
    @descripcion varchar(50),
    @id_punto_de_venta int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores varchar(1000) = '';
    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        SET @errores = @errores + 'La descripción del punto de venta no puede ser vacía. ';
    IF @errores <> ''
        THROW 50001, @errores, 1;

    INSERT INTO Comercial.Punto_de_venta (descripcion)
    VALUES (@descripcion);
    SET @id_punto_de_venta = SCOPE_IDENTITY();
END
GO

--Agregar Forma de pago

CREATE OR ALTER PROCEDURE Comercial.SP_AgregarFormaDePago
    @descripcion varchar(50),
    @id_forma_de_pago int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores varchar(1000) = '';
    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        SET @errores = @errores + 'La descripción de la forma de pago no puede ser vacía. ';
    IF @errores <> ''
        THROW 50001, @errores, 1;

    INSERT INTO Comercial.Forma_de_pago (descripcion)
    VALUES (@descripcion);
    SET @id_forma_de_pago = SCOPE_IDENTITY();
END
GO

--Agregar Venta

CREATE OR ALTER PROCEDURE Comercial.SP_AgregarVenta
    @id_punto_de_venta int,
    @id_forma_de_pago int,
    @numero_factura varchar(20),
    @fecha_emision datetime,
    @total decimal(10,2),
    @id_venta int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores varchar(1000) = '';
    IF NOT EXISTS (SELECT 1 FROM Comercial.Punto_de_venta WHERE id_punto_de_venta = @id_punto_de_venta)
        SET @errores = @errores + 'El punto de venta indicado no existe. ';
    IF NOT EXISTS (SELECT 1 FROM Comercial.Forma_de_pago WHERE id_forma_de_pago = @id_forma_de_pago)
        SET @errores = @errores + 'La forma de pago indicada no existe. ';
    IF @numero_factura IS NULL OR LTRIM(RTRIM(@numero_factura)) = ''
        SET @errores = @errores + 'El número de factura no puede ser vacío. ';
    IF @fecha_emision > CAST(GETDATE() AS DATE)
        SET @errores = @errores + 'La fecha de emisión no puede ser futura. ';
    IF @total <= 0
        SET @errores = @errores + 'El total de la venta debe ser un número positivo. ';

    IF @errores <> ''
        THROW 50001, @errores, 1;

    INSERT INTO Comercial.Venta (id_punto_de_venta, id_forma_de_pago, numero_factura, fecha_emision, total)
    VALUES (@id_punto_de_venta, @id_forma_de_pago, @numero_factura, @fecha_emision, @total);
    SET @id_venta = SCOPE_IDENTITY();
END
GO

--Agregar Entrada

CREATE OR ALTER PROCEDURE Comercial.SP_AgregarEntrada
    @id_parque int,
    @id_tipo_visitante int,
    @fecha_acceso date,
    @id_entrada int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores varchar(1000) = '';
    IF NOT EXISTS (SELECT 1 FROM Parques.Parque_nacional WHERE id_parque = @id_parque)
        SET @errores = @errores + 'El parque nacional indicado no existe. ';
    IF NOT EXISTS (SELECT 1 FROM Comercial.Tipo_visitante WHERE id_tipo_visitante = @id_tipo_visitante)
        SET @errores = @errores + 'El tipo de visitante indicado no existe. ';
    
    IF @errores <> ''
        THROW 50001, @errores, 1;

    INSERT INTO Comercial.Entrada (id_parque, id_tipo_visitante, fecha_acceso)
    VALUES (@id_parque, @id_tipo_visitante, @fecha_acceso);
    SET @id_entrada = SCOPE_IDENTITY();
END
GO

--Agregar Ticket de actividad
CREATE OR ALTER PROCEDURE Comercial.SP_AgregarTicketActividad
    @id_turno int,
    @id_ticket int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores varchar(1000) = '';
    IF NOT EXISTS (SELECT 1 FROM Actividades.Turno_actividad WHERE id_turno = @id_turno)
        SET @errores = @errores + 'El turno de actividad indicado no existe. ';
    
    IF @errores <> ''
        THROW 50001, @errores, 1;

    INSERT INTO Comercial.Ticket_actividad (id_turno)
    VALUES (@id_turno);
    SET @id_ticket = SCOPE_IDENTITY();
END
GO

--Agregar Item vendible
CREATE OR ALTER PROCEDURE Comercial.SP_AgregarItemVendible
    @id_entrada int = NULL,
    @id_ticket int = NULL,
    @tipo_item varchar(20),
    @id_item int OUTPUT
AS  
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores varchar(1000) = '';
    IF @tipo_item NOT IN ('Entrada', 'Ticket')
        SET @errores = @errores + 'El tipo de item vendible debe ser "Entrada" o "Ticket". ';

    IF @tipo_item = 'Entrada' AND NOT EXISTS (SELECT 1 FROM Comercial.Entrada WHERE id_entrada = @id_entrada)
        SET @errores = @errores + 'La entrada indicada no existe. ';
    IF @tipo_item = 'Entrada' AND @id_ticket IS NOT NULL
        SET @errores = @errores + 'Si el item es una entrada, no debe indicarse un ticket. ';
    IF @tipo_item = 'Ticket' AND NOT EXISTS (SELECT 1 FROM Comercial.Ticket_actividad WHERE id_ticket = @id_ticket)
        SET @errores = @errores + 'El ticket de actividad indicado no existe. ';
    IF @tipo_item = 'Ticket' AND @id_entrada IS NOT NULL
        SET @errores = @errores + 'Si el item es un ticket de actividad, no debe indicarse una entrada. ';
    
    
    IF @errores <> ''
        THROW 50001, @errores, 1;

    INSERT INTO Comercial.Item_vendible (id_entrada, id_ticket, tipo_item)
    VALUES (@id_entrada, @id_ticket, @tipo_item);
    SET @id_item = SCOPE_IDENTITY();
END
GO

--Agregar Detalle de venta
CREATE OR ALTER PROCEDURE Comercial.SP_AgregarDetalleVenta
    @id_venta int,
    @id_item int,
    @subtotal decimal(10,2),
    @id_detalle_venta int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores varchar(1000) = '';
    IF NOT EXISTS (SELECT 1 FROM Comercial.Venta WHERE id_venta = @id_venta)
        SET @errores = @errores + 'La venta indicada no existe. ';
    IF NOT EXISTS (SELECT 1 FROM Comercial.Item_vendible WHERE id_item = @id_item)
        SET @errores = @errores + 'El item vendible indicado no existe. ';
    IF @subtotal < 0
        SET @errores = @errores + 'El subtotal del detalle de venta no puede ser negativo. ';
    
    IF @errores <> ''
        THROW 50001, @errores, 1;

    INSERT INTO Comercial.Detalle_venta (id_venta, id_item, subtotal)
    VALUES (@id_venta, @id_item, @subtotal);
    SET @id_detalle_venta = SCOPE_IDENTITY();
END
GO

--Agregar Empresa

CREATE OR ALTER PROCEDURE Concesiones.SP_AgregarEmpresa
    @razon_social varchar(120),
    @cuit char(11),
    @rubro_principal varchar(80),
    @id_empresa int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores varchar(1000) = '';
    IF EXISTS (SELECT 1 FROM Concesiones.Empresa WHERE cuit = @cuit)
        SET @errores = @errores + 'ya existe una empresa con el mismo CUIT. ';

    IF @razon_social IS NULL OR LTRIM(RTRIM(@razon_social)) = ''
        SET @errores = @errores + 'La razón social de la empresa no puede ser vacía. ';
    IF @cuit IS NULL OR LTRIM(RTRIM(@cuit)) = '' OR LEN(@cuit) <> 11
        SET @errores = @errores + 'El CUIT de la empresa debe ser un número de 11 dígitos. ';
    IF @rubro_principal IS NULL OR LTRIM(RTRIM(@rubro_principal)) = ''
        SET @errores = @errores + 'El rubro principal de la empresa no puede ser vacío. ';
    
    IF @errores <> ''
        THROW 50001, @errores, 1;

    INSERT INTO Concesiones.Empresa (razon_social, cuit, rubro_principal)
    VALUES (@razon_social, @cuit, @rubro_principal);
    SET @id_empresa = SCOPE_IDENTITY();
END
GO

--Agregar Estado concesion
CREATE OR ALTER PROCEDURE Concesiones.SP_AgregarEstadoConcesion
    @descripcion varchar(50),
    @id_estado_concesion int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores varchar(1000) = '';
    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        SET @errores = @errores + 'La descripción del estado de concesión no puede ser vacía. ';
    IF @errores <> ''
        THROW 50001, @errores, 1;

    INSERT INTO Concesiones.Estado_concesion (descripcion)
    VALUES (@descripcion);
    SET @id_estado_concesion = SCOPE_IDENTITY();
END
GO

--agregar Concesion
CREATE OR ALTER PROCEDURE Concesiones.SP_AgregarConcesion
    @id_estado_concesion int,
    @id_parque int,
    @id_empresa int,
    @fecha_inicio date,
    @fecha_fin date,
    @monto_alquiler decimal(12,2),
    @id_concesion int OUTPUT    
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores varchar(1000) = '';
    IF NOT EXISTS (SELECT 1 FROM Concesiones.Estado_concesion WHERE id_estado_concesion = @id_estado_concesion)
        SET @errores = @errores + 'El estado de concesión indicado no existe. ';
    IF NOT EXISTS (SELECT 1 FROM Parques.Parque_nacional WHERE id_parque = @id_parque)
        SET @errores = @errores + 'El parque nacional indicado no existe. ';
    IF NOT EXISTS (SELECT 1 FROM Concesiones.Empresa WHERE id_empresa = @id_empresa)
        SET @errores = @errores + 'La empresa indicada no existe. ';
    IF @fecha_inicio > CAST(GETDATE() AS DATE)
        SET @errores = @errores + 'La fecha de inicio de la concesión no puede ser futura. ';
    IF @fecha_fin IS NULL OR @fecha_fin < @fecha_inicio
        SET @errores = @errores + 'La fecha de fin de la concesión no puede ser anterior a la fecha de inicio. ';
    IF @monto_alquiler <= 0
        SET @errores = @errores + 'El monto de alquiler de la concesión debe ser positivo. ';
    
    IF @errores <> ''
        THROW 50001, @errores, 1;

    INSERT INTO Concesiones.Concesion (id_estado_concesion, id_parque, id_empresa, fecha_inicio, fecha_fin, monto_alquiler)
    VALUES (@id_estado_concesion, @id_parque, @id_empresa, @fecha_inicio, @fecha_fin, @monto_alquiler);
    SET @id_concesion = SCOPE_IDENTITY();
END
GO

--Agregar Estado pago
CREATE OR ALTER PROCEDURE Concesiones.SP_AgregarEstadoPago
    @descripcion varchar(50),
    @id_estado_pago int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores varchar(1000) = '';
    IF @descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = ''
        SET @errores = @errores + 'La descripción del estado de pago no puede ser vacía. ';
    IF @errores <> ''
        THROW 50001, @errores, 1;

    INSERT INTO Concesiones.Estado_pago (descripcion)
    VALUES (@descripcion);
    SET @id_estado_pago = SCOPE_IDENTITY();
END
GO

--Agregar Pago canon
CREATE OR ALTER PROCEDURE Concesiones.SP_AgregarPagoCanon
    @id_concesion int,
    @id_estado_pago int,
    @fecha_pago date,
    @monto decimal(12,2),
    @periodo_mes int,
    @periodo_anio int,
    @id_pago int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores varchar(1000) = '';
    IF NOT EXISTS (SELECT 1 FROM Concesiones.Concesion WHERE id_concesion = @id_concesion)
        SET @errores = @errores + 'La concesión indicada no existe. ';
    IF NOT EXISTS (SELECT 1 FROM Concesiones.Estado_pago WHERE id_estado_pago = @id_estado_pago)
        SET @errores = @errores + 'El estado de pago indicado no existe. ';
    IF @fecha_pago > CAST(GETDATE() AS DATE)
        SET @errores = @errores + 'La fecha de pago no puede ser futura. ';
    IF @monto <= 0
        SET @errores = @errores + 'El monto del pago debe ser un número positivo. ';
    IF @periodo_mes < 1 OR @periodo_mes > 12
        SET @errores = @errores + 'El período mes del pago debe estar entre 1 y 12. ';
    IF @periodo_anio < 2000 OR @periodo_anio > YEAR(CAST(GETDATE() AS DATE)) + 1
        SET @errores = @errores + 'El período año del pago debe estar entre 2000 y el próximo año. ';
    
    IF @errores <> ''
        THROW 50001, @errores, 1;

    INSERT INTO Concesiones.Pago_canon (id_concesion, id_estado_pago, fecha_pago, monto, periodo_mes, periodo_anio)
    VALUES (@id_concesion, @id_estado_pago, @fecha_pago, @monto, @periodo_mes, @periodo_anio);
    SET @id_pago = SCOPE_IDENTITY();
END
GO