USE DATABASE jardineria;

--------------------------------------------------------------------------------------
-- Consultas de Selección y Ordenación (SELECT, FROM, ORDER BY)
--------------------------------------------------------------------------------------

-- Selección Completa: Recupera todas las columnas y todos los registros de la tabla empleado
-- SELECT * from empleado; --Version facil pero que genera mas confusion con un gran numero de tablas y datos
SELECT 
    c.codigo_cliente AS "Codigo Cliente",
    c.nombre_cliente AS "Nombre Cliente",
    c.nombre_contacto AS "Nombre Contacto",
    c.apellido_contacto AS "Apellido Contacto",
    c.telefono AS "Telefono",
    c.fax AS "Fax",
    c.linea_direccion1 AS "Linea Direccion 1",
    c.linea_direccion2 AS "Linea Direccion 2",
    c.ciudad AS "Ciudad",
    c.region AS "Region",
    c.pais AS "Pais",
    c.codigo_postal AS "Codigo Postal",
    c.codigo_empleado_rep_ventas AS "Representante Ventas",
    c.limite_credito AS "Limite Credito"
FROM cliente c;

-- Columnas Específicas: Muestra únicamente el nombre_cliente, nombre_contacto y telefono de la tabla cliente.
SELECT 
    c.nombre_cliente AS "Nombre Cliente", 
    c.nombre_contacto AS "Nombre Contacto", 
    c.telefono AS "Numero de Telefono"
FROM cliente c;

-- Orden Ascendente: Lista todos los nombre y apellido1 de la tabla empleado, ordenados alfabéticamente por apellido1.
SELECT 
    e.nombre AS "Nombre Empleado", 
    e.apellido1 AS "Apellido-1"
FROM empleado e
ORDER BY e.apellido1 ASC;

-- Orden Descendente: Muestra el nombre y el precio_venta de la tabla producto, ordenados del precio más alto al más bajo.
SELECT 
    p.nombre AS "Nombre Producto", 
    p.precio_venta AS "Precio Venta"
FROM producto p
ORDER BY p.precio_venta DESC;

-- Combinación de Campos: Lista el nombre y la gama de los productos, ordenados primero por gama (ascendente) y luego por nombre (ascendente).
SELECT 
    p.nombre AS "Nombre Producto", 
    p.gama AS "Gama Producto"
FROM producto p
ORDER BY p.gama ASC, p.nombre ASC;

------------------------------------------------------------------------------
-- Consultas de Filtrado Básico (WHERE, =)
------------------------------------------------------------------------------

-- Igualdad Simple: Obtén el nombre, apellido1 y puesto de los empleados cuyo puesto sea exactamente 'Director General'
SELECT 
    e.nombre AS "Nombre Empleado", 
    e.apellido1 AS "Apellido-1", 
    e.puesto AS "Puesto"
FROM empleado e
WHERE e.puesto = "Director General";

-- Filtrado Numérico: Muestra todos los datos de los clientes cuyo limite_credito sea igual a 0
SELECT 
    c.codigo_cliente AS "Codigo Cliente",
    c.nombre_cliente AS "Nombre Cliente",
    c.nombre_contacto AS "Nombre Contacto",
    c.apellido_contacto AS "Apellido Contacto",
    c.telefono AS "Telefono",
    c.fax AS "Fax",
    c.linea_direccion1 AS "Linea Direccion 1",
    c.linea_direccion2 AS "Linea Direccion 2",
    c.ciudad AS "Ciudad",
    c.region AS "Region",
    c.pais AS "Pais",
    c.codigo_postal AS "Codigo Postal",
    c.codigo_empleado_rep_ventas AS "Representante Ventas",
    c.limite_credito AS "Limite Credito"
FROM cliente c
WHERE c.limite_credito = 0;

-- Filtrado por Texto: Lista el nombre y el pais de las oficinas que se encuentran en 'España'
SELECT 
    o.codigo_oficina AS "Nombre Oficina", 
    o.pais AS "Pais"
FROM oficina o
WHERE o.pais = "España";

-- Diferente de: Recupera el nombre_cliente y el pais de todos los clientes que no viven en 'USA'
SELECT 
    c.nombre_cliente AS "Nombre Cliente", 
    c.pais AS "Pais"
FROM cliente c
WHERE c.pais <> "USA";

-- Doble Condición (AND): Muestra el nombre y apellido1 de los empleados cuyo puesto es 'Representante Ventas' y cuyo codigo_oficina es 'BCN-ES'
SELECT 
    e.nombre AS "Nombre Empleado", 
    e.apellido1 AS "Apellido-1"
FROM empleado e
WHERE e.puesto = "Representante Ventas" 
    AND e.codigo_oficina = "BCN-ES";

-------------------------------------------------------------------------------
-- Consultas con Rango y Opciones (BETWEEN, IN)
-------------------------------------------------------------------------------

-- Rango Numérico (BETWEEN): Lista el nombre y el precio_venta de los productos que tienen un precio de venta entre 10 y 20 (ambos inclusive)
SELECT 
    p.nombre AS "Nombre Producto", 
    p.precio_venta AS "Precio Venta"
FROM producto p
WHERE p.precio_venta BETWEEN 10 AND 20;

-- Rango de Stock (BETWEEN): Muestra el nombre y la cantidad_en_stock de los productos que tienen entre 500 y 1000 unidades en stock
SELECT 
    p.nombre AS "Nombre Producto", 
    p.cantidad_en_stock AS "Cantidad En Stock"
FROM producto p
WHERE p.cantidad_en_stock BETWEEN 500 AND 1000;

-- Múltiples Opciones (IN): Obtén el nombre_cliente y el pais de los clientes que residen en 'Francia', 'Alemania' o 'Italia'
SELECT 
    c.nombre_cliente AS "Nombre Cliente", 
    c.pais AS "Pais"
FROM cliente c
WHERE c.pais IN ('France','Germany','Italy');

-- Opción Negada (NOT IN): Muestra el nombre, apellido1 y puesto de los empleados que no tienen el puesto de 'Representante Ventas' o 'Director Oficina'.
SELECT 
    e.nombre AS "Nombre Empleado", 
    e.apellido1 AS "Apellido-1", 
    e.puesto AS "Puesto"
FROM empleado e
WHERE e.puesto NOT IN ('Representante Ventas','Director Oficina');

----------------------------------------------------------------------------------------------
-- Consultas con Patrones y Unicidad (LIKE, DISTINCT)
----------------------------------------------------------------------------------------------

-- Patrón al Inicio (LIKE): Lista el nombre_cliente y la ciudad de todos los clientes cuyo nombre comience con la letra 'G'
SELECT 
    c.nombre_cliente As "Nombre Cliente", 
    c.ciudad AS "Ciudad"
FROM cliente c
WHERE c.nombre_cliente LIKE "G%";

-- Patrón en Medio (LIKE): Muestra el nombre de los productos que contienen la palabra 'Planta' en cualquier posición
SELECT 
    p.nombre AS "Nombre Producto"
FROM producto p, gama_producto gp --Uso de combinacion de tablas antiguo, lo mas optimo seria un join *pero me dijiste que no >:(*
WHERE p.codigo_producto LIKE "%Planta%"
    OR p.nombre LIKE "%Planta%"
    OR p.dimensiones LIKE "%Planta%"
    OR p.proveedor LIKE "%Planta%"
    OR p.descripcion LIKE "%Planta%"
    OR gp.gama LIKE "%Planta%"
    OR gp.descripcion_texto LIKE "%Planta%"
    OR gp.descripcion_html LIKE "%Planta%";


-- Patrón al Final (LIKE): Obtén la linea_direccion1 de las oficinas cuya dirección termine con la palabra 'street' (utiliza el comodín `%street')
SELECT o.linea_direccion1 AS "Linea Direccion Oficina 1"
FROM oficina o
WHERE o.linea_direccion1 LIKE "%street"

-- Valores Únicos (DISTINCT): ¿Qué puestos diferentes existen en la tabla empleado? (Muestra la lista sin repeticiones)
SELECT DISTINCT 
    e.puesto AS "Puestos Empleados", 
    COUNT(*) AS "Numero de Empleados"
FROM empleado e
GROUP BY e.puesto; --Group By ya hace la distincion de registros

-- Valores Únicos por Categoría (DISTINCT): ¿Qué gamas diferentes de productos existen en la tabla producto?
SELECT DISTINCT 
    p.gama AS "Gamas de Productos", 
    COUNT(*) AS "Numero de Productos"
FROM producto p
GROUP BY p.gama;

-- Combinación Avanzada: Lista el nombre_cliente y el limite_credito de los clientes cuyo nombre_cliente contenga la palabra 'S.L' (%S.L%) y ordénalos por limite_credito de forma descendente.
SELECT 
    c.nombre_cliente AS "Nombre Cliente", 
    c.limite_credito AS "Limite de Credito"
FROM cliente c
WHERE c.nombre_cliente LIKE "%S.L%" 
    OR c.nombre_cliente LIKE "%SL%"
ORDER BY c.limite_credito DESC;