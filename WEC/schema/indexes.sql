-- Active: 1763026326945@@127.0.0.1@3306@wec
USE wec;

--====== INDEX ======
CREATE INDEX IF NOT EXISTS idx_results_race ON results(id_race, id_vehicle);
CREATE INDEX IF NOT EXISTS idx_inscriptions_race ON inscriptions(id_race);
CREATE INDEX IF NOT EXISTS idx_teams_name ON teams(team_name);
CREATE INDEX IF NOT EXISTS idx_pilots_name ON pilots(pilot_name);
CREATE INDEX IF NOT EXISTS idx_circuits_country ON circuits(country);
CREATE INDEX IF NOT EXISTS idx_penalties_type ON penalties(penalty_type)