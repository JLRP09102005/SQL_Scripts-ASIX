-- ============================================================
-- FILE: teams.sql
-- DESC: Datos iniciales de equipos
-- ============================================================
USE wec;

-- id_manufacturer referencia: 1=Toyota, 2=Ferrari, 3=Porsche, 4=Peugeot,
--                              5=BMW, 6=Cadillac, 7=Lamborghini, 8=Alpine
INSERT INTO teams (team_name, mechanics_num, id_manufacturer) VALUES
('Toyota Gazoo Racing',             12, 1),
('Ferrari AF Corse',                10, 2),
('Porsche Penske Motorsport',       11, 3),
('Peugeot TotalEnergies',            9, 4),
('BMW M Team WRT',                  10, 5),
('Cadillac Racing',                  8, 6),
('Lamborghini Iron Lynx',            9, 7),
('Alpine Endurance Team',            8, 8),
('United Autosports',                7, NULL),
('Proton Competition',               6, 3);