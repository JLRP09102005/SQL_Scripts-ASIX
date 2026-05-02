DELIMITER //

-- =================================================================
-- GET PROCEDURES
-- =================================================================

CREATE PROCEDURE sp_GetRaceLeaderboardById (
    IN p_id_race INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Returns the leaderboard for a specific race, ordered by position.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_race)) THEN
        SIGNAL SQLSTATE '45040' SET MESSAGE_TEXT = 'Race ID cannot be null';
    END IF;

    IF NOT fn_IdRegisteredFromRaces(p_id_race) THEN
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
    WHERE r.id_race = p_id_race
    ORDER BY r.position ASC;
END //

CREATE PROCEDURE sp_GetPilotSeasonStats (
    IN p_id_pilot INT,
    IN p_season_year INT
)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Returns aggregated season statistics for a pilot.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_pilot, p_season_year)) THEN
        SIGNAL SQLSTATE '45041' SET MESSAGE_TEXT = 'Parameters cannot be null';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyPilotById(p_id_pilot)
    IF NOT EXISTS (SELECT 1 FROM pilots WHERE id_pilot = p_id_pilot) THEN
        SIGNAL SQLSTATE '45041' SET MESSAGE_TEXT = 'Pilot ID does not exist';
    END IF;

    SELECT
        p.pilot_name AS 'PilotName',
        COUNT(DISTINCT r.id_race) AS 'RacesEntered',
        SUM(CASE WHEN r.position = 1 THEN 1 ELSE 0 END) AS 'Wins',
        SUM(CASE WHEN r.position <= 3 THEN 1 ELSE 0 END) AS 'Podiums',
        SUM(r.base_points_pilot - r.penalty_points_pilot) AS 'TotalPoints',
        AVG(r.position) AS 'AvgFinishPosition'
    FROM pilots p
    JOIN pilots_inscriptions pi ON pi.id_pilot = p.id_pilot
    JOIN results r ON r.id_vehicle = pi.id_vehicle AND r.id_race = pi.id_race AND r.id_team = pi.id_team
    JOIN races rac ON rac.id_race = r.id_race
    WHERE p.id_pilot = p_id_pilot
      AND YEAR(rac.event_date) = p_season_year
    GROUP BY p.id_pilot, p.pilot_name;
END //

DELIMITER ;