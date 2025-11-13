-- CODIGO DE CHATGPT PARA INSERCION DE REGISTROS EN LA BASE DE DATOS

USE diagrama1;

-- =====================
-- 1️⃣ Tabla: fabricas
-- =====================
INSERT INTO fabricas (id_fabrica, nombre, telefono, num_articulos, fk_fabrica_sustituta)
VALUES 
(1, 'TecnoParts', '555-1234', 3, NULL),
(2, 'MecaChile', '555-5678', 2, 1),
(3, 'InduMetal', '555-8765', 4, NULL);

-- =====================
-- 2️⃣ Tabla: articulos
-- =====================
INSERT INTO articulos (id_articulo, nombre, descripcion, stock_articulo, fabrica, lote)
VALUES
(101, 'Tornillo', 'Tornillo de acero 10mm', 200, 'TecnoParts', '2025-01-15'),
(102, 'Tuerca', 'Tuerca galvanizada 8mm', 350, 'TecnoParts', '2025-02-10'),
(103, 'Perno', 'Perno industrial 20mm', 120, 'MecaChile', '2025-03-01'),
(104, 'Arandela', 'Arandela reforzada 10mm', 500, 'InduMetal', '2025-01-20'),
(105, 'Clavo', 'Clavo para madera 5cm', 1000, 'InduMetal', '2025-03-12');

-- =====================
-- 3️⃣ Tabla: articulos_fabricas
-- =====================
INSERT INTO articulos_fabricas (id_articulo, id_fabrica)
VALUES
(101, 1),
(102, 1),
(103, 2),
(104, 3),
(105, 3);

-- =====================
-- 4️⃣ Tabla: direcciones
-- =====================
INSERT INTO direcciones (ciudad, comuna, calle, piso, puerta)
VALUES
('Santiago', 'Centro', 'Alameda', 2, 'B'),
('Valpo', 'Puerto', 'Condell', 1, 'A'),
('Conce', 'Norte', 'Prat', 3, 'C'),
('LaSerena', 'Coquimbo', 'Ovalo', 4, 'D');

-- =====================
-- 5️⃣ Tabla: clientes
-- =====================
INSERT INTO clientes (limite_credito, saldo, descuento)
VALUES
(500000, 150000.50, 10),
(250000, 50000.00, 5),
(800000, 300000.00, 15),
(1000000, 0.00, 20);

-- =====================
-- 6️⃣ Tabla: pedidos
-- =====================
INSERT INTO pedidos (num_cliente, direccion, fecha, num_articulo, cantidad_total)
VALUES
('1', 'Alameda 2B', '2025-03-10 10:30:00', '101', 50),
('2', 'Condell 1A', '2025-03-12 14:00:00', '103', 25),
('3', 'Prat 3C', '2025-03-15 09:45:00', '104', 100),
('1', 'Alameda 2B', '2025-03-18 16:30:00', '102', 75);

-- =====================
-- 7️⃣ Tabla: cliente_direcciones_pedidos
-- =====================
INSERT INTO cliente_direcciones_pedidos (id_cliente, id_direccion, id_pedido)
VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3),
(1, 1, 4);

-- =====================
-- 8️⃣ Tabla: detalles_pedido
-- =====================
INSERT INTO detalles_pedido (id_pedido, id_articulo, cantidad, precio_producto)
VALUES
(1, 101, 50, 120.5),
(2, 103, 25, 250.0),
(3, 104, 100, 75.9),
(4, 102, 75, 90.0);