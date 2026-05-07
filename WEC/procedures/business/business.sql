-- Active: 1763026326945@@127.0.0.1@3306@wec
USE wec;
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS sp_AddTeamPenalty ( IN p_penalty_type VARCHAR(20), IN p_penalty_value DECIMAL(7,2), IN p_vehicle_id INT, IN p_team_id INT, IN p_race_id INT )
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Applies a penalty (POINTS, TIME, DNF) to a team result. Updates the result record for the given vehicle, team and race. Called by sp_ProcessResultPenalty.'
BEGIN

    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;

        IF NOT v_error_message = '' THEN
            SIGNAL SQLSTATE '45034' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
            SIGNAL SQLSTATE '45034';
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_penalty_type,p_penalty_Value,p_vehicle_id,p_team_id,p_race_id)) THEN
        SET v_error_message = 'Error validating sp_AddTeamPenalty parameters, there are empty or null parameters';
        SIGNAL SQLSTATE '45034';
    END IF;

    IF NOT fn_CheckPenaltyTypeCorrect(p_penalty_type) THEN
        SET v_error_message = 'Error validating sp_AddTeamPenalty parameters, p_penalty_type has not the correct attribute';
        SIGNAL SQLSTATE '45034';
    END IF;

    IF NOT fn_IdRegisterExistsFromVehicles(p_vehicle_id) THEN
        SET v_error_message = 'Error validating sp_AddTeamPenalty parameters, p_vehicle_id is not registered at vehicles table';
        SIGNAL SQLSTATE '45034';
    END IF;

    IF NOT fn_IdRegisterExistsFromTeams(p_team_id) THEN
        SET v_error_message = 'Error validating sp_AddTeamPenalty parameters, p_team_id is not registered at teams table';
        SIGNAL SQLSTATE '45034';
    END IF;

    IF NOT fn_IdRegisteredFromRaces(p_race_id) THEN
        SET v_error_message = "Error validating sp_AddTeamPenalty parameters, p_race_id is not registered at races table";
        SIGNAL SQLSTATE '45034';
    END IF;

    START TRANSACTION;

    IF (p_penalty_type = 'POINTS') THEN
        UPDATE results res
        SET 
            res.penalty_points_team = GREATEST(0, res.penalty_points_team - FLOOR(p_penalty_value)),
            res.penalty_points_pilot = GREATEST(0, res.penalty_points_pilot - FLOOR(p_penalty_value))
        WHERE res.id_vehicle = p_vehicle_id
            AND res.id_team = p_team_id
            AND res.id_race = p_race_id;
        
        SET v_affected_rows = ROW_COUNT();

    ELSEIF (p_penalty_type = 'TIME') THEN
        UPDATE results res
        SET res.penalty_time = ADDTIME(res.penalty_time, SEC_TO_TIME(p_penalty_value))
        WHERE res.id_vehicle = p_vehicle_id
            AND res.id_team = p_team_id
            AND res.id_race = p_race_id;
        
        SET v_affected_rows = ROW_COUNT();
        
    ELSEIF (p_penalty_type = 'DNF' OR p_penalty_type = 'DSQ') THEN
        UPDATE results res
        SET 
            res.penalty_time = '838:59:59',
            res.penalty_points_team = 0,
            res.penalty_points_pilot = 0
        WHERE res.id_vehicle = p_vehicle_id
            AND res.id_team = p_team_id
            AND res.id_race = p_race_id;

        SET v_affected_rows = ROW_COUNT();

    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid penalty_type';
    END IF;

    IF NOT v_affected_rows > 0 THEN 
        SET v_error_message = 'Error executing sp_AddTeamPenalty, there was not affected rows at the transaction';
        SIGNAL SQLSTATE '45034';
    END IF;

    COMMIT;

END //

CREATE PROCEDURE IF NOT EXISTS sp_AddPilotPenalty ( IN p_penalty_type VARCHAR(20), IN p_penalty_value DECIMAL(7,2), IN p_result_id INT )
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Applies a penalty (POINTS, TIME, DSQ, DNF) to a pilot result. Updates the result record for the given result id. Called by sp_ProcessResultPenalty.'
BEGIN

    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;

        IF NOT v_error_message = '' THEN
            SIGNAL SQLSTATE '45035' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
            SIGNAL SQLSTATE '45035';
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_penalty_type, p_penalty_value, p_result_id)) THEN
        SET v_error_message = 'Error validating sp_AddPilotPenalty parameters, there are empty or null parameters';
        SIGNAL SQLSTATE '45035';
    END IF;

    IF NOT fn_CheckPenaltyTypeCorrect(p_penalty_type) THEN
        SET v_error_message = 'Error validating sp_AddPilotPenalty parameters, p_penalty_type has not the correct attribute';
        SIGNAL SQLSTATE '45035';
    END IF;

    IF NOT fn_IdRegisteredFromResults(p_result_id) THEN
        SET v_error_message = 'Error validating sp_AddPilotPenalty parameters, p_result_id is not registered at results table';
    END IF;

    START TRANSACTION;

    IF (p_penalty_type = 'POINTS') THEN
        UPDATE results res
        SET res.penalty_points_pilot = GREATEST(0, res.penalty_points_pilot - FLOOR(p_penalty_value))
        WHERE res.id_result = p_result_id;

        SET v_affected_rows = ROW_COUNT();

    ELSEIF (p_penalty_type = 'TIME') THEN
        UPDATE results res
        SET res.penalty_time = ADDTIME(res.penalty_time, SEC_TO_TIME(p_penalty_value))
        WHERE res.id_result = p_result_id;

        SET v_affected_rows = ROW_COUNT();

    ELSEIF (p_penalty_type = 'DNF' OR p_penalty_type = 'DSQ') THEN
        UPDATE results res
        SET 
            res.penalty_time = '838:59:59',
            res.penalty_points_pilot = 0
        WHERE res.id_result = p_result_id;

        SET v_affected_rows = ROW_COUNT();

    ELSE
        SIGNAL SQLSTATE '45035' SET MESSAGE_TEXT = 'Invalid penalty_type';
    END IF;

    IF NOT v_affected_rows > 0 THEN
        SET v_error_message = 'Error executing sp_AddPilotPenalty, there was not affected rows at the transaction';
        SIGNAL SQLSTATE '45035';
    END IF;

    COMMIT;

END //

CREATE PROCEDURE IF NOT EXISTS sp_GetPenaltyBasicInfo ( IN p_id_penalty INT, OUT p_penalty_type VARCHAR(20), OUT p_penalty_applies VARCHAR(20), OUT p_penalty_value DECIMAL(7,2) )
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Retrieves type, applies_to and value of a penalty by id. Outputs results into OUT parameters. Called by sp_ProcessResultPenalty.'
BEGIN

    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;

        IF NOT v_error_message = '' THEN
            SIGNAL SQLSTATE '45036' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
            SIGNAL SQLSTATE '45036';
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_penalty)) THEN
        SET v_error_message = 'Error validating sp_GetPenaltyBasicInfo parameters, there are empty or null parameters';
        SIGNAL SQLSTATE '45036';
    END IF;

    IF NOT fn_IdRegisteredFromPenalties(p_id_penalty) THEN
        SET v_error_message = 'Error validating sp_GetPenaltyBasicInfo parameters, p_id_penalty is not registered at penalties table';
        SIGNAL SQLSTATE '45036';
    END IF;

    SELECT
        pen.penalty_type,
        pen.penalty_applies_to,
        pen.penalty_value
    INTO
        p_penalty_type,
        p_penalty_applies,
        p_penalty_value
    FROM penalties pen
    WHERE pen.id_penalty = p_id_penalty;

END //

CREATE PROCEDURE IF NOT EXISTS sp_GetResultsForeignInfo ( IN p_result_id INT, OUT p_vehicle_id INT, OUT p_team_id INT, OUT p_race_id INT )
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Retrieves the foreign key ids (vehicle, team, race) of a result record by id. Outputs results into OUT parameters. Called by sp_ProcessResultPenalty.'
BEGIN

    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;

        IF NOT v_error_message = '' THEN
            SIGNAL SQLSTATE '45037' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
            SIGNAL SQLSTATE '45037';
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_result_id)) THEN
        SET v_error_message = 'Error validating sp_GetResultsBasicInfo parameters, there are empty or null parameters';
        SIGNAL SQLSTATE '45037';
    END IF;

    IF NOT fn_IdRegisteredFromResults(p_result_id) THEN
        SET v_error_message = 'Error validating sp_GetResultsBasicInfo parameters, p_result_id is not registered at results table';
        SIGNAL SQLSTATE '45037';
    END IF;

    SELECT
        res.id_vehicle,
        res.id_team,
        res.id_race
    INTO
        p_vehicle_id,
        p_team_id,
        p_race_id
    FROM results res
    WHERE res.id_result = p_result_id;

END //

CREATE PROCEDURE IF NOT EXISTS sp_ProcessResultPenalty ( IN p_id_penalty INT, IN p_id_result INT )
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Orchestrates penalty application to a result. Retrieves penalty and result data, then delegates to sp_AddPilotPenalty or sp_AddTeamPenalty based on penalty target.'
BEGIN

    DECLARE v_penalty_type VARCHAR(20) DEFAULT 'POINTS';
    DECLARE v_penalty_applies VARCHAR(20) DEFAULT 'PILOT';
    DECLARE v_penalty_value DECIMAL(7,2) DEFAULT 0;
    DECLARE v_vehicle_id INT DEFAULT NULL;
    DECLARE v_team_id INT DEFAULT NULL;
    DECLARE v_race_id INT DEFAULT NULL;
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        IF NOT v_error_message = '' THEN
            SIGNAL SQLSTATE '45038' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
            SIGNAL SQLSTATE '45038';
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_penalty, p_id_result)) THEN
        SET v_error_message = 'Error validating sp_ProcessResultPenalty parameters, there are empty or null parameters';
        SIGNAL SQLSTATE '45038';
    END IF;

    IF NOT fn_IdRegisteredFromPenalties(p_id_penalty) THEN
        SET v_error_message = 'Error validating sp_GetPenaltyBasicInfo parameters, p_id_penalty is not registered at penalties table';
        SIGNAL SQLSTATE '45038';
    END IF;

    IF NOT fn_IdRegisteredFromResults(p_id_result) THEN
        SET v_error_message = 'Error validating sp_GetResultsBasicInfo parameters, p_result_id is not registered at results table';
        SIGNAL SQLSTATE '45038';
    END IF;

    CALL sp_GetPenaltyBasicInfo(p_id_penalty, v_penalty_type, v_penalty_applies, v_penalty_value);
    CALL sp_GetResultsForeignInfo(p_id_result, v_vehicle_id, v_team_id, v_race_id);

    IF (v_penalty_applies = 'PILOT') THEN
        CALL sp_AddPilotPenalty(v_penalty_type, v_penalty_value, p_id_result);
    ELSE
        CALL sp_AddTeamPenalty(v_penalty_type, v_penalty_value, v_vehicle_id, v_team_id, v_race_id);
    END IF;

END //

CREATE PROCEDURE IF NOT EXISTS sp_AddResultPoints(IN p_race_id INT, IN p_result_id INT, IN p_result_points TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Updates the points of a result record for a given race and result id. Called by sp_UpdateLeaderPoints.'
BEGIN

    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT default 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        IF NOT v_error_message = '' THEN
            SIGNAL SQLSTATE '45039' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
            SIGNAL SQLSTATE '45039';
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_race_id, p_result_id, p_result_points)) THEN
        SET v_error_message = 'Error validating sp_AddResultPoints parameters, there are empty or null parameters';
        SIGNAL SQLSTATE '45039';
    END IF;

    IF NOT fn_IdRegisteredFromRaces(p_race_id) THEN
        SET v_error_message = 'Error validating sp_AddResultsPoints parameters, p_race_id is not registered at races table';
        SIGNAL SQLSTATE '45039';
    END IF;

    IF NOT fn_IdRegisteredFromResults(p_result_id) THEN
        SET v_error_message = 'Error validating sp_AddResultsPoints parameters, p_result_id is not registered at results table';
        SIGNAL SQLSTATE '45039';
    END IF;

    IF fn_CheckNegativeValues(p_result_points) THEN
        SET v_error_message = 'Error validating sp_AddResultsPoints parameters, p_result_points should not be a negative value';
        SIGNAL SQLSTATE '45039';
    END IF;

    UPDATE results res SET
        res.base_points_team = p_result_points,
        res.base_points_pilot = p_result_points
    WHERE 
        res.id_race = p_race_id AND
        res.id_result = p_result_id;
    
    SET v_affected_rows = ROW_COUNT();

    IF NOT v_affected_rows > 0 THEN
        SET v_error_message = 'Error executing sp_AddResultsPoints, there was no affected rows at the transaction';
        SIGNAL SQLSTATE '45001';
    END IF;

END //

CREATE PROCEDURE IF NOT EXISTS sp_AddResultPointsTx(
    IN p_race_id INT,
    IN p_result_id INT,
    IN p_result_points TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Transactional wrapper for sp_AddResultPoints. Use this when calling from application code directly.'
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    CALL sp_AddResultPoints(p_race_id, p_result_id, p_result_points);
    COMMIT;

END //

CREATE PROCEDURE IF NOT EXISTS sp_UpdateLeaderPoints (IN p_new_id_race INT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Iterates over the top 10 results of a race and assigns leaderboard points to each. Uses fn_GetPositionsPointsMultiplier and fn_GetLeaderboardPointsCalc to calculate points. Calls sp_AddResultPoints to persist each result.'
BEGIN

    DECLARE v_done TINYINT(1) DEFAULT 0;
    DECLARE v_cursor_open TINYINT(1) DEFAULT 0;
    DECLARE v_cur_id_result INT DEFAULT 0;
    DECLARE v_position TINYINT DEFAULT 1;
    DECLARE v_position_points TINYINT DEFAULT 25;
    DECLARE v_position_points_mult DECIMAL(3,1) DEFAULT 1;
    DECLARE v_points_calc_result TINYINT DEFAULT 0;
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE cur_times CURSOR FOR
        SELECT 
            res.id_result
        FROM results res
        WHERE res.id_race = p_new_id_race
        ORDER BY ADDTIME(res.final_time, res.penalty_time) ASC;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        IF v_cursor_open THEN
            CLOSE cur_times;
        END IF;

        IF NOT v_error_message = '' THEN
            SIGNAL SQLSTATE '45042' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
            SIGNAL SQLSTATE '45042';
        END IF;
    END;

    IF NOT fn_IdRegisteredFromRaces(p_new_id_race) THEN
        SET v_error_message = 'Error validating sp_UpdateLeaderPoints parameters, p_new_id_race is not registered at races table';
        SIGNAL SQLSTATE '45042';
    END IF;

    SELECT fn_GetPositionsPointsMultiplier(p_new_id_race) INTO v_position_points_mult;
    
    OPEN cur_times;
    SET v_cursor_open = 1;
    WHILE (v_done != 1 AND v_position <= 10) DO
        FETCH cur_times INTO v_cur_id_result;
        SELECT fn_GetLeaderboardPointsCalc(v_position, v_position_points, v_position_points_mult) INTO v_points_calc_result;

        IF(v_done != 1) THEN
            CALL sp_AddResultPoints(p_new_id_race, v_cur_id_result, v_points_calc_result);
        END IF;

        SET v_position = v_position + 1;
    END WHILE;
    CLOSE cur_times;

END //

CREATE PROCEDURE IF NOT EXISTS sp_UpdateLeaderPointsTx(IN p_new_id_race INT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Transactional wrapper for sp_UpdateLeaderPoints. Use this when calling from application code directly.'
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    CALL sp_UpdateLeaderPoints(p_new_id_race);
    COMMIT;

END //

DELIMITER ;