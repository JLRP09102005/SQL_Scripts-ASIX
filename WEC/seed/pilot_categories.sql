-- ============================================================
-- FILE: pilot_categories.sql
-- DESC: Datos iniciales de categorías de piloto
-- ============================================================
USE wec;

INSERT INTO pilot_categories (pilot_category_name, pilot_category_description, min_age) VALUES
('Platinum', 'Top professional drivers with extensive top-tier racing experience', 25),
('Gold',     'Highly experienced professional drivers',                            23),
('Silver',   'Semi-professional drivers with significant racing background',       21),
('Bronze',   'Gentleman drivers or drivers with limited professional experience',  18);