USE wec;
DELIMITER //

CREATE PROCEDURE AddTeamPenalty ( IN penalty_type VARCHAR(20), IN penalty_value DECIMAL(7,2), IN vehicle_id INT, IN team_id INT, IN race_id INT )
NOT DETERMINISTIC
MODIFIES SQL DATA
BEGIN
    DECLARE affected_rows INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    IF (penalty_type = 'POINTS') THEN
        UPDATE results res
        SET 
            res.penalty_points_team = GREATEST(0, res.penalty_points_team - FLOOR(penalty_value)),
            res.penalty_points_pilot = GREATEST(0, res.penalty_points_pilot - FLOOR(penalty_value))
        WHERE res.id_vehicle = vehicle_id
            AND res.id_team = team_id
            AND res.id_race = race_id;
        
        SET affected_rows = ROW_COUNT();

    ELSEIF (penalty_type = 'TIME') THEN
        UPDATE results res
        SET res.penalty_time = ADDTIME(res.penalty_time, SEC_TO_TIME(penalty_value))
        WHERE res.id_vehicle = vehicle_id
            AND res.id_team = team_id
            AND res.id_race = race_id;
        
        SET affected_rows = ROW_COUNT();
        
    ELSEIF (penalty_type = 'DNF' || penalty_type = 'DSQ') THEN
        UPDATE results res
        SET 
            res.penalty_time = SEC_TO_TIME(0),
            res.penalty_points_team = 0,
            res.penalty_points_pilot = 0
        WHERE res.id_vehicle = vehicle_id
            AND res.id_team = team_id
            AND res.id_race = race_id;

        SET affected_rows = ROW_COUNT();

    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid penalty_type';
    END IF;

    IF (CheckAfectedRowsCount(affected_rows)) THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No affected rows';
    END IF;

    COMMIT;

END //

CREATE PROCEDURE AddPilotPenalty ( IN penalty_type VARCHAR(20), IN penalty_value DECIMAL(7,2), IN result_id INT )
NOT DETERMINISTIC
MODIFIES SQL DATA
BEGIN
    DECLARE affected_rows INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    IF (penalty_type = 'POINTS') THEN
        UPDATE results res
        SET res.penalty_points_pilot = GREATEST(0, res.penalty_points_pilot - FLOOR(penalty_value))
        WHERE res.id_result = result_id;

        SET affected_rows = ROW_COUNT();

    ELSEIF (penalty_type = 'TIME') THEN
        UPDATE results res
        SET res.penalty_time = ADDTIME(res.penalty_time, SEC_TO_TIME(penalty_value))
        WHERE res.id_result = result_id;

        SET affected_rows = ROW_COUNT();

    ELSEIF (penalty_type = 'DNF' || penalty_type = 'DSQ') THEN
        UPDATE results res
        SET 
            res.penalty_time = SEC_TO_TIME(0),
            res.penalty_points_pilot = 0
        WHERE res.id_result = result_id;

        SET affected_rows = ROW_COUNT();

    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid penalty_type';
    END IF;

    IF (CheckAfectedRowsCount(affected_rows)) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No affected rows';
    END IF;

    COMMIT;
END //

CREATE PROCEDURE GetPenaltyBasicInfo ( IN id_penalty INT, OUT penalty_type VARCHAR(20), OUT penalty_applies VARCHAR(20), OUT penalty_value DECIMAL(7,2) )
DETERMINISTIC
READS SQL DATA
BEGIN
    SELECT
        pen.penalty_type INTO penalty_type,
        pen.penalty_applies_to INTO penalty_applies,
        pen.penalty_value INTO penalty_value
    FROM penalties pen
    WHERE pen.id_penalty = id_penalty;
END //

CREATE PROCEDURE GetResultsForeignInfo ( IN result_id INT, OUT vehicle_id INT, OUT team_id INT, OUT race_id INT )
DETERMINISTIC
READS SQL DATA
BEGIN
    SELECT
        res.id_vehicle INTO vehicle_id,
        res.id_team INTO team_id,
        res.id_race INTO race_id
    FROM results res
    WHERE res.id_result = result_id;
END //

CREATE PROCEDURE ProcessResultPenalty ( IN id_penalty INT, IN id_result INT )
DETERMINISTIC
MODIFIES SQL DATA
BEGIN
    DECLARE penalty_type VARCHAR(20) DEFAULT 'POINTS';
    DECLARE penalty_applies VARCHAR(20) DEFAULT 'PILOT';
    DECLARE penalty_value DECIMAL(7,2) DEFAULT 0;
    DECLARE vehicle_id INT DEFAULT NULL;
    DECLARE team_id INT DEFAULT NULL;
    DECLARE race_id INT DEFAULT NULL;

    CALL GetPenaltyBasicInfo(id_penalty, penalty_type, penalty_applies, penalty_value);
    CALL GetResultsForeignInfo(id_result, vehicle_id, team_id, race_id);

    IF (penalty_applies = 'PILOT') THEN
        CALL AddPilotPenalty(penalty_type, penalty_value, id_result);
    ELSE
        CALL AddTeamPenalty(penalty_type, penalty_value, vehicle_id, team_id, race_id);
    END IF;
END //

CREATE PROCEDURE AddResultPoints(IN race_id INT, IN result_id INT, IN result_points TINYINT)
DETERMINISTIC
MODIFIES SQL DATA
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    UPDATE results res SET
        res.base_points_team = result_points,
        res.base_points_pilot = result_points,
        res.penalty_points_team = result_points,
        res.penalty_points_pilot = result_points
    WHERE 
        res.id_race = race_id AND
        res.id_result = result_id;
    COMMIT;
END //

CREATE PROCEDURE UpdateLeaderPoints (IN new_id_race INT)
DETERMINISTIC
MODIFIES SQL DATA
BEGIN
    DECLARE v_done TINYINT(1) DEFAULT 0;
    DECLARE v_cur_id_result INT DEFAULT 0;
    DECLARE v_position TINYINT DEFAULT 1;
    DECLARE v_position_points TINYINT DEFAULT 25;
    DECLARE v_position_points_mult DECIMAL(3,1) DEFAULT 1;
    DECLARE v_points_calc_result TINYINT DEFAULT 0;
    DECLARE v_new_id_race INT DEFAULT NULL;

    SET v_new_id_race = new_id_race;

    DECLARE cur_times CURSOR FOR
        SELECT 
            res.id_result
        FROM results res
        WHERE res.id_race = v_new_id_race
        ORDER BY res.penalty_time ASC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        IF v_done !=
        CLOSE cur_times;

        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    SELECT GetPositionsPointsMultiplier(v_new_id_race) INTO v_position_points_mult;
    
    OPEN cur_times;
    WHILE (v_done != 1 AND v_position <= 10) DO
        FETCH cur_times INTO v_cur_id_result;
        SELECT GetLeaderboardPointsCalc(v_position, v_position_points, v_position_points_mult) INTO v_points_calc_result;

        IF(v_done != 1) THEN
            CALL AddResultPoints(v_new_id_race, v_cur_id_result, v_points_calc_result);
        END IF;

        SET v_position = v_position + 1;
    END WHILE;
    CLOSE cur_times;

    COMMIT;
END //

DELIMITER ;