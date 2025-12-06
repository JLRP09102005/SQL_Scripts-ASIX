-- Active: 1762272161423@@127.0.0.1@3306@electronica
-----------------------
-- Consulta 1 
-----------------------

-- Muestra el nombre de los empleados y el total de ventas que han realizado en 2023, pero solo si superan las 50 unidades vendidas.
WITH VentasPorAnyo AS (
    SELECT
        e.id AS empleado_id,
        e.nombre AS nombre_empleado,
        COUNT(v.id) AS total_ventas,
        SUM(v.cantidad) AS unidades_vendidas
    FROM empleados e
    LEFT JOIN ventas v
        ON v.empleado_id = e.id
       AND EXTRACT(YEAR FROM v.fecha) = 2023
    GROUP BY
        e.id,
        e.nombre
)
SELECT
    vpa.empleado_id AS "Codigo Empleado",
    vpa.nombre_empleado AS "Nombre Empleado",
    vpa.total_ventas AS "Total Ventas",
    vpa.unidades_vendidas AS "Unidades Vendidas"
FROM VentasPorAnyo vpa
WHERE vpa.unidades_vendidas > 50;

-----------------------
-- Consulta 2
-----------------------

-- Compara el precio de cada producto con el precio promedio de su categoría. Muestra los productos que estén un 20% por encima del promedio.
WITH PromedioCategoria AS (
    SELECT
        c.id AS categoria_id,
        ROUND(AVG(p.precio), 2) AS precio_promedio
    FROM categorias c
    LEFT JOIN productos p ON p.categoria_id = c.id
    GROUP BY c.id
),
ProductosPromedioCategoria AS (
    SELECT
        p.id AS codigo_producto,
        p.nombre,
        p.categoria_id,
        p.precio,
        pc.precio_promedio
    FROM productos p
    INNER JOIN PromedioCategoria pc ON p.categoria_id = pc.categoria_id
    WHERE p.precio > pc.precio_promedio * 1.2   -- 20% por encima del promedio
)
SELECT
    ppc.codigo_producto AS "Codigo Producto",
    ppc.nombre AS "Nombre",
    ppc.categoria_id AS "Categoria",
    ppc.precio AS "Precio",
    ppc.precio_promedio AS "Promedio Categoria"
FROM ProductosPromedioCategoria ppc
ORDER BY ppc.categoria_id;

-----------------------
-- Consulta 3
-----------------------

-- Lista todas las subcategorías de la categoría "Hardware" (ID=3), incluyendo subcategorías de subcategorías.
WITH RECURSIVE Categoria_SubCategorias AS (
    SELECT
        c.id,
        c.nombre,
        c.padre_id
    FROM categorias c
    WHERE c.id = 1

    UNION ALL

    SELECT
        c1.id,
        c1.nombre,
        c1.padre_id
    FROM categorias c1
    INNER JOIN Categoria_SubCategorias subc ON subc.id = c1.padre_id
)
SELECT
    csc.*
from Categoria_SubCategorias csc;

-- Codigo de IA para ver el formato de jerarquia
-- WITH RECURSIVE Categoria_SubCategorias AS (
--     SELECT
--         c.id,
--         c.nombre,
--         c.padre_id,
--         0 AS nivel,
--         CAST(c.id AS CHAR(50)) AS path
--     FROM categorias c
--     WHERE c.padre_id IS NULL

--     UNION ALL

--     SELECT
--         c1.id,
--         c1.nombre,
--         c1.padre_id,
--         csc.nivel + 1 AS nivel,
--         CONCAT(csc.path, '-', c1.id) AS path
--     FROM categorias c1
--     INNER JOIN Categoria_SubCategorias csc
--         ON c1.padre_id = csc.id
-- )
-- SELECT
--     id,
--     padre_id,
--     nivel,
--     CONCAT(REPEAT('    ', nivel), '↳ ', nombre) AS arbol
-- FROM Categoria_SubCategorias
-- ORDER BY path;


-----------------------
-- Consulta 4
-----------------------

-- Muestra la jerarquía completa de un proyecto con ID=5, desde el proyecto raíz hasta el más específico (ejemplo: ProyectoPadre → Subproyecto → Tarea).
WITH RECURSIVE JerarquiaProyectos AS (
    SELECT
        pro.id,
        pro.nombre,
        pro.proyecto_padre_id,
        0 AS nivel,
        CAST(pro.id AS VARCHAR(50)) AS path
    FROM proyectos pro
    WHERE pro.id = 1

    UNION ALL

    SELECT
        pro1.id,
        pro1.nombre,
        pro1.proyecto_padre_id,
        (jp.nivel + 1) AS nivel,
        CONCAT(jp.path, '-', pro1.id) AS path
    FROM proyectos pro1
    INNER JOIN JerarquiaProyectos jp ON pro1.proyecto_padre_id = jp.id
),
TareasAsociadas AS (
    SELECT
        tar.id,
        tar.nombre,
        tar.proyecto_id
    FROM tareas tar
    INNER JOIN JerarquiaProyectos jp ON jp.id = tar.proyecto_id
)
SELECT
    jp.id AS "Id Proyecto",
    jp.nombre AS "Nombre Proyecto",
    jp.proyecto_padre_id AS "Proyecto Padre Id",
    CONCAT(REPEAT('  ', jp.nivel), '↳ ', jp.nombre) AS "Jerarquia",
    ta.id AS "Id Tarea",
    ta.nombre AS "Nombre Tarea",
    ta.proyecto_id AS "Proyecto Id"
FROM JerarquiaProyectos jp
LEFT JOIN TareasAsociadas ta ON ta.proyecto_id = jp.id
ORDER BY jp.path;

WITH RECURSIVE JerarquiaProyectos AS (
    SELECT
        pro.id,
        pro.nombre,
        pro.proyecto_padre_id,
        0 AS nivel,
        CAST(pro.id AS VARCHAR(50)) AS path
    FROM proyectos pro
    WHERE pro.id = 1

    UNION ALL

    SELECT
        pro1.id,
        pro1.nombre,
        pro1.proyecto_padre_id,
        (jp.nivel + 1) AS nivel,
        CONCAT(jp.path, '-', pro1.id) AS path
    FROM proyectos pro1
    INNER JOIN JerarquiaProyectos jp ON pro1.proyecto_padre_id = jp.id
),
TareasAsociadas AS (
    SELECT
        tar.id,
        tar.nombre,
        tar.proyecto_id,
        (jp.nivel + 1) AS nivel,
        CONCAT(jp.path, '-', tar.id) AS path
    FROM tareas tar
    INNER JOIN JerarquiaProyectos jp ON jp.id = tar.proyecto_id
),
JerarquiaCompleta AS (
    SELECT
        jp.id,
        jp.nombre,
        jp.proyecto_padre_id,
        jp.nivel,
        jp.path,
        "Proyecto" AS tipo
    FROM JerarquiaProyectos jp

    UNION ALL

    SELECT
        ta.id,
        ta.nombre,
        ta.proyecto_id,
        ta.nivel,
        ta.path,
        "Tarea" AS tipo
    FROM TareasAsociadas ta
)
SELECT
    jc.id AS "Id",
    jc.nombre AS "Nombre",
    jc.proyecto_padre_id AS "Proyecto Padre",
    jc.nivel AS "Nivel",
    CONCAT(REPEAT('  ', jc.nivel), '↳ ', jc.nombre) AS "Jerarquia",
    jc.tipo AS "Tipo"
FROM JerarquiaCompleta jc
ORDER BY jc.path