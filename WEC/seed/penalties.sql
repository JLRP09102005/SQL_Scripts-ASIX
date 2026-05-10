-- Active: 1763026326945@@127.0.0.1@3306@wec
-- ============================================================
-- FILE: penalties.sql
-- DESC: Penalizaciones y su relación con resultados
-- ============================================================
USE wec;

INSERT INTO penalties (penalty_type, reason, penalty_value, penalty_applies_to) VALUES
('TIME',   'Speeding in pit lane',                          30.00, 'TEAM'),
('TIME',   'Unsafe release from pit box',                   10.00, 'TEAM'),
('POINTS', 'Causing a collision',                            5.00, 'PILOT'),
('TIME',   'Ignoring blue flags',                           20.00, 'PILOT'),
('DSQ',    'Technical infringement post-race inspection',    0.00, 'TEAM'),
('DNF',    'Engine failure during race',                     0.00, 'TEAM'),
('POINTS', 'Exceeding track limits repeatedly',              3.00, 'PILOT'),
('TIME',   'Pit stop procedure violation',                  15.00, 'TEAM'),
('POINTS', 'Dangerous driving under safety car',             5.00, 'PILOT'),
('TIME',   'Refueling infringement',                        10.00, 'TEAM');

-- Asignación de penalizaciones a resultados (penalties_results)
-- id_result 1 = Toyota #2 P1 Le Mans (tenía penalización de tiempo en pit)
-- id_result 5 = Ferrari #2 P5 Le Mans (colisión)
-- id_result 7 = Porsche #2 P7 Le Mans (DNF convertido en clasificado)
INSERT INTO penalties_results (id_penalty, id_result) VALUES
(1, 1),   -- Speeding pit lane → Toyota #2 Le Mans P1
(3, 5),   -- Causing collision → Ferrari #2 Le Mans P5
(8, 7),   -- Pit stop violation → Porsche #2 Le Mans P7
(2, 15),  -- Unsafe release → Ferrari #1 Spa P1
(4, 19),  -- Ignoring blue flags → Porsche #1 Bahrain P2
(7, 27);  -- Exceeding track limits → Toyota #2 Fuji P1