-- Active: 1762272161423@@127.0.0.1@3306@jardineria
USE jardineria;

--------------------------------------------------------
-- BLOQUE 1: INNER JOIN
--------------------------------------------------------

-- Consulta 1.1: Listar todos los clientes junto con su representante de ventas asignado
SELECT 
    c.codigo_cliente AS "Codigo Cliente", 
    c.nombre_cliente AS "Nombre Cliente", 
    c.apellido_contacto AS "Apellido Contacto", 
    e.codigo_empleado AS "Codigo Empleado", 
    e.nombre AS "Nombre Representante"
FROM cliente c
INNER JOIN empleado e
ON c.codigo_empleado_rep_ventas = e.codigo_empleado;

-- Consulta 1.2: Mostrar los pedidos con los detalles del cliente que los realizó
SELECT 
    p.codigo_pedido AS "Codigo Pedido", 
    p.fecha_pedido AS "Fecha Pedido",
    p.fecha_entrega AS "Fecha Entrega",
    p.estado AS "Estado Pedido", 
    c.codigo_cliente AS "Codigo Cliente",
    c.nombre_cliente AS "Nombre Cliente",
    c.nombre_contacto AS "Nombre Contacto",
    c.apellido_contacto AS "Apellido Contacto",
    c.telefono AS "Numero Telefonico",
    c.fax AS "Fax",
    c.linea_direccion1 AS "Direccion 1",
    c.linea_direccion2 AS "Direccion 2",
    c.ciudad AS "Ciudad",
    c.region AS "Region",
    c.pais AS "Pais",
    c.codigo_postal AS "Codigo Postal",
    c.codigo_empleado_rep_ventas AS "Codigo Representante de Ventas",
    c.limite_credito AS "Limite de Credito"
FROM pedido p
INNER JOIN cliente c
ON p.codigo_cliente = c.codigo_cliente;

-- Consulta 1.3: Obtener los productos con su información de gama correspondiente
SELECT 
    pro.codigo_producto AS "Codigo Producto",
    pro.nombre AS "Nombre Producto",
    gampro.gama AS "Gama Producto",
    gampro.descripcion_texto AS "Descripcion",
    gampro.descripcion_html AS "Descripcion Html"
FROM producto pro
INNER JOIN gama_producto gampro
ON pro.gama = gampro.gama;

-- Consulta 1.4: Listar los detalles de pedidos con información completa del producto
SELECT  
    detped.codigo_pedido AS "Codigo del Pedido",
    detped.cantidad AS "Cantidad",
    detped.precio_unidad AS "Precio por Unidad",
    detped.numero_linea AS "Numero Linea",
    pro.codigo_producto AS "Codigo Producto",
    pro.nombre AS "Nombre Producto",
    pro.gama AS "Gama",
    pro.dimensiones AS "Dimensiones",
    pro.proveedor AS "Proveedor",
    pro.descripcion AS "Descripcion",
    pro.cantidad_en_stock AS "Cantidad en Stock",
    pro.precio_venta AS "Precio de Venta",
    pro.precio_proveedor AS "Precio Proveedor"
FROM detalle_pedido detped
INNER JOIN producto pro
ON detped.codigo_producto = pro.codigo_producto;

-------------------------------------------------------------
-- BLOQUE 2: LEFT JOIN
-------------------------------------------------------------

-- Consulta 2.1: Listar todos los clientes y sus pagos (incluyendo clientes sin pagos)
SELECT
    cli.codigo_cliente AS "Codigo Cliente",
    cli.nombre_cliente AS "Nombre Cliente",
    cli.apellido_contacto AS "Apellido Contacto",
    cli.telefono AS "Telefono Contacto",
    cli.linea_direccion1 AS "Direccion 1",
    cli.linea_direccion2 AS "Direccion 2",
    cli.limite_credito AS "Limite de Credito",
    pag.id_transaccion AS "Identificador Transaccion",
    pag.forma_pago AS "Forma de Pago",
    pag.fecha_pago AS "Fecha del Pago",
    pag.total AS "Total"
FROM cliente cli
LEFT JOIN pago pag
ON pag.codigo_cliente = cli.codigo_cliente;

-- Consulta 2.2: Mostrar todos los empleados y sus subordinados directos (si los tienen)
SELECT
    emp.codigo_empleado AS "Codigo Empleado",
    emp.nombre AS "Nombre Empleado",
    emp.apellido1 AS "Apellido Empleado 1",
    emp.apellido2 AS "Apellido Empleado 2",
    emp.puesto AS "Puesto Empleado",
    emp1.codigo_empleado AS "Codigo Subordinado",
    emp1.nombre AS "Nombre Subordinado",
    emp1.apellido1 AS "Apellido Subordinado 1",
    emp1.apellido2 AS "Apellido Subordinado 2",
    emp1.puesto AS "Puesto Subordinado"
FROM empleado emp
LEFT JOIN empleado emp1
ON emp1.codigo_jefe = emp.codigo_empleado;

-- Consulta 2.3: Listar todos los productos y sus ventas (incluyendo productos no vendidos)
SELECT
    pro.codigo_producto AS "Codigo Producto",
    pro.nombre AS "Nombre Producto",
    pro.gama AS "Gama Producto",
    pro.precio_venta AS "Precio Venta",
    detped.codigo_pedido AS "Codigo Pedido",
    detped.cantidad AS "Cantidad",
    detped.numero_linea AS "Numero Linea"
FROM producto pro
LEFT JOIN detalle_pedido detped
ON detped.codigo_producto = pro.codigo_producto;

-- Consulta 2.4: Mostrar todas las oficinas y sus empleados (incluyendo oficinas sin empleados)
SELECT
    ofi.codigo_oficina AS "Codigo Oficina",
    ofi.ciudad AS "Ciudad",
    ofi.telefono AS "Telefono",
    ofi.linea_direccion1 AS "Direccion 1",
    ofi.linea_direccion2 AS "Direccion 2",
    emp.codigo_empleado AS "Codigo Empleado",
    emp.nombre AS "Nombre Empleado",
    emp.apellido1 AS "Apellido 1",
    emp.apellido2 AS "Apellido 2",
    emp.puesto AS "Puesto"
FROM oficina ofi
LEFT JOIN empleado emp
ON emp.codigo_oficina = ofi.codigo_oficina;

--------------------------------------------------------------------------
-- BLOQUE 3: RIGHT JOIN
--------------------------------------------------------------------------

-- Consulta 3.1: Mostrar todos los pagos y la información del cliente (incluyendo pagos sin cliente asociado)
SELECT
    pag.id_transaccion AS "Identificador Transaccion",
    pag.forma_pago AS "Forma de Pago",
    pag.fecha_pago AS "Fecha Pago",
    pag.total AS "Pago Total",
    cli.codigo_cliente AS "Codigo Cliente",
    cli.nombre_cliente AS "Nombre Cliente",
    cli.nombre_contacto AS "Nombre Contacto",
    cli.apellido_contacto AS "Apellido Contacto",
    cli.telefono AS "Telefono Contacto",
    cli.fax AS "Fax",
    cli.linea_direccion1 AS "Direccion 1",
    cli.linea_direccion2 AS "Direccion 2",
    cli.ciudad AS "Ciudad",
    cli.region AS "Region",
    cli.pais AS "Pais",
    cli.codigo_postal AS "Codigo Postal",
    cli.codigo_empleado_rep_ventas AS "Codigo Representante Ventas",
    cli.limite_credito AS "Limite de Credito"
FROM cliente cli
RIGHT JOIN pago pag
ON pag.codigo_cliente = cli.codigo_cliente;

-- Consulta 3.2: Listar todos los pedidos y sus detalles (incluyendo pedidos sin detalles)
SELECT
    ped.codigo_pedido AS "Codigo Pedido",
    ped.codigo_cliente AS "Codigo Cliente",
    ped.fecha_pedido AS "Fecha Pedido",
    ped.estado AS "Estado Pedido",
    ped.comentarios AS "Comentarios",
    detped.codigo_producto AS "Codigo Producto",
    detped.cantidad AS "Cantidad",
    detped.precio_unidad AS "Precio Unidad",
    detped.numero_linea AS "Numero Linea"
FROM detalle_pedido detped
RIGHT JOIN pedido ped
ON detped.codigo_pedido = ped.codigo_pedido;

-- Consulta 3.3: Mostrar todas las gamas de producto y los productos asociados (incluyendo gamas sin productos)
SELECT
    gamprod.gama AS "Gama Producto",
    gamprod.descripcion_texto AS "Descripcion",
    pro.codigo_producto AS "Codigo Producto",
    pro.nombre AS "Nombre Producto",
    pro.precio_venta AS "Precio Venta",
    pro.precio_proveedor AS "Precio Proveedor"
FROM producto pro
RIGHT JOIN gama_producto gamprod
ON pro.gama = gamprod.gama;

-- Consulta 3.4: Listar todos los empleados como jefes y sus subordinados (incluyendo jefes sin subordinados)
SELECT
    emp.codigo_empleado AS "Codigo Jefe",
    emp.nombre AS "Nombre Jefe",
    emp.apellido1 AS "Apellido Jefe 1",
    emp.apellido2 AS "Apellido Jefe 2",
    emp.puesto AS "Puesto Jefe",
    emp1.codigo_empleado AS "Codigo Subordinado",
    emp1.nombre AS "Nombre Subordinado",
    emp1.apellido1 AS "Apellido Subordinado 1",
    emp1.apellido2 AS "Apellido Subordinado 2",
    emp1.puesto AS "Puesto Subordinado"
FROM empleado emp
RIGHT JOIN empleado emp1
ON emp.codigo_jefe = emp1.codigo_empleado;

--------------------------------------------------------------------
-- BLOQUE 4: FULL OUTER JOIN 
--------------------------------------------------------------------
-- Full Outer Join Inclusive
SELECT
    detped.codigo_producto AS "Codigo Producto",
    detped.cantidad AS "Cantidad",
    detped.precio_unidad AS "Precio Unidad",
    ped.codigo_pedido AS "Codigo Pedido",
    ped.fecha_pedido AS "Fecha pedido"
FROM detalle_pedido detped
LEFT JOIN pedido ped
ON detped.codigo_pedido = ped.codigo_pedido

UNION

SELECT
    detped.codigo_producto AS "Codigo Producto",
    detped.cantidad AS "Cantidad",
    detped.precio_unidad AS "Precio Unidad",
    ped.codigo_pedido AS "Codigo Pedido",
    ped.fecha_pedido AS "Fecha pedido"
FROM detalle_pedido detped
RIGHT JOIN pedido ped
ON detped.codigo_pedido = ped.codigo_pedido;

-- Full Outer Join Inclusive
SELECT 
    emp.codigo_empleado AS "Codigo Jefe",
    emp.nombre AS "Nombre Jefe",
    emp.apellido1 AS "Apellido Jefe 1",
    emp.apellido2 AS "Apellido Jefe 2",
    emp.puesto AS "Puesto Jefe",
    emp1.codigo_empleado AS "Codigo Subordinado",
    emp1.nombre AS "Nombre Subordinado",
    emp1.apellido1 AS "Apellido Subordinado 1",
    emp1.apellido2 AS "Apellido Subordinado 2",
    emp1.puesto AS "Puesto Subordinado"
FROM empleado emp
LEFT JOIN empleado emp1
ON emp1.codigo_jefe = emp.codigo_empleado

UNION

SELECT 
    emp.codigo_empleado AS "Codigo Jefe",
    emp.nombre AS "Nombre Jefe",
    emp.apellido1 AS "Apellido Jefe 1",
    emp.apellido2 AS "Apellido Jefe 2",
    emp.puesto AS "Puesto Jefe",
    emp1.codigo_empleado AS "Codigo Subordinado",
    emp1.nombre AS "Nombre Subordinado",
    emp1.apellido1 AS "Apellido Subordinado 1",
    emp1.apellido2 AS "Apellido Subordinado 2",
    emp1.puesto AS "Puesto Subordinado"
FROM empleado emp
RIGHT JOIN empleado emp1
ON emp1.codigo_jefe = emp.codigo_empleado;

-- Full Outer Join Exclusive
SELECT 
    emp.codigo_empleado AS "Codigo Jefe",
    emp.nombre AS "Nombre Jefe",
    emp.apellido1 AS "Apellido Jefe 1",
    emp.apellido2 AS "Apellido Jefe 2",
    emp.puesto AS "Puesto Jefe",
    emp1.codigo_empleado AS "Codigo Subordinado",
    emp1.nombre AS "Nombre Subordinado",
    emp1.apellido1 AS "Apellido Subordinado 1",
    emp1.apellido2 AS "Apellido Subordinado 2",
    emp1.puesto AS "Puesto Subordinado"
FROM empleado emp
LEFT JOIN empleado emp1
ON emp1.codigo_jefe = emp.codigo_empleado
WHERE emp1.codigo_jefe IS NULL
    OR emp.codigo_empleado IS NULL

UNION

SELECT 
    emp.codigo_empleado AS "Codigo Jefe",
    emp.nombre AS "Nombre Jefe",
    emp.apellido1 AS "Apellido Jefe 1",
    emp.apellido2 AS "Apellido Jefe 2",
    emp.puesto AS "Puesto Jefe",
    emp1.codigo_empleado AS "Codigo Subordinado",
    emp1.nombre AS "Nombre Subordinado",
    emp1.apellido1 AS "Apellido Subordinado 1",
    emp1.apellido2 AS "Apellido Subordinado 2",
    emp1.puesto AS "Puesto Subordinado"
FROM empleado emp
RIGHT JOIN empleado emp1
ON emp1.codigo_jefe = emp.codigo_empleado
WHERE emp1.codigo_jefe IS NULL
    OR emp.codigo_empleado IS NULL;

-----------------------------------------------
-- EXTRA PRACTICE
-----------------------------------------------

-- Muestra el total de dinero que ha gastado cada cliente sumando todas las líneas de sus pedidos
SELECT
    cli.codigo_cliente AS "Codigo Cliente",
    cli.nombre_cliente AS "Nombre Cliente",
    cli.apellido_contacto AS "Apellido Contacto",
    IFNULL(SUM(detped.cantidad * detped.precio_unidad), 0) AS "Total Gastado"
FROM cliente cli
LEFT JOIN pedido ped
    ON ped.codigo_cliente = cli.codigo_cliente
LEFT JOIN detalle_pedido detped
    ON detped.codigo_pedido = ped.codigo_pedido
GROUP BY
    cli.codigo_cliente,
    cli.nombre_cliente,
    cli.apellido_contacto;

-- Calcula el beneficio unitario y total de cada producto vendido (precio de venta – precio proveedor).
SELECT
    pro.codigo_producto AS "Codigo Producto",
    pro.nombre AS "Nombre Producto",
    pro.gama AS "Gama Producto",
    (pro.precio_venta - pro.precio_proveedor) AS "Beneficio Unitario",
    COALESCE(SUM(detped.cantidad * (pro.precio_venta - pro.precio_proveedor)), 0) AS "Beneficio Total"
FROM producto pro
LEFT JOIN detalle_pedido detped
    ON detped.codigo_producto = pro.codigo_producto
GROUP BY
    pro.codigo_producto,
    pro.nombre,
    pro.gama,
    pro.precio_venta,
    pro.proveedor;

-- Obtén el promedio de ventas generadas por cada empleado que atiende clientes.
SELECT
    emp.codigo_empleado AS "Codigo Empleado",
    CONCAT(emp.nombre, ' ', emp.apellido1, ' ', IFNULL(emp.apellido2, '')) AS "Nombre Empleado",
    ROUND(AVG(ventas_x_cliente.cantidad_pedidos), 0) AS "Promedio Ventas"
FROM empleado emp
LEFT JOIN cliente cli
    ON cli.codigo_empleado_rep_ventas = emp.codigo_empleado
INNER JOIN (
    SELECT
        ped.codigo_cliente,
        COUNT(*) AS cantidad_pedidos
    FROM pedido ped
    GROUP BY ped.codigo_cliente
) AS ventas_x_cliente
    ON ventas_x_cliente.codigo_cliente = cli.codigo_cliente
GROUP BY
    emp.codigo_empleado,
    emp.nombre,
    emp.apellido1,
    emp.apellido2;

-- CODIGO DE IA
-- SELECT
--     emp.codigo_empleado AS "Código Empleado",
--     CONCAT(emp.nombre, ' ', emp.apellido1, ' ', IFNULL(emp.apellido2, '')) AS "Nombre Empleado",
--     AVG(ventas_por_cliente.num_pedidos) AS "Promedio Ventas por Cliente"
-- FROM empleado emp
-- JOIN cliente cli
--     ON cli.codigo_empleado_rep_ventas = emp.codigo_empleado
-- JOIN (
--     SELECT
--         ped.codigo_cliente,
--         COUNT(*) AS num_pedidos
--     FROM pedido ped
--     GROUP BY ped.codigo_cliente
-- ) AS ventas_por_cliente
--     ON ventas_por_cliente.codigo_cliente = cli.codigo_cliente
-- GROUP BY emp.codigo_empleado, emp.nombre, emp.apellido1, emp.apellido2
-- ORDER BY "Promedio Ventas por Cliente" DESC;

-- Calcula qué porcentaje de pedidos de cada país fueron entregados después de la fecha esperada
SELECT
    cli.pais AS "Pais",
    COUNT(*) AS "Pedidos por Pais",
    SUM(
        IF(ped.fecha_entrega > ped.fecha_esperada, 1, 0)
    ) AS "Pedidos Tardios",
    ROUND(
        100 * SUM(
        IF(ped.fecha_entrega > ped.fecha_esperada, 1, 0)
        ) / COUNT(*), 2
    ) AS "Porcentajes Tardios"
FROM pedido ped
INNER JOIN cliente cli
    ON ped.codigo_cliente = cli.codigo_cliente
GROUP BY cli.pais;

-- Muestra cuánto dinero se ha facturado por cada gama de productos.
SELECT
    pro.gama AS "Gama Producto",
    IFNULL(SUM(detped.cantidad * pro.precio_venta), 0) AS "Facturado"
FROM producto pro
LEFT JOIN detalle_pedido detped
    ON pro.codigo_producto = detped.codigo_producto
GROUP BY pro.gama;

-- Calcula el valor total del inventario vendido por los empleados de cada oficina.
SELECT
    ofi.codigo_oficina AS "Codigo Oficina",
    ofi.linea_direccion1 AS "Direccion 1",
    ofi.linea_direccion2 AS "Direccion 2",
    IFNULL(SUM(detped.cantidad * detped.precio_unidad), 0) AS "Valor Inventario Vendido"
FROM oficina ofi
LEFT JOIN empleado emp
    ON emp.codigo_oficina = ofi.codigo_oficina
INNER JOIN cliente cli
    ON cli.codigo_empleado_rep_ventas = emp.codigo_empleado
INNER JOIN pedido ped
    ON ped.codigo_cliente = cli.codigo_cliente
INNER JOIN detalle_pedido detped
    ON detped.codigo_pedido = ped.codigo_pedido
GROUP BY
    ofi.codigo_oficina,
    ofi.linea_direccion1,
    ofi.linea_direccion2;

-- Determina el porcentaje promedio de margen de descuento entre precio de venta y proveedor.
SELECT
    AVG(((pro.precio_venta - pro.precio_proveedor) / pro.precio_venta) * 100) AS "Promedio Descuento Venta/Proveedor"
FROM producto pro;

-- Muestra cuánto dinero total ha cobrado cada oficina según los pagos de sus clientes.
SELECT
    ofi.codigo_oficina AS "Codigo Oficina",
    COALESCE(SUM(sub.total_pagado_cliente), 0) AS "Dinero Total Cobrado"
FROM oficina ofi
LEFT JOIN empleado emp
    ON emp.codigo_oficina = ofi.codigo_oficina
LEFT JOIN (
    SELECT
        cli.codigo_empleado_rep_ventas,
        pag.codigo_cliente,
        SUM(pag.total) AS total_pagado_cliente
    FROM cliente cli
    LEFT JOIN pago pag
        ON pag.codigo_cliente = cli.codigo_cliente
    GROUP BY
        cli.codigo_empleado_rep_ventas,
        pag.codigo_cliente
) sub
    ON sub.codigo_empleado_rep_ventas = emp.codigo_empleado
GROUP BY ofi.codigo_oficina;

-- Calcula el beneficio neto de cada cliente (pagos – coste de productos).
SELECT
    cli.codigo_cliente AS "Codigo Cliente",
    CONCAT(cli.nombre_cliente, ' ', cli.apellido_contacto) AS "Nombre Cliente",
    COALESCE(SUM(pag.total), 0) - COALESCE(SUM(sub.total_coste), 0) AS "Beneficio Neto"
FROM cliente cli
LEFT JOIN pago pag
    ON pag.codigo_cliente = cli.codigo_cliente
LEFT JOIN (
    SELECT
        ped.codigo_pedido,
        ped.codigo_cliente,
        SUM(pro.precio_proveedor * detped.cantidad) AS total_coste
    FROM pedido ped
    LEFT JOIN detalle_pedido detped
        ON detped.codigo_pedido = ped.codigo_pedido
    LEFT JOIN producto pro
        ON detped.codigo_producto = pro.codigo_producto
    GROUP BY
        ped.codigo_pedido,
        ped.codigo_cliente
) sub
    ON sub.codigo_cliente = cli.codigo_cliente
GROUP BY 
    cli.codigo_cliente,
    cli.nombre_cliente,
    cli.apellido_contacto;

-- Muestra el margen porcentual promedio de beneficio por cada gama de productos.
SELECT
    gampro.gama AS "Gama Producto",
    COALESCE(
        ROUND(
            AVG(((pro.precio_venta - pro.precio_proveedor) / pro.precio_venta) * 100), 2
            ), 0
        ) AS "Margen Procentual Promedio Beneficios"
FROM gama_producto gampro
LEFT JOIN producto pro
    ON gampro.gama = pro.gama
GROUP BY gampro.gama;