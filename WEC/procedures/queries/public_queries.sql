-- Active: 1763026326945@@127.0.0.1@3306@wec
USE wec;
DELIMITER //

-- ============================================================
-- PUBLIC QUERIES (No authentication required)
-- Solo devuelven columnas seguras para el público general.
-- ============================================================

-- 1. Clasificación de una carrera (público)
CREATE PROCEDURE sp_public_race_leaderboard (
    IN p_race_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Public: leaderboard for a race (no login).'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_race_id)) THEN
        SIGNAL SQLSTATE '45040' SET MESSAGE_TEXT = 'Race ID cannot be null';
    END IF;

    IF NOT fn_IdRegisteredFromRaces(p_race_id) THEN
        SIGNAL SQLSTATE '45040' SET MESSAGE_TEXT = 'Race ID does not exist';
    END IF;

    SELECT
        r.position AS 'Position',
        p.pilot_name AS 'PilotName',
        t.team_name AS 'TeamName',
        v.model AS 'VehicleModel',
        r.final_time AS 'FinalTime',
        r.penalty_time AS 'PenaltyTime',
        (r.base_points_pilot - r.penalty_points_pilot) AS 'TotalPoints'
    FROM results r
    JOIN inscriptions i ON i.id_vehicle = r.id_vehicle AND i.id_race = r.id_race AND i.id_team = r.id_team
    JOIN pilots_inscriptions pi ON pi.id_vehicle = i.id_vehicle AND pi.id_race = i.id_race AND pi.id_team = i.id_team
    JOIN pilots p ON p.id_pilot = pi.id_pilot
    JOIN teams t ON t.id_team = r.id_team
    JOIN vehicles v ON v.id_vehicle = r.id_vehicle
    WHERE r.id_race = p_race_id
    ORDER BY r.position ASC;
END //

-- 2. Calendario de carreras (público)
CREATE PROCEDURE sp_public_race_calendar ()
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Public: list all races with basic info.'
BEGIN
    SELECT 
        r.id_race,
        r.event_name,
        r.event_date,
        r.event_duration,
        c.circuit_name,
        c.country
    FROM races r
    LEFT JOIN circuits c ON c.id_circuit = r.id_circuit
    ORDER BY r.event_date;
END //

-- 3. Listado de pilotos (público, solo nombre y categoría)
CREATE PROCEDURE sp_public_pilots_list ()
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Public: list all pilots (name and category only).'
BEGIN
    SELECT 
        p.pilot_name, 
        pc.pilot_category_name
    FROM pilots p
    JOIN pilot_categories pc ON pc.id_pilot_category = p.id_pilot_category
    ORDER BY p.pilot_name;
END //

-- 4. Resultados por equipo (público)
CREATE PROCEDURE sp_public_team_results (
    IN p_team_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Public: results of a specific team (no internal points).'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_team_id)) THEN
        SIGNAL SQLSTATE '45052' SET MESSAGE_TEXT = 'Team ID cannot be null';
    END IF;

    IF NOT fn_IdRegisterExistsFromTeams(p_team_id) THEN
        SIGNAL SQLSTATE '45052' SET MESSAGE_TEXT = 'Team ID does not exist';
    END IF;

    SELECT 
        r.id_race,
        rac.event_name,
        r.position,
        r.final_time,
        r.penalty_time
    FROM results r
    JOIN races rac ON rac.id_race = r.id_race
    WHERE r.id_team = p_team_id
    ORDER BY rac.event_date;
END //

DELIMITER ;