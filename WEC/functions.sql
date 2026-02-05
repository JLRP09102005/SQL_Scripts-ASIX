-- Active: 1763026326945@@127.0.0.1@3306@WEC
USE WEC;

DELIMITER //

CREATE PROCEDURE MaxLimit ( numToCheck INT, maxNumber INT, customErrorMessage VARCHAR(100) )

COMMENT='Check if the position to insrrt is unique per race'

BEGIN

    IF new_vehicles_num > NEW.max_vehicles THEN
        SIGNAL SQLSTATE '45000'
        IF customErrorMessage IS NULL OR customErrorMessage = '' THEN
            SET MESSAGE_TEXT = 'Number exceed the limit';
        ELSE
            SET MESSAGE_TEXT = customErrorMessage;
        END IF;
    END IF;

END;

DELIMITER ;