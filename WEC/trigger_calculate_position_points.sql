USE wec;

DELIMITER //
CREATE TRIGGER trg_calculate_position_points AFTER INSERT ON results
FOR EACH ROW
BEGIN
    DECLARE done TINYINT(1) DEFAULT 0;
    DECLARE cur_time TIME DEFAULT '00:00:00';
    DECLARE cur_id_result INT DEFAULT 0;
    DECLARE position TINYINT DEFAULT 1;
    DECLARE position_points TINYINT DEFAULT 25;
    DECLARE position_points_mult DECIMAL(3,1) DEFAULT 1;
    DECLARE points_calc_result TINYINT DEFAULT 0;
    DECLARE race_time TIME DEFAULT '06:00:00';

    DECLARE cur_times CURSOR FOR
        SELECT 
            res.id_result,
            res.penalty_time
        FROM results res
        WHERE res.id_race = NEW.id_race
        ORDER BY res.penalty_time ASC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    SELECT
        rac.event_duration INTO race_time
    FROM races rac
    WHERE rac.id_race = NEW.id_race;

    IF(race_time <= '06:00:00') THEN
        SET position_points_mult = 1;
    ELSEIF(race_time >= '08:00:00' AND race_time <= '10:00:00') THEN
        SET position_points_mult = 1.5;
    ELSEIF(race_time >= '24:00:00') THEN
        SET position_points_mult = 2;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Race time is not correct, the points calculation cant proceed';
    END IF;
    
    OPEN cur_times;
    WHILE (done != 1 AND position <= 10) DO
        FETCH cur_times INTO cur_id_result, cur_time;

        IF(position = 1) THEN
            SET points_calc_result = position_points * position_points_mult;
        ELSEIF(position = 2) THEN
            SET position_points = position_points - 7;
            SET points_calc_result = position_points * position_points_mult;
        ELSEIF(position >= 3 AND position <= 4) THEN
            SET position_points = position_points - 3;
            SET points_calc_result = position_points * position_points_mult;
        ELSEIF(position >= 5 AND position <= 9) THEN
            SET position_points = position_points - 2;
            SET points_calc_result = position_points * position_points_mult;
        ELSEIF(position = 10) THEN
            SET position_points = position_points - 1;
            SET points_calc_result = position_points * position_points_mult;
        END IF;

        IF(done != 1) THEN
            UPDATE results res SET
                res.base_points_team = points_calc_result,
                res.base_points_pilot = points_calc_result,
                res.penalty_points_team = points_calc_result,
                res.penalty_points_pilot = points_calc_result
            WHERE 
                res.id_race = NEW.id_race AND
                res.id_result = cur_id_result;
        END IF;

        SET position = position + 1;

    END WHILE;

    CLOSE cur_times;
END//
DELIMITER ;