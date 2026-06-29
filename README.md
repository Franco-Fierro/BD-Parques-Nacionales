# BD-Parques-Nacionales

Este proyecto es un sistema de gestión de Parques Nacionales diseñado para una materia de Bases de Datos Aplicada. Incluye la creación de una base de datos relacional, la definición de esquemas especializados, procedimientos almacenados para operaciones CRUD, importación de datos desde archivos CSV, reportes de actividad y un modelo de seguridad con roles.

## Objetivo

El objetivo del trabajo es modelar y gestionar información relacionada con parques, guardaparques, actividades turísticas, concesiones y comercio dentro de un sistema centralizado. El proyecto está pensado para soportar:

- Registro y administración de Parques Nacionales, Reservas y Parques Provinciales.
- Gestión de ubicaciones, tipos de parques y datos geográficos como latitud y longitud.
- Control de guardaparques y asignaciones de personal a parques.
- Administración de actividades turísticas, guías y turnos asociados.
- Procesos comerciales de venta de entradas, tickets de actividades y reportes de ingresos y visitas.
- Importación de datos desde archivos CSV para poblar la base con información realista.
- Definición de roles y permisos para asegurar el acceso a las operaciones.

## Contenido principal de `sql/`

- `00_CreacionEstructuraYTablas.sql`
  - Crea la base de datos `COM5600_G03` cuando no existe.
  - Define los esquemas `Parques`, `Actividades`, `Comercial` y `Concesiones`.
  - Crea tablas para ubicaciones, tipos de parque, parques nacionales, guardaparques, asignaciones y más.

- `01_StoreProcedureAgregado.sql`
  - Procedimientos almacenados para insertar nuevas filas.
  - Incluye validaciones de integridad y retorno de IDs generados.
  - Cubre datos maestros, parques, guardaparques, guías y actividades.

- `01_StoreProcedureModificacion.sql`
  - Procedimientos almacenados para modificar registros existentes.
  - Permite actualizar ubicaciones, tipos de parque, datos de parques, guardaparques y otros objetos.
  - Controla la consistencia y previene cambios inválidos.

- `01_StoreProcedureBorrado.sql`
  - Procedimientos almacenados para eliminar registros con validaciones referenciales.
  - Evita borrados cuando existen dependencias activas.
  - Incluye eliminaciones para ubicaciones, tipos de parque, actividades y guías por actividad.

- `01_StoreProcedureLogicaNegocio.sql`
  - Contiene lógica de negocio adicional para el sistema.
  - Normaliza operaciones complejas y encapsula reglas de la aplicación.

- `02_StoredProcedureImportacion.sql`
  - Procedimientos para importar datos desde archivos CSV.
  - Incluye limpieza, validación y manejo de errores.
  - Genera registros de importación y evita duplicados al insertar ubicaciones, tipos y parques.

- `02_PruebasDeImportacion.sql`
  - Scripts para verificar la importación de datos desde los archivos de ejemplo.
  - Permite comprobar que los registros se cargan correctamente.

- `03_StoredProcedureReportes.sql`
  - Procedimientos para generar reportes de visitas por período y análisis de ingresos.
  - Soporta filtros por semana, mes y año.

- `04_CreacionDeRoles.sql`
  - Define roles de la base de datos para distintos perfiles de usuario.
  - Asigna permisos de ejecución a procedimientos específicos.
  - Restringe inserciones, actualizaciones y borrados sobre esquemas según el rol.

- `04_ModificadoDeStoredProcedures.sql`
  - Cambios adicionales y ajustes en los procedimientos existentes.

- `04_SeguridadYCifrado.sql`
  - Contiene reglas y configuraciones de seguridad y cifrado para la base.
