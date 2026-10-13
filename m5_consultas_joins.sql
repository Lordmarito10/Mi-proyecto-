-- Motor utilizado: Microsoft SQL Server (SSMS)
-- Proyecto: RetailPro
-- Entrega: Pre-entrega 5 - Consultas con JOINs
-- Archivo: m5_consultas_joins.sql
-- Base de datos: Ventas_Tech_DB
--
-- Nota: el esquema de M3 contiene categorias, clientes, productos y ventas.
-- No incluye región, segmento ni canal real. Para el consolidado se usan
-- dos períodos de fechas como orígenes ilustrativos, sin afirmar que sean
-- canales reales del negocio.

USE Ventas_Tech_DB;
GO

/* =========================================================
   CONSULTA 1 — VISTA BASE DEL PROYECTO (INNER JOIN)
   Ventas enriquecidas con cliente, producto y categoría.
   ========================================================= */

SELECT
    v.fecha_venta,
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.email,
    c.ciudad,
    p.id_producto,
    p.nombre_producto AS descripcion_producto,
    cat.nombre_categoria AS categoria_producto,
    v.cantidad,
    v.precio_unitario,
    CAST(v.cantidad * v.precio_unitario AS DECIMAL(12,2)) AS total_venta
FROM ventas AS v
INNER JOIN clientes AS c
    ON v.id_cliente = c.id_cliente
INNER JOIN productos AS p
    ON v.id_producto = p.id_producto
INNER JOIN categorias AS cat
    ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta;
GO

/* =========================================================
   CONSULTA 2 — CLIENTES SIN VENTAS (LEFT JOIN)
   ========================================================= */

SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes AS c
LEFT JOIN ventas AS v
    ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL
ORDER BY c.nombre;
GO

/* =========================================================
   CONSULTA 3 — PRODUCTOS SIN VENTAS (LEFT JOIN)
   ========================================================= */

SELECT
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos AS p
INNER JOIN categorias AS cat
    ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas AS v
    ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL
ORDER BY p.nombre_producto;
GO

/* =========================================================
   CONSULTA 4 — CONSOLIDADO POR ORIGEN (UNION ALL)
   La consigna indica crear el origen como literal. Como la base
   de M3 no tiene una columna de canal, se separan las ventas por
   período: hasta el 10/03/2024 y desde el 11/03/2024. Los nombres
   son etiquetas de período, no canales reales.
   ========================================================= */

SELECT
    origen,
    SUM(total) AS total_origen
FROM (
    SELECT
        fecha_venta,
        cantidad * precio_unitario AS total,
        'Periodo_1_hasta_10_marzo' AS origen
    FROM ventas
    WHERE fecha_venta <= '2024-03-10'

    UNION ALL

    SELECT
        fecha_venta,
        cantidad * precio_unitario AS total,
        'Periodo_2_desde_11_marzo' AS origen
    FROM ventas
    WHERE fecha_venta >= '2024-03-11'
) AS consolidado
GROUP BY origen
ORDER BY origen;
GO
