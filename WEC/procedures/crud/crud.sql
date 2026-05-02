DELIMITER //

-- =================================================================
-- CIRCUITS
-- =================================================================

CREATE PROCEDURE sp_InsertCircuitData (
    IN p_circuit_name VARCHAR(100),
    IN p_country VARCHAR(50),
    IN p_length_km DECIMAL(3,2),
    IN p_direction CHAR(20),
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Inserts a new circuit record.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_circuit_name, p_country, p_length_km, p_direction)) THEN
        SET v_error_message = 'Parameters cannot be null or empty';
        SIGNAL SQLSTATE '45001';
    END IF;

    IF NOT fn_CircuitCorrectLength(p_length_km) THEN
        SET v_error_message = 'Circuit length out of valid range (3.5 - 15000 km)';
        SIGNAL SQLSTATE '45001';
    END IF;

    IF NOT fn_ValidateCircuitDirection(p_direction) THEN
        SET v_error_message = 'Direction must be CLOCKWISE or COUNTERCLOCKWISE';
        SIGNAL SQLSTATE '45001';
    END IF;

    IF fn_GetAnyCircuitRegistryByName(p_circuit_name) THEN
        SET v_error_message = 'Circuit name already exists';
        SIGNAL SQLSTATE '45001';
    END IF;

    START TRANSACTION;
    INSERT INTO circuits (circuit_name, country, length_km, direction)
    VALUES (p_circuit_name, p_country, p_length_km, p_direction);
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Insert failed, no rows affected';
        SIGNAL SQLSTATE '45001';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

CREATE PROCEDURE sp_UpdateCircuitData (
    IN p_circuit_id INT,
    IN p_circuit_name VARCHAR(100),
    IN p_country VARCHAR(50),
    IN p_length_km DECIMAL(3,2),
    IN p_direction CHAR(20),
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Updates an existing circuit record.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45012' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_circuit_id, p_circuit_name, p_country, p_length_km, p_direction)) THEN
        SET v_error_message = 'Parameters cannot be null or empty';
        SIGNAL SQLSTATE '45012';
    END IF;

    IF NOT fn_CircuitCorrectLength(p_length_km) THEN
        SET v_error_message = 'Circuit length out of valid range';
        SIGNAL SQLSTATE '45012';
    END IF;

    IF NOT fn_ValidateCircuitDirection(p_direction) THEN
        SET v_error_message = 'Direction must be CLOCKWISE or COUNTERCLOCKWISE';
        SIGNAL SQLSTATE '45012';
    END IF;

    IF NOT fn_GetAnyCircuitRegistryById(p_circuit_id) THEN
        SET v_error_message = 'Circuit ID does not exist';
        SIGNAL SQLSTATE '45012';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyCircuitRegistryByNameExcludingId(p_circuit_name, p_circuit_id)
    IF EXISTS (SELECT 1 FROM circuits WHERE circuit_name = p_circuit_name AND id_circuit != p_circuit_id) THEN
        SET v_error_message = 'Another circuit with this name already exists';
        SIGNAL SQLSTATE '45012';
    END IF;

    START TRANSACTION;
    UPDATE circuits
    SET circuit_name = p_circuit_name,
        country = p_country,
        length_km = p_length_km,
        direction = p_direction
    WHERE id_circuit = p_circuit_id;
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Update failed, no rows affected';
        SIGNAL SQLSTATE '45012';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

CREATE PROCEDURE sp_DeleteCircuitData (
    IN p_circuit_id INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Deletes a circuit record after checking dependencies.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45013' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_circuit_id)) THEN
        SET v_error_message = 'Circuit ID cannot be null';
        SIGNAL SQLSTATE '45013';
    END IF;

    IF NOT fn_GetAnyCircuitRegistryById(p_circuit_id) THEN
        SET v_error_message = 'Circuit ID does not exist';
        SIGNAL SQLSTATE '45013';
    END IF;

    IF fn_CheckForExtraDependences('circuits', p_circuit_id) THEN
        SET v_error_message = 'Cannot delete circuit because it has dependent records';
        SIGNAL SQLSTATE '45013';
    END IF;

    START TRANSACTION;
    DELETE FROM circuits WHERE id_circuit = p_circuit_id;
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Delete failed, no rows affected';
        SIGNAL SQLSTATE '45013';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

-- =================================================================
-- MANUFACTURERS
-- =================================================================

CREATE PROCEDURE sp_InsertManufacturerData (
    IN p_manufacturer_name VARCHAR(100),
    IN p_manufacturer_country VARCHAR(50),
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Inserts a new manufacturer.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_manufacturer_name, p_manufacturer_country)) THEN
        SET v_error_message = 'Parameters cannot be null or empty';
        SIGNAL SQLSTATE '45003';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyManufacturerByName(p_manufacturer_name)
    IF EXISTS (SELECT 1 FROM manufacturers WHERE manufacturer_name = p_manufacturer_name) THEN
        SET v_error_message = 'Manufacturer name already exists';
        SIGNAL SQLSTATE '45003';
    END IF;

    START TRANSACTION;
    INSERT INTO manufacturers (manufacturer_name, manufacturer_country)
    VALUES (p_manufacturer_name, p_manufacturer_country);
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Insert failed';
        SIGNAL SQLSTATE '45003';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

CREATE PROCEDURE sp_UpdateManufacturerData (
    IN p_id_manufacturer INT,
    IN p_manufacturer_name VARCHAR(100),
    IN p_manufacturer_country VARCHAR(50),
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Updates an existing manufacturer.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45016' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_manufacturer, p_manufacturer_name, p_manufacturer_country)) THEN
        SET v_error_message = 'Parameters cannot be null or empty';
        SIGNAL SQLSTATE '45016';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyManufacturerById(p_id_manufacturer)
    IF NOT EXISTS (SELECT 1 FROM manufacturers WHERE id_manufacturer = p_id_manufacturer) THEN
        SET v_error_message = 'Manufacturer ID does not exist';
        SIGNAL SQLSTATE '45016';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyManufacturerByNameExcludingId(p_manufacturer_name, p_id_manufacturer)
    IF EXISTS (SELECT 1 FROM manufacturers WHERE manufacturer_name = p_manufacturer_name AND id_manufacturer != p_id_manufacturer) THEN
        SET v_error_message = 'Another manufacturer with this name already exists';
        SIGNAL SQLSTATE '45016';
    END IF;

    START TRANSACTION;
    UPDATE manufacturers
    SET manufacturer_name = p_manufacturer_name,
        manufacturer_country = p_manufacturer_country
    WHERE id_manufacturer = p_id_manufacturer;
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Update failed';
        SIGNAL SQLSTATE '45016';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

CREATE PROCEDURE sp_DeleteManufacturerData (
    IN p_id_manufacturer INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Deletes a manufacturer if not referenced by any team.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45017' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_manufacturer)) THEN
        SET v_error_message = 'Manufacturer ID cannot be null';
        SIGNAL SQLSTATE '45017';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyManufacturerById(p_id_manufacturer)
    IF NOT EXISTS (SELECT 1 FROM manufacturers WHERE id_manufacturer = p_id_manufacturer) THEN
        SET v_error_message = 'Manufacturer ID does not exist';
        SIGNAL SQLSTATE '45017';
    END IF;

    IF fn_CheckForExtraDependences('manufacturers', p_id_manufacturer) THEN
        SET v_error_message = 'Cannot delete manufacturer because it has dependent records';
        SIGNAL SQLSTATE '45017';
    END IF;

    START TRANSACTION;
    DELETE FROM manufacturers WHERE id_manufacturer = p_id_manufacturer;
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Delete failed';
        SIGNAL SQLSTATE '45017';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

-- =================================================================
-- PILOT CATEGORIES
-- =================================================================

CREATE PROCEDURE sp_InsertPilotCategoriesData (
    IN p_pilot_category_name VARCHAR(50),
    IN p_pilot_category_description VARCHAR(100),
    IN p_min_age TINYINT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Inserts a new pilot category.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45005' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_pilot_category_name, p_pilot_category_description, p_min_age)) THEN
        SET v_error_message = 'Parameters cannot be null or empty';
        SIGNAL SQLSTATE '45005';
    END IF;

    IF p_min_age < 0 OR p_min_age > 120 THEN
        SET v_error_message = 'Minimum age out of range';
        SIGNAL SQLSTATE '45005';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyPilotCategoryByName(p_pilot_category_name)
    IF EXISTS (SELECT 1 FROM pilot_categories WHERE pilot_category_name = p_pilot_category_name) THEN
        SET v_error_message = 'Category name already exists';
        SIGNAL SQLSTATE '45005';
    END IF;

    START TRANSACTION;
    INSERT INTO pilot_categories (pilot_category_name, pilot_category_description, min_age)
    VALUES (p_pilot_category_name, p_pilot_category_description, p_min_age);
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Insert failed';
        SIGNAL SQLSTATE '45005';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

CREATE PROCEDURE sp_UpdatePilotCategoriesData (
    IN p_id_pilot_category INT,
    IN p_pilot_category_name VARCHAR(50),
    IN p_pilot_category_description VARCHAR(100),
    IN p_min_age TINYINT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Updates an existing pilot category.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45020' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_pilot_category, p_pilot_category_name, p_pilot_category_description, p_min_age)) THEN
        SET v_error_message = 'Parameters cannot be null or empty';
        SIGNAL SQLSTATE '45020';
    END IF;

    IF p_min_age < 0 OR p_min_age > 120 THEN
        SET v_error_message = 'Minimum age out of range';
        SIGNAL SQLSTATE '45020';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyPilotCategoryById(p_id_pilot_category)
    IF NOT EXISTS (SELECT 1 FROM pilot_categories WHERE id_pilot_category = p_id_pilot_category) THEN
        SET v_error_message = 'Category ID does not exist';
        SIGNAL SQLSTATE '45020';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyPilotCategoryByNameExcludingId(p_pilot_category_name, p_id_pilot_category)
    IF EXISTS (SELECT 1 FROM pilot_categories WHERE pilot_category_name = p_pilot_category_name AND id_pilot_category != p_id_pilot_category) THEN
        SET v_error_message = 'Another category with this name already exists';
        SIGNAL SQLSTATE '45020';
    END IF;

    START TRANSACTION;
    UPDATE pilot_categories
    SET pilot_category_name = p_pilot_category_name,
        pilot_category_description = p_pilot_category_description,
        min_age = p_min_age
    WHERE id_pilot_category = p_id_pilot_category;
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Update failed';
        SIGNAL SQLSTATE '45020';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

CREATE PROCEDURE sp_DeletePilotCategoriesData (
    IN p_id_pilot_category INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Deletes a pilot category if no pilot uses it.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45021' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_pilot_category)) THEN
        SET v_error_message = 'Category ID cannot be null';
        SIGNAL SQLSTATE '45021';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyPilotCategoryById(p_id_pilot_category)
    IF NOT EXISTS (SELECT 1 FROM pilot_categories WHERE id_pilot_category = p_id_pilot_category) THEN
        SET v_error_message = 'Category ID does not exist';
        SIGNAL SQLSTATE '45021';
    END IF;

    IF fn_CheckForExtraDependences('pilot_categories', p_id_pilot_category) THEN
        SET v_error_message = 'Cannot delete category because it has dependent records';
        SIGNAL SQLSTATE '45021';
    END IF;

    START TRANSACTION;
    DELETE FROM pilot_categories WHERE id_pilot_category = p_id_pilot_category;
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Delete failed';
        SIGNAL SQLSTATE '45021';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

-- =================================================================
-- PILOTS
-- =================================================================

CREATE PROCEDURE sp_InsertPilotData (
    IN p_pilot_name VARCHAR(100),
    IN p_pilot_age TINYINT,
    IN p_id_pilot_category INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Inserts a new pilot, validating age against category minimum.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;
    DECLARE v_min_age TINYINT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45006' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_pilot_name, p_pilot_age, p_id_pilot_category)) THEN
        SET v_error_message = 'Parameters cannot be null or empty';
        SIGNAL SQLSTATE '45006';
    END IF;

    IF p_pilot_age < 18 OR p_pilot_age > 99 THEN
        SET v_error_message = 'Pilot age out of valid range (18-99)';
        SIGNAL SQLSTATE '45006';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetPilotCategoryMinAge(p_id_pilot_category)
    SELECT min_age INTO v_min_age FROM pilot_categories WHERE id_pilot_category = p_id_pilot_category;
    IF v_min_age IS NULL THEN
        SET v_error_message = 'Pilot category ID does not exist';
        SIGNAL SQLSTATE '45006';
    END IF;

    IF p_pilot_age < v_min_age THEN
        SET v_error_message = CONCAT('Pilot age does not meet minimum age of ', v_min_age, ' for this category');
        SIGNAL SQLSTATE '45006';
    END IF;

    START TRANSACTION;
    INSERT INTO pilots (pilot_name, pilot_age, id_pilot_category)
    VALUES (p_pilot_name, p_pilot_age, p_id_pilot_category);
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Insert failed';
        SIGNAL SQLSTATE '45006';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

CREATE PROCEDURE sp_UpdatePilotData (
    IN p_id_pilot INT,
    IN p_pilot_name VARCHAR(100),
    IN p_pilot_age TINYINT,
    IN p_id_pilot_category INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Updates an existing pilot.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;
    DECLARE v_min_age TINYINT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45022' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_pilot, p_pilot_name, p_pilot_age, p_id_pilot_category)) THEN
        SET v_error_message = 'Parameters cannot be null or empty';
        SIGNAL SQLSTATE '45022';
    END IF;

    IF p_pilot_age < 18 OR p_pilot_age > 99 THEN
        SET v_error_message = 'Pilot age out of valid range';
        SIGNAL SQLSTATE '45022';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyPilotById(p_id_pilot)
    IF NOT EXISTS (SELECT 1 FROM pilots WHERE id_pilot = p_id_pilot) THEN
        SET v_error_message = 'Pilot ID does not exist';
        SIGNAL SQLSTATE '45022';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetPilotCategoryMinAge(p_id_pilot_category)
    SELECT min_age INTO v_min_age FROM pilot_categories WHERE id_pilot_category = p_id_pilot_category;
    IF v_min_age IS NULL THEN
        SET v_error_message = 'Pilot category ID does not exist';
        SIGNAL SQLSTATE '45022';
    END IF;

    IF p_pilot_age < v_min_age THEN
        SET v_error_message = CONCAT('Pilot age does not meet minimum age of ', v_min_age);
        SIGNAL SQLSTATE '45022';
    END IF;

    START TRANSACTION;
    UPDATE pilots
    SET pilot_name = p_pilot_name,
        pilot_age = p_pilot_age,
        id_pilot_category = p_id_pilot_category
    WHERE id_pilot = p_id_pilot;
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Update failed';
        SIGNAL SQLSTATE '45022';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

CREATE PROCEDURE sp_DeletePilotData (
    IN p_id_pilot INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Deletes a pilot if not referenced in inscriptions or penalties.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45023' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_pilot)) THEN
        SET v_error_message = 'Pilot ID cannot be null';
        SIGNAL SQLSTATE '45023';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyPilotById(p_id_pilot)
    IF NOT EXISTS (SELECT 1 FROM pilots WHERE id_pilot = p_id_pilot) THEN
        SET v_error_message = 'Pilot ID does not exist';
        SIGNAL SQLSTATE '45023';
    END IF;

    IF fn_CheckForExtraDependences('pilots', p_id_pilot) THEN
        SET v_error_message = 'Cannot delete pilot because it has dependent records';
        SIGNAL SQLSTATE '45023';
    END IF;

    START TRANSACTION;
    DELETE FROM pilots WHERE id_pilot = p_id_pilot;
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Delete failed';
        SIGNAL SQLSTATE '45023';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

-- =================================================================
-- TEAMS
-- =================================================================

CREATE PROCEDURE sp_InsertTeamData (
    IN p_team_name VARCHAR(100),
    IN p_mechanic_num TINYINT,
    IN p_id_manufacturer INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Inserts a new team.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45010' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_team_name, p_mechanic_num, p_id_manufacturer)) THEN
        SET v_error_message = 'Parameters cannot be null or empty';
        SIGNAL SQLSTATE '45010';
    END IF;

    IF p_mechanic_num < 1 OR p_mechanic_num > 20 THEN
        SET v_error_message = 'Number of mechanics out of range (1-20)';
        SIGNAL SQLSTATE '45010';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyTeamByName(p_team_name)
    IF EXISTS (SELECT 1 FROM teams WHERE team_name = p_team_name) THEN
        SET v_error_message = 'Team name already exists';
        SIGNAL SQLSTATE '45010';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyManufacturerById(p_id_manufacturer)
    IF NOT EXISTS (SELECT 1 FROM manufacturers WHERE id_manufacturer = p_id_manufacturer) THEN
        SET v_error_message = 'Manufacturer ID does not exist';
        SIGNAL SQLSTATE '45010';
    END IF;

    START TRANSACTION;
    INSERT INTO teams (team_name, mechanics_num, id_manufacturer)
    VALUES (p_team_name, p_mechanic_num, p_id_manufacturer);
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Insert failed';
        SIGNAL SQLSTATE '45010';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

CREATE PROCEDURE sp_UpdateTeamData (
    IN p_id_team INT,
    IN p_team_name VARCHAR(100),
    IN p_mechanic_num TINYINT,
    IN p_id_manufacturer INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Updates an existing team.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45030' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_team, p_team_name, p_mechanic_num, p_id_manufacturer)) THEN
        SET v_error_message = 'Parameters cannot be null or empty';
        SIGNAL SQLSTATE '45030';
    END IF;

    IF p_mechanic_num < 1 OR p_mechanic_num > 20 THEN
        SET v_error_message = 'Number of mechanics out of range';
        SIGNAL SQLSTATE '45030';
    END IF;

    IF NOT fn_IdRegisterExistsFromTeams(p_id_team) THEN
        SET v_error_message = 'Team ID does not exist';
        SIGNAL SQLSTATE '45030';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyTeamByNameExcludingId(p_team_name, p_id_team)
    IF EXISTS (SELECT 1 FROM teams WHERE team_name = p_team_name AND id_team != p_id_team) THEN
        SET v_error_message = 'Another team with this name already exists';
        SIGNAL SQLSTATE '45030';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyManufacturerById(p_id_manufacturer)
    IF NOT EXISTS (SELECT 1 FROM manufacturers WHERE id_manufacturer = p_id_manufacturer) THEN
        SET v_error_message = 'Manufacturer ID does not exist';
        SIGNAL SQLSTATE '45030';
    END IF;

    START TRANSACTION;
    UPDATE teams
    SET team_name = p_team_name,
        mechanics_num = p_mechanic_num,
        id_manufacturer = p_id_manufacturer
    WHERE id_team = p_id_team;
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Update failed';
        SIGNAL SQLSTATE '45030';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

CREATE PROCEDURE sp_DeleteTeamData (
    IN p_id_team INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Deletes a team if not referenced in inscriptions, results, or users.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45031' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_team)) THEN
        SET v_error_message = 'Team ID cannot be null';
        SIGNAL SQLSTATE '45031';
    END IF;

    IF NOT fn_IdRegisterExistsFromTeams(p_id_team) THEN
        SET v_error_message = 'Team ID does not exist';
        SIGNAL SQLSTATE '45031';
    END IF;

    IF fn_CheckForExtraDependences('teams', p_id_team) THEN
        SET v_error_message = 'Cannot delete team because it has dependent records';
        SIGNAL SQLSTATE '45031';
    END IF;

    START TRANSACTION;
    DELETE FROM teams WHERE id_team = p_id_team;
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Delete failed';
        SIGNAL SQLSTATE '45031';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

-- =================================================================
-- VEHICLES
-- =================================================================

CREATE PROCEDURE sp_InsertVehicleData (
    IN p_model VARCHAR(100),
    IN p_specifications_url VARCHAR(1024),
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Inserts a new vehicle.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45011' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_model, p_specifications_url)) THEN
        SET v_error_message = 'Parameters cannot be null or empty';
        SIGNAL SQLSTATE '45011';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyVehicleByModel(p_model)
    IF EXISTS (SELECT 1 FROM vehicles WHERE model = p_model) THEN
        SET v_error_message = 'Vehicle model already exists';
        SIGNAL SQLSTATE '45011';
    END IF;

    IF p_specifications_url NOT LIKE 'http%' THEN
        SET v_error_message = 'Specifications URL must start with http:// or https://';
        SIGNAL SQLSTATE '45011';
    END IF;

    START TRANSACTION;
    INSERT INTO vehicles (model, specifications_url)
    VALUES (p_model, p_specifications_url);
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Insert failed';
        SIGNAL SQLSTATE '45011';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

CREATE PROCEDURE sp_UpdateVehicleData (
    IN p_id_vehicle INT,
    IN p_model VARCHAR(100),
    IN p_specifications_url VARCHAR(1024),
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Updates an existing vehicle.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45032' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_vehicle, p_model, p_specifications_url)) THEN
        SET v_error_message = 'Parameters cannot be null or empty';
        SIGNAL SQLSTATE '45032';
    END IF;

    IF NOT fn_IdRegisterExistsFromVehicles(p_id_vehicle) THEN
        SET v_error_message = 'Vehicle ID does not exist';
        SIGNAL SQLSTATE '45032';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyVehicleByModelExcludingId(p_model, p_id_vehicle)
    IF EXISTS (SELECT 1 FROM vehicles WHERE model = p_model AND id_vehicle != p_id_vehicle) THEN
        SET v_error_message = 'Another vehicle with this model already exists';
        SIGNAL SQLSTATE '45032';
    END IF;

    IF p_specifications_url NOT LIKE 'http%' THEN
        SET v_error_message = 'Specifications URL must start with http:// or https://';
        SIGNAL SQLSTATE '45032';
    END IF;

    START TRANSACTION;
    UPDATE vehicles
    SET model = p_model,
        specifications_url = p_specifications_url
    WHERE id_vehicle = p_id_vehicle;
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Update failed';
        SIGNAL SQLSTATE '45032';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

CREATE PROCEDURE sp_DeleteVehicleData (
    IN p_id_vehicle INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Deletes a vehicle if not referenced in inscriptions or results.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45033' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_vehicle)) THEN
        SET v_error_message = 'Vehicle ID cannot be null';
        SIGNAL SQLSTATE '45033';
    END IF;

    IF NOT fn_IdRegisterExistsFromVehicles(p_id_vehicle) THEN
        SET v_error_message = 'Vehicle ID does not exist';
        SIGNAL SQLSTATE '45033';
    END IF;

    IF fn_CheckForExtraDependences('vehicles', p_id_vehicle) THEN
        SET v_error_message = 'Cannot delete vehicle because it has dependent records';
        SIGNAL SQLSTATE '45033';
    END IF;

    START TRANSACTION;
    DELETE FROM vehicles WHERE id_vehicle = p_id_vehicle;
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Delete failed';
        SIGNAL SQLSTATE '45033';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

-- =================================================================
-- RACES
-- =================================================================

CREATE PROCEDURE sp_InsertRaceData (
    IN p_event_name VARCHAR(100),
    IN p_event_date DATETIME,
    IN p_event_duration TIME,
    IN p_id_circuit INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Inserts a new race.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45008' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_event_name, p_event_date, p_event_duration, p_id_circuit)) THEN
        SET v_error_message = 'Parameters cannot be null or empty';
        SIGNAL SQLSTATE '45008';
    END IF;

    IF p_event_date < NOW() THEN
        SET v_error_message = 'Event date cannot be in the past';
        SIGNAL SQLSTATE '45008';
    END IF;

    IF p_event_duration < '01:00:00' THEN
        SET v_error_message = 'Event duration must be at least 1 hour';
        SIGNAL SQLSTATE '45008';
    END IF;

    IF NOT fn_GetAnyCircuitRegistryById(p_id_circuit) THEN
        SET v_error_message = 'Circuit ID does not exist';
        SIGNAL SQLSTATE '45008';
    END IF;

    START TRANSACTION;
    INSERT INTO races (event_name, event_date, event_duration, id_circuit)
    VALUES (p_event_name, p_event_date, p_event_duration, p_id_circuit);
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Insert failed';
        SIGNAL SQLSTATE '45008';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

CREATE PROCEDURE sp_UpdateRaceData (
    IN p_id_race INT,
    IN p_event_name VARCHAR(100),
    IN p_event_date DATETIME,
    IN p_event_duration TIME,
    IN p_id_circuit INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Updates an existing race.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45026' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_race, p_event_name, p_event_date, p_event_duration, p_id_circuit)) THEN
        SET v_error_message = 'Parameters cannot be null or empty';
        SIGNAL SQLSTATE '45026';
    END IF;

    IF p_event_date < NOW() THEN
        SET v_error_message = 'Event date cannot be in the past';
        SIGNAL SQLSTATE '45026';
    END IF;

    IF p_event_duration < '01:00:00' THEN
        SET v_error_message = 'Event duration must be at least 1 hour';
        SIGNAL SQLSTATE '45026';
    END IF;

    IF NOT fn_IdRegisteredFromRaces(p_id_race) THEN
        SET v_error_message = 'Race ID does not exist';
        SIGNAL SQLSTATE '45026';
    END IF;

    IF NOT fn_GetAnyCircuitRegistryById(p_id_circuit) THEN
        SET v_error_message = 'Circuit ID does not exist';
        SIGNAL SQLSTATE '45026';
    END IF;

    START TRANSACTION;
    UPDATE races
    SET event_name = p_event_name,
        event_date = p_event_date,
        event_duration = p_event_duration,
        id_circuit = p_id_circuit
    WHERE id_race = p_id_race;
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Update failed';
        SIGNAL SQLSTATE '45026';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

CREATE PROCEDURE sp_DeleteRaceData (
    IN p_id_race INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Deletes a race if no inscriptions or results exist.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45027' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_race)) THEN
        SET v_error_message = 'Race ID cannot be null';
        SIGNAL SQLSTATE '45027';
    END IF;

    IF NOT fn_IdRegisteredFromRaces(p_id_race) THEN
        SET v_error_message = 'Race ID does not exist';
        SIGNAL SQLSTATE '45027';
    END IF;

    IF fn_CheckForExtraDependences('races', p_id_race) THEN
        SET v_error_message = 'Cannot delete race because it has dependent records';
        SIGNAL SQLSTATE '45027';
    END IF;

    START TRANSACTION;
    DELETE FROM races WHERE id_race = p_id_race;
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Delete failed';
        SIGNAL SQLSTATE '45027';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

-- =================================================================
-- INSCRIPTIONS (Composite PK)
-- =================================================================

CREATE PROCEDURE sp_InsertInscriptionData (
    IN p_id_vehicle INT,
    IN p_id_race INT,
    IN p_id_team INT,
    IN p_vehicles_quantity TINYINT,
    IN p_registered_at TIMESTAMP,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Inserts a new inscription record.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_vehicle, p_id_race, p_id_team, p_vehicles_quantity, p_registered_at)) THEN
        SET v_error_message = 'Parameters cannot be null or empty';
        SIGNAL SQLSTATE '45002';
    END IF;

    IF NOT fn_CheckInscriptionData(p_vehicles_quantity, p_registered_at) THEN
        SET v_error_message = 'Inscription data invalid: vehicles_quantity must be 2 and registered_at within last day';
        SIGNAL SQLSTATE '45002';
    END IF;

    IF NOT fn_IdRegisterExistsFromVehicles(p_id_vehicle) THEN
        SET v_error_message = 'Vehicle ID does not exist';
        SIGNAL SQLSTATE '45002';
    END IF;

    IF NOT fn_IdRegisteredFromRaces(p_id_race) THEN
        SET v_error_message = 'Race ID does not exist';
        SIGNAL SQLSTATE '45002';
    END IF;

    IF NOT fn_IdRegisterExistsFromTeams(p_id_team) THEN
        SET v_error_message = 'Team ID does not exist';
        SIGNAL SQLSTATE '45002';
    END IF;

    IF fn_IdRegisteredFromInscriptions(p_id_vehicle, p_id_race, p_id_team) THEN
        SET v_error_message = 'Inscription already exists';
        SIGNAL SQLSTATE '45002';
    END IF;

    START TRANSACTION;
    INSERT INTO inscriptions (id_vehicle, id_race, id_team, vehicles_quantity, registered_at, max_vehicles, max_pilots, max_mechanics)
    VALUES (p_id_vehicle, p_id_race, p_id_team, p_vehicles_quantity, p_registered_at, 2, 3, 6);
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Insert failed';
        SIGNAL SQLSTATE '45002';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

CREATE PROCEDURE sp_UpdateInscriptionData (
    IN p_id_vehicle_old INT,
    IN p_id_race_old INT,
    IN p_id_team_old INT,
    IN p_new_id_vehicle INT,
    IN p_new_id_race INT,
    IN p_new_id_team INT,
    IN p_vehicles_quantity TINYINT,
    IN p_registered_at TIMESTAMP,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Updates an existing inscription.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45014' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_vehicle_old, p_id_race_old, p_id_team_old, p_new_id_vehicle, p_new_id_race, p_new_id_team, p_vehicles_quantity, p_registered_at)) THEN
        SET v_error_message = 'Parameters cannot be null or empty';
        SIGNAL SQLSTATE '45014';
    END IF;

    IF NOT fn_CheckInscriptionData(p_vehicles_quantity, p_registered_at) THEN
        SET v_error_message = 'Inscription data invalid';
        SIGNAL SQLSTATE '45014';
    END IF;

    IF NOT fn_IdRegisteredFromInscriptions(p_id_vehicle_old, p_id_race_old, p_id_team_old) THEN
        SET v_error_message = 'Original inscription does not exist';
        SIGNAL SQLSTATE '45014';
    END IF;

    IF NOT fn_IdRegisterExistsFromVehicles(p_new_id_vehicle) THEN
        SET v_error_message = 'New vehicle ID does not exist';
        SIGNAL SQLSTATE '45014';
    END IF;

    IF NOT fn_IdRegisteredFromRaces(p_new_id_race) THEN
        SET v_error_message = 'New race ID does not exist';
        SIGNAL SQLSTATE '45014';
    END IF;

    IF NOT fn_IdRegisterExistsFromTeams(p_new_id_team) THEN
        SET v_error_message = 'New team ID does not exist';
        SIGNAL SQLSTATE '45014';
    END IF;

    -- Check that new combination does not already exist (if different)
    IF (p_id_vehicle_old != p_new_id_vehicle OR p_id_race_old != p_new_id_race OR p_id_team_old != p_new_id_team) AND
       fn_IdRegisteredFromInscriptions(p_new_id_vehicle, p_new_id_race, p_new_id_team) THEN
        SET v_error_message = 'New inscription combination already exists';
        SIGNAL SQLSTATE '45014';
    END IF;

    START TRANSACTION;
    UPDATE inscriptions
    SET id_vehicle = p_new_id_vehicle,
        id_race = p_new_id_race,
        id_team = p_new_id_team,
        vehicles_quantity = p_vehicles_quantity,
        registered_at = p_registered_at
    WHERE id_vehicle = p_id_vehicle_old
      AND id_race = p_id_race_old
      AND id_team = p_id_team_old;
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Update failed';
        SIGNAL SQLSTATE '45014';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

CREATE PROCEDURE sp_DeleteInscriptionData (
    IN p_id_vehicle INT,
    IN p_id_race INT,
    IN p_id_team INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Deletes an inscription if no dependent records exist.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45015' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_vehicle, p_id_race, p_id_team)) THEN
        SET v_error_message = 'Parameters cannot be null';
        SIGNAL SQLSTATE '45015';
    END IF;

    IF NOT fn_IdRegisteredFromInscriptions(p_id_vehicle, p_id_race, p_id_team) THEN
        SET v_error_message = 'Inscription does not exist';
        SIGNAL SQLSTATE '45015';
    END IF;

    IF fn_CheckForExtraDependences('inscriptions', p_id_vehicle) THEN
        SET v_error_message = 'Cannot delete inscription because it has dependent records';
        SIGNAL SQLSTATE '45015';
    END IF;

    START TRANSACTION;
    DELETE FROM inscriptions
    WHERE id_vehicle = p_id_vehicle AND id_race = p_id_race AND id_team = p_id_team;
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Delete failed';
        SIGNAL SQLSTATE '45015';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

-- =================================================================
-- PILOTS INSCRIPTIONS
-- =================================================================

CREATE PROCEDURE sp_InsertPilotInscriptionData (
    IN p_id_pilot INT,
    IN p_id_vehicle INT,
    IN p_id_race INT,
    IN p_id_team INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Inserts a pilot inscription.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45007' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_pilot, p_id_vehicle, p_id_race, p_id_team)) THEN
        SET v_error_message = 'Parameters cannot be null or empty';
        SIGNAL SQLSTATE '45007';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyPilotById(p_id_pilot)
    IF NOT EXISTS (SELECT 1 FROM pilots WHERE id_pilot = p_id_pilot) THEN
        SET v_error_message = 'Pilot ID does not exist';
        SIGNAL SQLSTATE '45007';
    END IF;

    IF NOT fn_IdRegisteredFromInscriptions(p_id_vehicle, p_id_race, p_id_team) THEN
        SET v_error_message = 'Inscription (vehicle, race, team) does not exist';
        SIGNAL SQLSTATE '45007';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyPilotInscription(p_id_pilot, p_id_vehicle, p_id_race, p_id_team)
    IF EXISTS (SELECT 1 FROM pilots_inscriptions WHERE id_pilot = p_id_pilot AND id_vehicle = p_id_vehicle AND id_race = p_id_race AND id_team = p_id_team) THEN
        SET v_error_message = 'Pilot already inscribed for this combination';
        SIGNAL SQLSTATE '45007';
    END IF;

    START TRANSACTION;
    INSERT INTO pilots_inscriptions (id_pilot, id_vehicle, id_race, id_team)
    VALUES (p_id_pilot, p_id_vehicle, p_id_race, p_id_team);
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Insert failed';
        SIGNAL SQLSTATE '45007';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

CREATE PROCEDURE sp_UpdatePilotInscriptionData (
    IN p_old_id_pilot INT,
    IN p_id_vehicle INT,
    IN p_id_race INT,
    IN p_id_team INT,
    IN p_new_id_pilot INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Updates a pilot inscription (changing the pilot).'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45024' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_old_id_pilot, p_id_vehicle, p_id_race, p_id_team, p_new_id_pilot)) THEN
        SET v_error_message = 'Parameters cannot be null or empty';
        SIGNAL SQLSTATE '45024';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyPilotInscription(p_old_id_pilot, p_id_vehicle, p_id_race, p_id_team)
    IF NOT EXISTS (SELECT 1 FROM pilots_inscriptions WHERE id_pilot = p_old_id_pilot AND id_vehicle = p_id_vehicle AND id_race = p_id_race AND id_team = p_id_team) THEN
        SET v_error_message = 'Original pilot inscription does not exist';
        SIGNAL SQLSTATE '45024';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyPilotById(p_new_id_pilot)
    IF NOT EXISTS (SELECT 1 FROM pilots WHERE id_pilot = p_new_id_pilot) THEN
        SET v_error_message = 'New pilot ID does not exist';
        SIGNAL SQLSTATE '45024';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyPilotInscription(p_new_id_pilot, p_id_vehicle, p_id_race, p_id_team)
    IF EXISTS (SELECT 1 FROM pilots_inscriptions WHERE id_pilot = p_new_id_pilot AND id_vehicle = p_id_vehicle AND id_race = p_id_race AND id_team = p_id_team) THEN
        SET v_error_message = 'New pilot inscription already exists';
        SIGNAL SQLSTATE '45024';
    END IF;

    START TRANSACTION;
    UPDATE pilots_inscriptions
    SET id_pilot = p_new_id_pilot
    WHERE id_pilot = p_old_id_pilot
      AND id_vehicle = p_id_vehicle
      AND id_race = p_id_race
      AND id_team = p_id_team;
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Update failed';
        SIGNAL SQLSTATE '45024';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

CREATE PROCEDURE sp_DeletePilotInscriptionData (
    IN p_id_pilot INT,
    IN p_id_vehicle INT,
    IN p_id_race INT,
    IN p_id_team INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Deletes a pilot inscription.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45025' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_pilot, p_id_vehicle, p_id_race, p_id_team)) THEN
        SET v_error_message = 'Parameters cannot be null';
        SIGNAL SQLSTATE '45025';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyPilotInscription(p_id_pilot, p_id_vehicle, p_id_race, p_id_team)
    IF NOT EXISTS (SELECT 1 FROM pilots_inscriptions WHERE id_pilot = p_id_pilot AND id_vehicle = p_id_vehicle AND id_race = p_id_race AND id_team = p_id_team) THEN
        SET v_error_message = 'Pilot inscription does not exist';
        SIGNAL SQLSTATE '45025';
    END IF;

    START TRANSACTION;
    DELETE FROM pilots_inscriptions
    WHERE id_pilot = p_id_pilot
      AND id_vehicle = p_id_vehicle
      AND id_race = p_id_race
      AND id_team = p_id_team;
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Delete failed';
        SIGNAL SQLSTATE '45025';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

-- =================================================================
-- RESULTS
-- =================================================================

CREATE PROCEDURE sp_InsertResultData (
    IN p_position INT,
    IN p_final_time TIME,
    IN p_penalty_time TIME,
    IN p_base_points_team INT,
    IN p_base_points_pilot INT,
    IN p_penalty_points_team INT,
    IN p_penalty_points_pilot INT,
    IN p_id_vehicle INT,
    IN p_id_race INT,
    IN p_id_team INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Inserts a race result.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45009' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_position, p_final_time, p_penalty_time, p_base_points_team, p_base_points_pilot, p_penalty_points_team, p_penalty_points_pilot, p_id_vehicle, p_id_race, p_id_team)) THEN
        SET v_error_message = 'Parameters cannot be null';
        SIGNAL SQLSTATE '45009';
    END IF;

    IF p_position < 1 OR p_position > 60 THEN
        SET v_error_message = 'Position must be between 1 and 60';
        SIGNAL SQLSTATE '45009';
    END IF;

    IF p_final_time = '00:00:00' THEN
        SET v_error_message = 'Final time cannot be zero';
        SIGNAL SQLSTATE '45009';
    END IF;

    IF p_base_points_team < 0 OR p_base_points_pilot < 0 OR p_penalty_points_team < 0 OR p_penalty_points_pilot < 0 THEN
        SET v_error_message = 'Points cannot be negative';
        SIGNAL SQLSTATE '45009';
    END IF;

    IF NOT fn_IdRegisteredFromInscriptions(p_id_vehicle, p_id_race, p_id_team) THEN
        SET v_error_message = 'Inscription does not exist';
        SIGNAL SQLSTATE '45009';
    END IF;

    START TRANSACTION;
    INSERT INTO results (position, final_time, penalty_time, base_points_team, base_points_pilot, penalty_points_team, penalty_points_pilot, id_vehicle, id_race, id_team)
    VALUES (p_position, p_final_time, p_penalty_time, p_base_points_team, p_base_points_pilot, p_penalty_points_team, p_penalty_points_pilot, p_id_vehicle, p_id_race, p_id_team);
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Insert failed';
        SIGNAL SQLSTATE '45009';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

CREATE PROCEDURE sp_UpdateResultData (
    IN p_id_result INT,
    IN p_position INT,
    IN p_final_time TIME,
    IN p_penalty_time TIME,
    IN p_base_points_team INT,
    IN p_base_points_pilot INT,
    IN p_penalty_points_team INT,
    IN p_penalty_points_pilot INT,
    IN p_id_vehicle INT,
    IN p_id_race INT,
    IN p_id_team INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Updates an existing result.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45028' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_result, p_position, p_final_time, p_penalty_time, p_base_points_team, p_base_points_pilot, p_penalty_points_team, p_penalty_points_pilot, p_id_vehicle, p_id_race, p_id_team)) THEN
        SET v_error_message = 'Parameters cannot be null';
        SIGNAL SQLSTATE '45028';
    END IF;

    IF p_position < 1 OR p_position > 60 THEN
        SET v_error_message = 'Position out of range';
        SIGNAL SQLSTATE '45028';
    END IF;

    IF p_final_time = '00:00:00' THEN
        SET v_error_message = 'Final time cannot be zero';
        SIGNAL SQLSTATE '45028';
    END IF;

    IF p_base_points_team < 0 OR p_base_points_pilot < 0 OR p_penalty_points_team < 0 OR p_penalty_points_pilot < 0 THEN
        SET v_error_message = 'Points cannot be negative';
        SIGNAL SQLSTATE '45028';
    END IF;

    IF NOT fn_IdRegisteredFromResults(p_id_result) THEN
        SET v_error_message = 'Result ID does not exist';
        SIGNAL SQLSTATE '45028';
    END IF;

    IF NOT fn_IdRegisteredFromInscriptions(p_id_vehicle, p_id_race, p_id_team) THEN
        SET v_error_message = 'Inscription does not exist';
        SIGNAL SQLSTATE '45028';
    END IF;

    START TRANSACTION;
    UPDATE results
    SET position = p_position,
        final_time = p_final_time,
        penalty_time = p_penalty_time,
        base_points_team = p_base_points_team,
        base_points_pilot = p_base_points_pilot,
        penalty_points_team = p_penalty_points_team,
        penalty_points_pilot = p_penalty_points_pilot,
        id_vehicle = p_id_vehicle,
        id_race = p_id_race,
        id_team = p_id_team
    WHERE id_result = p_id_result;
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Update failed';
        SIGNAL SQLSTATE '45028';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

CREATE PROCEDURE sp_DeleteResultData (
    IN p_id_result INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Deletes a result.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45029' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_result)) THEN
        SET v_error_message = 'Result ID cannot be null';
        SIGNAL SQLSTATE '45029';
    END IF;

    IF NOT fn_IdRegisteredFromResults(p_id_result) THEN
        SET v_error_message = 'Result ID does not exist';
        SIGNAL SQLSTATE '45029';
    END IF;

    START TRANSACTION;
    DELETE FROM results WHERE id_result = p_id_result;
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Delete failed';
        SIGNAL SQLSTATE '45029';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

-- =================================================================
-- PENALTIES
-- =================================================================

CREATE PROCEDURE sp_InsertPenaltyData (
    IN p_penalty_type CHAR(30),
    IN p_reason VARCHAR(100),
    IN p_penalty_value DECIMAL(7,2),
    IN p_penalty_applies_to VARCHAR(30),
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Inserts a new penalty.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45004' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_penalty_type, p_reason, p_penalty_value, p_penalty_applies_to)) THEN
        SET v_error_message = 'Parameters cannot be null or empty';
        SIGNAL SQLSTATE '45004';
    END IF;

    IF NOT fn_CheckPenaltyTypeCorrect(p_penalty_type) THEN
        SET v_error_message = 'Invalid penalty type. Must be POINTS, TIME, DSQ, DNF';
        SIGNAL SQLSTATE '45004';
    END IF;

    IF p_penalty_value <= 0 THEN
        SET v_error_message = 'Penalty value must be positive';
        SIGNAL SQLSTATE '45004';
    END IF;

    -- FUNCIÓN FALTANTE: fn_CheckPenaltyAppliesToCorrect(p_penalty_applies_to)
    IF p_penalty_applies_to NOT IN ('TEAM', 'PILOT') THEN
        SET v_error_message = 'Penalty applies to must be TEAM or PILOT';
        SIGNAL SQLSTATE '45004';
    END IF;

    START TRANSACTION;
    INSERT INTO penalties (penalty_type, reason, penalty_value, penalty_applies_to)
    VALUES (p_penalty_type, p_reason, p_penalty_value, p_penalty_applies_to);
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Insert failed';
        SIGNAL SQLSTATE '45004';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

CREATE PROCEDURE sp_UpdatePenaltyData (
    IN p_id_penalty INT,
    IN p_penalty_type CHAR(30),
    IN p_reason VARCHAR(100),
    IN p_penalty_value DECIMAL(7,2),
    IN p_penalty_applies_to VARCHAR(30),
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Updates an existing penalty.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45018' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_penalty, p_penalty_type, p_reason, p_penalty_value, p_penalty_applies_to)) THEN
        SET v_error_message = 'Parameters cannot be null or empty';
        SIGNAL SQLSTATE '45018';
    END IF;

    IF NOT fn_CheckPenaltyTypeCorrect(p_penalty_type) THEN
        SET v_error_message = 'Invalid penalty type';
        SIGNAL SQLSTATE '45018';
    END IF;

    IF p_penalty_value <= 0 THEN
        SET v_error_message = 'Penalty value must be positive';
        SIGNAL SQLSTATE '45018';
    END IF;

    IF p_penalty_applies_to NOT IN ('TEAM', 'PILOT') THEN
        SET v_error_message = 'Penalty applies to must be TEAM or PILOT';
        SIGNAL SQLSTATE '45018';
    END IF;

    IF NOT fn_IdRegisteredFromPenalties(p_id_penalty) THEN
        SET v_error_message = 'Penalty ID does not exist';
        SIGNAL SQLSTATE '45018';
    END IF;

    START TRANSACTION;
    UPDATE penalties
    SET penalty_type = p_penalty_type,
        reason = p_reason,
        penalty_value = p_penalty_value,
        penalty_applies_to = p_penalty_applies_to
    WHERE id_penalty = p_id_penalty;
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Update failed';
        SIGNAL SQLSTATE '45018';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

CREATE PROCEDURE sp_DeletePenaltyData (
    IN p_id_penalty INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Deletes a penalty if not linked to any result.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45019' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_penalty)) THEN
        SET v_error_message = 'Penalty ID cannot be null';
        SIGNAL SQLSTATE '45019';
    END IF;

    IF NOT fn_IdRegisteredFromPenalties(p_id_penalty) THEN
        SET v_error_message = 'Penalty ID does not exist';
        SIGNAL SQLSTATE '45019';
    END IF;

    IF fn_CheckForExtraDependences('penalties', p_id_penalty) THEN
        SET v_error_message = 'Cannot delete penalty because it is applied to a result';
        SIGNAL SQLSTATE '45019';
    END IF;

    START TRANSACTION;
    DELETE FROM penalties WHERE id_penalty = p_id_penalty;
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Delete failed';
        SIGNAL SQLSTATE '45019';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

-- =================================================================
-- USER_ROLES
-- =================================================================

CREATE PROCEDURE sp_InsertUserRoleData (
    IN p_role_name VARCHAR(100),
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Inserts a new user role.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45046' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_role_name)) THEN
        SET v_error_message = 'Role name cannot be null or empty';
        SIGNAL SQLSTATE '45046';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyUserRoleByName(p_role_name)
    IF EXISTS (SELECT 1 FROM user_roles WHERE role_name = p_role_name) THEN
        SET v_error_message = 'Role name already exists';
        SIGNAL SQLSTATE '45046';
    END IF;

    START TRANSACTION;
    INSERT INTO user_roles (role_name) VALUES (p_role_name);
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Insert failed';
        SIGNAL SQLSTATE '45046';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

CREATE PROCEDURE sp_UpdateUserRoleData (
    IN p_id_user_role INT,
    IN p_role_name VARCHAR(100),
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Updates an existing user role.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45047' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_user_role, p_role_name)) THEN
        SET v_error_message = 'Parameters cannot be null or empty';
        SIGNAL SQLSTATE '45047';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyUserRoleById(p_id_user_role)
    IF NOT EXISTS (SELECT 1 FROM user_roles WHERE id_user_roles = p_id_user_role) THEN
        SET v_error_message = 'User role ID does not exist';
        SIGNAL SQLSTATE '45047';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyUserRoleByNameExcludingId(p_role_name, p_id_user_role)
    IF EXISTS (SELECT 1 FROM user_roles WHERE role_name = p_role_name AND id_user_roles != p_id_user_role) THEN
        SET v_error_message = 'Another role with this name already exists';
        SIGNAL SQLSTATE '45047';
    END IF;

    START TRANSACTION;
    UPDATE user_roles SET role_name = p_role_name WHERE id_user_roles = p_id_user_role;
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Update failed';
        SIGNAL SQLSTATE '45047';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

CREATE PROCEDURE sp_DeleteUserRoleData (
    IN p_id_user_role INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Deletes a user role if not assigned to any user.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45048' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_user_role)) THEN
        SET v_error_message = 'User role ID cannot be null';
        SIGNAL SQLSTATE '45048';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyUserRoleById(p_id_user_role)
    IF NOT EXISTS (SELECT 1 FROM user_roles WHERE id_user_roles = p_id_user_role) THEN
        SET v_error_message = 'User role ID does not exist';
        SIGNAL SQLSTATE '45048';
    END IF;

    IF fn_CheckForExtraDependences('user_roles', p_id_user_role) THEN
        SET v_error_message = 'Cannot delete role because it is assigned to one or more users';
        SIGNAL SQLSTATE '45048';
    END IF;

    START TRANSACTION;
    DELETE FROM user_roles WHERE id_user_roles = p_id_user_role;
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Delete failed';
        SIGNAL SQLSTATE '45048';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

-- =================================================================
-- USERS
-- =================================================================

CREATE PROCEDURE sp_InsertUserData (
    IN p_username VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_password_hash VARCHAR(255),
    IN p_team_id INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Inserts a new user.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45043' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_username, p_email, p_password_hash, p_team_id)) THEN
        SET v_error_message = 'Parameters cannot be null or empty';
        SIGNAL SQLSTATE '45043';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyUserByUsername(p_username)
    IF EXISTS (SELECT 1 FROM users WHERE username = p_username) THEN
        SET v_error_message = 'Username already exists';
        SIGNAL SQLSTATE '45043';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyUserByEmail(p_email)
    IF EXISTS (SELECT 1 FROM users WHERE email = p_email) THEN
        SET v_error_message = 'Email already exists';
        SIGNAL SQLSTATE '45043';
    END IF;

    IF NOT fn_IdRegisterExistsFromTeams(p_team_id) THEN
        SET v_error_message = 'Team ID does not exist';
        SIGNAL SQLSTATE '45043';
    END IF;

    START TRANSACTION;
    INSERT INTO users (username, email, password_hash, team_id)
    VALUES (p_username, p_email, p_password_hash, p_team_id);
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Insert failed';
        SIGNAL SQLSTATE '45043';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

CREATE PROCEDURE sp_UpdateUserData (
    IN p_id_user INT,
    IN p_username VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_password_hash VARCHAR(255),
    IN p_team_id INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Updates an existing user.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45044' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_user, p_username, p_email, p_password_hash, p_team_id)) THEN
        SET v_error_message = 'Parameters cannot be null or empty';
        SIGNAL SQLSTATE '45044';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyUserById(p_id_user)
    IF NOT EXISTS (SELECT 1 FROM users WHERE id_user = p_id_user) THEN
        SET v_error_message = 'User ID does not exist';
        SIGNAL SQLSTATE '45044';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyUserByUsernameExcludingId(p_username, p_id_user)
    IF EXISTS (SELECT 1 FROM users WHERE username = p_username AND id_user != p_id_user) THEN
        SET v_error_message = 'Another user with this username already exists';
        SIGNAL SQLSTATE '45044';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyUserByEmailExcludingId(p_email, p_id_user)
    IF EXISTS (SELECT 1 FROM users WHERE email = p_email AND id_user != p_id_user) THEN
        SET v_error_message = 'Another user with this email already exists';
        SIGNAL SQLSTATE '45044';
    END IF;

    IF NOT fn_IdRegisterExistsFromTeams(p_team_id) THEN
        SET v_error_message = 'Team ID does not exist';
        SIGNAL SQLSTATE '45044';
    END IF;

    START TRANSACTION;
    UPDATE users
    SET username = p_username,
        email = p_email,
        password_hash = p_password_hash,
        team_id = p_team_id
    WHERE id_user = p_id_user;
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Update failed';
        SIGNAL SQLSTATE '45044';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

CREATE PROCEDURE sp_DeleteUserData (
    IN p_id_user INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Deletes a user.'
BEGIN
    DECLARE v_error_message VARCHAR(255) DEFAULT '';
    DECLARE v_affected_rows INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_spstate = 0;
        ROLLBACK;
        IF v_error_message != '' THEN
            SIGNAL SQLSTATE '45045' SET MESSAGE_TEXT = v_error_message;
        ELSE
            RESIGNAL;
        END IF;
    END;

    IF NOT fn_CheckNullEmptyArray(JSON_ARRAY(p_id_user)) THEN
        SET v_error_message = 'User ID cannot be null';
        SIGNAL SQLSTATE '45045';
    END IF;

    -- FUNCIÓN FALTANTE: fn_GetAnyUserById(p_id_user)
    IF NOT EXISTS (SELECT 1 FROM users WHERE id_user = p_id_user) THEN
        SET v_error_message = 'User ID does not exist';
        SIGNAL SQLSTATE '45045';
    END IF;

    START TRANSACTION;
    DELETE FROM users WHERE id_user = p_id_user;
    SET v_affected_rows = ROW_COUNT();
    IF v_affected_rows = 0 THEN
        SET v_error_message = 'Delete failed';
        SIGNAL SQLSTATE '45045';
    END IF;
    COMMIT;
    SET p_spstate = 1;
END //

DELIMITER ;