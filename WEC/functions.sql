-- Active: 1762272161423@@127.0.0.1@3306@wec
USE WEC;

DELIMITER //

CREATE FUNCTION UnderMaxLimit ( IN numToCheck INT, IN maxNumber INT )
RETURNS TINYINT(1)
COMMENT 'Check if a value is under his max limit'
DETERMINISTIC
NO SQL
BEGIN
    RETURN (numToCheck < maxNumber );
END //

CREATE FUNCTION GetTeamMechanicsNumber ( IN search_team_id INT )
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

CREATE FUNCTION CountInscriptedPilots ( IN search_vehicle_id INT, IN search_team_id INT, IN search_race_id INT )
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

CREATE PROCEDURE AddTeamPenalty ( IN penalty_type VARCHAR(20), IN penalty_value DECIMAL(7,2), IN vehicle_id INT, IN team_id INT, IN race_id INT )
NOT DETERMINISTIC
MODIFIES SQL DATA
BEGIN

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
    ELSEIF (penalty_type = 'TIME') THEN
        UPDATE results res
        SET res.penalty_time = ADDTIME(res.penalty_time, SEC_TO_TIME(penalty_value))
        WHERE res.id_vehicle = vehicle_id
            AND res.id_team = team_id
            AND res.id_race = race_id;
    ELSE
        UPDATE results res
        SET 
            res.penalty_time = SEC_TO_TIME(0),
            res.penalty_points_team = 0,
            res.penalty_points_pilot = 0
        WHERE res.id_vehicle = vehicle_id
            AND res.id_team = team_id
            AND res.id_race = race_id;
    END IF;

    COMMIT;

END //

CREATE PROCEDURE AddPilotPenalty ( IN penalty_type VARCHAR(20), IN penalty_value DECIMAL(7,2), IN result_id INT )
NOT DETERMINISTIC
MODIFIES SQL DATA
BEGIN

    IF (penalty_type = 'POINTS') THEN
        UPDATE results res
        SET res.penalty_points_pilot = GREATEST(0, res.penalty_points_pilot - FLOOR(penalty_value))
        WHERE res.id_result = result_id;
    ELSEIF (penalty_type = 'TIME') THEN
        UPDATE results res
        SET res.penalty_time = ADDTIME(res.penalty_time, SEC_TO_TIME(penalty_value))
        WHERE res.id_result = result_id;
    ELSE
        UPDATE results res
        SET 
            res.penalty_time = SEC_TO_TIME(0),
            res.penalty_points_pilot = 0
        WHERE res.id_result = result_id;
    END IF;

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
NOT DETERMINISTIC
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

DELIMITER ;