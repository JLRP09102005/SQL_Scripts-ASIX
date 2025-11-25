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
        DATEDIFF(ped.fecha_entrega, ped.fecha_esperada) AS dias_retraso,
        CONCAT(cli.nombre_cliente, ' ', cli.apellido_contacto) AS nombre_cliente
    FROM cliente cli
)
SELECT
    ped.codigo_pedido AS "Codigo Pedido",
    ped.fecha_pedido AS "Fecha Pedido",
    sub.dias_retraso AS "Dias de Retraso",
    sub.cliente_pedido AS "Cliente Pedido"
FROM pedido ped
WHERE ped.fecha_entrega > ped.fecha_esperada;