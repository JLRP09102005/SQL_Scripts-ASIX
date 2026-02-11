USE wec;

DELIMITER //
CREATE TRIGGER trg_apply_result_penalties AFTER INSERT OR UPDATE penalties_results
FOR EACH ROW
BEGIN

    DECLARE penalty_type VARCHAR(20) DEFAULT 'POINTS';
    DECLARE penalty_applies VARCHAR(20) DEFAULT 'PILOT';
    DECLARE penalty_value DECIMAL(6,2) DEFAULT 0;
    DECLARE base_points_team INT DEFAULT 0;
    DECLARE base_points_pilot INT DEFAULT 0;
    DECLARE vehicle_id INT DEFAULT NULL;

    SELECT
        pen.penalty_type INTO penalty_type,
        pen.penalty_applies_to INTO penalty_applies,
        pen.penalty_value INTO penalty_value
    FROM penalties pen
    WHERE pen.id_penalty = NEW.id_penalty;

    SELECT
        res.base_points_team INTO base_points_team,
        res.base_points_pilot INTO base_points_pilot,
        res.id_vehicle INTO vehicle_id
    FROM results res
    WHERE res.id_result = NEW.id_result;

    IF (penalty_applies LIKE 'PILOT')

        IF (penalty_type LIKE 'POINTS')
            UPDATE results res
            SET 
                res.base_points_team = GREATEST(0, base_points_team - FLOOR(penalty_value))
            WHERE res.id_result = NEW.id_result;
        ELSE

        END IF;

    ELSE

    END IF;

END //
DELIMITER ;