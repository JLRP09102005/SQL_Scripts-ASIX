USE wec;

DELIMITER //

CREATE PROCEDURE IF NOT EXISTS sp_auth_login (IN p_email VARCHAR(100))
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Validates user credentials and returns user data with role'
BEGIN

    DECLARE v_error_message VARCHAR(255) DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        IF NOT v_error_handler = '' THEN
            SIGNAL SQLSTATE '45049' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_email)) THEN
        SET v_error_message = "Error validating sp_auth_login, there are empty or null parameters";
        SIGNAL SQLSTATE '45049';
    END IF;

    IF NOT fn_CheckEmailCorrectFormat(p_email) THEN
        SET v_error_message = "Email with incorrect format";
        SIGNAL SQLSTATE '45049';
    END IF;

    SELECT
        use.id_user,
        use.username,
        use.email,
        use.password_hash,
        use.team_id,
        ur.role_name AS role
    FROM users use
    LEFT JOIN user_userrole uu ON uu.id_user = use.id_user,
    LEFT JOIN user_roles ur ON ur.id_user_roles = uu.id_user_role;

END //

DELIMITER ;