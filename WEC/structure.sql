-- Active: 1762272161423@@127.0.0.1@3306@test
--====== DATABASE ======
CREATE DATABASE WEC;
USE WEC;

--====== TABLES ======
CREATE TABLE penalties(
    id_penalty INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    penalty_type ENUM('POINTS','TIME') DEFAULT 'POINTS' NOT NULL,
    reason VARCHAR(100) NOT NULL,
    penalty_value DECIMAL(6,2) NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
)
ENGINE=InnoDB
CHARACTER SET=utf8mb4
COLLATE=utf8mb4_unicode_cs
COMMENT='Team penalty registry';

CREATE TABLE results(
    id_result INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    position INT UNSIGNED NOT NULL,
    final_time TIME NOT NULL DEFAULT '00:00:00',
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
COLLATE=utf8mb4_unicode_cs
COMMENT='Team result registry';

CREATE TABLE vehicles(
    id_vehicle INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    model VARCHAR(100) NOT NULL,
    specifications MEDIUMBLOB COMMENT='Save PDFs'
)
ENGINE=InnoDB
CHARACTER SET=utf8mb4
COLLATE=utf8mb4_unicode_cs
COMMENT='Teams vehicles specifications';

CREATE TABLE races(
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
COLLATE=utf8mb4_unicode_cs
COMMENT='Championship races registry';

CREATE TABLE circuits(
    id_circuit INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    circuit_name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    length_km DECIMAL(3,2) UNSIGNED NOT NULL,
    direction ENUM('CLOCKWISE','COUNTERCLOCKWISE') NOT NULL DEFAULT 'CLOCKWISE'
)
ENGINE=InnoDB
CHARACTER SET=utf8mb4
COLLATE=utf8mb4_unicode_cs
COMMENT='Catalog of circuits existing';

CREATE TABLE teams(
    id_team INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    team_name VARCHAR(100) NOT NULL,
    mechanics_num TINYINT UNSIGNED NOT NULL,
    id_manufacturer INT UNSIGNED,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
)
ENGINE=InnoDB
CHARACTER SET=utf8mb4
COLLATE=utf8mb4_unicode_cs
COMMENT='List of teams participating in the Championship';

CREATE TABLE manufacturers(
    id_manufacturer INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    manufacturer_name VARCHAR(100) NOT NULL,
    manufacturer_country VARCHAR(50) NOT NULL
)
ENGINE=InnoDB
CHARACTER SET=utf8mb4
COLLATE=utf8mb4_unicode_cs
COMMENT='Manufacturers that sponsor teams';

CREATE TABLE pilots(
    id_pilot INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    pilot_name VARCHAR(100) NOT NULL,
    id_pilot_category TINYINT UNSIGNED NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
)
ENGINE=InnoDB
CHARACTER SET=utf8mb4
COLLATE=utf8mb4_unicode_cs
COMMENT='Catalog of pilots participating';

CREATE TABLE pilot_categories(
    id_pilot_category INT unsigned AUTO_INCREMENT PRIMARY KEY,
    pilot_category_name VARCHAR(50) NOT NULL,
    pilot_category_description VARCHAR(100) NOT NULL,
    min_age TINYINT NOT NULL UNSIGNED DEFAULT 0
)
ENGINE=InnoDB
CHARACTER SET=utf8mb4
COLLATE=utf8mb4_unicode_cs
COMMENT='Categories division for pilots';

--====== INTERMEDIATE TABLES ======
CREATE TABLE inscriptions(
    id_vehicle INT UNSIGNED NOT NULL,
    id_race INT UNSIGNED NOT NULL,
    id_team INT UNSIGNED NOT NULL,
    vehicles_quantity TINYINT UNSIGNED NOT NULL DEFAULT 1,
    registered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(id_vehicle, id_race, id_team)
)
ENGINE=InnoDB
CHARACTER SET=utf8mb4
COLLATE=utf8mb4_unicode_cs
COMMENT='Intermediate table to unify inscription info';

CREATE TABLE penalties_results(
    id_penalty INT UNSIGNED NOT NULL,
    id_result INT UNSIGNED NOT NULL,
    PRIMARY KEY(id_penalty, id_result)
)
ENGINE=InnoDB
CHARACTER SET=utf8mb4
COLLATE=utf8mb4_unicode_cs
COMMENT='Intermediate table for penalties-results';

CREATE TABLE pilots_inscriptions(
    id_pilot INT UNSIGNED NOT NULL,
    id_vehicle INT UNSIGNED NOT NULL,
    id_race INT UNSIGNED NOT NULL,
    id_team INT UNSIGNED NOT NULL,
    PRIMARY KEY(id_pilot, id_vehicle, id_race, id_team)
)
ENGINE=InnoDB
CHARACTER SET=utf8mb4
COLLATE=utf8mb4_unicode_cs
COMMENT='Add pilot information to the inscription';

--====== FOREIGN KEYS ======
ALTER TABLE results
ADD CONSTRAINT FK_result_inscription FOREIGN KEY (id_vehicle, id_race, id_team) REFERENCES inscriptions(id_vehicle, id_race, id_team)
    ON DELETE CASCADE;

ALTER TABLE races
ADD CONSTRAINT FK_race_circuit FOREIGN KEY (id_circuit) REFERENCES circuits(id_circuit)
    ON DELETE SET NULL;

ALTER TABLE teams
ADD CONSTRAINT FK_team_manufacturer FOREIGN KEY (id_manufacturer) REFERENCES manufacturers(id_manufacturer)
    ON DELETE SET NULL;

ALTER TABLE pilots
ADD CONSTRAINT FK_pilot_pilotcategory FOREIGN KEY(id_pilot_category) REFERENCES pilot_categories(id_pilot_category);

ALTER TABLE inscriptions
ADD CONSTRAINT FK_inscription_vehicle FOREIGN KEY (id_vehicle) REFERENCES vehicles(id_vehicle)
    ON DELETE CASCADE,
ADD CONSTRAINT FK_inscription_race FOREIGN KEY (id_race) REFERENCES races(id_race)
    ON DELETE CASCADE,
ADD CONSTRAINT FK_inscription_team FOREIGN KEY (id_team) REFERENCES teams(id_team)
    ON DELETE CASCADE;

ALTER TABLE penalties_results
ADD CONSTRAINT FK_penaltiesresults_penalty FOREIGN KEY (id_penalty) REFERENCES penalties(id_penalty)
    ON DELETE CASCADE,
ADD CONSTRAINT FK_penaltiesresults_result FOREIGN KEY (id_result) REFERENCES results(id_result)
    ON DELETE CASCADE;

ALTER TABLE pilots_inscriptions
ADD CONSTRAINT FK_pilotsinscriptions_pilot FOREIGN KEY (id_pilot) REFERENCES pilots(id_pilot)
    ON DELETE CASCADE,
ADD CONSTRAINT FK_pilotsinscriptions_inscription FOREIGN KEY (id_vehicle, id_race, id_team) REFERENCES inscriptions(id_vehicle, id_race, id_team)
    ON DELETE CASCADE;

--====== INDEX ======
CREATE INDEX idx_results_race ON results(id_race);
CREATE INDEX idx_results_vehicle ON results(id_vehicle);
CREATE INDEX idx_inscriptions_race ON inscriptions(id_race);
CREATE INDEX idx_teams_name ON teams(team_name);
CREATE INDEX idx_pilots_name ON pilots(pilot_name);
CREATE INDEX idx_circuits_country ON circuits(country);
CREATE INDEX idx_penalties_type ON penalties(penalty_type)

--====== CHECKS ======
