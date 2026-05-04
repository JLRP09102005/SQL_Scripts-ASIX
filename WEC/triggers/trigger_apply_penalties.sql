-- Active: 1763026326945@@127.0.0.1@3306@wec
USE wec;
DELIMITER //

CREATE TRIGGER IF NOT EXISTS trg_apply_result_penalties_insert AFTER INSERT ON penalties_results
FOR EACH ROW
BEGIN
    CALL sp_ProcessResultPenalty(NEW.id_penalty, NEW.id_result);
END //

CREATE TRIGGER IF NOT EXISTS trg_apply_result_penalties_update AFTER UPDATE ON penalties_results
FOR EACH ROW
BEGIN
    CALL sp_ProcessResultPenalty(NEW.id_penalty, NEW.id_result);
END //
DELIMITER ;