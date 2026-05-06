-- ============================================================
-- FILE: pilots.sql
-- DESC: Datos iniciales de pilotos
-- ============================================================
USE wec;

-- id_pilot_category: 1=Platinum, 2=Gold, 3=Silver, 4=Bronze
INSERT INTO pilots (pilot_name, pilot_age, id_pilot_category) VALUES
('Sebastien Buemi',         35, 1),-- Toyota Gazoo Racing
('Brendon Hartley',         34, 1),
('Ryo Hirakawa',            30, 1),
('Mike Conway',             40, 1),
('Kamui Kobayashi',         37, 1),
('Jose Maria Lopez',        40, 1),
('Alessandro Pier Guidi',   38, 1),-- Ferrari AF Corse
('James Calado',            34, 1),
('Antonio Giovinazzi',      30, 1),
('Miguel Molina',           34, 1),
('Nicklas Nielsen',         26, 2),
('Robert Kubica',           39, 1),
('Kevin Estre',             35, 1),-- Porsche Penske Motorsport
('Andre Lotterer',          42, 1),
('Laurens Vanthoor',        32, 1),
('KevenEstre',             35, 1),
('Matt Campbell',           29, 2),
('Michael Christensen',     31, 2),
('Loic Duval',              42, 1),-- Peugeot TotalEnergies
('Gustavo Menezes',         29, 2),
('Nico Muller',             32, 2),
('Paul di Resta',           38, 1),
('Mikkel Jensen',           27, 2),
('Jean-Eric Vergne',        34, 1),
('Dries Vanthoor',          25, 2),-- BMW M Team WRT
('Raffaele Marciello',      30, 1),
('Marco Wittmann',          34, 2),
('Renger van der Zande',    38, 1),-- Cadillac Racing
('Scott Dixon',             43, 1),
('Alex Lynn',               30, 2),
('Daniil Kvyat',            30, 1),-- Lamborghini Iron Lynx
('Mirko Bortolotti',        34, 1),
('Andrea Caldarelli',       32, 2),
('Nicolas Lapierre',        40, 1),-- Alpine Endurance Team
('Matthieu Vaxiviere',      32, 2),
('Charles Milesi',          23, 2),
('Philip Hanson',           24, 3),-- United Autosports
('Oliver Jarvis',           39, 2),
('Tom Gamble',              23, 3),
('Christian Ried',          46, 4),-- Proton Competition
('Joel Sturm',              24, 3),
('Harry Tincknell',         31, 2);