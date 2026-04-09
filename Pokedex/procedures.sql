USE pokedex;

DELIMITER //
CREATE PROCEDURE TransferPokemon(IN id_origin INT, IN id_destination INT, IN id_pokemon INT)
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT "Error: pokemon transfer failure" as mensaje
    END;

    DECLARE EXIT HANDLER FOR SQLSTATE '45000'
    BEGIN
        ROLLBACK;
        SELECT CONCAT("Error with", error_reason, "data") as mensaje;
    END;

    DECLARE origin_checker INT DEFAULT 0;
    DECLARE destination_checker INT DEFAULT 0;
    DECLARE pokemon_checker INT DEFAULT 0;
    DECLARE error_reason CHAR(10) DEFAULT 'No Reason';

    SELECT id INTO origin_checker FROM jugadores WHERE id = id_origin;
    IF origin_checkes IS NULL THEN
        SET error_reason = " player origin id ";
        SIGNAL SQLSTATE '45000';
    END IF;

    SELECT id INTO destination_checker FROM jugadores WHERE id = id_destination;
    IF destination_checker IS NULL THEN
        SET error_reason = " player destination id ";
        SIGNAL SQLSTATE '45000';
    END IF;

    SELECT pokemon_id INTO pokemon_checker FROM mochila_jugador WHERE pokemon_id = id_pokemon AND jugador_id = id_origin;
    IF pokemon_checker IS NULL THEN
        SET error_reason = " pokemon owner ";
        SIGNAL SQLSTATE '45000';
    END IF; 

    START TRANSACTION;

    DELETE FROM mochila_jugador
    WHERE jugador_id = id_origin AND pokemon_id = id_pokemon;

    INSERT INTO mochila_jugador(jugador_id, pokemon_id, fecha_captura)
    VALUES(id_destination, id_pokemon, NOW());

    COMMIT;

    SELECT "Pokemon transfer successful" as mensaje

END//
DELIMITER ;