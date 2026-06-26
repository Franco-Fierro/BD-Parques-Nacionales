--Universidad Nacional de La Matanza
--MATERIA: BASES DE DATOS APLICADA
--COMISION: 5600
--GRUPO: 03
--FIERRO, FRANCO EZEQUIEL
--GISMONDI, FRANCISCO


USE COM5600_G03
GO


CREATE OR ALTER PROCEDURE Comercial.SP_ReporteVisitasPorPeriodo
    @Periodo VARCHAR(10),
    @id_parque INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF UPPER(@Periodo) = 'SEMANA'
    BEGIN
        SELECT
            p.id_parque,
            p.nombre AS Parque,
            YEAR(e.fecha_acceso) AS Anio,
            DATEPART(ISO_WEEK, e.fecha_acceso) AS Semana,
            COUNT(*) AS Cantidad_Visitas
        FROM Comercial.Entrada e
        INNER JOIN Parques.Parque_nacional p ON e.id_parque = p.id_parque
        WHERE (@id_parque IS NULL OR e.id_parque = @id_parque)
        GROUP BY
            p.id_parque, p.nombre,
            YEAR(e.fecha_acceso),
            DATEPART(ISO_WEEK, e.fecha_acceso)
        ORDER BY p.nombre, Anio, Semana;
    END

    ELSE IF UPPER(@Periodo) = 'MES'
    BEGIN
        SELECT
            p.id_parque,
            p.nombre AS Parque,
            YEAR(e.fecha_acceso) AS Anio,
            MONTH(e.fecha_acceso) AS Mes,
            COUNT(*) AS Cantidad_Visitas
        FROM Comercial.Entrada e
        INNER JOIN Parques.Parque_nacional p ON e.id_parque = p.id_parque
        WHERE (@id_parque IS NULL OR e.id_parque = @id_parque)
        GROUP BY
            p.id_parque, p.nombre,
            YEAR(e.fecha_acceso),
            MONTH(e.fecha_acceso)
        ORDER BY p.nombre, Anio, Mes;
    END

    ELSE IF UPPER(@Periodo) = 'ANIO'
    BEGIN
        SELECT
            p.id_parque,
            p.nombre AS Parque,
            YEAR(e.fecha_acceso) AS Anio,
            COUNT(*) AS Cantidad_Visitas
        FROM Comercial.Entrada e
        INNER JOIN Parques.Parque_nacional p ON e.id_parque = p.id_parque
        WHERE (@id_parque IS NULL OR e.id_parque = @id_parque)
        GROUP BY
            p.id_parque, p.nombre,
            YEAR(e.fecha_acceso)
        ORDER BY p.nombre, Anio;
    END

    ELSE
        THROW 50001, 'Periodo invalido. Debe ser SEMANA, MES o ANIO.', 1;
END
GO





CREATE OR ALTER PROCEDURE Comercial.SP_ReporteIngresosPorParque
    @Periodo VARCHAR(10),
    @id_parque INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF UPPER(@Periodo) NOT IN ('SEMANA','MES','ANIO')
        THROW 50001, 'Periodo invalido. Debe ser SEMANA, MES o ANIO.', 1;

    -- ========================================================================
    -- RAMA MES
    -- ========================================================================
    IF UPPER(@Periodo) = 'MES'
    BEGIN
        ;WITH Ingresos AS (
            SELECT
                en.id_parque,
                YEAR(v.fecha_emision)  AS anio,
                MONTH(v.fecha_emision) AS periodo,
                'ENTRADA'              AS concepto,
                dv.subtotal            AS monto
            FROM Comercial.Detalle_venta dv
            INNER JOIN Comercial.Venta v        ON v.id_venta   = dv.id_venta
            INNER JOIN Comercial.Item_vendible i ON i.id_item    = dv.id_item
            INNER JOIN Comercial.Entrada en      ON en.id_entrada = i.id_entrada
            WHERE i.tipo_item = 'Entrada'

            UNION ALL

            SELECT
                a.id_parque,
                YEAR(v.fecha_emision)  AS anio,
                MONTH(v.fecha_emision) AS periodo,
                'TOUR'                 AS concepto,
                dv.subtotal            AS monto
            FROM Comercial.Detalle_venta dv
            INNER JOIN Comercial.Venta v          ON v.id_venta  = dv.id_venta
            INNER JOIN Comercial.Item_vendible i   ON i.id_item   = dv.id_item
            INNER JOIN Comercial.Ticket_actividad t ON t.id_ticket = i.id_ticket
            INNER JOIN Actividades.Turno_actividad tu ON tu.id_turno = t.id_turno
            INNER JOIN Actividades.Actividad a        ON a.id_actividad = tu.id_actividad
            WHERE i.tipo_item = 'Ticket'

            UNION ALL

            SELECT
                c.id_parque,
                YEAR(pc.fecha_pago)  AS anio,
                MONTH(pc.fecha_pago) AS periodo,
                'CONCESION'          AS concepto,
                pc.monto             AS monto
            FROM Concesiones.Pago_canon pc
            INNER JOIN Concesiones.Concesion c ON c.id_concesion = pc.id_concesion
        )
        SELECT
            p.id_parque,
            p.nombre AS Parque,
            ing.anio AS Anio,
            ing.periodo AS Mes,
            SUM(CASE WHEN ing.concepto = 'ENTRADA'   THEN ing.monto ELSE 0 END) AS Ingreso_Entradas,
            SUM(CASE WHEN ing.concepto = 'TOUR'      THEN ing.monto ELSE 0 END) AS Ingreso_Tours,
            SUM(CASE WHEN ing.concepto = 'CONCESION' THEN ing.monto ELSE 0 END) AS Ingreso_Concesiones,
            SUM(ing.monto) AS Total_Ingresos
        FROM Ingresos ing
        INNER JOIN Parques.Parque_nacional p ON p.id_parque = ing.id_parque
        WHERE (@id_parque IS NULL OR ing.id_parque = @id_parque)
        GROUP BY p.id_parque, p.nombre, ing.anio, ing.periodo
        ORDER BY p.nombre, Anio, Mes;
    END
    ELSE IF UPPER(@Periodo) = 'ANIO'
    BEGIN
        ;WITH Ingresos AS(
            SELECT
            en.id_parque,
            YEAR(v.fecha_emision) AS anio,
            'ENTRADA' AS concepto,
            dv.subtotal AS monto
            FROM Comercial.Detalle_venta dv
            INNER JOIN Comercial.Venta v    ON v.id_venta = dv.id_venta
            INNER JOIN Comercial.Item_vendible i on i.id_item = dv.id_item
            INNER JOIN Comercial.Entrada en ON en.id_entrada = i.id_entrada
            WHERE i.tipo_item='Entrada'

            UNION ALL
            SELECT
                a.id_parque,
                YEAR(v.fecha_emision)  AS anio,
                'TOUR'                 AS concepto,
                dv.subtotal            AS monto
            FROM Comercial.Detalle_venta dv
            INNER JOIN Comercial.Venta v          ON v.id_venta  = dv.id_venta
            INNER JOIN Comercial.Item_vendible i   ON i.id_item   = dv.id_item
            INNER JOIN Comercial.Ticket_actividad t ON t.id_ticket = i.id_ticket
            INNER JOIN Actividades.Turno_actividad tu ON tu.id_turno = t.id_turno
            INNER JOIN Actividades.Actividad a        ON a.id_actividad = tu.id_actividad
            WHERE i.tipo_item = 'Ticket'

            UNION ALL

            SELECT
                c.id_parque,
                YEAR(pc.fecha_pago)  AS anio,
                'CONCESION'          AS concepto,
                pc.monto             AS monto
            FROM Concesiones.Pago_canon pc
            INNER JOIN Concesiones.Concesion c ON c.id_concesion = pc.id_concesion
        )
        SELECT
            p.id_parque,
            p.nombre AS Parque,
            ing.anio AS Anio,
            SUM(CASE WHEN ing.concepto = 'ENTRADA'   THEN ing.monto ELSE 0 END) AS Ingreso_Entradas,
            SUM(CASE WHEN ing.concepto = 'TOUR'      THEN ing.monto ELSE 0 END) AS Ingreso_Tours,
            SUM(CASE WHEN ing.concepto = 'CONCESION' THEN ing.monto ELSE 0 END) AS Ingreso_Concesiones,
            SUM(ing.monto) AS Total_Ingresos
        FROM Ingresos ing
        INNER JOIN Parques.Parque_nacional p ON p.id_parque = ing.id_parque
        WHERE (@id_parque IS NULL OR ing.id_parque = @id_parque)
        GROUP BY p.id_parque, p.nombre, ing.anio
        ORDER BY p.nombre, Anio;
    END
    ELSE IF UPPER(@Periodo) = 'SEMANA'
    BEGIN
        ;WITH Ingresos AS (
  
            SELECT
                en.id_parque,
                YEAR(v.fecha_emision)  AS anio,
                DATEPART(ISO_WEEK, v.fecha_emision) AS periodo,
                'ENTRADA'              AS concepto,
                dv.subtotal            AS monto
            FROM Comercial.Detalle_venta dv
            INNER JOIN Comercial.Venta v        ON v.id_venta   = dv.id_venta
            INNER JOIN Comercial.Item_vendible i ON i.id_item    = dv.id_item
            INNER JOIN Comercial.Entrada en      ON en.id_entrada = i.id_entrada
            WHERE i.tipo_item = 'Entrada'

            UNION ALL

            SELECT
                a.id_parque,
                YEAR(v.fecha_emision)  AS anio,
                DATEPART(ISO_WEEK, v.fecha_emision) AS periodo,
                'TOUR'                 AS concepto,
                dv.subtotal            AS monto
            FROM Comercial.Detalle_venta dv
            INNER JOIN Comercial.Venta v          ON v.id_venta  = dv.id_venta
            INNER JOIN Comercial.Item_vendible i   ON i.id_item   = dv.id_item
            INNER JOIN Comercial.Ticket_actividad t ON t.id_ticket = i.id_ticket
            INNER JOIN Actividades.Turno_actividad tu ON tu.id_turno = t.id_turno
            INNER JOIN Actividades.Actividad a        ON a.id_actividad = tu.id_actividad
            WHERE i.tipo_item = 'Ticket'

            UNION ALL
            SELECT
                c.id_parque,
                YEAR(pc.fecha_pago)  AS anio,
                DATEPART(ISO_WEEK,pc.fecha_pago) AS periodo,
                'CONCESION'          AS concepto,
                pc.monto             AS monto
            FROM Concesiones.Pago_canon pc
            INNER JOIN Concesiones.Concesion c ON c.id_concesion = pc.id_concesion
        )
        SELECT
            p.id_parque,
            p.nombre AS Parque,
            ing.anio AS Anio,
            ing.periodo AS Semana,
            SUM(CASE WHEN ing.concepto = 'ENTRADA'   THEN ing.monto ELSE 0 END) AS Ingreso_Entradas,
            SUM(CASE WHEN ing.concepto = 'TOUR'      THEN ing.monto ELSE 0 END) AS Ingreso_Tours,
            SUM(CASE WHEN ing.concepto = 'CONCESION' THEN ing.monto ELSE 0 END) AS Ingreso_Concesiones,
            SUM(ing.monto) AS Total_Ingresos
        FROM Ingresos ing
        INNER JOIN Parques.Parque_nacional p ON p.id_parque = ing.id_parque
        WHERE (@id_parque IS NULL OR ing.id_parque = @id_parque)
        GROUP BY p.id_parque, p.nombre, ing.anio, ing.periodo
        ORDER BY p.nombre, Anio, Semana;
    END

END
GO






CREATE OR ALTER PROCEDURE Concesiones.SP_ReporteDeudoresXML
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @hoy DATE = CAST(GETDATE() AS DATE);

    ;WITH MesesEsperados AS (
        -- el primer mes de cada concesion
        SELECT
            c.id_concesion,
            c.id_empresa,
            c.monto_alquiler,
            c.fecha_inicio AS periodo
        FROM Concesiones.Concesion c
        WHERE c.fecha_inicio <= @hoy

        UNION ALL

        --suma un mes mientras no pase de hoy
        SELECT
            me.id_concesion,
            me.id_empresa,
            me.monto_alquiler,
            DATEADD(MONTH, 1, me.periodo)
        FROM MesesEsperados me
        WHERE DATEADD(MONTH, 1, me.periodo) <= @hoy
    )
    SELECT
        deudor.razon_social    AS Concesionario,
        YEAR(me.periodo)  AS Anio,
        MONTH(me.periodo) AS Mes,
        me.monto_alquiler AS Monto_Adeudado
    FROM MesesEsperados me
    INNER JOIN Concesiones.Empresa deudor ON deudor.id_empresa = me.id_empresa
    WHERE NOT EXISTS (
        SELECT 1 FROM Concesiones.Pago_canon pc
        WHERE pc.id_concesion = me.id_concesion
          AND pc.periodo_anio = YEAR(me.periodo)
          AND pc.periodo_mes  = MONTH(me.periodo)
    )
    ORDER BY Concesionario, Anio, Mes
    FOR XML AUTO, ROOT('Deudores'), ELEMENTS
    OPTION (MAXRECURSION 0);
END
GO





CREATE OR ALTER PROCEDURE Comercial.SP_ReporteMatrizVisitas
    @anio INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Parque,
        [1] AS Ene, [2] AS Feb, [3] AS Mar, [4] AS Abr,
        [5] AS May, [6] AS Jun, [7] AS Jul, [8] AS Ago,
        [9] AS Sep, [10] AS Oct, [11] AS Nov, [12] AS Dic
    FROM (
        SELECT
            p.nombre              AS Parque,
            MONTH(e.fecha_acceso) AS Mes
        FROM Comercial.Entrada e
        INNER JOIN Parques.Parque_nacional p ON p.id_parque = e.id_parque
        WHERE YEAR(e.fecha_acceso) = @anio
    ) AS fuente
    PIVOT (
        COUNT(Mes) FOR Mes IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
    ) AS pvt
    ORDER BY Parque;
END
GO


CREATE OR ALTER PROCEDURE Concesiones.SP_ReporteParquesConcesionesXML
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Parque.nombre,
        Parque.id_parque,
        (
            SELECT
                Empresa.razon_social,
                Empresa.rubro_principal,
                Concesion.fecha_inicio,
                Concesion.fecha_fin,
                Concesion.monto_alquiler
            FROM Concesiones.Concesion AS Concesion
            INNER JOIN Concesiones.Empresa AS Empresa
                ON Empresa.id_empresa = Concesion.id_empresa
            WHERE Concesion.id_parque = Parque.id_parque
            FOR XML AUTO, TYPE, ELEMENTS
        )
    FROM Parques.Parque_nacional AS Parque
    ORDER BY Parque.nombre
    FOR XML AUTO, ROOT('Parques'), ELEMENTS;
END
GO