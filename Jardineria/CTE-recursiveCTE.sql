-- Active: 1762272161423@@127.0.0.1@3306@jardineria
-----------------------
-- Consulta 1 
-----------------------

-- Muestra el nombre de los empleados y el total de ventas que han realizado en 2023, pero solo si superan las 50 unidades vendidas.
WITH VentasPorAnyo AS (
    SELECT
        emp.codigo_empleado,
        CONCAT_WS(' ', emp.nombre, emp.apellido1, emp.apellido2) AS nombre_empleado,
        COUNT(ped.codigo_pedido) AS total_ventas,
        SUM(detped.cantidad) AS unidades_vendidas
    FROM empleado emp
    LEFT JOIN cliente cli ON cli.codigo_empleado_rep_ventas = emp.codigo_empleado
    LEFT JOIN pedido ped ON ped.codigo_cliente = cli.codigo_cliente
    LEFT JOIN detalle_pedido detped ON detped.codigo_pedido = ped.codigo_pedido
    WHERE YEAR(ped.fecha_pedido) = 2023
    GROUP BY 
        emp.codigo_empleado,
        emp.nombre,
        emp.apellido1,
        emp.apellido2
)
SELECT
    vpa.codigo_empleado AS "Codigo Empleado",
    vpa.nombre_empleado AS "Nombre Empleado",
    vpa.total_ventas AS "Total Ventas",
    vpa.unidades_vendidas AS "Unidades Vendidas"
FROM VentasPorAnyo vpa
WHERE vpa.unidades_vendidas > 50

-----------------------
-- Consulta 2
-----------------------

-- Compara el precio de cada producto con el precio promedio de su categoría. Muestra los productos que estén un 20% por encima del promedio.
WITH PromedioCategoria AS (
    SELECT
        gampro.gama,
        ROUND(AVG(pro.precio_proveedor), 2) AS precio_promedio
    FROM gama_producto gampro
    LEFT JOIN producto pro ON pro.gama = gampro.gama
    GROUP BY gampro.gama
),
ProductosPromedioCategoria AS (
    SELECT
        pro.codigo_producto,
        pro.nombre,
        pro.gama,
        pro.dimensiones,
        pro.proveedor,
        pro.descripcion,
        pro.cantidad_en_stock,
        pro.precio_venta,
        pro.precio_proveedor,
        pc.precio_promedio
    FROM producto pro
    INNER JOIN PromedioCategoria pc ON pro.gama = pc.gama
    WHERE ((pro.precio_proveedor / pc.precio_promedio) * 100) > 120 -- 20% por encima del 100%
    -- WHERE pro.precio_proveedor > pc.precio_promedio * 1.2
)
SELECT
    ppc.codigo_producto AS "Codigo Producto",
    ppc.nombre AS "Nombre",
    ppc.gama AS "Gama",
    ppc.dimensiones AS "Dimensiones",
    ppc.Proveedor AS "Proveedor",
    ppc.descripcion AS "Descripcion",
    ppc.cantidad_en_stock AS "Cantidad en Stock",
    ppc.precio_venta AS "Precio Venta",
    ppc.precio_proveedor AS "Precio Proveedor",
    ppc.precio_promedio AS "Promedio por Gama"
FROM ProductosPromedioCategoria ppc
ORDER BY ppc.gama