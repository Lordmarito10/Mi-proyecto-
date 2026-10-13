-- Motor utilizado: Microsoft SQL Server (SSMS)
-- Proyecto: RetailPro
-- Entrega: Pre-entrega 4 - Consultas SQL de negocio
-- Archivo: m4_consultas_negocio.sql
-- Base de datos: Ventas_Tech_DB

USE Ventas_Tech_DB;
GO

/* CONSULTA 1 — RESUMEN EJECUTIVO MENSUAL */
SELECT
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;
GO

/* CONSULTA 2 — RANKING DE PRODUCTOS: TOP 5 POR FACTURACIÓN */
SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_generado
FROM ventas
GROUP BY id_producto
ORDER BY total_generado DESC;
GO

/* CONSULTA 3 — CLIENTES RECURRENTES */
SELECT
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY cantidad_pedidos DESC, total_gastado DESC;
GO

/* CONSULTA 4 — FACTURACIÓN MENSUAL FRENTE AL PROMEDIO GENERAL */
WITH facturacion_mensual AS (
    SELECT
        MONTH(fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
),
promedio_mensual AS (
    SELECT AVG(total_facturado) AS promedio_general
    FROM facturacion_mensual
)
SELECT
    fm.mes,
    fm.total_facturado,
    pm.promedio_general AS promedio_mensual_general,
    CASE
        WHEN fm.total_facturado >= pm.promedio_general THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparacion_promedio
FROM facturacion_mensual AS fm
CROSS JOIN promedio_mensual AS pm
ORDER BY fm.mes;
GO

/* BLOQUE DE CIERRE — 3 HALLAZGOS
   La base de M3 incluye ventas solamente de marzo de 2024.
   Los siguientes hallazgos describen el alcance de los datos y
   las métricas que permiten obtener las consultas; no inventan
   tendencias que no se pueden comprobar con el período disponible.
*/
-- Hallazgo 1: Los registros de ventas disponibles corresponden a marzo de 2024.
-- Hallazgo 2: El ranking ordena los productos por total facturado y muestra las unidades vendidas.
-- Hallazgo 3: La consulta de clientes recurrentes identifica a quienes tienen más de un pedido
--             y calcula el importe total asociado a sus compras.
