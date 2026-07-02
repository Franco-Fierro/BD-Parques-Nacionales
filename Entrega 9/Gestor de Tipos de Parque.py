import tkinter as tk
from tkinter import messagebox
import pyodbc
# --- CONFIGURACIÓN DE CONEXIÓN ---
# Reemplaza con los datos de tu SQL Server
CONNECTION_STRING = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=NOMBRE_DE_TU_SERVIDOR_SQL;"
    "DATABASE=TU_BASE_DE_DATOS;"
    "Trusted_Connection=yes;"
)

def conectar():
    try:
        return pyodbc.connect(CONNECTION_STRING)
    except Exception as e:
        messagebox.showerror("Error de Conexión", f"No se pudo conectar a la BD:\n{e}")
        return None

# --- FUNCIONES ABM ---
def listar_tipos():
    lista_box.delete(0, tk.END)
    conn = conectar()
    if conn:
        cursor = conn.cursor()
        cursor.execute("EXEC Parques.SP_Listar_TipoParque")
        for fila in cursor.fetchall():
            lista_box.insert(tk.END, f"{fila[0]} - {fila[1]}")
        conn.close()

def agregar_tipo():
    # .strip() elimina espacios en blanco; evita enviar "   " a la base de datos
    desc = entry_desc.get().strip() 

    if not desc:
        messagebox.showwarning("Atención", "La descripción no puede estar vacía.")
        return

    conn = conectar()
    if conn:
        try:
            cursor = conn.cursor()

            # Declaramos la variable de salida dentro de la consulta SQL enviada
            query = """
                DECLARE @out_id tinyint;
                EXEC Parques.SP_AgregarTipoParque 
                    @descripcion = ?, 
                    @id_tipo_parque = @out_id OUTPUT;
                SELECT @out_id;
            """
            
            cursor.execute(query, desc)
            
            # Capturamos el SCOPE_IDENTITY() que devolvió el procedimiento
            row = cursor.fetchone()
            id_generado = row[0] if row else "Desconocido"

            conn.commit()

            entry_desc.delete(0, tk.END)
            listar_tipos()
            
            messagebox.showinfo("Éxito", f"Tipo de parque agregado correctamente (ID: {id_generado}).")

        except Exception as e:
            # Si el SQL ejecuta tu "THROW 50001", el error se captura aquí amigablemente
            conn.rollback()
            messagebox.showerror("Error SQL", f"No se pudo registrar:\n{e}")

        finally:
            # Pase lo que pase (éxito o error), liberamos la conexión
            conn.close()

def eliminar_tipo():
    seleccion = lista_box.curselection()
    if not seleccion:
        messagebox.showwarning("Atención", "Por favor, seleccione un tipo de parque de la lista.")
        return

    # Extraemos el ID del item seleccionado
    item = lista_box.get(seleccion[0])
    id_tipo = item.split(" - ")[0] 

    # Confirmación de seguridad antes de borrar
    if not messagebox.askyesno("Confirmar", "¿Está seguro de que desea eliminar este tipo de parque?"):
        return

    conn = conectar()
    if conn:
        try:
            cursor = conn.cursor()
            
            # Ejecutamos el SP enviando el ID convertido a entero (adecuado para TINYINT)
            cursor.execute("EXEC Parques.SP_Borrar_Tipo_Parque @id_tipo_parque=?", int(id_tipo))
            
            # Aunque el SP tiene un COMMIT interno, pyodbc suele requerir el commit de la conexión
            conn.commit() 
            
            # Actualizamos la interfaz
            listar_tipos()
            messagebox.showinfo("Éxito", "Tipo de parque eliminado correctamente.")

        except Exception as e:
            # Si el SP arroja THROW 50003 o 50004, caerá aquí.
            # Hacemos rollback en Python por seguridad si la transacción del driver quedó abierta
            try:
                conn.rollback()
            except:
                pass
            
            # Limpiamos el mensaje de error para que sea legible para el usuario final
            mensaje_error = str(e)
            if "No existe el Tipo de Parque" in mensaje_error:
                msg = "El tipo de parque seleccionado ya no existe en la base de datos."
            elif "hay un Parque Nacional vinculado" in mensaje_error:
                msg = "No se puede eliminar: Existen Parques Nacionales registrados que dependen de este tipo."
            else:
                msg = f"No se pudo eliminar el registro:\n{mensaje_error}"
                
            messagebox.showerror("Error al eliminar", msg)

        finally:
            # Garantiza el cierre de la conexión pase lo que pase
            conn.close()

# --- INTERFAZ GRÁFICA (Tkinter) ---
ventana = tk.Tk()
ventana.title("Gestión - Tipos de Parque")
ventana.geometry("350x400")

tk.Label(ventana, text="Descripción del Tipo de Parque:").pack(pady=5)
entry_desc = tk.Entry(ventana, width=30)
entry_desc.pack(pady=5)

btn_frame = tk.Frame(ventana)
btn_frame.pack(pady=10)

tk.Button(btn_frame, text="Agregar", command=agregar_tipo).grid(row=0, column=0, padx=5)
tk.Button(btn_frame, text="Eliminar Seleccionado", command=eliminar_tipo).grid(row=0, column=1, padx=5)

tk.Label(ventana, text="Listado de Tipos (ID - Descripción):").pack(pady=5)
lista_box = tk.Listbox(ventana, width=40, height=10)
lista_box.pack(pady=5)

tk.Button(ventana, text="Actualizar Lista", command=listar_tipos).pack(pady=5)

# Cargar la lista al iniciar
listar_tipos()

ventana.mainloop()