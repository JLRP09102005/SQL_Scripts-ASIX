USE wec;

DELIMITER //
CREATE TRIGGER trg_calculate_position_points AFTER INSERT ON results
FOR EACH ROW
BEGIN
    CALL UpdateLeaderPoints(NEW.id_race);
END//
DELIMITER ;