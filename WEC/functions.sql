-- Active: 1762272161423@@127.0.0.1@3306@wec
USE WEC;

DELIMITER //

CREATE FUNCTION UnderMaxLimit ( numToCheck INT, maxNumber INT )
RETURNS TINYINT(1)
COMMENT 'Check if a value is under his max limit'
DETERMINISTIC
NO SQL
BEGIN
    RETURN (numToCheck < maxNumber );
END;

CREATE FUNCTION GetTeamMechanicsNumber ( search_team_id INT )
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

END;

CREATE FUNCTION CountInscriptedPilots ( search_vehicle_id INT, search_team_id INT, search_race_id INT )
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

END;

DELIMITER ;