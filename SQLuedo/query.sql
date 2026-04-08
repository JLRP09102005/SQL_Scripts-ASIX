-- Active: 1763026326945@@127.0.0.1@3306@cluedo_sql
USE cluedo_sql;

SELECT
    sos.id AS "Sospechoso ID",
    arm.id AS "Arma ID",
    hab.id AS "Habitacion ID"
FROM sospechosos sos
INNER JOIN eventos eve ON eve.sospechoso_id = sos.id
INNER JOIN habitaciones hab ON eve.habitacion_id = hab.id
INNER JOIN armas arm ON eve.arma_id = arm.id
WHERE 
    eve.hora BETWEEN CAST('21:30' AS TIME) AND CAST('22:00' AS TIME)
    AND hab.pasaje_secreto = 0
    AND hab.id != 6
    AND eve.arma_id IS NOT NULL;