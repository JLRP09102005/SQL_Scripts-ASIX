USE wec;

DELIMITER //
CREATE TRIGGER trg_apply_result_penalties_insert AFTER INSERT ON penalties_results
FOR EACH ROW
BEGIN
    CALL ProcessResultPenalty(NEW.id_penalty, NEW.id_result);
END //

CREATE TRIGGER trg_apply_result_penalties_update AFTER UPDATE ON penalties_results
FOR EACH ROW
BEGIN
    CALL ProcessResultPenalty(NEW.id_penalty, NEW.id_result);
END //
DELIMITER ;