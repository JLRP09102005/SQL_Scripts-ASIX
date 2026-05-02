-- Active: 1763026326945@@127.0.0.1@3306@wec
USE wec;
DELIMITER //

CREATE TRIGGER trg_validate_inscriptions BEFORE INSERT ON inscriptions
FOR EACH ROW
BEGIN

    DECLARE new_vehicles_num TINYINT;
    DECLARE new_pilots_num TINYINT;
    DECLARE mechanics_num TINYINT;

    SET new_vehicles_num = NEW.vehicles_quantity;
    SET mechanics_num = GetTeamMechanicsNumber(NEW.id_team);
    SET new_pilots_num = CountInscriptedPilots(NEW.id_vehicle, NEW.id_team, NEW.id_race);


    IF (NOT UnderMaxLimit(new_vehicles_num, NEW.max_vehicles)) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The vehicles number exceed the maximum allowed';
    END IF;

    IF (NOT UnderMaxLimit(new_pilots_num, NEW.max_pilots)) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The pilots number exceed the maximum allowed';
    END IF;

    IF (NOT UnderMaxLimit(mechanics_num, NEW.max_mechanics)) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The mechanics number exceed the maximum allowed';
    END IF;

END //
DELIMITER ;