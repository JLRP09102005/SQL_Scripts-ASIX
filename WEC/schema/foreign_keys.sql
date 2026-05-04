-- Active: 1763026326945@@127.0.0.1@3306@wec
USE wec;

--====== FOREIGN KEYS ======
ALTER TABLE results
ADD CONSTRAINT IF NOT EXISTS FK_result_inscription FOREIGN KEY (id_vehicle, id_race, id_team) REFERENCES inscriptions(id_vehicle, id_race, id_team)
    ON DELETE CASCADE;

ALTER TABLE races
ADD CONSTRAINT IF NOT EXISTS FK_race_circuit FOREIGN KEY (id_circuit) REFERENCES circuits(id_circuit)
    ON DELETE SET NULL;

ALTER TABLE teams
ADD CONSTRAINT IF NOT EXISTS FK_team_manufacturer FOREIGN KEY (id_manufacturer) REFERENCES manufacturers(id_manufacturer)
    ON DELETE SET NULL;

ALTER TABLE pilots
ADD CONSTRAINT IF NOT EXISTS FK_pilot_pilotcategory FOREIGN KEY(id_pilot_category) REFERENCES pilot_categories(id_pilot_category);

ALTER TABLE inscriptions
ADD CONSTRAINT IF NOT EXISTS FK_inscription_vehicle FOREIGN KEY (id_vehicle) REFERENCES vehicles(id_vehicle)
    ON DELETE CASCADE,
ADD CONSTRAINT IF NOT EXISTS FK_inscription_race FOREIGN KEY (id_race) REFERENCES races(id_race)
    ON DELETE CASCADE,
ADD CONSTRAINT IF NOT EXISTS FK_inscription_team FOREIGN KEY (id_team) REFERENCES teams(id_team)
    ON DELETE CASCADE;

ALTER TABLE penalties_results
ADD CONSTRAINT IF NOT EXISTS FK_penaltiesresults_penalty FOREIGN KEY (id_penalty) REFERENCES penalties(id_penalty)
    ON DELETE CASCADE,
ADD CONSTRAINT IF NOT EXISTS FK_penaltiesresults_result FOREIGN KEY (id_result) REFERENCES results(id_result)
    ON DELETE CASCADE;

ALTER TABLE pilots_inscriptions
ADD CONSTRAINT IF NOT EXISTS FK_pilotsinscriptions_pilot FOREIGN KEY (id_pilot) REFERENCES pilots(id_pilot)
    ON DELETE CASCADE,
ADD CONSTRAINT FK_pilotsinscriptions_inscription FOREIGN KEY (id_vehicle, id_race, id_team) REFERENCES inscriptions(id_vehicle, id_race, id_team)
    ON DELETE CASCADE;

ALTER TABLE users
ADD CONSTRAINT IF NOT EXISTS FK_users_teams FOREIGN KEY (team_id) REFERENCES teams(id_team)
    ON DELETE CASCADE;