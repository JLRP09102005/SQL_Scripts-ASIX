-- Active: 1763026326945@@127.0.0.1@3306@jardineria
-- 1.Jerarquía simple de un empleado expecífico
WITH RECURSIVE JerarquiaEmpleados AS (
    SELECT
        codigo_empleado,
        nombre,
        apellido1,
        codigo_jefe,
        1 AS nivel,
        CAST(codigo_empleado AS CHAR(100)) AS ruta
    FROM empleado
    WHERE codigo_empleado = 3

    UNION ALL

    SELECT
        e.codigo_empleado,
        e.nombre,
        e.apellido1,
        e.codigo_jefe,
        (j.nivel + 1) AS nivel,
        CONCAT(j.ruta, '-', e.codigo_empleado) AS ruta
    FROM empleado e
    JOIN JerarquiaEmpleados j ON e.codigo_jefe = j.codigo_empleado
)
SELECT 
    je.codigo_empleado,
    je.nombre,
    je.apellido1,
    je.codigo_jefe,
    je.nivel,
    je.ruta
    -- CONCAT(REPEAT('    ', je.nivel), '↳ ', je.nombre) AS jerarquia
FROM JerarquiaEmpleados je
ORDER BY je.ruta;

-- 2. Encontrar la cadena de mando ascendente a partir de un empleado expecifico
WITH RECURSIVE JerarquiaEmpleados AS (
    SELECT
        codigo_empleado,
        nombre,
        apellido1,
        codigo_jefe,
        1 AS nivel,
        CAST(codigo_empleado AS CHAR(100)) AS ruta
    FROM empleado
    WHERE codigo_empleado = 3

    UNION ALL

    SELECT
        e.codigo_empleado,
        e.nombre,
        e.apellido1,
        e.codigo_jefe,
        (j.nivel + 1) AS nivel,
        CONCAT(j.ruta, '-', e.codigo_empleado) AS ruta
    FROM empleado e
    JOIN JerarquiaEmpleados j ON e.codigo_empleado = j.codigo_jefe
    WHERE j.codigo_jefe IS NOT NULL
)
SELECT 
    je.codigo_empleado,
    je.nombre,
    je.apellido1,
    je.codigo_jefe,
    je.nivel,
    je.ruta
    -- CONCAT(REPEAT('    ', je.nivel), '↳ ', je.nombre) AS jerarquia
FROM JerarquiaEmpleados je
ORDER BY je.ruta;

-- 3. Contar empleados por nivel jerarquico especifico
WITH RECURSIVE JerarquiaNiveles AS (
    SELECT
        codigo_empleado,
        nombre,
        apellido1,
        codigo_jefe,
        1 AS nivel
    FROM empleado
    WHERE codigo_jefe IS NULL

    UNION ALL
    SELECT
        e.codigo_empleado,
        e.nombre,
        e.apellido1,
        e.codigo_jefe,
        (j.nivel + 1) AS nivel
    FROM empleado e
    INNER JOIN JerarquiaNiveles j ON e.codigo_jefe = j.codigo_empleado
)
SELECT
    nivel,
    COUNT(*) AS "Cantidad de empleados",
    GROUP_CONCAT(CONCAT(nombre, ' ', apellido1) ORDER BY nombre SEPARATOR ", ") AS "Empleados en el nivel"
FROM JerarquiaNiveles
GROUP BY nivel
ORDER BY nivel;