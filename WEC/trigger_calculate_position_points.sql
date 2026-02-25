USE wec;

DELIMITER //
CREATE TRIGGER trg_calculate_position_points AFTER INSERT ON results
FOR EACH ROW
BEGIN
    DECLARE v_done TINYINT(1) DEFAULT 0;
    DECLARE v_cur_id_result INT DEFAULT 0;
    DECLARE v_position TINYINT DEFAULT 1;
    DECLARE v_position_points TINYINT DEFAULT 25;
    DECLARE v_position_points_mult DECIMAL(3,1) DEFAULT 1;
    DECLARE v_points_calc_result TINYINT DEFAULT 0;

    DECLARE cur_times CURSOR FOR
        SELECT 
            res.id_result
        FROM results res
        WHERE res.id_race = NEW.id_race
        ORDER BY res.penalty_time ASC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        IF v_done !=
        CLOSE cur_times;
        RESIGNAL;
    END;

    SELECT GetPositionsPointsMultiplier(NEW.id_race) INTO v_position_points_mult;
    
    OPEN cur_times;
    WHILE (v_done != 1 AND v_position <= 10) DO
        FETCH cur_times INTO v_cur_id_result;
        SELECT GetLeaderboardPointsCalc(v_position, v_position_points, v_position_points_mult) INTO v_points_calc_result;

        IF(v_done != 1) THEN
            CALL AddResultPoints(NEW.id_race, v_cur_id_result, v_points_calc_result);
        END IF;

        SET v_position = v_position + 1;
    END WHILE;

    CLOSE cur_times;
END//
DELIMITER ;