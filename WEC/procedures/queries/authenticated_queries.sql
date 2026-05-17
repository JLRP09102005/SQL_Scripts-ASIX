-- Active: 1763026326945@@127.0.0.1@3306@wec
USE wec;
DELIMITER //

-- ============================================================
-- 1. ADMINISTRADORES (software-administrator, administratorDB)
--    Acceso total a todas las tablas sin filtro
-- ============================================================

-- 1.1 Ver todos los circuitos (admin)
CREATE PROCEDURE IF NOT EXISTS sp_admin_all_circuits (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Admin: view all circuits.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT (fn_UserHasRole(p_user_id, 'software-administrator') OR fn_UserHasRole(p_user_id, 'administratorDB')) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: admin role required';
    END IF;

    SELECT * FROM circuits ORDER BY id_circuit;
END //

-- 1.2 Ver todos los fabricantes (admin)
CREATE PROCEDURE IF NOT EXISTS sp_admin_all_manufacturers (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Admin: view all manufacturers.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT (fn_UserHasRole(p_user_id, 'software-administrator') OR fn_UserHasRole(p_user_id, 'administratorDB')) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: admin role required';
    END IF;

    SELECT * FROM manufacturers ORDER BY manufacturer_name;
END //

-- 1.3 Ver todos los pilotos (admin)
CREATE PROCEDURE IF NOT EXISTS sp_admin_all_pilots (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Admin: view all pilots.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT (fn_UserHasRole(p_user_id, 'software-administrator') OR fn_UserHasRole(p_user_id, 'administratorDB')) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: admin role required';
    END IF;

    SELECT p.*, pc.pilot_category_name
    FROM pilots p
    JOIN pilot_categories pc ON pc.id_pilot_category = p.id_pilot_category
    ORDER BY p.pilot_name;
END //

-- 1.4 Ver todos los equipos (admin)
CREATE PROCEDURE IF NOT EXISTS sp_admin_all_teams (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Admin: view all teams.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT (fn_UserHasRole(p_user_id, 'software-administrator') OR fn_UserHasRole(p_user_id, 'administratorDB')) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: admin role required';
    END IF;

    SELECT t.*, m.manufacturer_name
    FROM teams t
    LEFT JOIN manufacturers m ON m.id_manufacturer = t.id_manufacturer
    ORDER BY t.team_name;
END //

-- 1.5 Ver todos los vehículos (admin)
CREATE PROCEDURE IF NOT EXISTS sp_admin_all_vehicles (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Admin: view all vehicles.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT (fn_UserHasRole(p_user_id, 'software-administrator') OR fn_UserHasRole(p_user_id, 'administratorDB')) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: admin role required';
    END IF;

    SELECT * FROM vehicles ORDER BY model;
END //

-- 1.6 Ver todas las carreras (admin)
CREATE PROCEDURE IF NOT EXISTS sp_admin_all_races (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Admin: view all races.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT (fn_UserHasRole(p_user_id, 'software-administrator') OR fn_UserHasRole(p_user_id, 'administratorDB')) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: admin role required';
    END IF;

    SELECT r.*, c.circuit_name
    FROM races r
    LEFT JOIN circuits c ON c.id_circuit = r.id_circuit
    ORDER BY r.event_date;
END //

-- 1.7 Ver todas las inscripciones (admin)
CREATE PROCEDURE IF NOT EXISTS sp_admin_all_inscriptions (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Admin: view all inscriptions.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT (fn_UserHasRole(p_user_id, 'software-administrator') OR fn_UserHasRole(p_user_id, 'administratorDB')) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: admin role required';
    END IF;

    SELECT i.*, v.model, r.event_name, t.team_name
    FROM inscriptions i
    JOIN vehicles v ON v.id_vehicle = i.id_vehicle
    JOIN races r ON r.id_race = i.id_race
    JOIN teams t ON t.id_team = i.id_team
    ORDER BY i.id_race, i.id_team;
END //

-- 1.8 Ver todas las inscripciones de pilotos (admin)
CREATE PROCEDURE IF NOT EXISTS sp_admin_all_pilots_inscriptions (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Admin: view all pilots_inscriptions.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT (fn_UserHasRole(p_user_id, 'software-administrator') OR fn_UserHasRole(p_user_id, 'administratorDB')) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: admin role required';
    END IF;

    SELECT pi.*, p.pilot_name, v.model, r.event_name, t.team_name
    FROM pilots_inscriptions pi
    JOIN pilots p ON p.id_pilot = pi.id_pilot
    JOIN vehicles v ON v.id_vehicle = pi.id_vehicle
    JOIN races r ON r.id_race = pi.id_race
    JOIN teams t ON t.id_team = pi.id_team
    ORDER BY pi.id_race, pi.id_team, pi.id_pilot;
END //

-- 1.9 Ver todos los resultados (admin)
CREATE PROCEDURE IF NOT EXISTS sp_admin_all_results (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Admin: view all results.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT (fn_UserHasRole(p_user_id, 'software-administrator') OR fn_UserHasRole(p_user_id, 'administratorDB')) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: admin role required';
    END IF;

    SELECT 
        r.*, 
        rac.event_name,
        tea.team_name,
        veh.model
    FROM results r
    INNER JOIN races rac ON rac.id_race = r.id_race
    INNER JOIN teams tea ON tea.id_team = r.id_team
    INNER JOIN vehicles veh ON veh.id_vehicle = r.id_vehicle 
    ORDER BY rac.event_date, r.position;
END //

-- 1.10 Ver todas las penalizaciones (admin)
CREATE PROCEDURE IF NOT EXISTS sp_admin_all_penalties (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Admin: view all penalties.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT (fn_UserHasRole(p_user_id, 'software-administrator') OR fn_UserHasRole(p_user_id, 'administratorDB')) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: admin role required';
    END IF;

    SELECT
        pen.*,
        penres.id_result,
        tea.team_name,
        IF(pen.penalty_applies_to = 'PILOT', pil.pilot_name, NULL) AS pilot_name,
        IF(pen.penalty_applies_to = 'PILOT', pil.id_pilot, NULL)   AS id_pilot,
        rac.event_name
    FROM penalties pen
    LEFT JOIN penalties_results penres
        ON penres.id_penalty = pen.id_penalty
    LEFT JOIN results res
        ON res.id_result = penres.id_result
    LEFT JOIN races rac
        ON rac.id_race = res.id_race
    LEFT JOIN teams tea
        ON tea.id_team = res.id_team
    LEFT JOIN pilots_inscriptions pilins
        ON pilins.id_race = res.id_race
    AND pilins.id_team = res.id_team
    AND pilins.id_vehicle = res.id_vehicle
    LEFT JOIN pilots pil
        ON pil.id_pilot = pilins.id_pilot
    ORDER BY pen.created_at DESC;
END //

-- 1.11 Ver todas las relaciones penalización-resultado (admin)
CREATE PROCEDURE IF NOT EXISTS sp_admin_all_penalties_results (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Admin: view all penalties_results.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT (fn_UserHasRole(p_user_id, 'software-administrator') OR fn_UserHasRole(p_user_id, 'administratorDB')) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: admin role required';
    END IF;

    SELECT pr.*, p.penalty_type, res.id_race, rac.event_name
    FROM penalties_results pr
    JOIN penalties p ON p.id_penalty = pr.id_penalty
    JOIN results res ON res.id_result = pr.id_result
    JOIN races rac ON rac.id_race = res.id_race
    ORDER BY pr.id_penalty, pr.id_result;
END //

-- 1.11 Ver todos los usuarios y sus roles asignados (admin)
CREATE PROCEDURE IF NOT EXISTS sp_admin_all_users (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Admin: view all users.'
BEGIN

    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT (fn_UserHasRole(p_user_id, 'software-administrator') OR fn_UserHasRole(p_user_id, 'administratorDB')) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: admin role required';
    END IF;

    SELECT
        us.*,
        GROUP_CONCAT(userol.role_name ORDER BY userol.role_name SEPARATOR ', ') AS role
    FROM users us
    LEFT JOIN user_userrole useuse ON useuse.id_user = us.id_user
    LEFT JOIN user_roles userol ON userol.id_user_roles = useuse.id_user_role
    GROUP BY us.id_user
    ORDER BY us.username;

END //

-- ============================================================
-- 2. COMMISSIONER BOSS (SELECT global en penalties, results, races)
-- ============================================================

-- 2.1 Ver todas las penalizaciones (commissioner)
CREATE PROCEDURE IF NOT EXISTS sp_commissioner_all_penalties (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Commissioner boss: view all penalties.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'commissioner-boss') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: commissioner-boss role required';
    END IF;

    SELECT * FROM penalties ORDER BY created_at DESC;
END //

-- 2.2 Ver todos los resultados (commissioner)
CREATE PROCEDURE IF NOT EXISTS sp_commissioner_all_results (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Commissioner boss: view all results.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'commissioner-boss') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: commissioner-boss role required';
    END IF;

    SELECT r.id_result, r.position, r.final_time, r.penalty_time, 
           r.base_points_team, r.base_points_pilot,
           r.penalty_points_team, r.penalty_points_pilot,
           r.id_vehicle, r.id_race, r.id_team, rac.event_name
    FROM results r
    JOIN races rac ON rac.id_race = r.id_race
    ORDER BY rac.event_date, r.position;
END //

-- 2.3 Ver todas las carreras (commissioner)
CREATE PROCEDURE IF NOT EXISTS sp_commissioner_all_races (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Commissioner boss: view all races.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'commissioner-boss') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: commissioner-boss role required';
    END IF;

    SELECT r.*, c.circuit_name
    FROM races r
    LEFT JOIN circuits c ON c.id_circuit = r.id_circuit
    ORDER BY r.event_date;
END //

-- ============================================================
-- 3. RACE DIRECTOR (SELECT global en penalties, results, penalties_results, races)
-- ============================================================

-- 3.1 Ver todas las penalizaciones (race director)
CREATE PROCEDURE IF NOT EXISTS sp_racedirector_all_penalties (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Race director: view all penalties.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'race-director') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: race-director role required';
    END IF;

    SELECT * FROM penalties ORDER BY created_at DESC;
END //

-- 3.2 Ver todos los resultados (race director)
CREATE PROCEDURE IF NOT EXISTS sp_racedirector_all_results (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Race director: view all results.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'race-director') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: race-director role required';
    END IF;

    SELECT r.*, rac.event_name
    FROM results r
    JOIN races rac ON rac.id_race = r.id_race
    ORDER BY rac.event_date, r.position;
END //

-- 3.3 Ver todas las relaciones penalización-resultado (race director)
CREATE PROCEDURE IF NOT EXISTS sp_racedirector_all_penalties_results (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Race director: view all penalties_results.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'race-director') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: race-director role required';
    END IF;

    SELECT pr.*, p.penalty_type, res.id_race, rac.event_name
    FROM penalties_results pr
    JOIN penalties p ON p.id_penalty = pr.id_penalty
    JOIN results res ON res.id_result = pr.id_result
    JOIN races rac ON rac.id_race = res.id_race
    ORDER BY pr.id_penalty, pr.id_result;
END //

-- 3.4 Ver todas las carreras (race director)
CREATE PROCEDURE IF NOT EXISTS sp_racedirector_all_races (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Race director: view all races (with circuit).'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'race-director') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: race-director role required';
    END IF;

    SELECT r.*, c.circuit_name
    FROM races r
    LEFT JOIN circuits c ON c.id_circuit = r.id_circuit
    ORDER BY r.event_date;
END //

-- ============================================================
-- 4. DATA ANALYST (SELECT global en muchas tablas)
-- ============================================================

-- 4.1 Ver todas las carreras (analyst)
CREATE PROCEDURE IF NOT EXISTS sp_analyst_all_races (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Data analyst: view all races.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'data-analyst') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: data-analyst role required';
    END IF;

    SELECT r.id_race, r.event_name, r.event_date, r.event_duration, c.circuit_name, c.country, c.length_km
    FROM races r
    LEFT JOIN circuits c ON c.id_circuit = r.id_circuit
    ORDER BY r.event_date;
END //

-- 4.2 Ver todos los circuitos (analyst)
CREATE PROCEDURE IF NOT EXISTS sp_analyst_all_circuits (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Data analyst: view all circuits.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'data-analyst') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: data-analyst role required';
    END IF;

    SELECT * FROM circuits ORDER BY country, circuit_name;
END //

-- 4.3 Ver todas las categorías de pilotos (analyst)
CREATE PROCEDURE IF NOT EXISTS sp_analyst_all_pilot_categories (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Data analyst: view all pilot categories.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'data-analyst') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: data-analyst role required';
    END IF;

    SELECT * FROM pilot_categories ORDER BY pilot_category_name;
END //

-- 4.4 Ver todos los resultados (analyst)
CREATE PROCEDURE IF NOT EXISTS sp_analyst_all_results (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Data analyst: view all results.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'data-analyst') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: data-analyst role required';
    END IF;

    SELECT r.id_result, r.position, r.final_time, r.penalty_time,
           r.base_points_team, r.base_points_pilot,
           r.penalty_points_team, r.penalty_points_pilot,
           r.id_vehicle, r.id_race, r.id_team, rac.event_name
    FROM results r
    JOIN races rac ON rac.id_race = r.id_race
    ORDER BY rac.event_date, r.position;
END //

-- 4.5 Ver todos los equipos (analyst)
CREATE PROCEDURE IF NOT EXISTS sp_analyst_all_teams (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Data analyst: view all teams.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'data-analyst') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: data-analyst role required';
    END IF;

    SELECT t.id_team, t.team_name, t.mechanics_num, m.manufacturer_name
    FROM teams t
    LEFT JOIN manufacturers m ON m.id_manufacturer = t.id_manufacturer
    ORDER BY t.team_name;
END //

-- 4.6 Ver todas las penalizaciones (analyst)
CREATE PROCEDURE IF NOT EXISTS sp_analyst_all_penalties (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Data analyst: view all penalties.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'data-analyst') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: data-analyst role required';
    END IF;

    SELECT * FROM penalties ORDER BY created_at DESC;
END //

-- 4.7 Ver todos los pilotos (analyst)
CREATE PROCEDURE IF NOT EXISTS sp_analyst_all_pilots (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Data analyst: view all pilots.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'data-analyst') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: data-analyst role required';
    END IF;

    SELECT p.id_pilot, p.pilot_name, p.pilot_age, pc.pilot_category_name
    FROM pilots p
    JOIN pilot_categories pc ON pc.id_pilot_category = p.id_pilot_category
    ORDER BY p.pilot_name;
END //

-- 4.8 Ver todas las inscripciones de pilotos (analyst)
CREATE PROCEDURE IF NOT EXISTS sp_analyst_all_pilots_inscriptions (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Data analyst: view all pilots_inscriptions.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'data-analyst') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: data-analyst role required';
    END IF;

    SELECT pi.*, p.pilot_name, v.model, r.event_name, t.team_name
    FROM pilots_inscriptions pi
    JOIN pilots p ON p.id_pilot = pi.id_pilot
    JOIN vehicles v ON v.id_vehicle = pi.id_vehicle
    JOIN races r ON r.id_race = pi.id_race
    JOIN teams t ON t.id_team = pi.id_team
    ORDER BY pi.id_race, pi.id_team, pi.id_pilot;
END //

-- 4.9 Ver todas las inscripciones generales (analyst)
CREATE PROCEDURE IF NOT EXISTS sp_analyst_all_inscriptions (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Data analyst: view all inscriptions.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'data-analyst') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: data-analyst role required';
    END IF;

    SELECT i.*, v.model, r.event_name, t.team_name
    FROM inscriptions i
    JOIN vehicles v ON v.id_vehicle = i.id_vehicle
    JOIN races r ON r.id_race = i.id_race
    JOIN teams t ON t.id_team = i.id_team
    ORDER BY i.id_race, i.id_team;
END //

-- 4.10 Ver todos los vehículos (analyst)
CREATE PROCEDURE IF NOT EXISTS sp_analyst_all_vehicles (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Data analyst: view all vehicles.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'data-analyst') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: data-analyst role required';
    END IF;

    SELECT * FROM vehicles ORDER BY model;
END //

-- 4.11 Ver todas las relaciones penalización-resultado (analyst)
CREATE PROCEDURE IF NOT EXISTS sp_analyst_all_penalties_results (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Data analyst: view all penalties_results.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'data-analyst') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: data-analyst role required';
    END IF;

    SELECT pr.*, p.penalty_type, res.id_race, rac.event_name
    FROM penalties_results pr
    JOIN penalties p ON p.id_penalty = pr.id_penalty
    JOIN results res ON res.id_result = pr.id_result
    JOIN races rac ON rac.id_race = res.id_race
    ORDER BY pr.id_penalty, pr.id_result;
END //

-- ============================================================
-- 5. MANUFACTURER REPRESENTATIVE (filtrado por su fabricante)
-- ============================================================

-- 5.1 Ver su propio fabricante
CREATE PROCEDURE IF NOT EXISTS sp_manufacturer_my_data (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Manufacturer rep: view own manufacturer details.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_team_id INT;
    DECLARE v_manufacturer_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'manufacturer-representative') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: manufacturer-representative role required';
    END IF;

    SELECT team_id INTO v_team_id FROM users WHERE id_user = p_user_id;
    IF v_team_id IS NULL THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User has no associated team';
    END IF;

    SELECT id_manufacturer INTO v_manufacturer_id FROM teams WHERE id_team = v_team_id;
    IF v_manufacturer_id IS NULL THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Team has no manufacturer';
    END IF;

    SELECT * FROM manufacturers WHERE id_manufacturer = v_manufacturer_id;
END //

-- 5.2 Ver equipos que usan su fabricante
CREATE PROCEDURE IF NOT EXISTS sp_manufacturer_my_teams (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Manufacturer rep: view teams using my manufacturer.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_team_id INT;
    DECLARE v_manufacturer_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'manufacturer-representative') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: manufacturer-representative role required';
    END IF;

    SELECT team_id INTO v_team_id FROM users WHERE id_user = p_user_id;
    IF v_team_id IS NULL THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User has no associated team';
    END IF;

    SELECT id_manufacturer INTO v_manufacturer_id FROM teams WHERE id_team = v_team_id;
    IF v_manufacturer_id IS NULL THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Team has no manufacturer';
    END IF;

    SELECT t.id_team, t.team_name, t.mechanics_num
    FROM teams t
    WHERE t.id_manufacturer = v_manufacturer_id;
END //

-- 5.3 Ver vehículos de equipos de su fabricante
CREATE PROCEDURE IF NOT EXISTS sp_manufacturer_my_vehicles (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Manufacturer rep: view vehicles of teams using my manufacturer.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_team_id INT;
    DECLARE v_manufacturer_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'manufacturer-representative') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: manufacturer-representative role required';
    END IF;

    SELECT team_id INTO v_team_id FROM users WHERE id_user = p_user_id;
    IF v_team_id IS NULL THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User has no associated team';
    END IF;

    SELECT id_manufacturer INTO v_manufacturer_id FROM teams WHERE id_team = v_team_id;
    IF v_manufacturer_id IS NULL THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Team has no manufacturer';
    END IF;

    SELECT DISTINCT v.id_vehicle, v.model, v.specifications_url, t.team_name
    FROM vehicles v
    JOIN inscriptions i ON i.id_vehicle = v.id_vehicle
    JOIN teams t ON t.id_team = i.id_team
    WHERE t.id_manufacturer = v_manufacturer_id;
END //

-- ============================================================
-- 6. MECHANICAL BOSS (filtrado por su equipo)
-- ============================================================

-- 6.1 Ver vehículos de mi equipo (mechanical)
CREATE PROCEDURE IF NOT EXISTS sp_mechanical_my_vehicles (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Mechanical boss: view vehicles of own team.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_team_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'mechanical-boss') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: mechanical-boss role required';
    END IF;

    SELECT team_id INTO v_team_id FROM users WHERE id_user = p_user_id;
    IF v_team_id IS NULL THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User has no associated team';
    END IF;

    SELECT DISTINCT v.id_vehicle, v.model, v.specifications_url
    FROM vehicles v
    JOIN inscriptions i ON i.id_vehicle = v.id_vehicle
    WHERE i.id_team = v_team_id;
END //

-- 6.2 Ver circuitos (mechanical, global)
CREATE PROCEDURE IF NOT EXISTS sp_mechanical_all_circuits (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Mechanical boss: view all circuits (global).'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'mechanical-boss') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: mechanical-boss role required';
    END IF;

    SELECT * FROM circuits ORDER BY country, circuit_name;
END //

-- 6.3 Ver carreras (mechanical, global)
CREATE PROCEDURE IF NOT EXISTS sp_mechanical_all_races (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Mechanical boss: view all races (global).'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'mechanical-boss') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: mechanical-boss role required';
    END IF;

    SELECT r.*, c.circuit_name
    FROM races r
    LEFT JOIN circuits c ON c.id_circuit = r.id_circuit
    ORDER BY r.event_date;
END //

-- ============================================================
-- 7. TEAM MANAGER (filtrado por su equipo)
-- ============================================================

-- 7.1 Ver mi equipo (team manager)
CREATE PROCEDURE IF NOT EXISTS sp_teammanager_my_team (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Team manager: view own team details.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_team_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'team-manager') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: team-manager role required';
    END IF;

    SELECT team_id INTO v_team_id FROM users WHERE id_user = p_user_id;
    IF v_team_id IS NULL THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User has no associated team';
    END IF;

    SELECT t.*, m.manufacturer_name
    FROM teams t
    LEFT JOIN manufacturers m ON m.id_manufacturer = t.id_manufacturer
    WHERE t.id_team = v_team_id;
END //

-- 7.2 Ver pilotos de mi equipo
CREATE PROCEDURE IF NOT EXISTS sp_teammanager_my_pilots (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Team manager: view pilots of own team.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_team_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'team-manager') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: team-manager role required';
    END IF;

    SELECT team_id INTO v_team_id FROM users WHERE id_user = p_user_id;
    IF v_team_id IS NULL THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User has no associated team';
    END IF;

    SELECT DISTINCT p.id_pilot, p.pilot_name, p.pilot_age, pc.pilot_category_name
    FROM pilots p
    JOIN pilots_inscriptions pi ON pi.id_pilot = p.id_pilot
    JOIN pilot_categories pc ON pc.id_pilot_category = p.id_pilot_category
    WHERE pi.id_team = v_team_id
    ORDER BY p.pilot_name;
END //

-- 7.3 Ver inscripciones de mi equipo
CREATE PROCEDURE IF NOT EXISTS sp_teammanager_my_inscriptions (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Team manager: view inscriptions of own team.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_team_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'team-manager') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: team-manager role required';
    END IF;

    SELECT team_id INTO v_team_id FROM users WHERE id_user = p_user_id;
    IF v_team_id IS NULL THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User has no associated team';
    END IF;

    SELECT i.*, v.model, r.event_name
    FROM inscriptions i
    JOIN vehicles v ON v.id_vehicle = i.id_vehicle
    JOIN races r ON r.id_race = i.id_race
    WHERE i.id_team = v_team_id
    ORDER BY r.event_date;
END //

-- 7.4 Ver resultados de mi equipo
CREATE PROCEDURE IF NOT EXISTS sp_teammanager_my_results (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Team manager: view results of own team.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_team_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'team-manager') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: team-manager role required';
    END IF;

    SELECT team_id INTO v_team_id FROM users WHERE id_user = p_user_id;
    IF v_team_id IS NULL THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User has no associated team';
    END IF;

    SELECT r.*, rac.event_name
    FROM results r
    JOIN races rac ON rac.id_race = r.id_race
    WHERE r.id_team = v_team_id
    ORDER BY rac.event_date, r.position;
END //

-- 7.5 Ver penalizaciones de mi equipo
CREATE PROCEDURE IF NOT EXISTS sp_teammanager_my_penalties (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Team manager: view penalties of own team.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_team_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'team-manager') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: team-manager role required';
    END IF;

    SELECT team_id INTO v_team_id FROM users WHERE id_user = p_user_id;
    IF v_team_id IS NULL THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User has no associated team';
    END IF;

    SELECT p.id_penalty, p.penalty_type, p.reason, p.penalty_value, p.penalty_applies_to,
           pr.id_result, r.id_race, rac.event_name
    FROM penalties p
    JOIN penalties_results pr ON pr.id_penalty = p.id_penalty
    JOIN results r ON r.id_result = pr.id_result
    JOIN races rac ON rac.id_race = r.id_race
    WHERE r.id_team = v_team_id;
END //

-- 7.6 Ver vehículos de mi equipo (team manager puede ver, pero sin especificaciones técnicas completas? Lo dejamos igual que mechanical por ahora)
CREATE PROCEDURE IF NOT EXISTS sp_teammanager_my_vehicles (
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Team manager: view vehicles of own team.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_team_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User ID cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'team-manager') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: team-manager role required';
    END IF;

    SELECT team_id INTO v_team_id FROM users WHERE id_user = p_user_id;
    IF v_team_id IS NULL THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'User has no associated team';
    END IF;

    SELECT DISTINCT v.id_vehicle, v.model, v.specifications_url
    FROM vehicles v
    JOIN inscriptions i ON i.id_vehicle = v.id_vehicle
    WHERE i.id_team = v_team_id;
END //

-- ============================================================
-- 8. PILOT (filtrado por su pilot_id)
-- ============================================================

-- 8.1 Ver mis propias inscripciones
CREATE PROCEDURE IF NOT EXISTS sp_pilot_my_inscriptions (
    IN p_pilot_id INT,
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Pilot: view own inscriptions.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_pilot_id, p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Parameters cannot be null';
    END IF;

    -- Verificar que el usuario tiene rol pilot (opcional, también se podría comprobar que el usuario está asociado a ese piloto)
    IF NOT fn_UserHasRole(p_user_id, 'pilot') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: pilot role required';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pilots WHERE id_pilot = p_pilot_id) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Pilot ID does not exist';
    END IF;

    SELECT 
        pi.id_race, r.event_name, pi.id_vehicle, v.model, i.id_team, t.team_name
    FROM pilots_inscriptions pi
    JOIN races r ON r.id_race = pi.id_race
    JOIN inscriptions i ON i.id_vehicle = pi.id_vehicle AND i.id_race = pi.id_race AND i.id_team = pi.id_team
    JOIN vehicles v ON v.id_vehicle = pi.id_vehicle
    JOIN teams t ON t.id_team = pi.id_team
    WHERE pi.id_pilot = p_pilot_id
    ORDER BY r.event_date;
END //

-- 8.2 Ver mis resultados personales
CREATE PROCEDURE IF NOT EXISTS sp_pilot_my_results (
    IN p_pilot_id INT,
    IN p_user_id INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Pilot: view own results.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_pilot_id, p_user_id)) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Parameters cannot be null';
    END IF;

    IF NOT fn_UserHasRole(p_user_id, 'pilot') THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Insufficient privileges: pilot role required';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pilots WHERE id_pilot = p_pilot_id) THEN
        SIGNAL SQLSTATE '45099' SET MESSAGE_TEXT = 'Pilot ID does not exist';
    END IF;

    SELECT 
        r.id_race, rac.event_name, r.position, r.final_time, r.penalty_time,
        (r.base_points_pilot - r.penalty_points_pilot) AS 'PilotPoints'
    FROM results r
    JOIN inscriptions i ON i.id_vehicle = r.id_vehicle AND i.id_race = r.id_race AND i.id_team = r.id_team
    JOIN pilots_inscriptions pi ON pi.id_vehicle = i.id_vehicle AND pi.id_race = i.id_race AND pi.id_team = i.id_team
    JOIN races rac ON rac.id_race = r.id_race
    WHERE pi.id_pilot = p_pilot_id
    ORDER BY rac.event_date;
END //

-- ============================================================
-- 9. READONLY PUBLIC (ya implementado en archivo aparte)
-- ============================================================
-- NOTA: Los procedimientos para readonly-public no requieren p_user_id
-- y se entregan en un archivo separado (public_queries.sql)

DELIMITER ;