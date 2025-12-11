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

-- 4. Mapa jerarquico visual con indentacion
WITH RECURSIVE ArbolJerarquico AS (
    SELECT
        codigo_empleado,
        nombre,
        apellido1,
        codigo_jefe,
        puesto,
        1 AS nivel,
        CAST(CONCAT(SPACE(0), nombre, ' ', apellido1) AS CHAR(100)) AS estructura,
        CAST(codigo_empleado AS CHAR(100)) as ruta_jerarquica
    FROM empleado
    WHERE codigo_jefe IS NULL

    UNION ALL

    SELECT
        e.codigo_empleado,
        e.nombre,
        e.apellido1,
        e.codigo_jefe,
        e.puesto,
        (aj.nivel + 1) AS nivel,
        CAST(
            CONCAT(SPACE((aj.nivel) * 8), "┣", e.nombre, ' ', e.apellido1, ' (', e.puesto, ')') 
        AS CHAR(500)
        ) AS estructura,
        CONCAT(aj.ruta_jerarquica, '-', e.codigo_empleado) AS ruta_jerarquica
    FROM empleado e
    INNER JOIN ArbolJerarquico aj ON e.codigo_jefe = aj.codigo_empleado
)
SELECT
    aj.nivel,
    aj.estructura AS "Estructura Organizacional",
    aj.puesto,
    aj.ruta_jerarquica AS "Ruta Jerarquica"
FROM ArbolJerarquico aj
ORDER BY aj.estructura DESC;

-- 5. Analisis de ventas por jerarquia con path completo
WITH RECURSIVE JerarquiaVentas AS (
    SELECT
        e.codigo_empleado,
        e.nombre,
        e.apellido1,
        e.puesto,
        e.codigo_jefe,
        CAST(CONCAT(e.nombre, ' ', e.apellido1) AS CHAR(500)) AS nombre_completo,
        1 AS nivel
    FROM empleado e
    WHERE EXISTS ( -- Mostrar los empleados que tengan alguna foreign key en cliente de su pk
        SELECT 1
        FROM cliente c
        WHERE c.codigo_empleado_rep_ventas = e.codigo_empleado
    )

    UNION ALL

    SELECT
        jv.codigo_empleado,
        jv.nombre,
        jv.apellido1,
        jv.puesto,
        jv.codigo_jefe,
        CAST(
            CONCAT(e.nombre, ' ', e.apellido1, ' <- ', jv.nombre_completo)
        AS CHAR(500)),
        (jv.nivel + 1) AS nivel
    FROM empleado e
    INNER JOIN JerarquiaVentas jv ON jv.codigo_jefe = e.codigo_empleado
    WHERE e.codigo_jefe IS NOT NULL
),
ClientesPorEmpleado AS (
    SELECT
        codigo_empleado_rep_ventas,
        COUNT(*) AS total_clientes
        FROM cliente
        GROUP BY codigo_empleado_rep_ventas
)
SELECT
    jv.nivel,
    jv.nombre_completo AS "Cadena de Responsabilidad",
    COALESCE(cpe.total_clientes, 0) AS "Clientes Atendidos",
    CASE 
        WHEN jv.nivel = 1 THEN "Representante"
        WHEN jv.puesto LIKE "%Director%" THEN "Supervisor" 
        ELSE "Gerencia"
    END AS "Nivel de Gestion"
FROM JerarquiaVentas jv
LEFT JOIN ClientesPorEmpleado cpe ON cpe.codigo_empleado_rep_ventas = jv.codigo_empleado
ORDER BY
    jv.nivel,
    jv.nombre_completo;