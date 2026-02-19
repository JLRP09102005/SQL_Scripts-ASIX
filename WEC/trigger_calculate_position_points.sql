USE wec;

DELIMITER //
CREATE TRIGGER trg_calculate_position_points BEFORE INSERT ON results
FOR EACH ROW
BEGIN
    DECLARE done TINYINT(1) DEFAULT 0;
    DECLARE cur_time TIME DEFAULT '00:00:00';
    DECLARE cur_id_result INT DEFAULT 0;
    DECLARE loop_iterator_operator INT DEFAULT 25;
    DECLARE race_time TIME DEFAULT '06:00:00';

    DECLARE cur_times CURSOR FOR
        SELECT 
            res.id_result,
            res.penalty_time
        FROM results res
        WHERE res.id_race = NEW.id_race
        ORDER BY res.penalty_time DESC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    SELECT
        rac.event_duration INTO race_time
    FROM races rac
    WHERE rac.id_race = NEW.id_race;

    IF(race_time <= '06:00:00') THEN
        SET loop_iterator_operator = loop_iterator_operator * 1;
    ELSEIF(race_time >= '08:00:00' AND race_time <= '10:00:00') THEN
        SET loop_iterator_operator = loop_iterator_operator * 1.5;
    ELSEIF(race_time >= '24:00:00') THEN
        SET loop_iterator_operator = loop_iterator_operator * 2;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Race time is not correct, the points calculation cant proceed';
    END IF;
    
    OPEN cur_times;
    WHILE (done != 1) DO
        FETCH cur_times INTO cur_id_result, cur_time;

        IF(done != 1) THEN
            UPDATE results res SET
                res.base_points_team = loop_iterator_operator,
                res.base_points_pilot = loop_iterator_operator,
                res.penalty_points_team = loop_iterator_operator,
                res.penalty_points_pilot = loop_iterator_operator
            WHERE 
                res.id_race = NEW.id_race AND
                res.id_result = cur_id_result;

            SET loop_iterator_operator = loop_iterator_operator - 1;
        END IF;
    END WHILE;

    CLOSE cur_times;
END//
DELIMITER ;