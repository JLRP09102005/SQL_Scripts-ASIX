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

    SELECT GetPositionsPointsMultiplier(NEW.id_race) INTO position_points_mult;
    
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
        ELSE
            SET points_calc_result = 0;
        END IF;

        IF(done != 1) THEN
            CALL AddResultPoints(NEW.id_race, cur_id_result, points_calc_result);
        END IF;

        SET position = position + 1;

    END WHILE;

    CLOSE cur_times;
END//
DELIMITER ;