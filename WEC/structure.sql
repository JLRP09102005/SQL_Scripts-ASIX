-- Active: 1762272161423@@127.0.0.1@3306@test
--====== DATABASE ======
CREATE DATABASE WEC;
USE WEC;

--====== TABLES ======
CREATE TABLE penalties(
    id_penalty INT AUTO_INCREMENT PRIMARY KEY,
    penalty_type ENUM('POINTS','TIME') DEFAULT 'POINTS' NOT NULL,
    reason VARCHAR(50) NOT NULL,
    penalty_value INT NOT NULL
);

CREATE TABLE results(
    id_result INT AUTO_INCREMENT PK,
    position INT NOT NULL,
    final_time TIME DEFAULT '00:00:00' NOT NULL,
    base_points_team INT NOT NULL,
    base_points_pilot INT NOT NULL,
    penalty_points_team INT NOT NULL,
    penalty_points_pilot INT NOT NULL,
    id_inscription INT NOT NULL,
    id_prenalty INT
);

CREATE TABLE vehicles(
    id_vehicle INT AUTO_INCREMENT PRIMARY KEY,
    model VARCHAR(20) NOT NULL,
    specifications BLOB --PDF
);

CREATE TABLE races(
    id_race INT AUTO_INCREMENT PRIMARY KEY,
    event_name VARCHAR(20) NOT NULL,
    event_date DATETIME DEFAULT '2000-00-00 00:00:00' NOT NULL,
    event_duration TIME DEFAULT '00:00:00' NOT NULL,
    id_circuit INT NOT NULL
);

CREATE TABLE circuits(
    id_circuit INT AUTO_INCREMENT PRIMARY KEY,
    circuit_name VARCHAR(20) NOT NULL,
    country VARCHAR(20) NOT NULL,
    length_km INT NOT NULL,
    direction ENUM('CLOCKWISE','COUNTERCLOCKWISE') DEFAULT 'CLOCKWISE' NOT NULL
);

CREATE TABLE teams(
    id_equipo INT AUTO_INCREMENT PRIMARY KEY,
    team_name VARCHAR(20) NOT NULL,
    mechanics_num INT NOT NULL,
    manufacturer INT
);

CREATE TABLE manufacturers(
    id_manufacturer INT AUTO_INCREMENT PRIMARY KEY,
    manufacturer_name VARCHAR(20) NOT NULL,
    manufacturer_country VARCHAR(20) NOT NULL
);

CREATE TABLE pilots(
    id_pilot INT AUTO_INCREMENT PRIMARY KEY,
    pilot_name VARCHAR(30) NOT NULL,
    id_pilot_category INT NOT NULL
);

CREATE TABLE pilots_categories(
    id_pilot_category INT AUTO_INCREMENT NOT NULL,
    pilot_category_name VARCHAR(20) NOT NULL,
    pilot_category_description TEXT NOT NULL,
    min_age TINYINT
);

--====== INTERMEDIATE TABLES ======
CREATE TABLE inscriptions(
    id_vehicle INT,
    id_race INT,
    id_team INT,
    vehicles_quantity TINYINT NOT NULL,
    PRIMARY KEY(id_vehicle, id_race, id_team)
);

CREATE TABLE penalties_results(
    id_penalty INT,
    id_result INT,
    PRIMARY KEY(id_penalty, id_result)
);

CREATE TABLE pilots_inscriptions(
    id_pilot INT,
    id_inscription INT,
    PRIMARY KEY(id_pilot, id_inscription)
);

--====== FOREIGN KEYS ======
ALTER TABLE results
ADD CONSTRAINT FK_result_inscription,
ADD CONSTRAINT FK_result_penalty FOREIGN KEY (id_penalty) REFERENCES penalties(id_penalty);

ALTER TABLE races
ADD CONSTRAINT FK_race_circuit FOREIGN KEY (id_circuit) REFERENCES circuits(id_circuit);

ALTER TABLE teams
ADD CONSTRAINT FK_team_manufacturer FOREIGN KEY (id_manufacturer) REFERENCES manufacturers(id_manufacturer);

ALTER TABLE pilots
ADD CONSTRAINT FK_pilot_pilotcategory FOREIGN KEY(id_pilot_category) REFERENCES pilots_categories(id_pilot_category);

ALTER TABLE inscriptions
ADD CONSTRAINT FK_inscription_vehicle FOREIGN KEY (id_vehicle) REFERENCES vehicles(id_vehicle),
ADD CONSTRAINT FK_inscription_race FOREIGN KEY (id_race) REFERENCES races(id_race),
ADD CONSTRAINT FK_inscription_team FOREIGN KEY (id_team) REFERENCES teams(id_team);

ALTER TABLE penalties_results
ADD CONSTRAINT FK_penaltiesresults_penalty FOREIGN KEY (id_penalty) REFERENCES penalties(id_penalty),
ADD CONSTRAINT FK_penaltiesresults_result FOREIGN KEY (id_result) REFERENCES results(id_result);

ALTER TABLE pilots_inscriptions
ADD CONSTRAINT FK_pilotsinscriptions_pilot FOREIGN KEY (id_pilot) REFERENCES pilots(id_pilot),
ADD CONSTRAINT FK_pilotsinscriptions_inscription FOREIGN KEY (id_inscription) REFERENCES inscriptions(id_inscription);