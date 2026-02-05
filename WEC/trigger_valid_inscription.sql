--implementar comrpbar maximo de mecanicos

USE wec;

DELIMITER //
CREATE TRIGGER trg_validate_inscriptions BEFORE INSERT ON inscriptions
FOR EACH ROW
BEGIN

    DECLARE new_vehicles_num TINYINT;
    DECLARE new_pilots_num TINYINT;
    DECLARE new_mechanics_num TINYINT;

    SET new_vehicles_num = NEW.vehicles_quantity;

    SELECT
        COUNT(p.id_pilot) INTO new_pilots_num
    FROM pilots_inscriptions pilins
    JOIN pilots p ON p.id_pilot = pilins.id_pilot
    WHERE pilins.id_vehicle = NEW.id_vehicle AND pilins.id_team = NEW.id_team AND pilins.id_race = NEW.id_race;

    SELECT MaxLimit(new_vehicles_num, NEW.max_vehicles, 'The vehicles number exceed the maximum allowed');
    SELECT MaxLimit(new_pilots_num, NEW.max_pilots, 'The pilots number exceed the maximum allowed');

    SELECT

    -- IF new_vehicles_num > NEW.max_vehicles THEN
    --     SIGNAL SQLSTATE '45000'
    --         SET MESSAGE_TEXT = 'The vehicles number exceed the maximum allowed';
    -- END IF;

    -- IF new_pilots_num > NEW.max_pilots THEN
    --     SIGNAL SQLSTATE '45000'
    --         SET MESSAGE_TEXT = 'The pilots number exceed the maximum allowed';
    -- END IF;

END //
DELIMITER ;