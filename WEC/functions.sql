-- Active: 1763026326945@@127.0.0.1@3306@WEC
USE WEC;

DELIMITER //

CREATE FUNCTION UnderMaxLimit ( numToCheck INT, maxNumber INT )
RETURNS TINYINT(1)
COMMENT='Check if the position to insrrt is unique per race'
DETERMINISTIC
BEGIN
    RETURN (numToCheck < maxNumber )
END;

DELIMITER ;