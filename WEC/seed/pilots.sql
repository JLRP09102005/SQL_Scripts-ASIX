-- ============================================================
-- FILE: pilots.sql
-- DESC: Datos iniciales de pilotos
-- ============================================================
USE wec;

-- id_pilot_category: 1=Platinum, 2=Gold, 3=Silver, 4=Bronze
INSERT INTO pilots (pilot_name, pilot_age, id_pilot_category) VALUES
-- Toyota Gazoo Racing
('Sebastien Buemi',         35, 1),
('Brendon Hartley',         34, 1),
('Ryo Hirakawa',            30, 1),
('Mike Conway',             40, 1),
('Kamui Kobayashi',         37, 1),
('Jose Maria Lopez',        40, 1),

-- Ferrari AF Corse
('Alessandro Pier Guidi',   38, 1),
('James Calado',            34, 1),
('Antonio Giovinazzi',      30, 1),
('Miguel Molina',           34, 1),
('Nicklas Nielsen',         26, 2),
('Robert Kubica',           39, 1),

-- Porsche Penske Motorsport
('Kevin Estre',             35, 1),
('Andre Lotterer',          42, 1),
('Laurens Vanthoor',        32, 1),
('KevenEstre',             35, 1),
('Matt Campbell',           29, 2),
('Michael Christensen',     31, 2),

-- Peugeot TotalEnergies
('Loic Duval',              42, 1),
('Gustavo Menezes',         29, 2),
('Nico Muller',             32, 2),
('Paul di Resta',           38, 1),
('Mikkel Jensen',           27, 2),
('Jean-Eric Vergne',        34, 1),

-- BMW M Team WRT
('Dries Vanthoor',          25, 2),
('Raffaele Marciello',      30, 1),
('Marco Wittmann',          34, 2),

-- Cadillac Racing
('Renger van der Zande',    38, 1),
('Scott Dixon',             43, 1),
('Alex Lynn',               30, 2),

-- Lamborghini Iron Lynx
('Daniil Kvyat',            30, 1),
('Mirko Bortolotti',        34, 1),
('Andrea Caldarelli',       32, 2),

-- Alpine Endurance Team
('Nicolas Lapierre',        40, 1),
('Matthieu Vaxiviere',      32, 2),
('Charles Milesi',          23, 2),

-- United Autosports
('Philip Hanson',           24, 3),
('Oliver Jarvis',           39, 2),
('Tom Gamble',              23, 3),

-- Proton Competition
('Christian Ried',          46, 4),
('Joel Sturm',              24, 3),
('Harry Tincknell',         31, 2);