-- Active: 1762272161423@@127.0.0.1@3306@jardineria
USE jardineria;

-----------------------------------------------------
-- Consulta 1 – Empleados y sus oficinas:
-----------------------------------------------------

--  Enunciado: Listar el código, nombre, y primer apellido de cada empleado junto con la ciudad y país de su oficina. Ordenar el resultado por ciudad y nombre.
SELECT
    CONCAT(emp.nombre, ' ', emp.apellido1) AS "Nombre Empleado",
    (SELECT
        ofi.ciudad
    FROM oficina ofi
    WHERE ofi.codigo_oficina = emp.codigo_oficina
    ) Ciudad_Oficina,
    (SELECT
        ofi.pais
    FROM oficina ofi
    WHERE ofi.codigo_oficina = emp.codigo_oficina
    ) AS "Pais Oficina"
FROM empleado emp
ORDER BY
    emp.nombre,
    Ciudad_Oficina;

-----------------------------------------------------
-- Consulta 2 – Pedidos por cliente:
-----------------------------------------------------

-- Enunciado: Obtener para cada cliente (mostrando su código y nombre) la cantidad total de pedidos realizados. Se debe utilizar una subconsulta.
SELECT
    cli.codigo_cliente AS "Codigo Cliente",
    CONCAT(cli.nombre_cliente, ' ', cli.apellido_contacto) AS "Nombre Cliente",
    (SELECT
        COUNT(ped.codigo_cliente)
    FROM pedido ped
    WHERE ped.codigo_cliente = cli.codigo_cliente
    ) AS "Total pedidos"
FROM cliente cli
GROUP BY
    cli.codigo_cliente;

-----------------------------------------------------
-- Consulta 3 – Productos con margen de ganancia:
-----------------------------------------------------

-- Enunciado: Listar los productos (mostrando código, nombre y gama) junto con el cálculo del margen de ganancia (diferencia entre precio_venta y precio_proveedor). Incluir solo aquellos productos con un margen mayor a 50.
SELECT
    pro.codigo_producto AS "Codigo Producto",
    pro.nombre AS "Nombre Producto",
    pro.gama AS "Gama Producto",
    (SUM(pro.precio_venta - pro.precio_proveedor)) AS Margen_Ganancia
FROM producto pro
GROUP BY pro.codigo_producto
HAVING Margen_Ganancia > 50;

------------------------------------------------------
-- Consulta 4 – Pedidos entregados tarde:
------------------------------------------------------

-- Enunciado: Mostrar la lista de pedidos que se entregaron con retraso (donde fecha_entrega es mayor que fecha_esperada), incluyendo el número de días de retraso y el nombre del cliente que realizó el pedido. Se debe usar un CTE
WITH sub AS (
    SELECT
        ped.codigo_pedido,
        ped.fecha_pedido,
        ped.fecha_esperada,
        ped.fecha_entrega,
        CONCAT(ped.fecha_esperada, ' > ', ped.fecha_entrega) AS fechas_comparation,
        DATEDIFF(ped.fecha_entrega, ped.fecha_esperada) AS dias_retraso,
        CONCAT(cli.nombre_cliente, ' ', cli.apellido_contacto) AS nombre_cliente
    FROM pedido ped
    LEFT JOIN cliente cli
        ON ped.codigo_cliente = cli.codigo_cliente
)
SELECT
    sub.codigo_pedido AS "Codigo Pedido",
    sub.fecha_pedido AS "Fecha Pedido",
    sub.fechas_comparation AS " Fecha Esperada>Entregada",
    sub.dias_retraso AS "Dias de Retraso",
    sub.nombre_cliente AS "Cliente Pedido"
FROM sub
WHERE sub.fecha_entrega > sub.fecha_esperada;

-- SELECT
--     ped.codigo_pedido AS "Codigo Pedido",
--     ped.fecha_pedido AS "Fecha Pedido",
--     DATEDIFF(ped.fecha_entrega, ped.fecha_esperada) AS dias_retraso,
--     sub.nombre_cliente AS "Cliente Pedido"
-- FROM pedido ped
-- LEFT JOIN (
--     SELECT
--         CONCAT(cli.nombre_cliente, ' ', cli.apellido_contacto) AS nombre_cliente,
--         cli.codigo_cliente AS codigo_cliente
--     FROM cliente cli
-- ) sub
--     ON sub.codigo_cliente = ped.codigo_cliente
-- WHERE ped.fecha_entrega > ped.fecha_esperada;

------------------------------------------------------
-- Consulta 5 – Empleados por oficina:
------------------------------------------------------

-- Enunciado: Listar cada oficina (mostrando su código y ciudad) junto con el total de empleados que trabajan en ella. Se debe utilizar un CTE.
WITH OficinasEmpleados AS (
    SELECT
        ofi.codigo_oficina,
        ofi.ciudad,
        IFNULL(COUNT(emp.codigo_empleado), 0) AS total_empleados
    FROM oficina ofi
    LEFT JOIN empleado emp
        ON emp.codigo_oficina = ofi.codigo_oficina
    GROUP BY -- SE QUE SON MUCHAS CONDICIONES, PERO SOLO ME ASEGURO DE QUE NO SE REPITEN OFICINAS Y SE SUMAN AUNQUE SE QUE CON LA PK DEBERIA SER SUFICIENTE
        ofi.codigo_oficina,
        ofi.ciudad,
        ofi.linea_direccion2,
        ofi.linea_direccion1,
        ofi.codigo_postal,
        ofi.pais
)
SELECT
    OficinasEmpleados.codigo_oficina AS "Codigo Oficina",
    OficinasEmpleados.ciudad AS "Ciudad Oficina",
    OficinasEmpleados.total_empleados AS "Total Empleados Oficina"
FROM OficinasEmpleados;

-- WITH sub AS (
--     SELECT
--         ofi.codigo_oficina,
--         CONCAT(ofi.linea_direccion2, '-', ofi.linea_direccion1, ', ', ofi.codigo_postal, ', ', ofi.ciudad, ', ', ofi.pais) AS direccion_oficina,
--         IFNULL(COUNT(emp.codigo_empleado), 0) AS total_empleados
--     FROM oficina ofi
--     LEFT JOIN empleado emp
--         ON emp.codigo_oficina = ofi.codigo_oficina
--     GROUP BY ofi.codigo_oficina
-- )
-- SELECT
--     sub.codigo_oficina AS "Codigo Oficina",
--     sub.direccion_oficina AS "Direccion Oficina",
--     sub.total_empleados AS "Total Empleados Oficina"
-- FROM sub;

------------------------------------------------------
-- Consulta 6 – Jefes y número de subordinados:
------------------------------------------------------

-- Enunciado: Obtener la lista de empleados que actúan como jefes (tienen empleados a su cargo) junto con el número de subordinados que tienen y la ciudad de su oficina. Se debe usar un JOIN y un CTE.
WITH JefSubOfi AS (
    SELECT
        sub.codigo_jefe,
        COUNT(sub.codigo_empleado) AS num_subordinados
    FROM empleado sub
    WHERE sub.codigo_jefe IS NOT NULL
    GROUP BY sub.codigo_jefe
)
SELECT
    jef.codigo_empleado AS "Codigo Jefe",
    COALESCE(CONCAT(jef.nombre, ' ', jef.apellido1, ' ', jef.apellido2), '') AS "Nombre Jefe",
    JefSubOfi.num_subordinados AS "Numero Subordinados",
    ofi.codigo_oficina AS "Codigo Oficina",
    CONCAT(ofi.linea_direccion1, ' -', ofi.linea_direccion2, ', ', ofi.codigo_postal, ', ', ofi.ciudad, ', ', ofi.pais) AS "Dirección Oficina"
FROM empleado jef
INNER JOIN JefSubOfi
    ON JefSubOfi.codigo_jefe = jef.codigo_empleado
LEFT JOIN oficina ofi
    ON ofi.codigo_oficina = jef.codigo_oficina
ORDER BY JefSubOfi.num_subordinados DESC;

------------------------------------------------------------
-- Consulta 7 – Totales de pedidos y pagos por cliente:
------------------------------------------------------------

-- Enunciado: Para cada cliente, calcular el total monetario de sus pedidos (sumando el valor de cada detalle de pedido) y el total de pagos realizados, mostrando además la diferencia entre ambos totales. Se deben emplear un CTE y un  JOIN.
WITH TotalPedidos AS (
    SELECT
        ped.codigo_cliente,
        SUM(detped.cantidad * detped.precio_unidad) AS total_monetario
    FROM pedido ped
    INNER JOIN detalle_pedido detped
        ON detped.codigo_pedido = ped.codigo_pedido
    GROUP BY ped.codigo_cliente
),
TotalPagos AS (
    SELECT
        pag.codigo_cliente,
        COUNT(pag.codigo_cliente) AS total_pagos
    FROM pago pag
    GROUP BY pag.codigo_cliente
),
InfoCliente AS (
    SELECT
        cli.codigo_cliente,
        cli.nombre_cliente,
        cli.apellido_contacto
    FROM cliente cli
)
SELECT
    totped.codigo_cliente AS "Codigo Cliente",
    CONCAT(infcli.nombre_cliente, ' ', infcli.apellido_contacto) AS "Nombre Cliente",
    IFNULL(totped.total_monetario, 0) AS "Total Monetario Pedidos",
    IFNULL(totpag.total_pagos, 0) AS "Total de Pagos",
    IFNULL((totped.total_monetario - totpag.total_pagos), 0) AS "Diferencia"
FROM totalPedidos totped
LEFT JOIN TotalPagos totpag
    ON totpag.codigo_cliente = totped.codigo_cliente
LEFT JOIN InfoCliente infcli
    ON infcli.codigo_cliente = totped.codigo_cliente
ORDER BY 
    totped.total_monetario DESC,
    totpag.total_pagos DESC;

------------------------------------------------------------
-- Consulta 8 – Productos más pedidos y total de ventas:
------------------------------------------------------------

-- Enunciado: Listar los productos que han sido pedidos en cantidad superior a 10 unidades (suma de las cantidades de la tabla detalle_pedido) y mostrar, además de su gama, el total de ventas (calculado como precio_unidad multiplicado por cantidad). Se debe utilizar un CTE.
WITH UnidadesTotalVentas AS (
    SELECT
        detped.codigo_producto,
        SUM(detped.cantidad) AS total_pedidos,
        SUM(detped.precio_unidad * detped.cantidad) AS total_ventas
    FROM detalle_pedido detped
    GROUP BY detped.codigo_producto
    HAVING total_pedidos > 10
),
InfoProducto AS (
    SELECT
        pro.codigo_producto,
        pro.nombre,
        pro.gama
    FROM producto pro
)
SELECT
    unitotven.codigo_producto AS "Codigo Producto",
    infpro.nombre AS "Nombre Producto",
    infpro.gama AS "Gama Producto",
    unitotven.total_ventas AS "Total de Ventas"
FROM UnidadesTotalVentas unitotven
INNER JOIN InfoProducto infpro
    ON infpro.codigo_producto = unitotven.codigo_producto;

------------------------------------------------------------
-- Consulta 9 – Productos más pedidos y total de ventas:
------------------------------------------------------------

-- Enunciado: Crear una vista final que combine información de pedidos, clientes y empleados (usando el representante de ventas de cada cliente) para calcular el tiempo promedio (en días) entre fecha_pedido y fecha_entrega para cada proveedor, considerando solo los pedidos que ya fueron entregados.
WITH InfoPedidoProducto AS (
    SELECT
        ped.codigo_pedido,
        ped.fecha_pedido,
        ped.fecha_entrega,
        ped.fecha_esperada,
        CONCAT(ped.fecha_entrega, ' > ', ped.fecha_esperada) AS fecha_entrega_espera,
        ped.estado,
        ped.comentarios,
        ped.codigo_cliente,
        pro.proveedor
    FROM pedido ped
    INNER JOIN detalle_pedido detped
        ON detped.codigo_pedido = ped.codigo_pedido
    INNER JOIN producto pro
        ON pro.codigo_producto = detped.codigo_producto
    WHERE ped.estado = "Entregado"
),
Info_Cliente_Empleado AS (
    SELECT
        cli.codigo_cliente,
        CONCAT_WS(' ', cli.nombre_cliente, cli.apellido_contacto, cli.nombre_contacto) AS nombre_cliente,
        cli.telefono,
        cli.fax,
        CONCAT_WS(', ', cli.linea_direccion1, cli.linea_direccion2, cli.ciudad, cli.pais, cli.codigo_postal) AS direccion_cliente,
        cli.limite_credito,
        cli.codigo_empleado_rep_ventas,
        CONCAT_WS(' ', emp.nombre, emp.apellido1, emp.apellido2) AS nombre_empleado,
        emp.extension,
        emp.email,
        emp.codigo_oficina,
        emp.codigo_jefe,
        emp.puesto
    FROM cliente cli
    LEFT JOIN empleado emp
        ON emp.codigo_empleado = cli.codigo_empleado_rep_ventas
),
PromedioProveedor AS (
    SELECT
        infpedpro.proveedor,
        ROUND(AVG(DATEDIFF(infpedpro.fecha_entrega, infpedpro.fecha_pedido)), 0) AS promedio_espera
    FROM InfoPedidoProducto infpedpro
    GROUP BY infpedpro.proveedor
)
SELECT
    infpedpro.codigo_pedido AS "Codigo Pedido",
    infpedpro.fecha_pedido AS "Fecha Pedido",
    infpedpro.fecha_entrega_espera AS "Fecha Entrega > Esperada",
    propro.proveedor AS "Proveedor",
    propro.promedio_espera AS "Espera Promedio",
    infpedpro.estado AS "Estado Pedido",
    IFNULL(infpedpro.comentarios, "nada") AS "Comentarios",
    infcliemp.codigo_cliente AS "Codigo Cliente",
    infcliemp.nombre_cliente AS "Nombre Cliente",
    infcliemp.telefono AS "Telefono Cliente",
    infcliemp.fax AS "Fax",
    COALESCE(infcliemp.direccion_cliente, '') AS "Direccion Cliente",
    infcliemp.limite_credito AS "Limite de Credito",
    infcliemp.codigo_empleado_rep_ventas AS "Codigo Empleado",
    COALESCE(infcliemp.nombre_empleado, '') AS "Nombre Empleado",
    infcliemp.extension AS "Extension",
    infcliemp.email AS "Email",
    infcliemp.codigo_oficina AS "Codigo Oficina",
    infcliemp.codigo_jefe AS "Codigo Empleado Jefe",
    infcliemp.puesto AS "Puesto"
FROM InfoPedidoProducto infpedpro
LEFT JOIN PromedioProveedor propro
    ON propro.proveedor = infpedpro.proveedor
INNER JOIN Info_Cliente_Empleado infcliemp
    ON infcliemp.codigo_cliente = infpedpro.codigo_cliente
ORDER BY infpedpro.codigo_pedido ASC;

-- CORREGIDO POR IA
-- WITH InfoPedidoProducto AS (
--     SELECT
--         ped.codigo_pedido,
--         ped.fecha_pedido,
--         ped.fecha_entrega,
--         ped.fecha_esperada,
--         CONCAT(ped.fecha_entrega, ' > ', ped.fecha_esperada) AS fecha_entrega_espera,
--         ped.estado,
--         ped.comentarios,
--         ped.codigo_cliente,
--         pro.proveedor
--     FROM pedido ped
--     INNER JOIN detalle_pedido detped
--         ON detped.codigo_pedido = ped.codigo_pedido
--     INNER JOIN producto pro
--         ON pro.codigo_producto = detped.codigo_producto
--     WHERE ped.estado = 'Entregado'
--         AND ped.fecha_entrega IS NOT NULL  -- ✅ Mejor práctica
-- ),
-- PromedioProveedor AS (
--     SELECT
--         proveedor,
--         ROUND(AVG(DATEDIFF(fecha_entrega, fecha_pedido)), 0) AS promedio_espera
--     FROM InfoPedidoProducto
--     GROUP BY proveedor
-- ),
-- InfoClienteEmpleado AS (
--     SELECT
--         cli.codigo_cliente,
--         CONCAT(cli.nombre_cliente, ' ', cli.apellido_contacto, ' - ', cli.nombre_contacto) AS nombre_cliente,
--         cli.telefono,
--         cli.fax,
--         CONCAT_WS(' ',  -- ✅ Maneja NULLs automáticamente
--             cli.linea_direccion1,
--             NULLIF(cli.linea_direccion2, ''),
--             cli.ciudad,
--             cli.pais,
--             cli.codigo_postal
--         ) AS direccion_cliente,
--         cli.limite_credito,
--         cli.codigo_empleado_rep_ventas,
--         CONCAT_WS(' ',  -- ✅ Mejor que CONCAT para NULLs
--             emp.nombre,
--             emp.apellido1,
--             NULLIF(emp.apellido2, '')
--         ) AS nombre_empleado,
--         emp.extension,
--         emp.email,
--         emp.codigo_oficina,
--         emp.codigo_jefe,
--         emp.puesto
--     FROM cliente cli
--     LEFT JOIN empleado emp
--         ON emp.codigo_empleado = cli.codigo_empleado_rep_ventas
-- )
-- SELECT DISTINCT  -- ✅ Evita duplicados si hay varios productos por pedido
--     ipp.codigo_pedido AS "Codigo Pedido",
--     ipp.fecha_pedido AS "Fecha Pedido",
--     ipp.fecha_entrega_espera AS "Fecha Entrega > Esperada",
--     pp.promedio_espera AS "Espera Promedio",
--     ipp.estado AS "Estado Pedido",
--     IFNULL(ipp.comentarios, "Sin comentarios") AS "Comentarios",
--     ipp.proveedor AS "Proveedor",
--     ice.codigo_cliente AS "Codigo Cliente",
--     ice.nombre_cliente AS "Nombre Cliente",
--     ice.telefono AS "Telefono Cliente",
--     ice.fax AS "Fax",
--     ice.direccion_cliente AS "Direccion Cliente",  -- ✅ Ya no necesita COALESCE
--     ice.limite_credito AS "Limite de Credito",
--     ice.codigo_empleado_rep_ventas AS "Codigo Empleado",
--     ice.nombre_empleado AS "Nombre Empleado",  -- ✅ Ya no necesita COALESCE
--     ice.extension AS "Extension",
--     ice.email AS "Email",
--     ice.codigo_oficina AS "Codigo Oficina",
--     ice.codigo_jefe AS "Codigo Empleado Jefe",
--     ice.puesto AS "Puesto"
-- FROM InfoPedidoProducto ipp
-- LEFT JOIN PromedioProveedor pp
--     ON pp.proveedor = ipp.proveedor
-- INNER JOIN InfoClienteEmpleado ice
--     ON ice.codigo_cliente = ipp.codigo_cliente
-- ORDER BY ipp.codigo_pedido ASC;

------------------------------------------------------------
-- Consulta 10 – Clientes con límite de crédito bajo:
------------------------------------------------------------

-- Enunciado: Listar la información de los clientes cuyo límite de crédito es menor que el promedio del límite de crédito de todos los clientes en su mismo país. Se debe utilizar una subconsulta correlacionada.
SELECT
    cli.codigo_cliente AS "Codigo Cliente",
    CONCAT_WS(' ', cli.nombre_cliente, cli.apellido_contacto, cli.nombre_contacto) AS "Nombre Cliente",
    cli.telefono AS "Num Telefono",
    cli.fax AS "Fax",
    CONCAT_WS(', ', cli.linea_direccion1, cli.linea_direccion2, cli.ciudad, cli.region, cli.pais, cli.codigo_postal) AS "Direccion Cliente",
    cli.codigo_empleado_rep_ventas AS "Codigo Representante Ventas",
    cli.limite_credito AS "Limite de Credito"
FROM cliente cli
WHERE cli.limite_credito < (
    SELECT AVG(cli1.limite_credito)
    FROM cliente cli1
    WHERE cli1.pais = cli.pais
);

------------------------------------------------------------
-- Consulta 11 – Reporte por oficina de ventas a tiempo:
------------------------------------------------------------

-- Enunciado: Generar un reporte que para cada oficina muestre el total de ventas, el total de pedidos y el promedio de ventas por pedido. Las ventas se calculan como la suma de (precio_unidad multiplicado por cantidad) de los detalles de pedido, considerando solo aquellos pedidos que fueron entregados a tiempo (donde fecha_entrega es menor o igual que fecha_esperada). Se deben usar múltiples CTE’s.
WITH TotalVentasPedidosOficina AS (
    SELECT
        detped.codigo_pedido,
        detped.cantidad,
        detped.precio_unidad,
        SUM(detped.cantidad * detped.precio_unidad) AS venta_pedido,
        ofi.codigo_oficina,
        CONCAT_WS(', ', ofi.linea_direccion1, ofi.linea_direccion2, ofi.ciudad, ofi.region, ofi.pais, ofi.codigo_postal) AS direccion_oficina,
        ofi.telefono
    FROM detalle_pedido detped
    INNER JOIN pedido ped
        ON ped.codigo_pedido = detped.codigo_pedido
    INNER JOIN cliente cli
        ON cli.codigo_cliente = ped.codigo_cliente
    INNER JOIN empleado emp
        ON emp.codigo_empleado = cli.codigo_empleado_rep_ventas
    INNER JOIN oficina ofi
        ON ofi.codigo_oficina = emp.codigo_oficina
    WHERE ped.fecha_entrega <= ped.fecha_esperada
    GROUP BY 
        ofi.codigo_oficina,
        ped.codigo_pedido
),
ResumenOficina AS (
    SELECT
        tvpo.codigo_oficina,
        tvpo.direccion_oficina,
        tvpo.telefono,
        ROUND(SUM(venta_pedido), 0) AS total_ventas,
        ROUND(AVG(tvpo.venta_pedido), 2) AS promedio_ventas_pedido,
        COUNT(*) AS total_pedidos
    FROM TotalVentasPedidosOficina tvpo
    GROUP BY
        tvpo.codigo_oficina,
        tvpo.direccion_oficina,
        tvpo.telefono
)
SELECT
    ro.codigo_oficina AS "Codigo Oficina",
    ro.direccion_oficina AS "Direccion Oficina",
    ro.telefono AS "Telefono Oficina",
    ro.total_pedidos AS "Total Pedidos",
    ro.total_ventas AS "Total Ventas",
    ro.promedio_ventas_pedido AS "Promedio Ventas por Pedido"
FROM ResumenOficina ro

-- Consulta anterior pendiente a mejorar:
-- WITH TotalVentasPedidosOficina AS (
--     SELECT
--         detped.codigo_pedido,
--         detped.cantidad,
--         detped.precio_unidad,
--         ROUND(SUM(detped.cantidad * detped.precio_unidad), 0) AS total_ventas,
--         COUNT(DISTINCT ped.codigo_pedido) AS total_pedidos,
--         ofi.codigo_oficina,
--         CONCAT_WS(', ', ofi.linea_direccion1, ofi.linea_direccion2, ofi.ciudad, ofi.region, ofi.pais, ofi.codigo_postal) AS direccion_oficina,
--         ofi.telefono
--     FROM detalle_pedido detped
--     INNER JOIN pedido ped
--         ON ped.codigo_pedido = detped.codigo_pedido
--     INNER JOIN cliente cli
--         ON cli.codigo_cliente = ped.codigo_cliente
--     INNER JOIN empleado emp
--         ON emp.codigo_empleado = cli.codigo_empleado_rep_ventas
--     INNER JOIN oficina ofi
--         ON ofi.codigo_oficina = emp.codigo_oficina
--     WHERE ped.fecha_entrega <= ped.fecha_esperada
--     GROUP BY ofi.codigo_oficina
-- ),
-- PromedioVentasPedido AS (
--     SELECT
--         ped.codigo_pedido,
--         AVG(detped.cantidad * detped.precio_unidad) AS promedio_ventas_pedido
--     FROM pedido ped
--     INNER JOIN detalle_pedido detped
--         ON detped.codigo_pedido = ped.codigo_pedido
--     GROUP BY ped.codigo_pedido
-- )
-- SELECT
--     tvpo.codigo_oficina AS "Codigo Oficina",
--     tvpo.direccion_oficina AS "Direccion Oficina",
--     tvpo.telefono AS "Telefono Oficina",
--     tvpo.total_ventas AS "Total Ventas",
--     tvpo.total_pedidos AS "Total Pedidos",
--     pvp.promedio_ventas_pedido AS "Promedio Ventas por Pedido"
-- FROM TotalVentasPedidosOficina tvpo
-- LEFT JOIN PromedioVentasPedido pvp
--     ON pvp.codigo_pedido = tvpo.codigo_pedido

------------------------------------------------------------------
-- Consulta 12 – Ranking de productos por margen en cada gama:
------------------------------------------------------------------

-- Enunciado: Listar, para cada gama de producto, los 5 productos con mayor margen de ganancia promedio (calculado como la diferencia entre precio_venta y precio_proveedor). Se debe utilizar un CTE.
WITH RankingGama AS (
    SELECT
        pro.gama,
        pro.codigo_producto,
        pro.nombre,
        (pro.precio_venta - pro.precio_proveedor) AS margen_ganancia,
        ROW_NUMBER() OVER (PARTITION BY pro.gama ORDER BY margen_ganancia DESC) AS top_num
    FROM producto pro
)
SELECT
    rg.gama AS "Gama Producto",
    rg.codigo_producto AS "Codigo Producto",
    rg.nombre AS "Nombre Producto",
    rg.top_num AS "Position in TOP"
FROM RankingGama rg
WHERE rg.top_num <= 5

------------------------------------------------------------------
-- Consulta 13 – Ranking de clientes por índice de actividad:
------------------------------------------------------------------

-- Enunciado: Generar un ranking de clientes basado en su actividad, donde se sume el total de pedidos y el total de pagos (aplicando una ponderación, por ejemplo, 0.6 para pedidos y 0.4 para pagos) para calcular un “índice de actividad”. Mostrar solo aquellos clientes cuyo índice supere un valor específico (por ejemplo, 5). Se deben emplear subconsultas y JOIN’s.
SELECT
    ROW_NUMBER() OVER (ORDER BY IndiceActividad DESC) AS "Position Ranking",
    cli.codigo_cliente AS "Codigo Cliente",
    CONCAT(cli.nombre_cliente, ' ', cli.apellido_contacto, ', ', cli.nombre_contacto) AS "Nombre Cliente",
    ((ci.num_pedidos * 0.6) + (ci.num_pagos * 0.4)) AS IndiceActividad
FROM cliente cli
LEFT JOIN (
    SELECT
        cli1.codigo_cliente,
        COUNT(DISTINCT ped.codigo_pedido) AS num_pedidos,
        COUNT(DISTINCT pag.codigo_cliente) AS num_pagos
    FROM pedido ped
    INNER JOIN cliente cli1 ON cli1.codigo_cliente = ped.codigo_cliente
    INNER JOIN pago pag ON pag.codigo_cliente = cli1.codigo_cliente
    GROUP BY cli1.codigo_cliente
) ci
    ON ci.codigo_cliente = cli.codigo_cliente
WHERE ((ci.num_pedidos * 0.6) + (ci.num_pagos * 0.4)) > 5

--IA Code
-- SELECT
--     ROW_NUMBER() OVER (ORDER BY ((ci.num_pedidos * 0.6) + (ci.num_pagos * 0.4)) DESC) AS "Position Ranking",
--     cli.codigo_cliente AS "Codigo Cliente",
--     CONCAT(cli.nombre_cliente, ' ', cli.apellido_contacto, ', ', cli.nombre_contacto) AS "Nombre Cliente",
--     ci.num_pedidos,
--     ci.num_pagos,
--     ((ci.num_pedidos * 0.6) + (ci.num_pagos * 0.4)) AS IndiceActividad
-- FROM cliente cli
-- LEFT JOIN (
--     SELECT
--         cli1.codigo_cliente,
--         COUNT(DISTINCT ped.codigo_pedido) AS num_pedidos,
--         COUNT(pag.codigo_cliente) AS num_pagos
--     FROM cliente cli1
--     LEFT JOIN pedido ped ON cli1.codigo_cliente = ped.codigo_cliente
--     LEFT JOIN pago pag ON pag.codigo_cliente = cli1.codigo_cliente
--     GROUP BY cli1.codigo_cliente  -- ✅ Corregido
-- ) ci ON ci.codigo_cliente = cli.codigo_cliente
-- WHERE ((ci.num_pedidos * 0.6) + (ci.num_pagos * 0.4)) > 5  -- ✅ WHERE en lugar de HAVING
-- ORDER BY IndiceActividad DESC;

-------------------------------------------------------------------------
-- Consulta 14 – Diferencia entre primer y último pedido por empleado:
-------------------------------------------------------------------------

-- Enunciado: Identificar los empleados que, como representantes de ventas, tienen una diferencia mayor a 5 días entre el primer pedido asignado y el último pedido asignado. Se debe utilizar un CTE y funciones de agregación en varias etapas.
