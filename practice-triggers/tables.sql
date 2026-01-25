CREATE DATABASE biblioteca;
USE biblioteca;

CREATE TABLE libros (
    libro_id INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(200) NOT NULL,
    autor VARCHAR(100) NOT NULL,
    cantidad_total INT DEFAULT 3,
    cantidad_disponible INT DEFAULT 3,
    fecha_ultimo_prestamo DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE socios (
    socio_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(250) NOT NULL,
    prestamos_activos INT DEFAULT 0,
    max_prestamos INT DEFAULT 2,
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE prestamos (
    prestamo_id INT PRIMARY KEY AUTO_INCREMENT,
    libro_id INT NOT NULL,
    socio_id INT NOT NULL,
    fecha_prestamo DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_devolucion DATE,

    FOREIGN KEY (libro_id) REFERENCES libros(libros_id),
    FOREIGN KEY (socios_id) REFERENCES socios(socios_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;