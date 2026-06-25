------------------------------------------------------------------
--Universidad Nacional de La Matanza
--MATERIA: BASES DE DATOS APLICADA
--COMISION: 5600
--GRUPO: 03
--FIERRO, FRANCO EZEQUIEL
--GISMONDI, FRANCISCO
----------------------------------------------------------------
-- Nombre del archivo: CreacionDeRoles.sql
-- Descripcion: el script contiene la creacion de los roles de la base de datos COM5600_G03
-- Objetivo: el script tiene como objetivo crear los roles de la base de datos COM5600_G03
----------------------------------------------------------------
USE COM5600_G03
GO
----------------------------------------------------------------

-- ADMINISTRADORES
CREATE ROLE Rol_Secretario_Administrativo;
CREATE ROLE Rol_Administrador_Parque;
CREATE ROLE Rol_Administrador_Parque_Tecnico;
CREATE ROLE Rol_Auditor;

--GUARDAPARQUES
CREATE ROLE Rol_Administrador_GuardaParques;

--ACTIVIDADES
CREATE ROLE Rol_Administrador_Actividades;
CREATE ROLE Rol_Administrador_Guias;

--CONCESIONES
CREATE ROLE Rol_Administrador_Concesiones;

--OPERATIVOS
CREATE ROLE Rol_Boleteria;
CREATE ROLE Rol_Importador;

GO
-- ==========================================
-- DENEGACIÓN EXPLÍCITA 
-- ==========================================

DENY INSERT, UPDATE, DELETE ON SCHEMA::Parques TO 
    Rol_Secretario_Administrativo, Rol_Administrador_Parque, 
    Rol_GuardaParque, Rol_Administrador_GuardaParques, 
    Rol_Administrador_Actividades, Rol_Administrador_Guias, Rol_Guia, 
    Rol_Administrador_Concesiones, Rol_Concesionarios, 
    Rol_Boleteria, Rol_Importador, Rol_Comprador;

DENY INSERT, UPDATE, DELETE ON SCHEMA::Actividades TO 
    Rol_Secretario_Administrativo, Rol_Administrador_Parque, 
    Rol_GuardaParque, Rol_Administrador_GuardaParques, 
    Rol_Administrador_Actividades, Rol_Administrador_Guias, Rol_Guia, 
    Rol_Administrador_Concesiones, Rol_Concesionarios, 
    Rol_Boleteria, Rol_Importador, Rol_Comprador;

DENY INSERT, UPDATE, DELETE ON SCHEMA::Comercial TO 
    Rol_Secretario_Administrativo, Rol_Administrador_Parque, 
    Rol_GuardaParque, Rol_Administrador_GuardaParques, 
    Rol_Administrador_Actividades, Rol_Administrador_Guias, Rol_Guia, 
    Rol_Administrador_Concesiones, Rol_Concesionarios, 
    Rol_Boleteria, Rol_Importador, Rol_Comprador;

DENY INSERT, UPDATE, DELETE ON SCHEMA::Concesiones TO 
    Rol_Secretario_Administrativo, Rol_Administrador_Parque, 
    Rol_GuardaParque, Rol_Administrador_GuardaParques, 
    Rol_Administrador_Actividades, Rol_Administrador_Guias, Rol_Guia, 
    Rol_Administrador_Concesiones, Rol_Concesionarios, 
    Rol_Boleteria, Rol_Importador, Rol_Comprador;
GO

-- ==========================================
-- Rol_Secretario_Administrativo
-- Maneja configuraciones estructurales y catálogos.
-- ==========================================
GRANT EXECUTE ON Parques.SP_AgregarUbicacion TO Rol_Secretario_Administrativo;
GRANT EXECUTE ON Parques.SP_AgregarTipoParque TO Rol_Secretario_Administrativo;
GRANT EXECUTE ON Actividades.SP_AgregarTipoActividad TO Rol_Secretario_Administrativo;
GRANT EXECUTE ON Comercial.SP_AgregarTipoVisitante TO Rol_Secretario_Administrativo;
GRANT EXECUTE ON Comercial.SP_AgregarPuntoDeVenta TO Rol_Secretario_Administrativo;
GRANT EXECUTE ON Comercial.SP_AgregarFormaDePago TO Rol_Secretario_Administrativo;
GRANT EXECUTE ON Parques.SP_Borrar_Ubicacion TO Rol_Secretario_Administrativo;
GRANT EXECUTE ON Parques.SP_Borrar_Tipo_Parque TO Rol_Secretario_Administrativo;

-- ==========================================
-- Rol_Administrador_Parque
-- Maneja los Parques y sus tarifarios.
-- ==========================================
GRANT EXECUTE ON Parques.SP_AgregarParque TO Rol_Administrador_Parque;
GRANT EXECUTE ON Parques.SP_Modificar_Parque_nacional TO Rol_Administrador_Parque;
GRANT EXECUTE ON Comercial.SP_AgregarTarifarioParque TO Rol_Administrador_Parque;
GRANT EXECUTE ON Comercial.SP_Modificar_Tarifario_parque TO Rol_Administrador_Parque;

-- ==========================================
-- Rol_Administrador_GuardaParques
-- RRHH exclusivo para los Guardaparques.
-- ==========================================
GRANT EXECUTE ON Parques.SP_AgregarGuardaparque TO Rol_Administrador_GuardaParques;
GRANT EXECUTE ON Parques.SP_Modificar_Datos_Guardaparque TO Rol_Administrador_GuardaParques;
GRANT EXECUTE ON Parques.SP_Modificar_Estado_Guardaparque TO Rol_Administrador_GuardaParques;
GRANT EXECUTE ON Parques.SP_AgregarGuardaparqueAParque TO Rol_Administrador_GuardaParques;
GRANT EXECUTE ON Parques.SP_Registrar_Egreso_guardaparque TO Rol_Administrador_GuardaParques;
GRANT EXECUTE ON Parques.SP_ReasignarGuardaparque TO Rol_Administrador_GuardaParques;

-- ==========================================
-- Rol_Administrador_Actividades y Guias
-- Planificación de excursiones y asignación de personal.
-- ==========================================
GRANT EXECUTE ON Actividades.SP_AgregarActividad TO Rol_Administrador_Actividades;
GRANT EXECUTE ON Actividades.SP_Modificar_Actividad TO Rol_Administrador_Actividades;
GRANT EXECUTE ON Actividades.SP_AgregarTurnoActividad TO Rol_Administrador_Actividades;
GRANT EXECUTE ON Actividades.SP_Modificar_Turno_actividad TO Rol_Administrador_Actividades;
GRANT EXECUTE ON Actividades.SP_Borrar_Turno_Actividad TO Rol_Administrador_Actividades;

GRANT EXECUTE ON Actividades.SP_AgregarGuia TO Rol_Administrador_Guias;
GRANT EXECUTE ON Actividades.SP_Modificar_Guia TO Rol_Administrador_Guias;
GRANT EXECUTE ON Actividades.SP_AgregarGuiaPorActividad TO Rol_Administrador_Guias;
GRANT EXECUTE ON Actividades.SP_Modificar_Guias_por_actividad TO Rol_Administrador_Guias;
GRANT EXECUTE ON Actividades.SP_Borrar_Guia_Por_Actividad TO Rol_Administrador_Guias;
GRANT EXECUTE ON Actividades.SP_AsignarGuiaConValidacion TO Rol_Administrador_Guias;

-- ==========================================
-- Rol_Boleteria
-- Maneja la caja y venta diaria de tickets y entradas.
-- ==========================================
GRANT EXECUTE ON Comercial.SP_AgregarVenta TO Rol_Boleteria;
GRANT EXECUTE ON Comercial.SP_AgregarEntrada TO Rol_Boleteria;
GRANT EXECUTE ON Comercial.SP_AgregarTicketActividad TO Rol_Boleteria;
GRANT EXECUTE ON Comercial.SP_AgregarItemVendible TO Rol_Boleteria;
GRANT EXECUTE ON Comercial.SP_AgregarDetalleVenta TO Rol_Boleteria;
GRANT EXECUTE ON Comercial.SP_RegistrarVenta TO Rol_Boleteria;

-- ==========================================
-- Rol_Administrador_Concesiones
-- Alta de empresas y control de sus pagos (Cánones).
-- ==========================================
GRANT EXECUTE ON Concesiones.SP_AgregarEmpresa TO Rol_Administrador_Concesiones;
GRANT EXECUTE ON Concesiones.SP_Modificar_Empresa TO Rol_Administrador_Concesiones;
GRANT EXECUTE ON Concesiones.SP_AgregarConcesion TO Rol_Administrador_Concesiones;
GRANT EXECUTE ON Concesiones.SP_Modificar_Datos_Concesion TO Rol_Administrador_Concesiones;
GRANT EXECUTE ON Concesiones.SP_AgregarPagoCanon TO Rol_Administrador_Concesiones;
GRANT EXECUTE ON Concesiones.SP_Modificar_Estado_Pago_Canon TO Rol_Administrador_Concesiones;
GRANT EXECUTE ON Concesiones.SP_AgregarEstadoConcesion TO Rol_Administrador_Concesiones;
GRANT EXECUTE ON Concesiones.SP_AgregarEstadoPago TO Rol_Administrador_Concesiones;
GRANT EXECUTE ON Concesiones.SP_RegistrarPagoCanon TO Rol_Administrador_Concesiones;
GRANT EXECUTE ON Concesiones.SP_RenovarConcesion TO Rol_Administrador_Concesiones;

-- ==========================================
-- Rol_Administrador_Parque_Tecnico (SysAdmin/Soporte)
-- Permiso total a nivel de esquemas.
-- ==========================================
GRANT CONTROL ON SCHEMA::Parques TO Rol_Administrador_Parque_Tecnico;
GRANT CONTROL ON SCHEMA::Actividades TO Rol_Administrador_Parque_Tecnico;
GRANT CONTROL ON SCHEMA::Comercial TO Rol_Administrador_Parque_Tecnico;
GRANT CONTROL ON SCHEMA::Concesiones TO Rol_Administrador_Parque_Tecnico;

-- ==========================================
-- Rol_Auditor
-- Solo lectura en todos los esquemas para generar reportes.
-- ==========================================
GRANT SELECT ON SCHEMA::Parques TO Rol_Auditor;
GRANT SELECT ON SCHEMA::Actividades TO Rol_Auditor;
GRANT SELECT ON SCHEMA::Comercial TO Rol_Auditor;
GRANT SELECT ON SCHEMA::Concesiones TO Rol_Auditor;

-- ==========================================
-- Rol_Importador
-- Permite importar datos desde archivos externos.
-- ==========================================
GRANT EXECUTE ON Parques.SP_ImportarParques TO Rol_Importador;
GRANT EXECUTE ON Actividades.SP_ImportarActividades TO Rol_Importador;


PRINT 'Asignación de permisos completada.';
GO