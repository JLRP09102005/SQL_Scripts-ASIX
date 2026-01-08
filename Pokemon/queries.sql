-- Active: 1762272161423@@127.0.0.1@3306@pokebase
WITH RECURSIVE PokeEvolution AS (
    SELECT
        p.id_pokemon,
        p.nombre,
        CASE 
          WHEN p.tipo2 IS NULL THEN p.tipo1
          ELSE CONCAT(p.tipo1, '-', p.tipo2)
        END AS tipo,
        0 AS nivel,
        CAST(p.id_pokemon AS CHAR(50)) as path,
        CAST(NULL AS UNSIGNED) AS id_prev_pokemon 
    FROM pokemon p
    WHERE p.nombre = 'Charmander'

    UNION ALL

    SELECT
        p1.id_pokemon,
        p1.nombre,
        CASE 
          WHEN p1.tipo2 IS NULL THEN p1.tipo1
          ELSE CONCAT(p1.tipo1, '-', p1.tipo2)
        END AS tipo,
        (pe.nivel + 1) AS nivel,
        CONCAT(pe.path, '-', p1.id_pokemon) AS path,
        CAST(pe.id_pokemon AS UNSIGNED) AS id_prev_pokemon
    FROM pokemon p1
    INNER JOIN evoluciones e ON e.id_pokemon_destino = p1.id_pokemon
    INNER JOIN PokeEvolution pe ON pe.id_pokemon = e.id_pokemon_origen
),
PokeEstadistics AS (
    SELECT
        pev.id_pokemon,
        CONCAT(est_base.ps, '/+', (est_base.ps - IFNULL(prev_est_base.ps, est_base.ps))) AS ps,
        CONCAT(est_base.ataque, '/+', (est_base.ataque - IFNULL(prev_est_base.ataque, est_base.ataque))) AS ataque,
        CONCAT(est_base.ataque_esp, '/+', (est_base.ataque_esp - IFNULL(prev_est_base.ataque_esp, est_base.ataque_esp))) AS ataque_esp,
        CONCAT(est_base.defensa, '/+', (est_base.defensa - IFNULL(prev_est_base.defensa, est_base.defensa))) AS defensa,
        CONCAT(est_base.defensa_esp, '/+', (est_base.defensa_esp - IFNULL(prev_est_base.defensa_esp, est_base.defensa_esp))) AS defensa_esp,
        CONCAT(est_base.velocidad, '/+', (est_base.velocidad - IFNULL(prev_est_base.velocidad, est_base.velocidad))) AS velocidad
    FROM PokeEvolution pev
    LEFT JOIN estadisticas_base est_base ON est_base.id_pokemon = pev.id_pokemon
    LEFT JOIN estadisticas_base prev_est_base ON prev_est_base.id_pokemon = pev.id_prev_pokemon

),
PokeMovements AS (
    SELECT
        m.id_movimiento,
        m.nombre,
        pokmov.id_pokemon,
        pokmov.metodo_aprendizaje,
        pokmov.nivel_requerido
    FROM movimientos m
    INNER JOIN pokemon_movimientos pokmov ON pokmov.id_movimiento = m.id_movimiento
)
SELECT
    pev.nivel AS 'Nivel Evolutivo',
    pev.nombre AS 'Nombre Pokemon',
    CONCAT(REPEAT('    ', pev.nivel), '↳ ', pev.nombre) AS 'Jerarquia',
    pev.tipo AS 'Tipos',
    pes.ps AS 'PS',
    pes.ataque AS 'Ataque',
    pes.defensa AS 'Defensa',
    pes.ataque_esp AS 'Ataque Espeacial',
    pes.defensa_esp AS 'Defensa Especial',
    pes.velocidad AS 'Velocidad',
    pm.nombre AS 'Nombre Movimiento',
    pm.metodo_aprendizaje AS 'Metodo Aprendizaje',
    pm.nivel_requerido AS "Nivel Requerido"
FROM PokeEvolution pev
LEFT JOIN PokeEstadistics pes ON pes.id_pokemon = pev.id_pokemon
LEFT JOIN PokeMovements pm ON pm.id_pokemon = pev.id_pokemon
ORDER BY pev.path;

DESCRIBE estadisticas_base;