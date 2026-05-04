-- Active: 1763026326945@@127.0.0.1@3306@wec
USE wec;
DELIMITER //

CREATE TRIGGER IF NOT EXISTS trg_calculate_position_points AFTER INSERT ON results
FOR EACH ROW
BEGIN
    CALL sp_UpdateLeaderPoints(NEW.id_race);
END//
DELIMITER ;