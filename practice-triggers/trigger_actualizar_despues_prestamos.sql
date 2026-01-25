-- CREATE TRIGGER Se actualice (UPDATE a socion en el cuerpo) despues de recibir un prestamo (AFTER INSERT en prestamos) para actualizar los libros disponibles (UPDATE en el cuerpo) y los prestamos (= pero en tabla prestamos) activos en socios

DELIMITER $$

CREATE TRIGGER actualizar_despues_prestamos
AFTER INSERT ON prestamos
FOR EACH ROW
BEGIN
    /*2 ACCIONES: 1) Actualice la informacion en LIBROS disminuyendo la cantidad disponible en 1 
                  2) Actualice la informacion en SOCIOS aumentando en 1 los prestamos activos*/
    UPDATE libros
    SET cantidad_disponible = cantidad_disponible -1,
        fecha_ultimo_prestamos = NOW()
    WHERE libro_id = NEW.libro_id;

    UPDATE socios
    SET prestamos_activos = prestamos_activos +1,
    WHERE socio_id = NEW.socio_id;

$$