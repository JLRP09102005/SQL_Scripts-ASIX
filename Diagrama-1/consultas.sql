DROP DATABASE diagrama1;

-- Seleccionar todas las columnas de la tabla clientes
SELECT * FROM clientes;

-- Seleccionar el id, la calle, el piso, y la puerta de la tabla direcciones
SELECT id_direccion, calle, piso, puerta FROM direcciones;

-- Seleccionar todas las fabricas con una cantidad de articulos mayor a 15
SELECT * FROM fabricas
WHERE num_articulos >= 15;

-- Relacionar las fabricas con los articulos que las proveen
SELECT * FROM fabricas
INNER JOIN articulos ON fabricas.nombre = articulos.fabrica;

SELECT 
    fabricas.nombre,
    articulos.id_articulo,
    articulos.nombre
FROM fabricas
INNER JOIN articulos
ON fabricas.nombre = articulos.fabrica;