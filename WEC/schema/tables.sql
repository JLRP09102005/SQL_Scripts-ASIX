-- Active: 1763026326945@@127.0.0.1@3306@wec
USE wec;

--====== TABLES ======
CREATE TABLE IF NOT EXISTS penalties(
    id_penalty INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    penalty_type ENUM('POINTS','TIME','DSQ','DNF') DEFAULT 'POINTS' NOT NULL,
    reason VARCHAR(100) NOT NULL,
    penalty_value DECIMAL(7,2) NOT NULL, #Penalty time in seconds
    penalty_applies_to ENUM('TEAM','PILOT'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
)
ENGINE=InnoDB
CHARACTER SET=utf8mb4
COLLATE=utf8mb4_bin
COMMENT='Team penalty registry';

CREATE TABLE IF NOT EXISTS results(
    id_result INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    position INT UNSIGNED NOT NULL,
    final_time TIME NOT NULL DEFAULT '00:00:00',
    penalty_time TIME NOT NULL DEFAULT '00:00:00',
    base_points_team INT UNSIGNED NOT NULL DEFAULT 0,
    base_points_pilot INT UNSIGNED NOT NULL DEFAULT 0,
    penalty_points_team INT UNSIGNED NOT NULL DEFAULT 0,
    penalty_points_pilot INT UNSIGNED NOT NULL DEFAULT 0,
    id_vehicle INT UNSIGNED NOT NULL,
    id_race INT UNSIGNED NOT NULL,
    id_team INT UNSIGNED NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
)
ENGINE=InnoDB
CHARACTER SET=utf8mb4
COLLATE=utf8mb4_bin
COMMENT='Team result registry';

CREATE TABLE IF NOT EXISTS vehicles(
    id_vehicle INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    model VARCHAR(100) NOT NULL,
    specifications_url VARCHAR(1024)
)
ENGINE=InnoDB
CHARACTER SET=utf8mb4
COLLATE=utf8mb4_bin
COMMENT='Teams vehicles specifications';

CREATE TABLE IF NOT EXISTS races(
    id_race INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    event_name VARCHAR(100) NOT NULL,
    event_date DATETIME NOT NULL,
    event_duration TIME NOT NULL DEFAULT '00:00:00',
    id_circuit INT UNSIGNED,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
)
ENGINE=InnoDB
CHARACTER SET=utf8mb4
COLLATE=utf8mb4_bin
COMMENT='Championship races registry';

CREATE TABLE IF NOT EXISTS circuits(
    id_circuit INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    circuit_name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    length_km DECIMAL(3,2) UNSIGNED NOT NULL,
    direction ENUM('CLOCKWISE','COUNTERCLOCKWISE') NOT NULL DEFAULT 'CLOCKWISE'
)
ENGINE=InnoDB
CHARACTER SET=utf8mb4
COLLATE=utf8mb4_bin
COMMENT='Catalog of circuits existing';

CREATE TABLE IF NOT EXISTS teams(
    id_team INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    team_name VARCHAR(100) UNIQUE NOT NULL,
    mechanics_num TINYINT UNSIGNED NOT NULL,
    id_manufacturer INT UNSIGNED,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
)
ENGINE=InnoDB
CHARACTER SET=utf8mb4
COLLATE=utf8mb4_bin
COMMENT='List of teams participating in the Championship';

CREATE TABLE IF NOT EXISTS manufacturers(
    id_manufacturer INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    manufacturer_name VARCHAR(100) NOT NULL,
    manufacturer_country VARCHAR(50) NOT NULL
)
ENGINE=InnoDB
CHARACTER SET=utf8mb4
COLLATE=utf8mb4_bin
COMMENT='Manufacturers that sponsor teams';

CREATE TABLE IF NOT EXISTS pilots(
    id_pilot INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    pilot_name VARCHAR(100) NOT NULL,
    pilot_age TINYINT UNSIGNED NOT NULL,
    id_pilot_category INT UNSIGNED NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
)
ENGINE=InnoDB
CHARACTER SET=utf8mb4
COLLATE=utf8mb4_bin
COMMENT='Catalog of pilots participating';

CREATE TABLE IF NOT EXISTS pilot_categories(
    id_pilot_category INT unsigned AUTO_INCREMENT PRIMARY KEY,
    pilot_category_name VARCHAR(50) NOT NULL,
    pilot_category_description VARCHAR(100) NOT NULL,
    min_age TINYINT UNSIGNED NOT NULL DEFAULT 0
)
ENGINE=InnoDB
CHARACTER SET=utf8mb4
COLLATE=utf8mb4_bin
COMMENT='Categories division for pilots';

CREATE TABLE IF NOT EXISTS user_roles(
    id_user_roles INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(100) NOT NULL
)
ENGINE=InnoDB
CHARACTER SET=utf8mb4
COLLATE=utf8mb4_bin
COMMENT='Categories for users';


CREATE TABLE IF NOT EXISTS users(
    id_user INT UNSIGNED AUTO_INCREMENT primary KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    team_id INT UNSIGNED DEFAULT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
)
ENGINE=InnoDB
CHARACTER SET=utf8mb4
COLLATE=utf8mb4_bin
COMMENT='User table registry';

--====== INTERMEDIATE TABLES ======
CREATE TABLE IF NOT EXISTS inscriptions(
    id_vehicle INT UNSIGNED NOT NULL,
    id_race INT UNSIGNED NOT NULL,
    id_team INT UNSIGNED NOT NULL,
    vehicles_quantity TINYINT UNSIGNED NOT NULL DEFAULT 1,
    registered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    max_vehicles TINYINT NOT NULL DEFAULT 2,
    max_pilots TINYINT NOT NULL DEFAULT 3,
    max_mechanics TINYINT NOT NULL DEFAULT 6,
    PRIMARY KEY(id_vehicle, id_race, id_team)
)
ENGINE=InnoDB
CHARACTER SET=utf8mb4
COLLATE=utf8mb4_bin
COMMENT='Intermediate table to unify inscription info';

CREATE TABLE IF NOT EXISTS penalties_results(
    id_penalty INT UNSIGNED NOT NULL,
    id_result INT UNSIGNED NOT NULL,
    PRIMARY KEY(id_penalty, id_result)
)
ENGINE=InnoDB
CHARACTER SET=utf8mb4
COLLATE=utf8mb4_bin
COMMENT='Intermediate table for penalties-results';

CREATE TABLE IF NOT EXISTS pilots_inscriptions(
    id_pilot INT UNSIGNED NOT NULL,
    id_vehicle INT UNSIGNED NOT NULL,
    id_race INT UNSIGNED NOT NULL,
    id_team INT UNSIGNED NOT NULL,
    PRIMARY KEY(id_pilot, id_vehicle, id_race, id_team)
)
ENGINE=InnoDB
CHARACTER SET=utf8mb4
COLLATE=utf8mb4_bin
COMMENT='Add pilot information to the inscription';

CREATE TABLE IF NOT EXISTS user_userrole(
    id_user INT UNSIGNED NOT NULL,
    id_user_role INT UNSIGNED NOT NULL
)
ENGINE=InnoDB
CHARACTER SET=utf8mb4
COLLATE=utf8mb4_bin
COMMENT='Intermediate table for users and user roles'