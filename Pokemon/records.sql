-- Active: 1762272161423@@127.0.0.1@3306@pokebase
USE pokebase;

INSERT INTO pokemon (nombre, tipo1, tipo2, generacion) VALUES
('Bulbasaur',  'Planta',  'Veneno', 1),
('Ivysaur',    'Planta',  'Veneno', 1),
('Venusaur',   'Planta',  'Veneno', 1),
('Charmander', 'Fuego',   NULL,     1),
('Charmeleon', 'Fuego',   NULL,     1),
('Charizard',  'Fuego',   'Volador',1),
('Squirtle',   'Agua',    NULL,     1),
('Wartortle',  'Agua',    NULL,     1),
('Blastoise',  'Agua',    NULL,     1),
('Pikachu',    'Eléctrico', NULL,   1),
('Raichu',     'Eléctrico', NULL,   1);

INSERT INTO estadisticas_base (id_stat, id_pokemon, ps, ataque, defensa, ataque_esp, defensa_esp, velocidad) VALUES
(1,  1, 45, 49, 49, 65, 65, 45),  -- Bulbasaur
(2,  2, 60, 62, 63, 80, 80, 60),  -- Ivysaur
(3,  3, 80, 82, 83, 100,100,80),  -- Venusaur
(4,  4, 39, 52, 43, 60, 50, 65),  -- Charmander
(5,  5, 58, 64, 58, 80, 65, 80),  -- Charmeleon
(6,  6, 78, 84, 78, 109,85,100),  -- Charizard
(7,  7, 44, 48, 65, 50, 64, 43),  -- Squirtle
(8,  8, 59, 63, 80, 65, 80, 58),  -- Wartortle
(9,  9, 79, 83,100, 85,105, 78),  -- Blastoise
(10,10,35, 55, 40, 50, 50, 90),   -- Pikachu
(11,11,60, 90, 55, 90, 80,110);   -- Raichu

INSERT INTO evoluciones (id_pokemon_origen, id_pokemon_destino, metodo, nivel_requerido) VALUES
(1, 2,  'Subir nivel', 16),  -- Bulbasaur -> Ivysaur
(2, 3,  'Subir nivel', 32),  -- Ivysaur -> Venusaur
(4, 5,  'Subir nivel', 16),  -- Charmander -> Charmeleon
(5, 6,  'Subir nivel', 36),  -- Charmeleon -> Charizard
(7, 8,  'Subir nivel', 16),  -- Squirtle -> Wartortle
(8, 9,  'Subir nivel', 36),  -- Wartortle -> Blastoise
(10,11,'Piedra Trueno', NULL); -- Pikachu -> Raichu

INSERT INTO movimientos (nombre, tipo, potencia, precision_mov) VALUES
('Placaje',        'Normal',    40, 100),
('Látigo Cepa',    'Planta',    45, 100),
('Ascuas',         'Fuego',     40, 100),
('Lanzallamas',    'Fuego',     90, 100),
('Pistola Agua',   'Agua',      40, 100),
('Hidrobomba',     'Agua',     110,  80),
('Impactrueno',    'Eléctrico', 40, 100),
('Rayo',           'Eléctrico', 90, 100),
('Hoja Afilada',   'Planta',    55,  95),
('Tormenta Floral','Planta',   120,  85);

INSERT INTO habilidades (nombre, descripcion) VALUES
('Espesura',  'Potencia los movimientos de tipo Planta cuando los PS son bajos.'),
('Mar Llamas','Potencia los movimientos de tipo Fuego cuando los PS son bajos.'),
('Torrente',  'Potencia los movimientos de tipo Agua cuando los PS son bajos.'),
('Electricidad Estática', 'Puede paralizar al rival al contacto.'),
('Cicatriz Lucha', 'Aumenta el ataque cuando los PS son bajos.');

-- Bulbasaur (1)
INSERT INTO pokemon_movimientos (id_pokemon, id_movimiento, metodo_aprendizaje, nivel_requerido) VALUES
(1, 1, 'Nivel', 1),   -- Placaje
(1, 2, 'Nivel', 9),   -- Látigo Cepa
(1, 9, 'Nivel', 20),  -- Hoja Afilada
(1,10, 'MT',   0);    -- Tormenta Floral (ejemplo MT)

-- Charmander (4)
INSERT INTO pokemon_movimientos (id_pokemon, id_movimiento, metodo_aprendizaje, nivel_requerido) VALUES
(4, 1, 'Nivel', 1),   -- Placaje
(4, 3, 'Nivel', 7),   -- Ascuas
(4, 4, 'Nivel', 34);  -- Lanzallamas

-- Squirtle (7)
INSERT INTO pokemon_movimientos (id_pokemon, id_movimiento, metodo_aprendizaje, nivel_requerido) VALUES
(7, 1, 'Nivel', 1),   -- Placaje
(7, 5, 'Nivel', 8),   -- Pistola Agua
(7, 6, 'Nivel', 42);  -- Hidrobomba

-- Pikachu (10)
INSERT INTO pokemon_movimientos (id_pokemon, id_movimiento, metodo_aprendizaje, nivel_requerido) VALUES
(10,1, 'Nivel', 1),   -- Placaje
(10,7, 'Nivel', 5),   -- Impactrueno
(10,8, 'MT',   0);    -- Rayo por MT

-- Bulbasaur, Ivysaur, Venusaur -> Espesura
INSERT INTO pokemon_habilidades (id_pokemon, id_habilidad, es_oculta) VALUES
(1, 1, FALSE),
(2, 1, FALSE),
(3, 1, FALSE);

-- Charmander, Charmeleon, Charizard -> Mar Llamas
INSERT INTO pokemon_habilidades (id_pokemon, id_habilidad, es_oculta) VALUES
(4, 2, FALSE),
(5, 2, FALSE),
(6, 2, FALSE);

-- Squirtle, Wartortle, Blastoise -> Torrente
INSERT INTO pokemon_habilidades (id_pokemon, id_habilidad, es_oculta) VALUES
(7, 3, FALSE),
(8, 3, FALSE),
(9, 3, FALSE);

-- Pikachu, Raichu -> Electricidad Estática
INSERT INTO pokemon_habilidades (id_pokemon, id_habilidad, es_oculta) VALUES
(10,4, FALSE),
(11,4, FALSE);
