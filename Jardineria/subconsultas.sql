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
    pro.gama AS "Gama Producto"
