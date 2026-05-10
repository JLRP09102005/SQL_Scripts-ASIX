-- Active: 1763026326945@@127.0.0.1@3306@wec
-- ============================================================
-- FILE: circuits.sql
-- DESC: Datos iniciales de circuitos
-- ============================================================
USE wec;

INSERT INTO circuits (circuit_name, country, length_km, direction) VALUES
('Circuit de la Sarthe',        'France',       13.63, 'CLOCKWISE'),
('Spa-Francorchamps',           'Belgium',       7.00, 'CLOCKWISE'),
('Bahrain International Circuit','Bahrain',      5.41, 'CLOCKWISE'),
('Fuji Speedway',               'Japan',         4.56, 'CLOCKWISE'),
('Circuit of the Americas',     'United States', 5.51, 'COUNTERCLOCKWISE'),
('Autodromo di Monza',          'Italy',         5.79, 'CLOCKWISE'),
('Portimão',                    'Portugal',      4.68, 'CLOCKWISE'),
('São Paulo Circuit',           'Brazil',        4.31, 'COUNTERCLOCKWISE');