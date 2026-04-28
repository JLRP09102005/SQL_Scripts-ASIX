DELIMITER //

CREATE PROCEDURE sp_AddTeamPenalty ( IN p_penalty_type VARCHAR(20), IN p_penalty_value DECIMAL(7,2), IN p_vehicle_id INT, IN p_team_id INT, IN p_race_id INT )
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
        SET v_error_me ssage = 'Error validating sp_AddTeamPenalty parameters, p_vehicle_id is not registered at vehicles table';
        SIGNAL SQLSTATE '45034';
    END IF;

    IF NOT fn_IdRegisterExistsFromTeams(p_team_id) THEN
        SET v_error_message = 'Error validating sp_AddTeamPenalty parameters, p_team_id is not registered at teams table';
        SIGNAL SQLSTATE '45034';
    END IF;

    IF NOT fn_IdRegisteredFromRaces(p_reace_id) THEN
        SET v_error_message = "Error validating sp_AddTeamPenalty parameters, p_race_id is not registered at races table";
        SIGNAL SQLSTATE '45034'
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
        
        SET affected_rows = ROW_COUNT();

    ELSEIF (p_penalty_type = 'TIME') THEN
        UPDATE results res
        SET res.penalty_time = ADDTIME(res.penalty_time, SEC_TO_TIME(p_penalty_value))
        WHERE res.id_vehicle = p_vehicle_id
            AND res.id_team = p_team_id
            AND res.id_race = p_race_id;
        
        SET affected_rows = ROW_COUNT();
        
    ELSEIF (p_penalty_type = 'DNF' || p_penalty_type = 'DSQ') THEN
        UPDATE results res
        SET 
            res.penalty_time = SEC_TO_TIME(0),
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
        SET v_error_message = 'Error executing sp_AddTeamPenalty, there was not affected rows at the transaction'
        SIGNAL SQLSTATE '45034'
    END IF;

    COMMIT;

END //

CREATE PROCEDURE sp_AddPilotPenalty ( IN p_penalty_type VARCHAR(20), IN p_penalty_value DECIMAL(7,2), IN p_result_id INT )
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
        SIGNAL SQLSTATE '45035'
    END IF;

    IF NOT fn_CheckPenaltyTypeCorrect(p_penalty_type) THEN
        SET v_error_message = 'Error validating sp_AddPilotPenalty parameters, p_penalty_type has not the correct attribute';
        SIGNAL SQLSTATE '45035';
    END IF;

    IF NOT fn_IdRegisteredFromResults(p_result_id) THEN
        v_error_message = 'Error validating sp_AddPilotPenalty parameters, p_result_id is not registered at results table'
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

    ELSEIF (penalp_penalty_typety_type = 'DNF' || p_penalty_type = 'DSQ') THEN
        UPDATE results res
        SET 
            res.penalty_time = SEC_TO_TIME(0),
            res.penalty_points_pilot = 0
        WHERE res.id_result = p_result_id;

        SET v_affected_rows = ROW_COUNT();

    ELSE
        SIGNAL SQLSTATE '45035' SET MESSAGE_TEXT = 'Invalid penalty_type';
    END IF;

    IF NOT v_affected_rows > 0 THEN
        SET v_error_message = 'Error executing sp_AddPilotPenalty, there was not affected rows at the transaction'
        SIGNAL SQLSTATE '45035'
    END IF;

    COMMIT;

END //

CREATE PROCEDURE sp_GetPenaltyBasicInfo ( IN p_id_penalty INT, OUT p_penalty_type VARCHAR(20), OUT p_penalty_applies VARCHAR(20), OUT p_penalty_value DECIMAL(7,2) )
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
        pen.penalty_type INTO p_penalty_type,
        pen.penalty_applies_to INTO p_penalty_applies,
        pen.penalty_value INTO p_penalty_value
    FROM penalties pen
    WHERE pen.id_penalty = p_id_penalty;

END //

CREATE PROCEDURE sp_GetResultsForeignInfo ( IN p_result_id INT, OUT p_vehicle_id INT, OUT p_team_id INT, OUT p_race_id INT )
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
        res.id_vehicle INTO p_vehicle_id,
        res.id_team INTO p_team_id,
        res.id_race INTO p_race_id
    FROM results res
    WHERE res.id_result = p_result_id;

END //

CREATE PROCEDURE sp_ProcessResultPenalty ( IN p_id_penalty INT, IN p_id_result INT )
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

    DELCARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        IF NOT v_error_message = '' THEN
            SIGNAL SQLSTATE '45038' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
            SIGNAL SQLSTATE '45038'
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_penalty, p_id_result)) THEN
        SET v_error_message = 'Error validating sp_ProcessResultPenalty parameters, there are empty or null parameters';
        SIGNAL SQLSTATE '45038';
    END IF;

    IF NOT fn_IdRegisteredFromPenalties(p_id_penalty) THEN
        SET v_error_message = 'Error validating sp_GetPenaltyBasicInfo parameters, p_id_penalty is not registered at penalties table';
        SIGNAL SQLSTATE '45038';
    END IF

    IF NOT fn_IdRegisteredFromResults(p_id_result) THEN
        SET v_error_message = 'Error validating sp_GetResultsBasicInfo parameters, p_result_id is not registered at results table';
        SIGNAL SQLSTATE '45038';
    END IF;

    CALL sp_GetPenaltyBasicInfo(p_id_penalty, v_penalty_type, v_penalty_applies, v_penalty_value);
    CALL sp_GetResultsForeignInfo(p_id_result, v_vehicle_id, v_team_id, v_race_id);

    IF (v_penalty_applies = 'PILOT') THEN
        CALL AddPilotPenalty(v_penalty_type, v_penalty_value, p_id_result);
    ELSE
        CALL sp_AddTeamPenalty(v_penalty_type, v_penalty_value, v_vehicle_id, v_team_id, v_race_id);
    END IF;

END //

CREATE PROCEDURE sp_AddResultPoints(IN p_race_id INT, IN p_result_id INT, IN p_result_points TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Updates the points of a result record for a given race and result id. Called by sp_UpdateLeaderPoints.'
BEGIN

    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT default 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;

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

    IF CheckNegativeValues(p_result_points) THEN
        SET v_error_message = 'Error validating sp_AddResultsPoints parameters, p_result_points should not be a negative value';
        SIGNAL SQLSTATE '45039'
    END IF;

    START TRANSACTION;
    UPDATE results res SET
        res.base_points_team = p_result_points,
        res.base_points_pilot = p_result_points,
        res.penalty_points_team = p_result_points,
        res.penalty_points_pilot = p_result_points
    WHERE 
        res.id_race = p_race_id AND
        res.id_result = p_result_id;
    
    SET v_affected_rows = ROW_COUNT();

    IF NOT v_affected_rows > 0 THEN
        SET v_error_message = 'Error executing sp_AddResultsPoints, there was no affected rows at the transaction';
        SIGNAL SQLSTATE '45001';
    END IF;

    COMMIT;

END //

CREATE PROCEDURE sp_UpdateLeaderPoints (IN p_new_id_race INT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Iterates over the top 10 results of a race and assigns leaderboard points to each. Uses fn_GetPositionsPointsMultiplier and fn_GetLeaderboardPointsCalc to calculate points. Calls sp_AddResultPoints to persist each result.'
BEGIN

    DECLARE v_done TINYINT(1) DEFAULT 0;
    DECLARE v_cur_id_result INT DEFAULT 0;
    DECLARE v_position TINYINT DEFAULT 1;
    DECLARE v_position_points TINYINT DEFAULT 25;
    DECLARE v_position_points_mult DECIMAL(3,1) DEFAULT 1;
    DECLARE v_points_calc_result TINYINT DEFAULT 0;
    DECLARE v_new_id_race INT DEFAULT NULL;
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    SET v_new_id_race = p_new_id_race;

    DECLARE cur_times CURSOR FOR
        SELECT 
            res.id_result
        FROM results res
        WHERE res.id_race = v_new_id_race
        ORDER BY res.penalty_time ASC;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        CLOSE cur_times;
        ROLLBACK;

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

    START TRANSACTION;

    SELECT GetPositionsPointsMultiplier(v_new_id_race) INTO v_position_points_mult;
    
    OPEN cur_times;
    WHILE (v_done != 1 AND v_position <= 10) DO
        FETCH cur_times INTO v_cur_id_result;
        SELECT GetLeaderboardPointsCalc(v_position, v_position_points, v_position_points_mult) INTO v_points_calc_result;

        IF(v_done != 1) THEN
            CALL sp_AddResultPoints(v_new_id_race, v_cur_id_result, v_points_calc_result);
        END IF;

        SET v_position = v_position + 1;
    END WHILE;
    CLOSE cur_times;

    COMMIT;

END //

CREATE PROCEDURE sp_InsertCircuitData (IN p_circuit_name VARCHAR(100), IN p_country VARCHAR(50), IN p_length_km DECIMAL(3,2), IN p_direction CHAR(20), OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Inserts a new circuit record into the circuits table. Validates all input data including direction enum and length range. Returns execution state via p_spstate.'
BEGIN

    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT default 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;

        IF NOT v_error_message = '' THEN
            SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
            SIGNAL SQLSTATE '45001';
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_circuit_name, p_country, p_length_km, p_direction)) THEN
        SET v_error_message = 'Error validating sp_InsertCircuitData parameters, there are empty or null parameters';
        SIGNAL SQLSTATE '45001';
    END IF;

    IF NOT CircuitCorrectLength(p_length_km) THEN
        SET v_error_message = 'Error validating sp_InsertCircuitData parameters, the circuit length is out or under the bounds';
        SIGNAL SQLSTATE '45001';
    END IF;

    IF NOT ValidateCircuitDirection(p_direction) THEN
        SET v_error_message = 'Error validating sp_InsertCircuitData parameters, the circuit direction has not a correct value';
        SIGNAL SQLSTATE '45001';
    END IF;

    IF fn_GetAnyCircuitRegistryByName(p_circuit_name) THEN
        SET v_error_message = 'Error validating sp_InsertCircuitData parameters, already exists a circuit registry with this name';
        SIGNAL SQLSTATE '45001';
    END IF;

    START TRANSACTION;

    INSERT INTO circuits (circuit_name,country,length_km,direction)
        VALUES(p_circuit_name, p_country, p_length_km, p_direction);
    
    SET v_affected_rows = ROW_COUNT();

    IF NOT v_affected_rows > 0 THEN
        SET v_error_message = 'Error executing sp_InsertCircuitData, there was no affected rows at the transaction';
        SIGNAL SQLSTATE '45001';
    END IF;

    COMMIT;

    SET p_spstate = 1;

END //

CREATE PROCEDURE sp_UpdateCircuitData (IN p_circuit_id INT, IN p_circuit_name VARCHAR(100), IN p_country VARCHAR(50), IN p_length_km DECIMAL(3,2), IN p_direction CHAR(20), OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Updates an existing circuit record by id. Validates all input data including direction enum, length range and name uniqueness. Returns execution state via p_spstate.'
BEGIN

    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT default 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;

        IF NOT v_error_message = '' THEN
            SIGNAL SQLSTATE '45012' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
            SIGNAL SQLSTATE '45012';
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_circuit_name, p_country, p_length_km, p_direction)) THEN
        SET v_error_message = 'Error validating sp_UpdateCircuitData parameters, there are empty or null parameters';
        SIGNAL SQLSTATE '45012';
    END IF;

    IF NOT CircuitCorrectLength(p_length_km) THEN
        SET v_error_message = 'Error validating sp_UpdateCircuitData parameters, the circuit length is out or under the bounds';
        SIGNAL SQLSTATE '45012';
    END IF;

    IF NOT ValidateCircuitDirection(p_direction) THEN
        SET v_error_message = 'Error validating sp_UpdateCircuitData parameters, the circuit direction has not a correct value';
        SIGNAL SQLSTATE '45012';
    END IF;

    IF NOT fn_GetAnyCircuitRegistryByName(p_circuit_name) THEN
        SET v_error_message = 'Error validating sp_UpdateCircuitData parameters, not exists a circuit registry with this name';
        SIGNAL SQLSTATE '45012';
    END IF;

    START TRANSACTION;

    UPDATE table circuits
        SET circuit_name = p_circuit_name,
            country = p_country,
            length_km = p_length_km,
            direction = p_direction
    WHERE id_circuit = p_circuit_id;
    
    SET v_affected_rows = ROW_COUNT();

    IF NOT v_affected_rows > 0 THEN
        SET v_error_message = 'Error executing sp_UpdateCircuitData, there were no affected rows at the transaction';
        SIGNAL SQLSTATE '45012';
    END IF;

    COMMIT;

    SET p_spstate = 1;

END //

CREATE PROCEDURE sp_DeleteCircuitData (IN p_circuit_id INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Deletes an existing circuit record by id. Validates referential integrity before deletion to prevent orphaned dependent records. Returns execution state via p_spstate.'
BEGIN

    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;

        IF NOT v_error_message = '' THEN
            SIGNAL SQLSTATE '45013' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
            SIGNAL SQLSTATE '45013';
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_circuit_id)) THEN
        SET v_error_message = 'Error validating sp_DeleteCircuitData parameters, there are empty or null parameters';
        SIGNAL SQLSTATE '45013';
    END IF;

    IF NOT fn_GetAnyCircuitRegistryById(p_circuit_id) THEN
        SET v_error_message = 'Error validating sp_DeleteCircuitData parameters, not exists a circuit registry with this id';
    END IF;

    IF NOT fn_CheckForExtraDependences('circuits', p_circuit_id) THEN
        SET v_error_message = "Error validating sp_DeleteCircuitData conditions, there are some restrictions";
        SIGNAL SQLSTATE '45013';
    END IF

    START TRANSACTION;

    DELETE FROM circuits WHERE id_circuit = p_circuit_id;

    SET v_affected_rows = ROW_COUNT()
    IF NOT v_affected_rows > 0 THEN
        SET v_error_message = 'Error executing sp_DeleteCircuitData, there were no affected rows at the transaction';
        SIGNAL SQLSTATE '45013';
    END IF;

    COMMIT;

    SET p_spstate = 1;

END //

CREATE PROCEDURE sp_InsertInscriptionData (IN p_id_vehicle INT, IN p_id_race INT, IN p_id_team INT, IN p_vehicles_quantity TINYINT, IN p_registered_at TIMESTAMP, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Inserts a new inscription record into the inscriptions table. Validates all foreign keys (vehicle, race, team) and registration date before insertion. Returns execution state via p_spstate.'
BEGIN

    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;

        IF NOT v_error_message = '' THEN
            SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
            SIGNAL SQLSTATE '45002';
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_vehicle, p_id_race, p_id_team, p_vehicles_quantity, p_registered_at)) THEN
        SET v_error_message = 'Error validating sp_InsertInscriptionData parameters, there are empty or null parameters';
        SIGNAL SQLSTATE '45002';
    END IF;

    IF NOT fn_CheckInscriptionData(p_vehicles_quantity, p_registered_at) THEN
        SET v_error_message = 'Error validating sp_InsertInscriptionData parameters, incorrect inscription parameters';
        SIGNAL SQLSTATE '45002'
    END IF;

    IF NOT fn_IdRegisterExistsFromVehicles(p_id_vehicle) THEN
        SET v_error_message = 'Error validating sp_InsertInscriptionData parameters, p_id_vehicle is not registered at vehicles table';
        SIGNAL SQLSTATE '45002';
    END IF;

    IF NOT fn_IdRegisteredFromRaces(p_id_race) THEN
        SET v_error_message = 'Error validating sp_InsertInscriptionData parameters, p_id_race is not registered at races table';
        SIGNAL SQLSTATE '45002';
    END IF;

    IF NOT fn_IdRegisterExistsFromTeams(p_id_team) THEN
        SET v_error_message = 'Error validating sp_InsertInscriptionData parameters, p_id_team is not registered at team table';
        SIGNAL SQLSTATE '45002';
    END IF;

    START TRANSACTION;

    INSERT INTO inscriptions (id_vehicle, id_race, id_team, vehicles_quantity, registered_at, max_vehicles, max_pilots, max_mechanics)
        VALUES(p_id_vehicle, p_id_race, p_id_team, p_vehicles_quantity, p_registered_at, 2, 3, 4);
    
    SET v_affected_rows = ROW_COUNT();
    IF NOT v_affected_rows > 0 THEN
        SET v_error_message = 'Error executing sp_InsertInscriptionData, there were no affected rows at the transaction';
        SIGNAL SQLSTATE '45002';
    END IF;

    COMMIT;

    SET p_spstate = 1;

END //

CREATE PROCEDURE sp_UpdateInscriptionData (IN p_id_inscription INT, IN p_id_vehicle INT, IN p_id_race INT, IN p_id_team INT, IN p_vehicles_quantity TINYINT, IN p_registered_at TIMESTAMP, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Updates an existing inscription record by id. Validates all foreign keys (vehicle, race, team) and registration date before update. Returns execution state via p_spstate.'
BEGIN

    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;

        IF NOT v_error_message = '' THEN
            SIGNAL SQLSTATE '45014' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
            SIGNAL SQLSTATE '45015';
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_vehicle, p_id_race, p_id_team, p_vehicles_quantity, p_registered_at)) THEN
        SET v_error_message = 'Error validating sp_UpdateInscriptionData parameters, there are empty or null parameters';
        SIGNAL SQLSTATE '45014';
    END IF;

    IF NOT fn_IdRegisterExistsFromVehicles(p_id_vehicle) THEN
        SET v_error_message = 'Error validating sp_UpdateInscriptionData parameters, p_id_vehicle is not registered at vehicles table';
    END IF;

    IF NOT fn_IdRegisteredFromRaces(p_id_race) THEN
        SET v_error_message = 'Error validating sp_UpdateInscriptionData parameters, p_id_race is not registered at races table';
        SIGNAL SQLSTATE '45014';
    END IF;

    IF NOT fn_IdRegisterExistsFromTeams(p_id_team) THEN
        SET v_error_message = 'Error validating sp_UpdateInscriptionData parameters, p_id_team is not registered at team table';
        SIGNAL SQLSTATE '45014';
    END IF;

    IF NOT fn_CheckInscriptionData(p_vehicles_quantity, p_registered_at) THEN
        SET v_error_message = 'Error validating sp_UpdateInscriptionData parameters, incorrect inscription parameters';
        SIGNAL SQLSTATE '45014';
    END IF;

    START TRANSACTION;

    UPDATE inscriptions
        SET vehicles_quantity = p_vehicles_quantity,
            registered_at = p_registered_at,
    WHERE id_vehicle = p_id_vehicle AND id_race = p_id_race AND id_team = p_id_team;

    SET v_affected_rows = ROW_COUNT();
    IF NOT v_affected_rows > 0 THEN
        SET v_error_message = 'Error executing sp_UpdateInscriptionData, there were no affected rows at the transaction';
        SIGNAL SQLSTATE '45014';
    END IF

    COMMIT;

    SET p_spstate = 1;

END //

CREATE PROCEDURE sp_DeleteInscriptionData (IN p_id_vehicle INT, IN p_id_race INT, IN p_id_team INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Deletes an existing inscription record by id. Validates referential integrity before deletion to prevent orphaned dependent records. Returns execution state via p_spstate.'
BEGIN

    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;

        IF NOT v_error_message = '' THEN
            SIGNAL SQLSTATE '45015' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
            SIGNAL SQLSTATE '45015';
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_vehicle, p_id_race, p_id_team)) THEN
        SET v_error_message = 'Error validating sp_DeleteInscriptionData parameters, there are empty or null parameters';
        SIGNAL SQLSTATE '45015';
    END IF;

    IF NOT fn_CheckForExtraDependences('inscriptions', p_id_vehicle) THEN
        SET v_error_message = "Error validating sp_DeleteInscriptionData conditions, there are some restrictions";
        SIGNAL SQLSTATE '45015';
    END IF

    IF NOT fn_CheckForExtraDependences('inscriptions', p_id_race) THEN
        SET v_error_message = "Error validating sp_DeleteInscriptionData conditions, there are some restrictions";
        SIGNAL SQLSTATE '45015';
    END IF

    IF NOT fn_CheckForExtraDependences('inscriptions', p_id_team) THEN
        SET v_error_message = "Error validating sp_DeleteInscriptionData conditions, there are some restrictions";
        SIGNAL SQLSTATE '45015';
    END IF

    START TRANSACTION;

    DELETE FROM inscriptions 
    WHERE id_vehicle = p_id_vehicle,
          id_race = p_id_race,
          id_team = p_id_team;
    
    SET v_affected_rows = ROW_COUNT();
    IF NOT v_affected_rows > 0 THEN
        SET v_error_message = 'Error executing sp_DeleteInscriptionData, there were no affected rows at the transaction';
        SIGNAL SQLSTATE '45015';
    END IF;

    COMMIT;

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45015' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que "p_id_inscription" no sea nulo (futura funcion)
    #Comprobar que el id de la inscripcion existe en la tabla de inscripciones con un select (futura funcion)

    ##Comienza la transaccion

    #Eliminar de la tabla de inscripciones el registro donde el id coincida con "p_id_inscription"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se elimino el registro y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_InsertManufacturerData (IN p_manufacturer_name VARCHAR(100), IN p_manufacturer_country VARCHAR(50), OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Inserts a new manufacturer record into the manufacturers table. Validates that the manufacturer name is not null or empty and checks for duplicate entries before insertion. Returns execution state via p_spstate.'
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45003' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion
    
    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que todos los parametros de tipo string no esten vacios (futura funcion)

    #Comienza la transaccion

    #Insert de los datos pasados como parametros a la tabla de fabricantes

    #Hacer un select con la funcion ROW_COUNT y comprobar si se insertaron los datos y guarda el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler
    
    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_UpdateManufacturerData (IN p_id_manufacturer INT, IN p_manufacturer_name VARCHAR(100), IN p_manufacturer_country VARCHAR(50), OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Updates an existing manufacturer record by id. Validates that the manufacturer exists, ensures the name is not null or empty, and checks for duplicate name entries before update. Returns execution state via p_spstate.'
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45016' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que todos los parametros de tipo string no esten vacios (futura funcion)
    #Comprobar que el id del fabricante existe en la tabla de fabricantes con un select (futura funcion)

    ##Comienza la transaccion

    #Actualizar los datos en la tabla de fabricantes donde el id coincida con "p_id_manufacturer"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se actualizaron los datos y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_DeleteManufacturerData (IN p_id_manufacturer INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Deletes an existing manufacturer record by id. Validates that the manufacturer exists and checks for associated vehicles referencing it before deletion to prevent orphaned dependent records. Returns execution state via p_spstate.'
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45017' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que "p_id_manufacturer" no sea nulo (futura funcion)
    #Comprobar que el id del fabricante existe en la tabla de fabricantes con un select (futura funcion)
    #Comprobar que el fabricante no tiene vehiculos asociados en la tabla de vehiculos (futura funcion, integridad referencial)

    ##Comienza la transaccion

    #Eliminar de la tabla de fabricantes el registro donde el id coincida con "p_id_manufacturer"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se elimino el registro y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_InsertPenaltyData (IN p_penalty_type CHAR(30), IN p_reason VARCHAR(100), IN p_penalty_value DECIMAL(7,2), IN p_penalty_applies_to VARCHAR(30), OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Inserts a new penalty record into the penalties table. Validates that penalty_type, reason, and penalty_applies_to are not null or empty, and that penalty_value is a positive number before insertion. Returns execution state via p_spstate.'
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45004' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion
    
    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que los parametros de tipo string no esten vacios (futura funcion)
    #Comprobar que el "p_penalty_value" tenga un valor razonablke y no sea 0 o negativo (futura funcion)
    #Comprobar que el "p_penalty_applies_to" solo contiene ['TEAM','PILOT'] (futura funcion)

    #Comienza la transaccion

    #Insert de los datos pasados como parametros a la tabla de penalties

    #Hacer un select con la funcion ROW_COUNT y comprobar si se insertaron los datos y guarda el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler
    
    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_UpdatePenaltyData (IN p_id_penalty INT, IN p_penalty_type CHAR(30), IN p_reason VARCHAR(100), IN p_penalty_value DECIMAL(7,2), IN p_penalty_applies_to VARCHAR(30), OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Updates an existing penalty record by id. Validates that the penalty exists, ensures penalty_type, reason, and penalty_applies_to are not null or empty, and that penalty_value is a positive number before update. Returns execution state via p_spstate.'
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45018' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que los parametros de tipo string no esten vacios (futura funcion)
    #Comprobar que el "p_penalty_value" tenga un valor razonable y no sea 0 o negativo (futura funcion)
    #Comprobar que el "p_penalty_applies_to" solo contiene ['TEAM','PILOT'] (futura funcion)
    #Comprobar que el id de la penalty existe en la tabla de penalties con un select (futura funcion)

    ##Comienza la transaccion

    #Actualizar los datos en la tabla de penalties donde el id coincida con "p_id_penalty"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se actualizaron los datos y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_DeletePenaltyData (IN p_id_penalty INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Deletes an existing penalty record by id. Validates that the penalty exists and checks for dependent records referencing it before deletion to prevent orphaned data. Returns execution state via p_spstate.'
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45019' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que "p_id_penalty" no sea nulo (futura funcion)
    #Comprobar que el id de la penalty existe en la tabla de penalties con un select (futura funcion)
    #Comprobar que la penalty no tiene registros asociados en otras tablas (futura funcion, integridad referencial)

    ##Comienza la transaccion

    #Eliminar de la tabla de penalties el registro donde el id coincida con "p_id_penalty"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se elimino el registro y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_InsertPilotCategoriesData (IN p_pilot_category_name VARCHAR(50), IN p_pilot_category_description VARCHAR(100), IN p_min_age TINYINT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Inserts a new pilot category record into the pilot_categories table. Validates that pilot_category_name is not null or empty, checks for duplicate category names, and ensures min_age is a positive valid age value before insertion. Returns execution state via p_spstate.'
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45005' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion
    
    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que los parametros de tipo string no esten vacios (futura funcion)
    #Comprobar que el "p_min_age" tenga un valor razonable y no sea 0 o negativo (futura funcion)

    #Comienza la transaccion

    #Insert de los datos pasados como parametros a la tabla de pilot_categories

    #Hacer un select con la funcion ROW_COUNT y comprobar si se insertaron los datos y guarda el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler
    
    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_UpdatePilotCategoriesData (IN p_id_pilot_category INT, IN p_pilot_category_name VARCHAR(50), IN p_pilot_category_description VARCHAR(100), IN p_min_age TINYINT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Updates an existing pilot category record by id. Validates that the category exists, ensures pilot_category_name is not null or empty, checks for duplicate category names, and ensures min_age is a positive valid age value before update. Returns execution state via p_spstate.'
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45020' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que los parametros de tipo string no esten vacios (futura funcion)
    #Comprobar que el "p_min_age" tenga un valor razonable y no sea 0 o negativo (futura funcion)
    #Comprobar que el id de la categoria existe en la tabla de pilot_categories con un select (futura funcion)

    ##Comienza la transaccion

    #Actualizar los datos en la tabla de pilot_categories donde el id coincida con "p_id_pilot_category"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se actualizaron los datos y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_DeletePilotCategoriesData (IN p_id_pilot_category INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Deletes an existing pilot category record by id. Validates that the category exists and checks for associated pilots referencing it before deletion to prevent orphaned dependent records. Returns execution state via p_spstate.'
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45021' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que "p_id_pilot_category" no sea nulo (futura funcion)
    #Comprobar que el id de la categoria existe en la tabla de pilot_categories con un select (futura funcion)
    #Comprobar que la categoria no tiene pilotos asociados en la tabla de pilotos (futura funcion, integridad referencial)

    ##Comienza la transaccion

    #Eliminar de la tabla de pilot_categories el registro donde el id coincida con "p_id_pilot_category"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se elimino el registro y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_InsertPilotData (IN p_pilot_name VARCHAR(100), IN p_pilot_age TINYINT, IN p_id_pilot_category INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Inserts a new pilot record into the pilots table. Validates that pilot_name is not null or empty, ensures pilot_age is a positive value meeting the minimum age requirement of the given category, and verifies the pilot category foreign key exists before insertion. Returns execution state via p_spstate.'
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45006' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion
    
    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que los parametros de tipo string no esten vacios (futura funcion)
    #Comprobar que el "p_pilot_age" tenga un valor razonable y no sea 0 o negativo (futura funcion)
    #Comprobar que la "p_id_pilot_category" existe con un if not exists de un select con esa id a la tabla de categoria de pilotos

    #Comienza la transaccion

    #Insert de los datos pasados como parametros a la tabla de pilots

    #Hacer un select con la funcion ROW_COUNT y comprobar si se insertaron los datos y guarda el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler
    
    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_UpdatePilotData (IN p_id_pilot INT, IN p_pilot_name VARCHAR(100), IN p_pilot_age TINYINT, IN p_id_pilot_category INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Updates an existing pilot record by id. Validates that the pilot exists, ensures pilot_name is not null or empty, verifies pilot_age is a positive value meeting the minimum age requirement of the given category, and checks the pilot category foreign key exists before update. Returns execution state via p_spstate.'
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45022' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que los parametros de tipo string no esten vacios (futura funcion)
    #Comprobar que el "p_pilot_age" tenga un valor razonable y no sea 0 o negativo (futura funcion)
    #Comprobar que el "p_id_pilot" existe con un if not exists de un select con esa id a la tabla de pilots
    #Comprobar que la "p_id_pilot_category" existe con un if not exists de un select con esa id a la tabla de categoria de pilotos

    ##Comienza la transaccion

    #Actualizar los datos en la tabla de pilots donde el id coincida con "p_id_pilot"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se actualizaron los datos y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_DeletePilotData (IN p_id_pilot INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Deletes an existing pilot record by id. Validates that the pilot exists and checks for dependent records such as race results or team assignments referencing it before deletion to prevent orphaned data. Returns execution state via p_spstate.'
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45023' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que "p_id_pilot" no sea nulo (futura funcion)
    #Comprobar que el "p_id_pilot" existe con un if not exists de un select con esa id a la tabla de pilots
    #Comprobar que el piloto no tiene inscripciones asociadas en la tabla de inscripciones (futura funcion, integridad referencial)
    #Comprobar que el piloto no tiene penalizaciones asociadas en la tabla de penalties (futura funcion, integridad referencial)

    ##Comienza la transaccion

    #Eliminar de la tabla de pilots el registro donde el id coincida con "p_id_pilot"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se elimino el registro y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_InsertPilotInscriptionData (IN p_id_pilot INT, IN p_id_vehicle INT, IN p_id_race INT, IN p_id_team INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Inserts a new pilot inscription record into the pilot_inscriptions table. Validates all foreign keys (pilot, vehicle, race, team) exist before insertion, and checks for duplicate pilot-race combinations to prevent double registration. Returns execution state via p_spstate.'
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45007' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion
    
    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que la "p_id_pilot" existe con un if not exists de un select con esa id a la tabla de pilotos
    #Comprobar que la "p_id_vehicle" existe con un if not exists de un select con esa id a la tabla de vehiculos
    #Comprobar que la "p_id_race" existe con un if not exists de un select con esa id a la tabla de carreras
    #Comprobar que la "p_id_team" existe con un if not exists de un select con esa id a la tabla de equipos

    #Comienza la transaccion

    #Insert de los datos pasados como parametros a la tabla de pilot_inscriptions

    #Hacer un select con la funcion ROW_COUNT y comprobar si se insertaron los datos y guarda el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler
    
    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_UpdatePilotInscriptionData (IN p_id_pilot_inscription INT, IN p_id_pilot INT, IN p_id_vehicle INT, IN p_id_race INT, IN p_id_team INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Updates an existing pilot inscription record by id. Validates that the inscription exists, verifies all foreign keys (pilot, vehicle, race, team) exist, and checks for duplicate pilot-race combinations excluding the current record before update. Returns execution state via p_spstate.'
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45024' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que la "p_id_pilot_inscription" existe con un if not exists de un select con esa id a la tabla de pilot_inscriptions
    #Comprobar que la "p_id_pilot" existe con un if not exists de un select con esa id a la tabla de pilotos
    #Comprobar que la "p_id_vehicle" existe con un if not exists de un select con esa id a la tabla de vehiculos
    #Comprobar que la "p_id_race" existe con un if not exists de un select con esa id a la tabla de carreras
    #Comprobar que la "p_id_team" existe con un if not exists de un select con esa id a la tabla de equipos

    ##Comienza la transaccion

    #Actualizar los datos en la tabla de pilot_inscriptions donde el id coincida con "p_id_pilot_inscription"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se actualizaron los datos y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_DeletePilotInscriptionData (IN p_id_pilot_inscription INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Deletes an existing pilot inscription record by id. Validates that the pilot inscription exists and checks for dependent records such as race results or penalties referencing it before deletion to prevent orphaned data. Returns execution state via p_spstate.'
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45025' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que "p_id_pilot_inscription" no sea nulo (futura funcion)
    #Comprobar que la "p_id_pilot_inscription" existe con un if not exists de un select con esa id a la tabla de pilot_inscriptions
    #Comprobar que la inscripcion no tiene penalizaciones asociadas en la tabla de penalties (futura funcion, integridad referencial)
    #Comprobar que la inscripcion no tiene resultados asociados en la tabla de resultados (futura funcion, integridad referencial)

    ##Comienza la transaccion

    #Eliminar de la tabla de pilot_inscriptions el registro donde el id coincida con "p_id_pilot_inscription"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se elimino el registro y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_InsertRaceData (IN p_event_name VARCHAR(100), IN p_event_date DATETIME, IN p_event_duration TIME, IN p_id_circuit INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Inserts a new race record into the races table. Validates that event_name is not null or empty, ensures event_date is not in the past, verifies event_duration is a positive time value, and checks the circuit foreign key exists before insertion. Returns execution state via p_spstate.'
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45008' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion
    
    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que los parametros de tipo string no esten vacios (futura funcion)
    #Comprobar que "p_event_date" este dentro de unos valores razonables (como por ejemplo el mismo anyo)
    #Comprobar que "p_event_duration" no sea 0 ni tenga un valor minimo muy bajo
    #Comprobar que el id del circuito es correcto con un if not exists y un select a la tabla de cuircuitos con el id de parametro

    #Comienza la transaccion

    #Insert de los datos pasados como parametros a la tabla de races

    #Hacer un select con la funcion ROW_COUNT y comprobar si se insertaron los datos y guarda el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler
    
    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_UpdateRaceData (IN p_id_race INT, IN p_event_name VARCHAR(100), IN p_event_date DATETIME, IN p_event_duration TIME, IN p_id_circuit INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Updates an existing race record by id. Validates that the race exists, ensures event_name is not null or empty, verifies event_date is not in the past, checks event_duration is a positive time value, and confirms the circuit foreign key exists before update. Returns execution state via p_spstate.'
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45026' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que los parametros de tipo string no esten vacios (futura funcion)
    #Comprobar que "p_event_date" este dentro de unos valores razonables (como por ejemplo el mismo anyo)
    #Comprobar que "p_event_duration" no sea 0 ni tenga un valor minimo muy bajo
    #Comprobar que el "p_id_race" existe con un if not exists y un select a la tabla de races con el id de parametro
    #Comprobar que el id del circuito es correcto con un if not exists y un select a la tabla de circuitos con el id de parametro

    ##Comienza la transaccion

    #Actualizar los datos en la tabla de races donde el id coincida con "p_id_race"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se actualizaron los datos y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_DeleteRaceData (IN p_id_race INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Deletes an existing race record by id. Validates that the race exists and checks for dependent records such as inscriptions, pilot inscriptions, and race results referencing it before deletion to prevent orphaned data. Returns execution state via p_spstate.'
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45027' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que "p_id_race" no sea nulo (futura funcion)
    #Comprobar que el "p_id_race" existe con un if not exists y un select a la tabla de races con el id de parametro
    #Comprobar que la carrera no tiene inscripciones asociadas en la tabla de inscripciones (futura funcion, integridad referencial)
    #Comprobar que la carrera no tiene pilot_inscriptions asociadas en la tabla de pilot_inscriptions (futura funcion, integridad referencial)
    #Comprobar que la carrera no tiene resultados asociados en la tabla de resultados (futura funcion, integridad referencial)

    ##Comienza la transaccion

    #Eliminar de la tabla de races el registro donde el id coincida con "p_id_race"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se elimino el registro y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_InsertResultData (
    IN p_position INT, 
    IN p_final_time TIME, 
    IN p_penalty_time TIME, 
    IN p_base_points_team INT, 
    IN p_base_points_pilot INT, 
    IN p_penalty_points_team INT, 
    IN p_id_vehicle INT, 
    IN p_id_race INT,
    IN p_id_team INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Inserts a new race result record into the results table. Validates that position is a positive integer, final_time and penalty_time are valid time values, base and penalty points are non-negative, and verifies all foreign keys (vehicle, race, team) exist before insertion. Returns execution state via p_spstate.'
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45009' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion
    
    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que "p_position" este dentro de las posiciones posibles del leaderboard (futura funcion)
    #Comprobar que "p_final_time" este dentro de unos valores razonables de tiempo (futura funcion)
    #Comprobar que todos los parametros que tengan que ver con los puntos no sean negativos (futura funcion)
    #Comprobar que la "p_id_vehicle" existe con un if not exists de un select con esa id a la tabla de vehiculos
    #Comprobar que la "p_id_race" existe con un if not exists de un select con esa id a la tabla de carreras
    #Comprobar que la "p_id_team" existe con un if not exists de un select con esa id a la tabla de equipos

    #Comienza la transaccion

    #Insert de los datos pasados como parametros a la tabla de results

    #Hacer un select con la funcion ROW_COUNT y comprobar si se insertaron los datos y guarda el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler
    
    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_UpdateResultData (
    IN p_id_result INT,
    IN p_position INT,
    IN p_final_time TIME,
    IN p_penalty_time TIME,
    IN p_base_points_team INT,
    IN p_base_points_pilot INT,
    IN p_penalty_points_team INT,
    IN p_id_vehicle INT,
    IN p_id_race INT,
    IN p_id_team INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Updates an existing race result record by id. Validates that the result exists, ensures position is a positive integer, final_time and penalty_time are valid time values, base and penalty points are non-negative, and verifies all foreign keys (vehicle, race, team) exist before update. Returns execution state via p_spstate.'
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45028' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que "p_position" este dentro de las posiciones posibles del leaderboard (futura funcion)
    #Comprobar que "p_final_time" este dentro de unos valores razonables de tiempo (futura funcion)
    #Comprobar que todos los parametros que tengan que ver con los puntos no sean negativos (futura funcion)
    #Comprobar que el "p_id_result" existe con un if not exists de un select con esa id a la tabla de results
    #Comprobar que la "p_id_vehicle" existe con un if not exists de un select con esa id a la tabla de vehiculos
    #Comprobar que la "p_id_race" existe con un if not exists de un select con esa id a la tabla de carreras
    #Comprobar que la "p_id_team" existe con un if not exists de un select con esa id a la tabla de equipos

    ##Comienza la transaccion

    #Actualizar los datos en la tabla de results donde el id coincida con "p_id_result"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se actualizaron los datos y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_DeleteResultData (IN p_id_result INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Deletes an existing race result record by id. Validates that the result exists and checks for dependent records such as pilot results or penalty assignments referencing it before deletion to prevent orphaned data. Returns execution state via p_spstate.'
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45029' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que "p_id_result" no sea nulo (futura funcion)
    #Comprobar que el "p_id_result" existe con un if not exists de un select con esa id a la tabla de results

    ##Comienza la transaccion

    #Eliminar de la tabla de results el registro donde el id coincida con "p_id_result"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se elimino el registro y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_InsertTeamData (IN p_team_name VARCHAR(100), IN p_mechanic_num TINYINT, IN p_id_manufacturer INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Inserts a new team record into the teams table. Validates that team_name is not null or empty, checks for duplicate team names, ensures mechanic_num is a positive value, and verifies the manufacturer foreign key exists before insertion. Returns execution state via p_spstate.'
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45010' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion
    
    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que los parametros de tipo string no esten vacios (futura funcion)
    #Comprobar "p_mechanic_num" no se pase de X numero de mecanicos (futura funcion)
    #Comprobar que el fabricante existe con un if not exists y un select a la tabla de fabricantes con el parametro "p_id_manufacturer"

    #Comienza la transaccion

    #Insert de los datos pasados como parametros a la tabla de teams

    #Hacer un select con la funcion ROW_COUNT y comprobar si se insertaron los datos y guarda el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler
    
    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_UpdateTeamData (IN p_id_team INT, IN p_team_name VARCHAR(100), IN p_mechanic_num TINYINT, IN p_id_manufacturer INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Updates an existing team record by id. Validates that the team exists, ensures team_name is not null or empty, checks for duplicate team names excluding the current record, verifies mechanic_num is a positive value, and confirms the manufacturer foreign key exists before update. Returns execution state via p_spstate.'
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45030' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que los parametros de tipo string no esten vacios (futura funcion)
    #Comprobar "p_mechanic_num" no se pase de X numero de mecanicos (futura funcion)
    #Comprobar que el "p_id_team" existe con un if not exists y un select a la tabla de teams con el parametro "p_id_team"
    #Comprobar que el fabricante existe con un if not exists y un select a la tabla de fabricantes con el parametro "p_id_manufacturer"

    ##Comienza la transaccion

    #Actualizar los datos en la tabla de teams donde el id coincida con "p_id_team"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se actualizaron los datos y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_DeleteTeamData (IN p_id_team INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Deletes an existing team record by id. Validates that the team exists and checks for dependent records such as inscriptions, pilot inscriptions, and race results referencing it before deletion to prevent orphaned data. Returns execution state via p_spstate.'
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45031' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que "p_id_team" no sea nulo (futura funcion)
    #Comprobar que el "p_id_team" existe con un if not exists y un select a la tabla de teams con el parametro "p_id_team"
    #Comprobar que el equipo no tiene inscripciones asociadas en la tabla de inscripciones (futura funcion, integridad referencial)
    #Comprobar que el equipo no tiene pilot_inscriptions asociadas en la tabla de pilot_inscriptions (futura funcion, integridad referencial)
    #Comprobar que el equipo no tiene resultados asociados en la tabla de results (futura funcion, integridad referencial)

    ##Comienza la transaccion

    #Eliminar de la tabla de teams el registro donde el id coincida con "p_id_team"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se elimino el registro y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_InsertVehicleData (IN p_model VARCHAR(100), IN p_specifications_url VARCHAR(1024), OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Inserts a new vehicle record into the vehicles table. Validates that model is not null or empty, checks for duplicate model entries, and ensures specifications_url is a valid and well-formed URL before insertion. Returns execution state via p_spstate.'
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45011' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion
    
    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que los parametros de tipo string no esten vacios (futura funcion)
    #Comprobar con un if LOAD_FILE que el archivo especificado en el URL existe (preguntar a Quim)

    #Comienza la transaccion

    #Insert de los datos pasados como parametros a la tabla de vehicles

    #Hacer un select con la funcion ROW_COUNT y comprobar si se insertaron los datos y guarda el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler
    
    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_UpdateVehicleData (IN p_id_vehicle INT, IN p_model VARCHAR(100), IN p_specifications_url VARCHAR(1024), OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Updates an existing vehicle record by id. Validates that the vehicle exists, ensures model is not null or empty, checks for duplicate model entries excluding the current record, and verifies specifications_url is a valid and well-formed URL before update. Returns execution state via p_spstate.'
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45032' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que los parametros de tipo string no esten vacios (futura funcion)
    #Comprobar con un if LOAD_FILE que el archivo especificado en el URL existe (preguntar a Quim)
    #Comprobar que el "p_id_vehicle" existe con un if not exists y un select a la tabla de vehicles con el parametro "p_id_vehicle"

    ##Comienza la transaccion

    #Actualizar los datos en la tabla de vehicles donde el id coincida con "p_id_vehicle"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se actualizaron los datos y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_DeleteVehicleData (IN p_id_vehicle INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Deletes an existing vehicle record by id. Validates that the vehicle exists and checks for dependent records such as inscriptions, pilot inscriptions, and race results referencing it before deletion to prevent orphaned data. Returns execution state via p_spstate.'
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45033' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que "p_id_vehicle" no sea nulo (futura funcion)
    #Comprobar que el "p_id_vehicle" existe con un if not exists y un select a la tabla de vehicles con el parametro "p_id_vehicle"
    #Comprobar que el vehiculo no tiene inscripciones asociadas en la tabla de inscripciones (futura funcion, integridad referencial)
    #Comprobar que el vehiculo no tiene pilot_inscriptions asociadas en la tabla de pilot_inscriptions (futura funcion, integridad referencial)
    #Comprobar que el vehiculo no tiene resultados asociados en la tabla de results (futura funcion, integridad referencial)

    ##Comienza la transaccion

    #Eliminar de la tabla de vehicles el registro donde el id coincida con "p_id_vehicle"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se elimino el registro y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_GetRaceLeaderboardById (IN p_id_race INT)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Retrieves the leaderboard for a specific race by id and date. Returns pilots ordered by final position, including pilot name, team, vehicle, final time, penalty time, and total points, filtered by the given race date. Reads data only without modifying it.'
BEGIN

    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        IF NOT v_error_message = '' THEN
            SIGNAL SQLSTATE '45040' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
            SIGNAL SQLSTATE '45040';
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_race, p_race_date)) THEN
        SET v_error_message = 'Error validating sp_GetRaceLeaderboard parameters, there are empty or null parameters';
        SIGNAL SQLSTATE '45040';
    END IF;

    IF NOT fn_IdRegisteredFromRaces(p_id_race) THEN
        SET v_error_message = 'Error validating sp_GetRaceLeaderboard parameters, p_id_race is not registered at races table';
        SIGNAL SQLSTATE '45040';
    END IF;

    SELECT
        res.position AS 'Position',
        pil.pilot_name AS 'PilotName',

    FROM results res
    INNER JOIN pilot_inscriptions pilins ON pilins.id_race = res.id_race
    INNER JOIN pilots pil ON pil.id_pilot = pilins.id_pilot
    INNER JOIN teams tea ON tea.id_team = 
    WHERE res.id_race = p_id_race;

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45040' usando la variable "v_error_message"

    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que la carrera existe con un if not exists y un select a la tabla de carreras con el parametro "p_id_race" (futura funcion)
    #Comprobar que el parametro "p_race_date" tenga un valor coherente (futura funcion)

    #Select de posicion, nombre del piloto, nombre del equipo, tiempo final,
    #tiempo de penalizacion, puntos base del piloto y puntos base del equipo
    #de la tabla de results con inner join a races filtrando por "p_id_race"
    #y por fecha de carrera igual a "p_race_date"
    #ordenado por posicion de forma ascendente

END //

CREATE PROCEDURE sp_GetPilotSeasonStats (IN p_id_pilot INT, IN p_season_date DATETIME)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Retrieves season statistics for a specific pilot by id and season date. Returns aggregated performance data such as races entered, wins, podiums, points, and average finish position for the given season. Reads data only without modifying it.'
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45041' usando la variable "v_error_message"

    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que el piloto existe con un if not exists y un select a la tabla de pilotos con el parametro "p_id_pilot" (futura funcion)
    #Comprobar que el parametro "p_season_date" tenga un valor coherente (futura funcion)

    #Select de puntos del piloto, nombre, vehiculo, equipo from carreras where p_season_date inner join a inscripciones, resultados y pilotos junto a sus inscripciones

END //


##He hecho algunos procedimientos GET, pero se podrian hacer muchos mas
##Procedimiento de comprobacion de inscripcion

##Procedimiento de insercion y modificacion de datos en tablas de auditoria (EXAMPLE)
/* CREATE TABLE audit_log (
    id_audit      INT AUTO_INCREMENT PRIMARY KEY,
    table_name    VARCHAR(100)                    NOT NULL,
    action        ENUM('INSERT','UPDATE','DELETE') NOT NULL,
    record_id     INT                             NOT NULL,
    changed_by    VARCHAR(100)                    NOT NULL,
    changed_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_data      JSON                            NULL,
    new_data      JSON                            NULL
); */
/* CREATE PROCEDURE sp_AuditLog (
    IN p_table_name VARCHAR(100),
    IN p_action     ENUM('INSERT','UPDATE','DELETE'),
    IN p_record_id  INT,
    IN p_changed_by VARCHAR(100),
    IN p_old_data   JSON,
    IN p_new_data   JSON,
    OUT p_spstate   TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Signal SQLSTATE '45099' usando la variable "v_error_message"
        #Resignal en caso de ser error de la transaccion

    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que "p_table_name" no este vacio (futura funcion)
    #Comprobar que "p_action" este dentro de los valores permitidos ['INSERT','UPDATE','DELETE'] (futura funcion)

    ##Comienza la transaccion

    #Insertar en la tabla de auditoria: tabla afectada, accion, id del registro,
    #usuario que hizo el cambio, timestamp automatico, datos anteriores (JSON) y datos nuevos (JSON)

    #Hacer un select con ROW_COUNT y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END // */