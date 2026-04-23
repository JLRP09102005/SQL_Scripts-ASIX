-- Active: 1762272161423@@127.0.0.1@3306@wec
USE WEC;
DELIMITER //

CREATE FUNCTION CheckAfectedRowsCount ( IN row_count INT )
RETURNS TINYINT(1)
COMMENT 'Check if there are any row afected by an a DDL or DML sentence'
NOT DETERMINISTIC
NO SQL
BEGIN
    RETURN (row_count != 0);
END //

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

CREATE FUNCTION GetPositionsPointsMultiplier (IN race_id INT)
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

CREATE FUNCTION GetLeaderboardPointsCalc (IN position INT, IN base_points INT, IN points_mult DECIMAL(3,2))
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

CREATE FUNCTION fn_CheckNullEmptyArray (array JSON)
RETURNS TINYINT(1) DETERMINISTIC
BEGIN

    DECLARE i INT DEFAULT 0;
    DECLARE total INT DEFAULT 0;
    DECLARE sentence VARCHAR(255) DEFAULT '';

    SET total = JSON_LENGTH(arr);
    WHILE i < total DO

        SET sentence = JSON_UNQUOTE(JSON_EXTRACT(arr, CONCAT('$[', i, ']')));
        IF sentence = "" OR sentence = null THEN
            RETURN 1;
        END IF;

        SET i = i + 1;

    END WHILE;

    RETURN 0;

END //

DELIMITER ;

DELIMITER $$
CREATE FUNCTION procesar_array(arr JSON)
RETURNS VARCHAR(255) DETERMINISTIC
BEGIN
  DECLARE i INT DEFAULT 0;
  DECLARE total INT;
  DECLARE resultado VARCHAR(255) DEFAULT '';
  SET total = JSON_LENGTH(arr);
  WHILE i < total DO
    SET resultado = CONCAT(resultado, ' ', JSON_UNQUOTE(JSON_EXTRACT(arr, CONCAT('$[', i, ']'))));
    SET i = i + 1;
  END WHILE;
  RETURN TRIM(resultado);
END$$
DELIMITER ;