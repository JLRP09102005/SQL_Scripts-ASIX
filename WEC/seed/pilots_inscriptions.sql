-- ============================================================
-- FILE: pilots_inscriptions.sql
-- DESC: Asignación de pilotos a inscripciones
--       PK: (id_pilot, id_vehicle, id_race, id_team)
--
-- Pilotos por equipo (ver 05_pilots.sql):
--   Toyota(1):      1-6    | Ferrari(2):      7-12
--   Porsche(3):    13-18   | Peugeot(4):     19-24
--   BMW(5):        25-27   | Cadillac(6):    28-30
--   Lamborghini(7):31-33   | Alpine(8):      34-36
--   United(9):     37-39   | Proton(10):     40-42
-- ============================================================
USE wec;

INSERT INTO pilots_inscriptions (id_pilot, id_vehicle, id_race, id_team) VALUES
(1, 1, 4, 1), (2, 1, 4, 1), (3, 1, 4, 1),-- Toyota #1 (v1, team 1): Buemi, Hartley, Hirakawa -- ── Le Mans (race 4) ─────────────────────────────────────────
(4, 2, 4, 1), (5, 2, 4, 1), (6, 2, 4, 1),-- Toyota #2 (v2, team 1): Conway, Kobayashi, Lopez
(7, 3, 4, 2), (8, 3, 4, 2), (9, 3, 4, 2),-- Ferrari #1 (v3, team 2): Pier Guidi, Calado, Giovinazzi
(10, 4, 4, 2), (11, 4, 4, 2), (12, 4, 4, 2),-- Ferrari #2 (v4, team 2): Molina, Nielsen, Kubica
(13, 5, 4, 3), (14, 5, 4, 3), (15, 5, 4, 3),-- Porsche #1 (v5, team 3): Estre, Lotterer, Vanthoor L
(17, 6, 4, 3), (18, 6, 4, 3),-- Porsche #2 (v6, team 3): Campbell, Christensen
(19, 7, 4, 4), (20, 7, 4, 4), (21, 7, 4, 4),-- Peugeot #1 (v7, team 4): Duval, Menezes, Muller
(22, 8, 4, 4), (23, 8, 4, 4), (24, 8, 4, 4),-- Peugeot #2 (v8, team 4): di Resta, Jensen, Vergne
(25, 9, 4, 5), (26, 9, 4, 5), (27, 9, 4, 5),-- BMW #1 (v9, team 5): D.Vanthoor, Marciello, Wittmann
(28, 10, 4, 5), (29, 10, 4, 5),-- BMW #2 (v10, team 5): van der Zande, Dixon
(28, 11, 4, 6), (29, 11, 4, 6), (30, 11, 4, 6),-- Cadillac #1 (v11, team 6): van der Zande, Dixon, Lynn
(31, 12, 4, 6), (32, 12, 4, 6),-- Cadillac #2 (v12, team 6): Kvyat, Bortolotti
(31, 13, 4, 7), (32, 13, 4, 7), (33, 13, 4, 7),-- Lamborghini #1 (v13, team 7): Kvyat, Bortolotti, Caldarelli
(34, 14, 4, 7), (35, 14, 4, 7),-- Lamborghini #2 (v14, team 7): Lapierre, Vaxiviere
(34, 15, 4, 8), (35, 15, 4, 8), (36, 15, 4, 8),-- Alpine #1 (v15, team 8): Lapierre, Vaxiviere, Milesi
(37, 16, 4, 8), (38, 16, 4, 8),-- Alpine #2 (v16, team 8): Hanson, Jarvis
(37, 17, 4, 9), (38, 17, 4, 9), (39, 17, 4, 9),-- United #1 (v17, team 9): Hanson, Jarvis, Gamble
(40, 18, 4, 9), (41, 18, 4, 9),-- United #2 (v18, team 9): Ried, Sturm
(40, 19, 4, 10), (41, 19, 4, 10), (42, 19, 4, 10),-- Proton #1 (v19, team 10): Ried, Sturm, Tincknell
(1, 20, 4, 10), (2, 20, 4, 10),-- Proton #2 (v20, team 10): Buemi, Hartley
(1, 1, 3, 1), (2, 1, 3, 1),-- ── Spa (race 3) ─────────────────────────────────────────────
(4, 2, 3, 1), (5, 2, 3, 1),
(7, 3, 3, 2), (8, 3, 3, 2),
(10, 4, 3, 2), (11, 4, 3, 2),
(13, 5, 3, 3), (14, 5, 3, 3),
(17, 6, 3, 3), (18, 6, 3, 3),
(19, 7, 3, 4), (20, 7, 3, 4),
(22, 8, 3, 4), (23, 8, 3, 4),
(25, 9, 3, 5), (26, 9, 3, 5),
(28, 10, 3, 5), (29, 10, 3, 5),
(34, 15, 3, 8), (35, 15, 3, 8),
(36, 16, 3, 8), (37, 16, 3, 8),
(1, 1, 7, 1), (2, 1, 7, 1), (3, 1, 7, 1),-- ── Bahrain (race 7) ─────────────────────────────────────────
(4, 2, 7, 1), (5, 2, 7, 1), (6, 2, 7, 1),
(7, 3, 7, 2), (8, 3, 7, 2),
(10, 4, 7, 2), (11, 4, 7, 2),
(13, 5, 7, 3), (14, 5, 7, 3),
(17, 6, 7, 3), (18, 6, 7, 3),
(28, 11, 7, 6), (29, 11, 7, 6), (30, 11, 7, 6),
(31, 12, 7, 6), (32, 12, 7, 6),
(31, 13, 7, 7), (32, 13, 7, 7), (33, 13, 7, 7),
(34, 14, 7, 7), (35, 14, 7, 7),
(1, 1, 6, 1), (2, 1, 6, 1),-- ── Fuji (race 6) ────────────────────────────────────────────
(4, 2, 6, 1), (5, 2, 6, 1),
(7, 3, 6, 2), (8, 3, 6, 2),
(10, 4, 6, 2), (11, 4, 6, 2),
(25, 9, 6, 5), (26, 9, 6, 5),
(28, 10, 6, 5), (29, 10, 6, 5),
(34, 15, 6, 8), (35, 15, 6, 8),
(36, 16, 6, 8), (37, 16, 6, 8);