-- Active: 1763026326945@@127.0.0.1@3306@wec
USE WEC;
DELIMITER //

CREATE FUNCTION fn_CheckAfectedRowsCount ( row_count INT )
RETURNS TINYINT(1)
COMMENT 'Check if there are any row afected by an a DDL or DML sentence'
NOT DETERMINISTIC
NO SQL
BEGIN
    RETURN (row_count != 0);
END //

CREATE FUNCTION fn_CheckNegativeValues (value INT)
RETURNS TINYINT(1) DETERMINISTIC
COMMENT 'Check if the parameter given is negative'
BEGIN
    IF value < 0 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END //

CREATE FUNCTION fn_UnderMaxLimit ( numToCheck INT, maxNumber INT )
RETURNS TINYINT(1)
COMMENT 'Check if a value is under his max limit'
DETERMINISTIC
NO SQL
BEGIN
    RETURN (numToCheck < maxNumber);
END //

CREATE FUNCTION fn_GetTeamMechanicsNumber ( search_team_id INT )
RETURNS TINYINT
COMMENT 'Returns the number of mechanics for boxes of a team'
DETERMINISTIC
READS SQL DATA
BEGIN

    DECLARE mechanics_number TINYINT DEFAULT 0;

    SELECT
        tea.mechanics_num INTO mechanics_number
    FROM teams tea
    WHERE search_team_id = tea.id_team;

    RETURN IFNULL(mechanics_number, 0);

END //

CREATE FUNCTION fn_CountInscriptedPilots ( search_vehicle_id INT, search_team_id INT, search_race_id INT )
RETURNS TINYINT
COMMENT 'Count the number of pilots inscripted in a especific race, team and vehicle'
DETERMINISTIC
READS SQL DATA
BEGIN

    DECLARE pilots_count_number TINYINT DEFAULT 0;

    SELECT
        COUNT(p.id_pilot) INTO pilots_count_number
    FROM pilots_inscriptions pilins
    LEFT JOIN pilots p ON p.id_pilot = pilins.id_pilot
    WHERE pilins.id_vehicle = search_vehicle_id AND pilins.id_team = search_team_id AND pilins.id_race = search_race_id;

    RETURN IFNULL(pilots_count_number, 0);

END //

CREATE FUNCTION fn_GetPositionsPointsMultiplier (race_id INT)
RETURNS DECIMAL(3,1)
COMMENT 'Get the multiplier number of the leader board positions using race id'
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE race_time TIME DEFAULT '00:00:00';
    DECLARE points_mult DECIMAL(3,1) DEFAULT 1;

    SELECT
        rac.event_duration INTO race_time
    FROM races rac
    WHERE rac.id_race = race_id;

    IF(race_time <= '06:00:00') THEN
        SET points_mult = 1;
    ELSEIF(race_time >= '08:00:00' AND race_time <= '10:00:00') THEN
        SET points_mult = 1.5;
    ELSEIF(race_time >= '24:00:00') THEN
        SET points_mult = 2;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Race time is not correct, the points calculation cant proceed';
    END IF;

    RETURN points_mult;
END //

CREATE FUNCTION fn_GetLeaderboardPointsCalc (position INT, base_points INT, points_mult DECIMAL(3,2))
RETURNS INT
DETERMINISTIC
NO SQL
BEGIN
    DECLARE calc_result INT DEFAULT 0;

    IF(position = 1) THEN
        SET calc_result = base_points * points_mult;
    ELSEIF(position = 2) THEN
        SET base_points = base_points - 7;
        SET calc_result = base_points * points_mult;
    ELSEIF(position >= 3 AND position <= 4) THEN
        SET base_points = base_points - 3;
        SET calc_result = base_points * points_mult;
    ELSEIF(position >= 5 AND position <= 9) THEN
        SET base_points = base_points - 2;
        SET calc_result = base_points * points_mult;
    ELSEIF(position = 10) THEN
        SET base_points = base_points - 1;
        SET calc_result = base_points * points_mult;
    ELSE
        SET calc_result = 0;
    END IF;

    RETURN calc_result;
END //

CREATE FUNCTION fn_CircuitCorrectLength (p_circuit_length DECIMAL(5,2))
RETURNS TINYINT(1) NOT DETERMINISTIC
COMMENT 'Validate that the circuit length is reasonable'
BEGIN
    IF p_circuit_length > 3.5 AND p_circuit_length < 15000 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END //

CREATE FUNCTION fn_ValidateCircuitDirection (p_circuit_direction VARCHAR(50))
RETURNS TINYINT(1) DETERMINISTIC
COMMENT 'Validate that the circuit direction has 1 of the posible circuit directions'
BEGIN
    IF p_circuit_direction IN ('CLOCKWISE','COUNTERCLOCKWISE') THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END //

CREATE FUNCTION fn_GetAnyCircuitRegistryByName (p_circuit_name VARCHAR(50))
RETURNS TINYINT(1) DETERMINISTIC
BEGIN
    DECLARE p_select_result INT DEFAULT 0;

    SELECT 1 INTO p_select_result
    FROM circuits
    WHERE circuit_name = p_circuit_name;

    RETURN p_select_result;
END //

CREATE FUNCTION fn_GetAnyCircuitRegistryById (p_circuit_id INT)
RETURNS TINYINT(1) DETERMINISTIC
BEGIN
    DECLARE p_select_result INT DEFAULT 0;

    SELECT 1 INTO p_select_result
    FROM circuits
    WHERE id_circuit = p_circuit_id;

    RETURN p_select_result;
END //

CREATE FUNCTION fn_CheckNullEmptyArray (arr JSON)
RETURNS TINYINT(1) DETERMINISTIC
BEGIN

    DECLARE i INT DEFAULT 0;
    DECLARE total INT DEFAULT 0;
    DECLARE sentence VARCHAR(255) DEFAULT '';

    SET total = JSON_LENGTH(arr);
    WHILE i < total DO

        SET sentence = JSON_UNQUOTE(JSON_EXTRACT(arr, CONCAT('$[', i, ']')));
        IF sentence = "" OR sentence IS NULL THEN
            RETURN 0;
        END IF;

        SET i = i + 1;

    END WHILE;

    RETURN 1;

END //

CREATE FUNCTION fn_CheckPenaltyTypeCorrect (p_penalty_type VARCHAR(20))
RETURNS TINYINT(1) DETERMINISTIC
BEGIN
    IF p_penalty_type = 'POINTS' THEN RETURN 1; END IF;
    IF p_penalty_type = 'TIME' THEN RETURN 1; END IF;
    IF p_penalty_type = 'DSQ' THEN RETURN 1; END IF;
    IF p_penalty_type = 'DNF' THEN RETURN 1; END IF;

    RETURN 0;
END //

CREATE FUNCTION fn_IdRegisterExistsFromVehicles (p_id INT)
RETURNS TINYINT(1) DETERMINISTIC
BEGIN
    DECLARE v_select_result TINYINT(1) DEFAULT 0;

    SELECT 1 INTO v_select_result
    FROM vehicles
    WHERE id_vehicle = p_id
    LIMIT 1;

    RETURN v_select_result;
END //

CREATE FUNCTION fn_IdRegisterExistsFromTeams(p_id INT)
RETURNS TINYINT(1) DETERMINISTIC
BEGIN
    DECLARE v_select_result TINYINT(1) DEFAULT 0;

    SELECT 1 INTO v_select_result
    FROM teams
    WHERE id_team = p_id
    LIMIT 1;

    RETURN v_select_result;
END //

CREATE FUNCTION fn_IdRegisteredFromRaces(p_id INT)
RETURNS TINYINT(1) DETERMINISTIC
BEGIN
    DECLARE v_select_result TINYINT(1) DEFAULT 0;

    SELECT 1 INTO v_select_result
    FROM races
    WHERE id_race = p_id;

    RETURN v_select_result;
END //

CREATE FUNCTION fn_IdRegisteredFromResults(p_id INT)
RETURNS TINYINT(1) DETERMINISTIC
BEGIN
    DECLARE v_select_result TINYINT(1) DEFAULT 0;

    SELECT 1 INTO v_select_result
    FROM results
    WHERE id_result = p_id;

    RETURN v_select_result;
END //

CREATE FUNCTION fn_IdRegisteredFromPenalties(p_id INT)
RETURNS TINYINT(1) DETERMINISTIC
BEGIN
    DECLARE v_select_result TINYINT(1) DEFAULT 0;

    SELECT 1 INTO v_select_result
    FROM penalties
    WHERE id_penalty = p_id;

    RETURN v_select_result;
END //

CREATE FUNCTION fn_IdRegisteredFromInscriptions(p_id_vehicle INT, p_id_race INT, p_id_team INT)
RETURNS TINYINT(1) DETERMINISTIC
BEGIN
    DECLARE v_select_result TINYINT(1) DEFAULT 0;

    SELECT 1 INTO v_select_result
    FROM inscriptions
    WHERE id_vehicle = p_id_vehicle AND id_race = p_id_race AND id_team = p_id_team;

    RETURN v_select_result;
END //

CREATE FUNCTION fn_CheckForExtraDependences(p_table_name VARCHAR(64), p_record_id INT)
RETURNS TINYINT(1) DETERMINISTIC
READS SQL DATA
BEGIN

    DECLARE v_dep_table VARCHAR(64) DEFAULT '';
    DECLARE v_dep_column VARCHAR(64) DEFAULT '';
    DECLARE v_count INT DEFAULT 0;
    DECLARE v_total INT DEFAULT 0;
    DECLARE v_done TINYINT(1) DEFAULT 0;
    DECLARE v_sql TEXT;

    DECLARE cur_deps CURSOR FOR
        SELECT kcu.table_name, kcu.column_name
        FROM information_schema.key_column_usage kcu
        WHERE kcu.referenced_table_name = p_table_name
            AND kcu.referenced_table_schema = DATABASE();
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    OPEN cur_deps;

    WHILE v_done != 1 DO

        FETCH cur_deps INTO v_dep_table, v_dep_column;

        SET v_sql = CONCAT(
            'SELECT COUNT(*) INTO @dep_count FROM `',v_dep_table, '` WHERE `', v_dep_column, '` = ', p_record_id
        );

        PREPARE stmt FROM v_sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET v_total = v_total + @dep_count;

    END WHILE;

    CLOSE cur_deps;

    IF NOT v_total = 0 THEN
        RETURN 1;
    END IF;
    
    RETURN 0;

END //

CREATE FUNCTION fn_CheckInscriptionData(p_vehicles_quantity TINYINT, p_registration_date TIMESTAMP)
RETURNS TINYINT(1) DETERMINISTIC
BEGIN
    IF NOT p_vehicles_quantity = 2 THEN
        RETURN 0;
    END IF;

    IF NOT DATE(p_registration_date) >= DATE(NOW() - INTERVAL 1 DAY) AND NOT DATE(p_registration_date) <= DATE(NOW()) THEN
        RETURN 0;
    END IF;

    RETURN 1;
END //

CREATE FUNCTION fn_UserHasRole(p_user_id INT, p_role_name VARCHAR(100))
RETURNS TINYINT(1)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count
    FROM user_userrole uu
    JOIN user_roles ur ON ur.id_user_roles = uu.id_user_role
    WHERE uu.id_user = p_user_id AND ur.role_name = p_role_name;
    RETURN IF(v_count > 0, 1, 0);
END //

DELIMITER ;