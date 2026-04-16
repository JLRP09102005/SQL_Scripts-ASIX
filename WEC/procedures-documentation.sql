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
    #Declarar una variable "affected_rows" de tipo INT y por defecto con valor 0

    #Declarar un exit handler para un sqlexception
        #Un rollback para que la transaccion la cual contiene el error vuelva a poner los valores anteriores a los cambios
        #Un resignal para reanunciar el motivo del evento de error

    ##Comienzo de la transaccion

    #Comprobar el estado del penalty (POINTS,TIME,DNF)
    #-Se calcula los puntos de resultado restado al del penalty y se actualiza
    #-Despues de calcular e insertar, insertar en en la variable affected_rows cuantos registros fueron afectados
    #-En el caso de que no sea correcto el estado de penalty enviar un signal sqlstate 45000

    #Comprobar si affected_rows tiene registros afectados
    #-En el caso de no tenerlosenviar un signal sqlstate 45000 avisando de esto

    ##Final de transaccion

END //

CREATE PROCEDURE GetPenaltyBasicInfo ( IN id_penalty INT, OUT penalty_type VARCHAR(20), OUT penalty_applies VARCHAR(20), OUT penalty_value DECIMAL(7,2) )
DETERMINISTIC
READS SQL DATA
BEGIN

    #Crear un select para sacar de la tabla de penalties la informacion de un penalty en especifico

END //

CREATE PROCEDURE GetResultsForeignInfo ( IN result_id INT, OUT vehicle_id INT, OUT team_id INT, OUT race_id INT )
DETERMINISTIC
READS SQL DATA
BEGIN
    
    #Crear un select para sacar de la tabla de resultados la informacion de un resultado en especifico

END //

CREATE PROCEDURE ProcessResultPenalty ( IN id_penalty INT, IN id_result INT )
DETERMINISTIC
MODIFIES SQL DATA
BEGIN

    #Declarar una variable "penalty_type" de tipo VARCHAR(20) por defecto con valor 'POINTS'
    #Declarar una variable "penalty_applies" de tipo VARCHAR(20) por defecto con valor 'PILOT'
    #Declarar una variable "penalty_value" de tipo DECIMAL(7,2) por defecto con valor 0
    #Declarar una variable "vehicle_id" de tipo INT por defecto con valor NULL
    #Declarar una variable "team_id" de tipo INT por defecto con valor NULL
    #Declarar una variable "race_id" de tipo INT por defecto con valor NULL

    #LLamada al procedimiento GetPenaltyBasicInfo
    #LLamada al procedimiento GetResultsForeignInfo

    #Condicional if que compruebe si la penalizacion se aplica al piloto o al equipo
    #-En el caso de que se aplique al piloto se llama al procedimiento AddPilotPenalty
    #-En el caso de que se aplique al equipo se llama al procedimiento AddTeamPenalty

END //

CREATE PROCEDURE AddResultPoints(IN race_id INT, IN result_id INT, IN result_points TINYINT)
DETERMINISTIC
MODIFIES SQL DATA
BEGIN

    #Declarar un exit handler para SQLEXCEPTION
        #Hacer un rollback a cualquier transaccion ocurrida
        #Hacer un resignal para volver a lanzar el evento de error
    
    ##Comenzar la transaccion

    #Actualizar la base de datos resultados con la informacion 



    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    UPDATE results res SET
        res.base_points_team = result_points,
        res.base_points_pilot = result_points,
        res.penalty_points_team = result_points,
        res.penalty_points_pilot = result_points
    WHERE 
        res.id_race = race_id AND
        res.id_result = result_id;
    COMMIT;
END //