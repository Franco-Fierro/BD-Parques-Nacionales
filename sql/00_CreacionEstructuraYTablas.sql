------------------------------------------------------------------
--Universidad Nacional de La Matanza
--MATERIA: BASES DE DATOS APLICADA
--COMISION: 5600
--GRUPO: 03
--FIERRO, FRANCO EZEQUIEL
--GISMONDI, FRANCISCO
----------------------------------------------------------------

--Objetivo: Definir la estructura relacional para la gestion de Parques Nacionales. Mediante la creaci�n de tablas y restricciones de integridad.

------------------ CREACION DE BBDD -------------------

-- Cambiar al contexto master
/*USE master;
GO
-- Cambiar la base de datos a modo de usuario único para eliminarla
ALTER DATABASE COM5600_G03 
SET SINGLE_USER 
WITH ROLLBACK IMMEDIATE;
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
    EXEC('CREATE SCHEMA Parques') 
END 
GO

IF SCHEMA_ID('Actividades') IS NULL 
BEGIN 
    EXEC('CREATE SCHEMA Actividades') 
END 
GO

IF SCHEMA_ID('Comercial') IS NULL 
BEGIN 
    EXEC('CREATE SCHEMA Comercial') 
END 
GO

IF SCHEMA_ID('Concesiones') IS NULL 
BEGIN 
    EXEC('CREATE SCHEMA Concesiones') 
END 
GO

------------------ CREACION DE TABLAS -------------------
--- Tablas que pertenecen al SCHEMA Parques --- 
IF OBJECT_ID('Parques.Ubicacion','U') IS NULL 
BEGIN 
    CREATE TABLE Parques.Ubicacion ( 
        id_ubicacion INT PRIMARY KEY IDENTITY(1,1), 
        provincia VARCHAR(60) NOT NULL,
        region VARCHAR(80) NOT NULL, 
        latitud DECIMAL(8,6) NOT NULL, 
        longitud DECIMAL(9,6) NOT NULL 
    );
END 
GO

IF OBJECT_ID('Parques.Tipo_parque','U') IS NULL 
BEGIN 
    CREATE TABLE Parques.Tipo_parque ( 
        id_tipo_parque TINYINT PRIMARY KEY IDENTITY(1,1),
        descripcion VARCHAR(50) NOT NULL 
    );
END 
GO 

IF OBJECT_ID('Parques.Parque_nacional','U') IS NULL 
BEGIN 
    CREATE TABLE Parques.Parque_nacional ( 
        id_parque SMALLINT PRIMARY KEY IDENTITY(1,1), 
        id_ubicacion INT NOT NULL, 
        id_tipo_parque TINYINT NOT NULL, 
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
        id_guardaparque INT PRIMARY KEY NOT NULL IDENTITY(1, 1),
        dni VARCHAR(10) UNIQUE NOT NULL, 
        nombre VARCHAR(50) NOT NULL, 
        apellido VARCHAR(50) NOT NULL, 
        fecha_ingreso DATE NOT NULL, 
        estado VARCHAR(10) NOT NULL CHECK(estado in('Activo','Inactivo')) 
    );
END 
GO 

IF OBJECT_ID('Parques.Asignacion_guardaparque','U') IS NULL 
BEGIN 
    CREATE TABLE Parques.Asignacion_guardaparque ( 
        id_asignacion INT PRIMARY KEY NOT NULL IDENTITY(1, 1), 
        id_guardaparque INT NOT NULL, 
        id_parque SMALLINT NOT NULL,  
        fecha_inicio DATE NOT NULL, 
        fecha_fin DATE, 
        motivo_egreso VARCHAR(100),
        CONSTRAINT FK_Asignacion_guardaparque_Guardaparque FOREIGN KEY (id_guardaparque) REFERENCES Parques.Guardaparque (id_guardaparque), 
        CONSTRAINT FK_Asignacion_guardaparque_Parque_nacional FOREIGN KEY (id_parque) REFERENCES Parques.Parque_nacional(id_parque) 
    );
END 
GO

---Tablas que pertenecen al SCHEMA Actividades --- 
IF OBJECT_ID('Actividades.Guia','U') IS NULL 
BEGIN 
    CREATE TABLE Actividades.Guia (
        id_guia INT PRIMARY KEY NOT NULL IDENTITY(1, 1), 
        dni VARCHAR(10) UNIQUE NOT NULL, 
        nombre VARCHAR(50) NOT NULL, 
        apellido VARCHAR(50) NOT NULL, 
        titulo VARCHAR(80),
        especialidad VARCHAR(80), 
        vigencia_autorizacion DATE NOT NULL
    ); 
END 
GO 

IF OBJECT_ID('Actividades.Tipo_actividad','U') IS NULL 
BEGIN 
    CREATE TABLE Actividades.Tipo_actividad ( 
        id_tipo_actividad TINYINT IDENTITY(1,1) PRIMARY KEY NOT NULL, 
        descripcion VARCHAR(50) NOT NULL 
    ); 
END 
GO

IF OBJECT_ID('Actividades.Actividad','U') IS NULL 
BEGIN 
    CREATE TABLE Actividades.Actividad ( 
        id_actividad INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
        id_tipo_actividad TINYINT NOT NULL, 
        id_parque SMALLINT NOT NULL,
        nombre VARCHAR(80) NOT NULL, 
        duracion_minutos SMALLINT NOT NULL, 
        cupo_maximo SMALLINT, 
        costo DECIMAL(10,2) NOT NULL DEFAULT (0), 
        CONSTRAINT FK_Actividad_Parque_nacional FOREIGN KEY (id_parque) REFERENCES Parques.Parque_nacional (id_parque), 
        CONSTRAINT FK_Actividad_Tipo_actividad FOREIGN KEY (id_tipo_actividad) REFERENCES Actividades.Tipo_actividad (id_tipo_actividad), 
        CONSTRAINT CHK_Actividad_duracion CHECK (duracion_minutos > 0) 
    ); 
END 
GO

IF OBJECT_ID('Actividades.Guias_por_actividad','U') IS NULL 
BEGIN 
    CREATE TABLE Actividades.Guias_por_actividad ( 
        id_guia INT NOT NULL, 
        id_actividad INT NOT NULL, 
        rol VARCHAR(30), 
        fecha_asignacion DATE NOT NULL, 
        PRIMARY KEY (id_guia, id_actividad), 
        CONSTRAINT FK_Guias_por_actividad_Guia FOREIGN KEY (id_guia) REFERENCES Actividades.Guia (id_guia), 
        CONSTRAINT FK_Guias_por_actividad_Actividad FOREIGN KEY (id_actividad) REFERENCES Actividades.Actividad (id_actividad) 
    ); 
END 
GO 

IF OBJECT_ID('Actividades.Turno_actividad','U') IS NULL 
BEGIN 
    CREATE TABLE Actividades.Turno_actividad ( 
        id_turno INT PRIMARY KEY NOT NULL IDENTITY(1, 1),
        id_actividad INT NOT NULL, 
        fecha DATE NOT NULL, 
        hora_inicio TIME(0), 
        CONSTRAINT FK_Turno_actividad_Actividad FOREIGN KEY (id_actividad) REFERENCES Actividades.Actividad (id_actividad) 
    ); 
END 
GO

---Tablas que pertenecen al SCHEMA Comercial --- 
IF OBJECT_ID('Comercial.Tipo_visitante','U') IS NULL 
BEGIN 
    CREATE TABLE Comercial.Tipo_visitante ( 
        id_tipo_visitante TINYINT PRIMARY KEY NOT NULL IDENTITY(1, 1), 
        descripcion VARCHAR(50) NOT NULL 
    );
END 
GO 

IF OBJECT_ID('Comercial.Tarifario_parque','U') IS NULL 
BEGIN 
    CREATE TABLE Comercial.Tarifario_parque ( 
        id_tarifario INT PRIMARY KEY NOT NULL IDENTITY(1, 1), 
        id_parque SMALLINT NOT NULL, 
        id_tipo_visitante TINYINT NOT NULL, 
        precio_actual DECIMAL(10,2) NOT NULL, 
        CONSTRAINT FK_Tarifario_parque_Parque_nacional FOREIGN KEY (id_parque) REFERENCES Parques.Parque_nacional (id_parque), 
        CONSTRAINT FK_Tarifario_parque_Tipo_visitante FOREIGN KEY (id_tipo_visitante) REFERENCES Comercial.Tipo_visitante (id_tipo_visitante) 
    );
END 
GO

IF OBJECT_ID('Comercial.Punto_de_venta','U') IS NULL 
BEGIN 
    CREATE TABLE Comercial.Punto_de_venta ( 
        id_punto_de_venta TINYINT PRIMARY KEY NOT NULL IDENTITY(1, 1), 
        descripcion VARCHAR(50) NOT NULL 
    );
END 
GO 

IF OBJECT_ID('Comercial.Forma_de_pago','U') IS NULL 
BEGIN 
    CREATE TABLE Comercial.Forma_de_pago ( 
        id_forma_de_pago TINYINT PRIMARY KEY NOT NULL IDENTITY(1, 1), 
        descripcion VARCHAR(50) NOT NULL 
    );
END 
GO 

IF OBJECT_ID('Comercial.Venta','U') IS NULL 
BEGIN 
    CREATE TABLE Comercial.Venta (
        id_venta INT PRIMARY KEY NOT NULL IDENTITY(1, 1), 
        id_punto_de_venta TINYINT NOT NULL,
        id_forma_de_pago TINYINT NOT NULL,
        numero_factura VARCHAR(20) UNIQUE NOT NULL,
        fecha_emision DATETIME NOT NULL, 
        total DECIMAL(10,2) NOT NULL, 
        CONSTRAINT FK_Venta_Punto_de_venta FOREIGN KEY (id_punto_de_venta) REFERENCES Comercial.Punto_de_venta (id_punto_de_venta), 
        CONSTRAINT FK_Venta_Forma_de_pago FOREIGN KEY (id_forma_de_pago) REFERENCES Comercial.Forma_de_pago (id_forma_de_pago), 
        CONSTRAINT CHK_Venta_total CHECK (total >= 0) 
    );
END 
GO

IF OBJECT_ID('Comercial.Entrada','U') IS NULL 
BEGIN 
    CREATE TABLE Comercial.Entrada ( 
        id_entrada INT PRIMARY KEY NOT NULL IDENTITY(1, 1),
        id_parque SMALLINT NOT NULL, -- Actualizado para coincidir con PK
        id_tipo_visitante TINYINT NOT NULL, -- Actualizado para coincidir con PK
        fecha_acceso DATE NOT NULL, 
        CONSTRAINT FK_Entrada_Parque_nacional FOREIGN KEY (id_parque) REFERENCES Parques.Parque_nacional (id_parque), 
        CONSTRAINT FK_Entrada_Tipo_visitante FOREIGN KEY (id_tipo_visitante) REFERENCES Comercial.Tipo_visitante (id_tipo_visitante) 
    ); -- CORREGIDO: Faltaba este paréntesis de cierre
END 
GO 

IF OBJECT_ID('Comercial.Ticket_actividad','U') IS NULL 
BEGIN 
    CREATE TABLE Comercial.Ticket_actividad ( 
        id_turno INT NOT NULL,
        id_ticket INT PRIMARY KEY NOT NULL IDENTITY(1, 1), 
        CONSTRAINT FK_Ticket_actividad_Turno_actividad FOREIGN KEY (id_turno) REFERENCES Actividades.Turno_actividad (id_turno) 
    ); 
END 
GO

IF OBJECT_ID('Comercial.Item_vendible','U') IS NULL 
BEGIN 
    CREATE TABLE Comercial.Item_vendible ( 
        id_item INT PRIMARY KEY NOT NULL IDENTITY(1, 1),
        tipo_item VARCHAR(20) NOT NULL, 
        id_entrada INT NULL, 
        id_ticket INT NULL,  
        CONSTRAINT FK_Item_vendible_Entrada FOREIGN KEY (id_entrada) REFERENCES Comercial.Entrada (id_entrada), 
        CONSTRAINT FK_Item_vendible_Ticket_actividad FOREIGN KEY (id_ticket) REFERENCES Comercial.Ticket_actividad (id_ticket) 
    );
END 
GO 

IF OBJECT_ID('Comercial.Detalle_venta','U') IS NULL 
BEGIN 
    CREATE TABLE Comercial.Detalle_venta ( 
        id_detalle_venta INT PRIMARY KEY NOT NULL IDENTITY(1, 1), 
        id_venta INT NOT NULL, 
        id_item INT NOT NULL, 
        subtotal DECIMAL(10,2) NOT NULL, 
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
        id_empresa INT PRIMARY KEY NOT NULL IDENTITY(1, 1),
        razon_social VARCHAR(120) NOT NULL, 
        cuit CHAR(11) UNIQUE NOT NULL, 
        rubro_principal VARCHAR(80) 
    ); 
END 
GO 

IF OBJECT_ID('Concesiones.Estado_concesion','U') IS NULL 
BEGIN 
    CREATE TABLE Concesiones.Estado_concesion ( 
        id_estado_concesion TINYINT PRIMARY KEY NOT NULL IDENTITY(1, 1),
        descripcion VARCHAR(30) UNIQUE NOT NULL 
    ); 
END 
GO

IF OBJECT_ID('Concesiones.Concesion','U') IS NULL 
BEGIN 
    CREATE TABLE Concesiones.Concesion ( 
        id_concesion INT PRIMARY KEY NOT NULL IDENTITY(1, 1),
        id_estado_concesion TINYINT NOT NULL, -- Actualizado para coincidir con PK
        id_parque SMALLINT NOT NULL, -- Actualizado para coincidir con PK
        id_empresa INT NOT NULL, 
        fecha_inicio DATE NOT NULL, 
        fecha_fin DATE NOT NULL, 
        monto_alquiler DECIMAL(12,2) NOT NULL, 
        CONSTRAINT FK_Concesion_Parque_nacional FOREIGN KEY (id_parque) REFERENCES Parques.Parque_nacional (id_parque), 
        CONSTRAINT FK_Concesion_Empresa FOREIGN KEY (id_empresa) REFERENCES Concesiones.Empresa (id_empresa), 
        CONSTRAINT FK_Concesion_Estado_concesion FOREIGN KEY (id_estado_concesion) REFERENCES Concesiones.Estado_concesion (id_estado_concesion), 
        CONSTRAINT CHK_Concesion_fechas CHECK (fecha_fin > fecha_inicio)
    ); -- CORREGIDO: Faltaba este paréntesis de cierre
END 
GO 

IF OBJECT_ID('Concesiones.Estado_pago','U') IS NULL 
BEGIN 
    CREATE TABLE Concesiones.Estado_pago ( 
        id_estado_pago TINYINT PRIMARY KEY NOT NULL IDENTITY(1, 1),
        descripcion VARCHAR(30) UNIQUE NOT NULL 
    ); 
END 
GO 

IF OBJECT_ID('Concesiones.Pago_canon','U') IS NULL 
BEGIN 
    CREATE TABLE Concesiones.Pago_canon ( 
        id_pago INT PRIMARY KEY NOT NULL IDENTITY(1, 1),
        id_estado_pago TINYINT NOT NULL,
        id_concesion INT NOT NULL, 
        fecha_pago DATE NOT NULL, 
        monto DECIMAL(12,2) NOT NULL, 
        periodo_mes TINYINT NOT NULL, 
        periodo_anio SMALLINT NOT NULL, 
        CONSTRAINT FK_Pago_canon_Concesion FOREIGN KEY (id_concesion) REFERENCES Concesiones.Concesion (id_concesion), 
        CONSTRAINT FK_Pago_canon_Estado_pago FOREIGN KEY (id_estado_pago) REFERENCES Concesiones.Estado_pago (id_estado_pago), 
        CONSTRAINT CHK_Pago_monto CHECK (monto > 0), 
        CONSTRAINT CHK_Pago_periodo_mes CHECK (periodo_mes BETWEEN 1 AND 12) 
    ); 
END 
GO

--Tabla para log de errores de importacion 
IF OBJECT_ID('Parques.Log_Errores_Importacion', 'U') IS NULL 
BEGIN 
    CREATE TABLE Parques.Log_Errores_Importacion ( 
        id_error INT PRIMARY KEY IDENTITY(1,1), 
        fecha DATETIME DEFAULT GETDATE(), 
        archivo VARCHAR(255), 
        registro_nombre VARCHAR(255),
        motivo_error VARCHAR(255) 
    );
END 
GO