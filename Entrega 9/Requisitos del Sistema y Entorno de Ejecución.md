# Requisitos del Sistema y Entorno de Ejecución

Para garantizar el correcto funcionamiento de las aplicaciones desarrolladas en esta entrega y su correcta integración con el modelo de datos, el entorno debe cumplir con los siguientes requerimientos técnicos.

## 1. Motor de Base de Datos (Backend)

- **Servidor:** Microsoft SQL Server (versión Express, Developer o superior).
- **Estado de la BD:** La base de datos del proyecto debe estar creada, con sus tablas principales y catálogos previamente poblados mediante el script de datos de prueba.
- **Lógica de Negocio:** Todos los _Stored Procedures_ (procedimientos almacenados) de consulta ("To-Be") y de gestión (ABM) deben estar compilados y disponibles en el servidor.
- **Permisos:** Se requiere una cuenta de acceso válida (Autenticación de Windows o SQL Server) que posea permisos de lectura, escritura y ejecución de procedimientos sobre el esquema del proyecto.

---

## 2. Aplicación de Gestión Operativa (Python)

Para ejecutar la aplicación de escritorio basada en la interfaz gráfica de gestión, el equipo cliente necesita:

- **Intérprete de Python:** Python 3.8 o superior instalado en el sistema operativo.
- **Controladores del Sistema (Drivers):** Tener instalado el _ODBC Driver for SQL Server_ (se recomienda la versión 17 o superior) para permitir la comunicación entre Python y el motor de base de datos.
- **Dependencias y Librerías:**
  - `pyodbc`: Biblioteca encargada de gestionar la conexión y la ejecución de las sentencias SQL hacia el servidor.
  - `tkinter`: Componente para la renderización de la interfaz gráfica (incluido de forma nativa en la instalación estándar de Python en Windows).

> **Nota de instalación:** Las dependencias externas se pueden instalar desde la terminal ejecutando:
>
> ```bash
> pip install pyodbc
> ```

---

## 3. Plataforma de Business Intelligence (Power BI)

Para poder generar los reportes de análisis y visualización de datos, se requiere:

- **Software:** Microsoft Power BI Desktop (versión 2.XX o superior).
- **Conexión a la Base de Datos:** Configurar la conexión a la base de datos SQL Server mediante el conector nativo de Power BI.
