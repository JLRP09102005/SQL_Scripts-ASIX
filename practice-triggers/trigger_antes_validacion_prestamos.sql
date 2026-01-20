DELIMITER $$

CREATE TRIGGER validar_antes_prestamo
BEFORE INSERT ON prestamos;
BEGIN

-- PREPARACION de las variables y datos que necesitaos para VALIDAR
    DECLARE disponibles INT;
    DECLARE prestamos_socio INT;
    DECLARE limite_socio INT;

    SELECT cantidad_disponible INTO disponibles
    FROM libros
    WHERE libro_id = NEW.libro_id;

    SELECT prestamos_activos INTO prestamos_socio
    FROM socios
    WHERE socio_id = NEW.socio_id;

-- 1a Validacion
    IF disponibles <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'There are no books';
    END IF;

-- 2a Validacion
    SELECT max_prestamos INTO limite_socio
    FROM socios
    WHERE socio_id = NEW.socio_id;

    IF prestamos_socio >= limite_socio THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "There's no more book loans";
    END IF;
END;

$$