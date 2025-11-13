CREATE DATABASE IF NOT EXISTS diagrama1;
USE diagrama1;

-- =====================
-- Declaracion de tablas
-- =====================
CREATE TABLE direcciones(
    id_direccion INT PRIMARY KEY AUTO_INCREMENT,
    ciudad VARCHAR(10) NOT NULL,
    comuna VARCHAR(10) NOT NULL,
    calle VARCHAR(10) NOT NULL,
    piso INT NOT NULL,
    puerta VARCHAR(10) NOT NULL
);

CREATE TABLE clientes(
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    limite_credito FLOAT NOT NULL,
    saldo DECIMAL(10,2) NOT NULL,
    descuento DECIMAL(10,2)
);

CREATE TABLE pedidos(
    id_pedido INT PRIMARY KEY AUTO_INCREMENT,
    num_cliente VARCHAR(10) NOT NULL,
    direccion VARCHAR(50) NOT NULL,
    fecha DATETIME NOT NULL,
    num_articulo VARCHAR(10) NOT NULL,
    cantidad_total INT NOT NULL
);

CREATE TABLE articulos(
    id_articulo INT PRIMARY KEY,
    nombre VARCHAR(10) NOT NULL,
    descripcion VARCHAR(50) NOT NULL,
    stock_articulo INT NOT NULL,
    fabrica VARCHAR(10) NOT NULL,
    lote DATE NOT NULL
);

CREATE TABLE fabricas(
    id_fabrica INT PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    num_articulos INT NOT NULL,
    fk_fabrica_sustituta INT NULL
);

-- =================================
-- Declaracion de tablas intermedias
-- =================================
CREATE TABLE cliente_direcciones_pedidos(
    id_cliente INT NOT NULL,
    id_direccion INT NOT NULL,
    id_pedido INT NOT NULL,
    PRIMARY KEY (id_cliente, id_direccion, id_pedido)
);

CREATE TABLE detalles_pedido(
    id_pedido INT NOT NULL,
    id_articulo INT NOT NULL,
    cantidad INT NOT NULL,
    precio_producto FLOAT NOT NULL,
    PRIMARY KEY (id_pedido, id_articulo)
);

CREATE TABLE articulos_fabricas(
    id_articulo INT NOT NULL,
    id_fabrica INT NOT NULL,
    PRIMARY KEY (id_articulo, id_fabrica)
);

-- =================================================
-- Declaracion de foreign keys y acciones en cascada
-- =================================================
ALTER TABLE fabricas
ADD CONSTRAINT fk_fabrica_sustituta
FOREIGN KEY (fk_fabrica_sustituta) REFERENCES fabricas(id_fabrica)
ON DELETE SET NULL
ON UPDATE CASCADE;

ALTER TABLE cliente_direcciones_pedidos
ADD CONSTRAINT fk_cdp_cliente
FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
ON DELETE CASCADE
ON UPDATE CASCADE,
ADD CONSTRAINT fk_cdp_direccion
FOREIGN KEY (id_direccion) REFERENCES direcciones(id_direccion)
ON DELETE CASCADE
ON UPDATE CASCADE,
ADD CONSTRAINT fk_cdp_pedido
FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE detalles_pedido
ADD CONSTRAINT fk_detped_pedido
FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
ON DELETE CASCADE
ON UPDATE CASCADE,
ADD CONSTRAINT fk_detped_articulo
FOREIGN KEY (id_articulo) REFERENCES articulos(id_articulo)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE articulos_fabricas
ADD CONSTRAINT fk_artfab_articulo
FOREIGN KEY (id_articulo) REFERENCES articulos(id_articulo)
ON DELETE CASCADE
ON UPDATE CASCADE,
ADD CONSTRAINT fk_artfab_fabrica
FOREIGN KEY (id_fabrica) REFERENCES fabricas(id_fabrica)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- =================================================
-- TimeStamps de auditoria
-- =================================================
ALTER TABLE direcciones
ADD COLUMN fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
ON UPDATE CURRENT_TIMESTAMP;

ALTER TABLE clientes
ADD COLUMN fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
ON UPDATE CURRENT_TIMESTAMP;

ALTER TABLE pedidos
ADD COLUMN fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
ON UPDATE CURRENT_TIMESTAMP;

ALTER TABLE articulos
ADD COLUMN fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
ON UPDATE CURRENT_TIMESTAMP;

ALTER TABLE fabricas
ADD COLUMN fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
ON UPDATE CURRENT_TIMESTAMP;

ALTER TABLE detalles_pedido
ADD COLUMN fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
ON UPDATE CURRENT_TIMESTAMP;

-- ========================================================
-- Validacion de datos con check
-- ========================================================
ALTER TABLE clientes
ADD CONSTRAINT chk_cli_saldo_positivo CHECK (saldo >= 0),
ADD CONSTRAINT chk_cli_rango_descuento CHECK (descuento >= 0 AND descuento <= 100);

ALTER TABLE pedidos
ADD CONSTRAINT chk_ped_cantidad_positiva CHECK (cantidad_total >= 0);

ALTER TABLE articulos
ADD CONSTRAINT chk_art_stock_positivo CHECK (stock_articulo >= 0);

ALTER TABLE fabricas
ADD CONSTRAINT chk_fab_num_articulos_positivo CHECK (num_articulos >= 0);

ALTER TABLE detalles_pedido
ADD CONSTRAINT chk_detped_cantidad_positiva CHECK (cantidad >= 0),
ADD CONSTRAINT chk_detped_precio_producto_positivo CHECK (precio_producto >= 0);

-- ========================================================
-- Creacion de indices para el rendimiento de las consultas
-- ========================================================
CREATE INDEX idx_cliente_direcciones ON cliente_direcciones_pedidos(id_cliente);
CREATE INDEX idx_pedido_fecha ON pedidos(fecha);