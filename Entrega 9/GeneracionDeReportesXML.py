import tkinter as tk
from tkinter import ttk, messagebox, filedialog
import pyodbc
import xml.dom.minidom
# --- CONFIGURACIÓN DE CONEXIÓN ---
# Reemplaza con los datos de tu SQL Server
CONNECTION_STRING = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=NOMBRE_DE_TU_SERVIDOR_SQL;"
    "DATABASE=TU_BASE_DE_DATOS;"
    "Trusted_Connection=yes;"
)


def exportar_reporte_xml(nombre_sp, nombre_archivo_sugerido):
    try:
        conn = pyodbc.connect(CONNECTION_STRING)
        cursor = conn.cursor()
        
        cursor.execute(f"EXEC {nombre_sp}") 
        
        filas = cursor.fetchall()
        
        if not filas:
            messagebox.showwarning("Sin datos", f"El reporte {nombre_sp} no generó información.")
            return
            
        xml_crudo = "".join(fila[0] for fila in filas if fila[0] is not None)
        
        if not xml_crudo.strip():
            messagebox.showwarning("Sin datos", "El reporte se generó vacío.")
            return

        try:
            dom = xml.dom.minidom.parseString(xml_crudo)
            xml_formateado = dom.toprettyxml(indent="  ", encoding="utf-8").decode("utf-8")
            
            lineas = [linea for linea in xml_formateado.splitlines() if linea.strip()]
            xml_listo = "\n".join(lineas)
            
        except Exception as e:
            print(f"Error interno de minidom: {e}") 
            xml_listo = xml_crudo

        ruta_guardado = filedialog.asksaveasfilename(
            title=f"Guardar {nombre_archivo_sugerido}",
            initialfile=nombre_archivo_sugerido,
            defaultextension=".xml",
            filetypes=(("Archivos XML", "*.xml"), ("Todos los archivos", "*.*"))
        )
        
        if not ruta_guardado:
            return 
            
        with open(ruta_guardado, "w", encoding="utf-8") as archivo_xml:
            archivo_xml.write(xml_listo)
            
        messagebox.showinfo("Éxito", f"Reporte guardado exitosamente en:\n{ruta_guardado}")

    except pyodbc.Error as e:
        messagebox.showerror("Error de Base de Datos", f"Fallo al generar el reporte:\n{e}")
    except Exception as e:
        messagebox.showerror("Error de Sistema", f"Fallo al guardar el archivo:\n{e}")
    finally:
        if 'conn' in locals():
            conn.close()

# --- Interfaz Gráfica (Agrega esto a tu ventana existente) ---
root = tk.Tk()
root.title("Gestión de Parques Nacionales - Módulos Extra")
root.geometry("400x250")

# Marco para organizar los botones
frame_extras = ttk.LabelFrame(root, text="Módulos de Integración (Entregas 6 y 7)", padding=20)
frame_extras.pack(fill="both", expand=True, padx=10, pady=10)

lbl_instrucciones = ttk.Label(frame_extras, text="Seleccione la operación que desea realizar:")
lbl_instrucciones.pack(pady=10)

# Botón para el Reporte de Deudores
btn_xml_deudores = ttk.Button(
    frame_extras, 
    text="Exportar Reporte de Deudores (XML)", 
    command=lambda: exportar_reporte_xml("Concesiones.SP_ReporteDeudoresXML", "Reporte_Deudores.xml")
)
btn_xml_deudores.pack(fill="x", pady=5)

# Botón para el Reporte de Parques y Concesiones
btn_xml_concesiones = ttk.Button(
    frame_extras, 
    text="Exportar Parques y Concesiones (XML)", 
    command=lambda: exportar_reporte_xml("Concesiones.SP_ReporteParquesConcesionesXML", "Parques_y_Concesiones.xml")
)
btn_xml_concesiones.pack(fill="x", pady=5)

root.mainloop()