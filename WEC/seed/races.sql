-- ============================================================
-- FILE: races.sql
-- DESC: Datos iniciales de carreras (temporada 2024 WEC)
-- ============================================================
USE wec;

-- id_circuit: 1=Le Mans, 2=Spa, 3=Bahrain, 4=Fuji, 5=COTA, 6=Monza, 7=Portimão, 8=São Paulo
INSERT INTO races (event_name, event_date, event_duration, id_circuit) VALUES
('1000 Miles of Sebring',           '2024-03-16 12:00:00', '06:00:00', NULL),
('6 Hours of Imola',                '2024-04-21 12:00:00', '06:00:00', 6),
('6 Hours of Spa-Francorchamps',    '2024-05-11 14:30:00', '06:00:00', 2),
('24 Hours of Le Mans',             '2024-06-15 16:00:00', '24:00:00', 1),
('6 Hours of Sao Paulo',            '2024-07-14 12:30:00', '06:00:00', 8),
('6 Hours of Fuji',                 '2024-09-15 11:00:00', '06:00:00', 4),
('6 Hours of Bahrain',              '2024-11-02 15:00:00', '06:00:00', 3),
('8 Hours of Portimao',             '2025-04-13 14:00:00', '08:00:00', 7);