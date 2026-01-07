CREATE DATABASE IF NOT EXISTS pokebase;
USE pokebase;

---------------------------------
-- TABLES
---------------------------------

CREATE TABLE IF NOT EXISTS pokemon (
    id_pokemon INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    tipo1 VARCHAR(20) NOT NULL,
    tipo2 VARCHAR(20),
    generacion TINYINT NOT NULL
);

CREATE TABLE IF NOT EXISTS estadisticas_base (
    id_stat INT PRIMARY KEY,
    id_pokemon INT NOT NULL,
    ps INT NOT NULL,
    ataque INT NOT NULL,
    defensa INT NOT NULL,
    ataque_esp INT NOT NULL,
    defensa_esp INT NOT NULL,
    velocidad INT NOT NULL
);

CREATE TABLE IF NOT EXISTS evoluciones (
    id_pokemon_origen INT,
    id_pokemon_destino INT,
    metodo VARCHAR(50),
    nivel_requerido INT
);

CREATE TABLE IF NOT EXISTS movimientos (
    id_movimiento INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    tipo VARCHAR(20),
    potencia INT,
    precision_mov INT
);

CREATE TABLE IF NOT EXISTS habilidades (
    id_habilidad INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50),
    descripcion TEXT
);

---------------------------------
-- INTERMEDIATE TABLES
---------------------------------

CREATE TABLE IF NOT EXISTS pokemon_movimientos (
    id_pokemon INT,
    id_movimiento INT,
    metodo_aprendizaje VARCHAR(30), #nivel, MT, tutor...
    nivel_requerido INT
);

CREATE TABLE IF NOT EXISTS pokemon_habilidades (
    id_pokemon INT,
    id_habilidad INT,
    es_oculta BOOLEAN DEFAULT FALSE
);

---------------------------------
-- KEY CONSTRAINTS
---------------------------------

ALTER TABLE estadisticas_base
ADD FOREIGN KEY (id_pokemon) REFERENCES pokemon(id_pokemon);

ALTER TABLE evoluciones
ADD PRIMARY KEY(id_pokemon_origen, id_pokemon_destino),
ADD FOREIGN KEY (id_pokemon_origen) REFERENCES pokemon(id_pokemon),
ADD FOREIGN KEY (id_pokemon_destino) REFERENCES pokemon(id_pokemon);

ALTER TABLE pokemon_movimientos
ADD PRIMARY KEY (id_pokemon, id_movimiento),
ADD FOREIGN KEY (id_pokemon) REFERENCES pokemon(id_pokemon),
ADD FOREIGN KEY (id_movimiento) REFERENCES movimientos(id_movimiento);

ALTER TABLE pokemon_habilidades
ADD PRIMARY KEY (id_pokemon, id_habilidad),
ADD FOREIGN KEY (id_pokemon) REFERENCES pokemon(id_pokemon),
ADD FOREIGN KEY (id_habilidad) REFERENCES habilidades(id_habilidad);