DELIMITER //

CREATE PROCEDURE AddTeamPenalty ( IN penalty_type VARCHAR(20), IN penalty_value DECIMAL(7,2), IN vehicle_id INT, IN team_id INT, IN race_id INT )
NOT DETERMINISTIC
MODIFIES SQL DATA
BEGIN

    #Declarar una variable "affected_rows" de tipo INT y por defecto con valor 0

    #Declarar un exit handler para un sqlexception
        #Un rollback para que la transaccion la cual contiene el error vuelva a poner los valores anteriores a los cambios
        #Un resignal para reanunciar el motivo del evento de error
    
    ##Comienzo de transaccion

    #Comprobar el estado del penalty (POINTS,TIME,DNF)
    #-Se calcula los puntos de resultado restado al del penalty y se actualiza
    #-Despues de calcular e insertar, insertar en en la variable affected_rows cuantos registros fueron afectados
    #-En el caso de que no sea correcto el estado de penalty enviar un signal sqlstate 45000

    #Comprobar si affected_rows tiene registros afectados
    #-En el caso de no tenerlosenviar un signal sqlstate 45000 avisando de esto

    ##Final de transaccion

END //

CREATE PROCEDURE AddPilotPenalty ( IN penalty_type VARCHAR(20), IN penalty_value DECIMAL(7,2), IN result_id INT )
NOT DETERMINISTIC
MODIFIES SQL DATA
BEGIN
    DECLARE affected_rows INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    IF (penalty_type = 'POINTS') THEN
        UPDATE results res
        SET res.penalty_points_pilot = GREATEST(0, res.penalty_points_pilot - FLOOR(penalty_value))
        WHERE res.id_result = result_id;

        SET affected_rows = ROW_COUNT();

    ELSEIF (penalty_type = 'TIME') THEN
        UPDATE results res
        SET res.penalty_time = ADDTIME(res.penalty_time, SEC_TO_TIME(penalty_value))
        WHERE res.id_result = result_id;

        SET affected_rows = ROW_COUNT();

    ELSEIF (penalty_type = 'DNF' || penalty_type = 'DSQ') THEN
        UPDATE results res
        SET 
            res.penalty_time = SEC_TO_TIME(0),
            res.penalty_points_pilot = 0
        WHERE res.id_result = result_id;

        SET affected_rows = ROW_COUNT();

    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid penalty_type';
    END IF;

    IF (CheckAfectedRowsCount(affected_rows)) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No affected rows';
    END IF;

    COMMIT;
END //