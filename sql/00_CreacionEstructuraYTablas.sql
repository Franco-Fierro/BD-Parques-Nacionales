------------------------------------------------------------------
--Universidad Nacional de La Matanza
--MATERIA: BASES DE DATOS APLICADA
--GRUPO: 03
--FIERRO, FRANCO EZEQUIEL
--GISMONDI, FRANCISCO
--QUISPE BARJA, SERGIO DANIEL
----------------------------------------------------------------

--Objetivo: Definir la estructura relacional para la gestion de Parques Nacionales. Mediante la creaci�n de tablas y restricciones de integridad.

------------------ CREACION DE BBDD -------------------

-- Cambiar al contexto master
/*USE master;
GO
-- Eliminar la base
DROP DATABASE COM5600_G03;
GO*/


IF DB_ID('COM5600_G03') IS NULL
    CREATE DATABASE COM5600_G03 COLLATE Latin1_General_CI_AS;
GO	

USE COM5600_G03
GO

------------------ CREACION DE ESQUEMAS -------------------
IF SCHEMA_ID('Parques') IS NULL
BEGIN
    EXEC('CREATE SCHEMA Parques') --El SCHEMA Parques se vinculara con Parque_nacional, Ubicacion, Tipo_parque,Guardaparque, y Asignacion_guardaparque
END

IF SCHEMA_ID('Actividades') IS NULL
BEGIN
    EXEC('CREATE SCHEMA Actividades') --El SCHEMA Actividades se vinculara con Actividad, Tipo_actividad, Turno_actividad, Guia y Guia_por_actividad
END

IF SCHEMA_ID('Comercial') IS NULL
BEGIN
    EXEC('CREATE SCHEMA Comercial') --El SCHEMA Comercial se vinculara con Venta, Detalle_venta, Item_vendible, Entrada, Ticket_actividad, Tarifario_parque, Tipo_visitante, Punto_de_venta Y Forma_de_pago
END

IF SCHEMA_ID('Concesiones') IS NULL
BEGIN
    EXEC('CREATE SCHEMA Concesiones') --El SCHEMA  Concesiones se vinculara con Concesion, Empresa, Pago_canon, Estado_pago y Estado_consecion
END


------------------ CREACION DE TABLAS -------------------

--- Tablas que pertenecen al SCHEMA Parques ---

IF OBJECT_ID('Parques.Ubicacion','U') IS NULL
BEGIN
    CREATE TABLE Parques.Ubicacion (
      id_ubicacion INT PRIMARY KEY IDENTITY(1,1),
      provincia VARCHAR(50) NOT NULL,
      localidad VARCHAR(80) NOT NULL
    );
END
GO

IF OBJECT_ID('Parques.Tipo_parque','U') IS NULL
BEGIN
    CREATE TABLE Parques.Tipo_parque (
      id_tipo_parque INT PRIMARY KEY IDENTITY(1,1),
      descripcion VARCHAR(50) NOT NULL
    );
END
GO

IF OBJECT_ID('Parques.Parque_nacional','U') IS NULL
BEGIN
    CREATE TABLE Parques.Parque_nacional (
      id_parque INT PRIMARY KEY IDENTITY(1,1),
      id_ubicacion INT NOT NULL,
      id_tipo_parque INT NOT NULL,
      nombre VARCHAR(100) NOT NULL,
      superficie DECIMAL(12,2) NOT NULL,
      CONSTRAINT FK_Parque_nacional_Ubicacion FOREIGN KEY (id_ubicacion) REFERENCES Parques.Ubicacion (id_ubicacion),
      CONSTRAINT FK_Parque_nacional_Tipo_parque FOREIGN KEY (id_tipo_parque) REFERENCES Parques.Tipo_parque (id_tipo_parque)
    );
END
GO


IF OBJECT_ID('Parques.Guardaparque','U') IS NULL
BEGIN
    CREATE TABLE Parques.Guardaparque (
      id_guardaparque int PRIMARY KEY NOT NULL IDENTITY(1, 1),
      dni char(8) UNIQUE NOT NULL,
      nombre varchar(50) NOT NULL,
      apellido varchar(50) NOT NULL,
      fecha_ingreso date NOT NULL,
      estado char(20) NOT NULL CHECK(estado in('Activo','Inactivo'))
    );
END
GO

IF OBJECT_ID('Parques.Asignacion_guardaparque','U') IS NULL
BEGIN
    CREATE TABLE Parques.Asignacion_guardaparque (
      id_asignacion int PRIMARY KEY NOT NULL IDENTITY(1, 1),
      id_guardaparque int NOT NULL,
      id_parque int NOT NULL,
      fecha_inicio date NOT NULL,
      fecha_fin date,
      motivo_egreso varchar(100),
      CONSTRAINT FK_Asignacion_guardaparque_Guardaparque FOREIGN KEY (id_guardaparque) REFERENCES Parques.Guardaparque (id_guardaparque),
      CONSTRAINT FK_Asignacion_guardaparque_Parque_nacional FOREIGN KEY (id_parque) REFERENCES Parques.Parque_nacional(id_parque)
    );
END
GO

---Tablas que pertenecen al SCHEMA Actividades ---

IF OBJECT_ID('Actividades.Guia','U') IS NULL
BEGIN
    CREATE TABLE Actividades.Guia (
      id_guia int PRIMARY KEY NOT NULL IDENTITY(1, 1),
      dni char(8) UNIQUE NOT NULL,
      nombre varchar(50) NOT NULL,
      apellido varchar(50) NOT NULL,
      titulo varchar(80),
      especialidad varchar(80),
      vigencia_autorizacion date NOT NULL,
    )
END
GO

IF OBJECT_ID('Actividades.Tipo_actividad','U') IS NULL
BEGIN
    CREATE TABLE Actividades.Tipo_actividad (
      id_tipo_actividad int IDENTITY(1,1) PRIMARY KEY NOT NULL,
      descripcion varchar(50) NOT NULL
    )
END
GO

IF OBJECT_ID('Actividades.Actividad','U') IS NULL
BEGIN
    CREATE TABLE Actividades.Actividad (
      id_actividad int  IDENTITY(1, 1) PRIMARY KEY NOT NULL,
      id_tipo_actividad int NOT NULL,
      id_parque int NOT NULL,
      nombre varchar(80) NOT NULL,
      duracion_minutos int NOT NULL,
      cupo_maximo int,
      costo decimal(10,2) NOT NULL DEFAULT (0),
      CONSTRAINT FK_Actividad_Parque_nacional FOREIGN KEY (id_parque) REFERENCES Parques.Parque_nacional (id_parque),
      CONSTRAINT FK_Actividad_Tipo_actividad FOREIGN KEY (id_tipo_actividad) REFERENCES Actividades.Tipo_actividad (id_tipo_actividad),
      CONSTRAINT CHK_Actividad_duracion CHECK (duracion_minutos > 0)
    )
END
GO

IF OBJECT_ID('Actividades.Guias_por_actividad','U') IS NULL
BEGIN
    CREATE TABLE Actividades.Guias_por_actividad (
      id_guia int NOT NULL,
      id_actividad int NOT NULL,
      rol varchar(30),
      fecha_asignacion date NOT NULL,
      PRIMARY KEY (id_guia, id_actividad),
      CONSTRAINT FK_Guias_por_actividad_Guia FOREIGN KEY (id_guia) REFERENCES Actividades.Guia (id_guia),
      CONSTRAINT FK_Guias_por_actividad_Actividad FOREIGN KEY (id_actividad) REFERENCES Actividades.Actividad (id_actividad)
    )
END
GO


IF OBJECT_ID('Actividades.Turno_actividad','U') IS NULL
BEGIN
    CREATE TABLE Actividades.Turno_actividad (
      id_turno int PRIMARY KEY NOT NULL IDENTITY(1, 1),
      id_actividad int NOT NULL,
      fecha date NOT NULL,
      hora_inicio time,
      CONSTRAINT FK_Turno_actividad_Actividad FOREIGN KEY (id_actividad) REFERENCES Actividades.Actividad (id_actividad)
    )
END
GO

---Tablas que pertenecen al SCHEMA Comercial ---

IF OBJECT_ID('Comercial.Tipo_visitante','U') IS NULL
BEGIN
    CREATE TABLE Comercial.Tipo_visitante (
      id_tipo_visitante int PRIMARY KEY NOT NULL IDENTITY(1, 1),
      descripcion varchar(50) NOT NULL
    );
END
GO

IF OBJECT_ID('Comercial.Tarifario_parque','U') IS NULL
BEGIN
    CREATE TABLE Comercial.Tarifario_parque (
      id_tarifario int PRIMARY KEY NOT NULL IDENTITY(1, 1),
      id_parque int NOT NULL,
      id_tipo_visitante int NOT NULL,
      precio_actual decimal(10,2) NOT NULL,
      CONSTRAINT FK_Tarifario_parque_Parque_nacional FOREIGN KEY (id_parque) REFERENCES Parques.Parque_nacional (id_parque),
      CONSTRAINT FK_Tarifario_parque_Tipo_visitante FOREIGN KEY (id_tipo_visitante) REFERENCES Comercial.Tipo_visitante (id_tipo_visitante)
    );
END
GO

IF OBJECT_ID('Comercial.Punto_de_venta','U') IS NULL
BEGIN
    CREATE TABLE Comercial.Punto_de_venta (
      id_punto_de_venta int PRIMARY KEY NOT NULL IDENTITY(1, 1),
      descripcion varchar(50) NOT NULL
    );
END
GO

IF OBJECT_ID('Comercial.Forma_de_pago','U') IS NULL
BEGIN
    CREATE TABLE Comercial.Forma_de_pago (
      id_forma_de_pago int PRIMARY KEY NOT NULL IDENTITY(1, 1),
      descripcion varchar(50) NOT NULL
    );
END
GO

IF OBJECT_ID('Comercial.Venta','U') IS NULL
BEGIN
    CREATE TABLE Comercial.Venta (
      id_venta int PRIMARY KEY NOT NULL IDENTITY(1, 1),
      id_punto_de_venta int NOT NULL,
      id_forma_de_pago int NOT NULL,
      numero_factura varchar(20) UNIQUE NOT NULL,
      fecha_emision datetime NOT NULL,
      total decimal(10,2) NOT NULL,
      CONSTRAINT FK_Venta_Punto_de_venta FOREIGN KEY (id_punto_de_venta) REFERENCES Comercial.Punto_de_venta (id_punto_de_venta),
      CONSTRAINT FK_Venta_Forma_de_pago FOREIGN KEY (id_forma_de_pago) REFERENCES Comercial.Forma_de_pago (id_forma_de_pago),
      CONSTRAINT CHK_Venta_total CHECK (total >= 0)
    );
END
GO

IF OBJECT_ID('Comercial.Entrada','U') IS NULL
BEGIN
    CREATE TABLE Comercial.Entrada (
      id_entrada int PRIMARY KEY NOT NULL IDENTITY(1, 1),
      id_parque int NOT NULL,
      id_tipo_visitante int NOT NULL,
      fecha_acceso date NOT NULL,
      CONSTRAINT FK_Entrada_Parque_nacional FOREIGN KEY (id_parque) REFERENCES Parques.Parque_nacional (id_parque),
      CONSTRAINT FK_Entrada_Tipo_visitante FOREIGN KEY (id_tipo_visitante) REFERENCES Comercial.Tipo_visitante (id_tipo_visitante)

    );
END
GO

IF OBJECT_ID('Comercial.Ticket_actividad','U') IS NULL
BEGIN
    CREATE TABLE Comercial.Ticket_actividad (
      id_turno int NOT NULL,
      id_ticket int PRIMARY KEY NOT NULL IDENTITY(1, 1) ,
      CONSTRAINT FK_Ticket_actividad_Turno_actividad FOREIGN KEY (id_turno) REFERENCES Actividades.Turno_actividad (id_turno)
    );
END
GO

IF OBJECT_ID('Comercial.Item_vendible','U') IS NULL
BEGIN
    CREATE TABLE Comercial.Item_vendible (
      id_item int PRIMARY KEY NOT NULL IDENTITY(1, 1), 
      tipo_item varchar(20) NOT NULL,
      id_entrada int NULL, -- Se permite nulo
      id_ticket int NULL,  -- Se permite nulo
      CONSTRAINT FK_Item_vendible_Entrada FOREIGN KEY (id_entrada) REFERENCES Comercial.Entrada (id_entrada),
      CONSTRAINT FK_Item_vendible_Ticket_actividad FOREIGN KEY (id_ticket) REFERENCES Comercial.Ticket_actividad (id_ticket)
    );
END
GO


IF OBJECT_ID('Comercial.Detalle_venta','U') IS NULL
BEGIN
    CREATE TABLE Comercial.Detalle_venta (
      id_detalle_venta int PRIMARY KEY NOT NULL IDENTITY(1, 1),
      id_venta int NOT NULL,
      id_item int NOT NULL,
      subtotal decimal(10,2) NOT NULL,
      CONSTRAINT FK_Detalle_venta_Venta FOREIGN KEY (id_venta) REFERENCES Comercial.Venta (id_venta),
      CONSTRAINT FK_Detalle_venta_Item_vendible FOREIGN KEY (id_item) REFERENCES Comercial.Item_vendible (id_item),
      CONSTRAINT CHK_Detalle_subtotal CHECK (subtotal > 0)
    );
END
GO

---Tablas que pertenecen al SCHEMA Concesiones ---

IF OBJECT_ID('Concesiones.Empresa','U') IS NULL
BEGIN
    CREATE TABLE Concesiones.Empresa (
      id_empresa int PRIMARY KEY NOT NULL IDENTITY(1, 1),
      razon_social varchar(120) NOT NULL,
      cuit varchar(11) UNIQUE NOT NULL,
      rubro_principal varchar(80)
    )
END
GO

IF OBJECT_ID('Concesiones.Estado_concesion','U') IS NULL
BEGIN
    CREATE TABLE Concesiones.Estado_concesion (
      id_estado_concesion int PRIMARY KEY NOT NULL IDENTITY(1, 1),
      descripcion varchar(30) UNIQUE NOT NULL
    )
END
GO

IF OBJECT_ID('Concesiones.Concesion','U') IS NULL
BEGIN
    CREATE TABLE Concesiones.Concesion (
      id_concesion int PRIMARY KEY NOT NULL IDENTITY(1, 1),
      id_estado_concesion int NOT NULL,
      id_parque int NOT NULL,
      id_empresa int NOT NULL,
      fecha_inicio date NOT NULL,
      fecha_fin date NOT NULL,
      monto_alquiler decimal(12,2) NOT NULL,
      CONSTRAINT FK_Concesion_Parque_nacional FOREIGN KEY (id_parque) REFERENCES Parques.Parque_nacional (id_parque),
      CONSTRAINT FK_Concesion_Empresa FOREIGN KEY (id_empresa) REFERENCES Concesiones.Empresa (id_empresa),
      CONSTRAINT FK_Concesion_Estado_concesion FOREIGN KEY (id_estado_concesion) REFERENCES Concesiones.Estado_concesion (id_estado_concesion),
      CONSTRAINT CHK_Concesion_fechas CHECK (fecha_fin > fecha_inicio)

    )
END
GO

IF OBJECT_ID('Concesiones.Estado_pago','U') IS NULL
BEGIN
    CREATE TABLE Concesiones.Estado_pago (
      id_estado_pago int PRIMARY KEY NOT NULL IDENTITY(1, 1),
      descripcion varchar(30) UNIQUE NOT NULL
    )
END
GO


IF OBJECT_ID('Concesiones.Pago_canon','U') IS NULL
BEGIN
    CREATE TABLE Concesiones.Pago_canon (
      id_pago int PRIMARY KEY NOT NULL IDENTITY(1, 1),
      id_estado_pago int NOT NULL,
      id_concesion int NOT NULL,
      fecha_pago date NOT NULL,
      monto decimal(12,2) NOT NULL,
      periodo_mes int NOT NULL,
      periodo_anio int NOT NULL,
      CONSTRAINT FK_Pago_canon_Concesion FOREIGN KEY (id_concesion) REFERENCES Concesiones.Concesion (id_concesion),
      CONSTRAINT FK_Pago_canon_Estado_pago FOREIGN KEY (id_estado_pago) REFERENCES Concesiones.Estado_pago (id_estado_pago),
      CONSTRAINT CHK_Pago_monto CHECK (monto > 0),
      CONSTRAINT CHK_Pago_periodo_mes CHECK (periodo_mes BETWEEN 1 AND 12)
    )
END
GO