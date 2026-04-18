DELIMITER //

CREATE PROCEDURE sp_AddTeamPenalty ( IN penalty_type VARCHAR(20), IN penalty_value DECIMAL(7,2), IN vehicle_id INT, IN team_id INT, IN race_id INT )
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
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

CREATE PROCEDURE sp_AddPilotPenalty ( IN penalty_type VARCHAR(20), IN penalty_value DECIMAL(7,2), IN result_id INT )
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
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

CREATE PROCEDURE sp_GetPenaltyBasicInfo ( IN id_penalty INT, OUT penalty_type VARCHAR(20), OUT penalty_applies VARCHAR(20), OUT penalty_value DECIMAL(7,2) )
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Crear un select para sacar de la tabla de penalties la informacion de un penalty en especifico

END //

CREATE PROCEDURE sp_GetResultsForeignInfo ( IN result_id INT, OUT vehicle_id INT, OUT team_id INT, OUT race_id INT )
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
BEGIN
    
    #Crear un select para sacar de la tabla de resultados la informacion de un resultado en especifico

END //

CREATE PROCEDURE sp_ProcessResultPenalty ( IN id_penalty INT, IN id_result INT )
DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
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

CREATE PROCEDURE sp_AddResultPoints(IN race_id INT, IN result_id INT, IN result_points TINYINT)
DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar un exit handler para SQLEXCEPTION
        #Hacer un rollback a cualquier transaccion ocurrida
        #Hacer un resignal para volver a lanzar el evento de error
    
    ##Comenzar la transaccion

    #Actualizar la base de datos resultados con la informacion proporcionada como argumentos del procedimiento

    ##Final de la transaccion

END //

CREATE PROCEDURE sp_UpdateLeaderPoints (IN new_id_race INT)
DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_done" de tipo TINYINT(1) y valor por defecto 0
    #Declarar una variable "v_cur_id_result" de tipo INT con valor por defecto 0
    #Declarar una variable "v_position" de tipo TINYINY con valor por defecto 1
    #Declarar una variable "v_position_points" de tipo TINYINT con valor por defecto 25
    #Declarar una variable "v_position_points_mult" de tipo DECIMAL(3,1) CON VALOR POR DEFECTO 1
    #Declarar una variable "v_points_calc_result" de tipo TINYINT con valor por defecto 0
    #Declarar una variable "v_new_id_race" de tipo INT con valor por defecto NULL

    #Declarar un cursor para un nselect de todos los resultados de una carrera X

    #Declarar un continue handler para un valor not found con un set de v_done a 1

    #Declarar un exit handler para un SQLEXCEPTION
        #Cerrar el cursor en caso de que este abierto
        #Hacer un rollback a los cambios de la transaccion
        #Hacer un resignal para relanzar el evento de fallo sin suprimir la salida de texto
    
    ##Comienza la transaccion

    #Llamada a la funcion GetPositionsPointsMultiplier para guardar el resultado en la variable v_position_points_mult

    #Abrir el cursor
    ##Bucle while para las 10 primeras iteraciones de posiciones y mientras que v_done seqa diferente de 0
        #Hacer un fetch a la variable v_cur_id_result del cursor cur_times\
        #Llamada a la funcion GetLeaderboardPointsCalc e introducir el resultado en la variable v_points_calc_result

        ##Condicion if que comprueba que v_done sea diferente de 1
            #Si es diferente de 1, se llama al procedimiento AddResultPoints
        
        #Se suma v_position + 1
    
    #Se cierra el cursor

    ##Final de la transaccion

END //

CREATE PROCEDURE sp_InsertCircuitData (IN p_circuit_name VARCHAR(100), IN p_country VARCHAR(50), IN p_length_km DECIMAL(3,2), IN p_direction CHAR(20), OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    #Declarar un continue handler for NOT FOUND con un signal que de un mensaje diciendo que el circuito no esta duplicado
    #Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback a los cambios de la transaccion
        #Signal SQSTATE '45001' usando la variable "v_error_message" como mensaje de error
        #Resignal en caso de ser error de la transaccion

    #Comprobar con un if que ninguno de los datos sea null (futura funcion)
    #Comprobar que ningun string este vacio (futura funcion)
    #Comprobar con un if que la longitud del circuito sea razonable (futura funcion)
    #Comprobar que la direccion del circuito esta dentro de dos valores concretos ['CLOCKWISE','COUNTERCLOCKWISE'] (futura funcion)
    #Comprobar que no haya un registro ya existente del circuito en la tabla de circuitos con un select (futura funcion)

    ##Comienza la transaccion

    #Insertar los datos comprobados en la tabla de circuitos

    #Hacer un select con la funcion FOUND_ROWS y comprobar si se insertaron los datos y guarda el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_InsertInscriptionsData (IN p_id_vehicle INT, IN p_id_race INT, IN p_id_team INT, IN p_vehicles_quantity TINYINT, IN p_registered_at TIMESTAMP, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45002' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que la fecha de registro sea correcta y cumpla con el formato (futura funcion)
    #Comprobar que la cantidad de coches a registrar sea mayor que 0 (futura funcion)
    #Comprobar que el id del vehiculo existe en la tabla de vehiculos con un select (futura funcion)
    #Comprobar que el id de la carrera existe en la tabla de carreras con un select (futura funcion)
    #Comprobar que el id del equipo existe con un select a la tabla de equipos (futura funcion)
    
    ##Comienza la transaccion

    #Insert de los datos pasados como parametros a la tabla de inscripciones

    #Hacer un select con la funcion FOUND_ROWS y comprobar si se insertaron los datos y guarda el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler
    
    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_InsertManufacturersData (IN p_manufacturer_name VARCHAR(100), IN p_manufacturer_country VARCHAR(50), OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45003' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion
    
    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que todos los parametros de tipo string no esten vacios (futura funcion)

    #Comienza la transaccion

    #Insert de los datos pasados como parametros a la tabla de fabricantes

    #Hacer un select con la funcion FOUND_ROWS y comprobar si se insertaron los datos y guarda el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler
    
    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_InsertPenaltiesData (IN p_penalty_type CHAR(30), IN p_reason VARCHAR(100), IN p_penalty_value DECIMAL(7,2), IN p_penalty_applies_to VARCHAR(30), OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45004' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion
    
    #Comprobar que ninguno de los parametros sea nulo
    #

END //





##Procedimiento de insercion en todas las tablas
##Procedimiento de comprobacion de inscripcion
##Procedimiento de insercion y modificacion de datos en tablas de auditoria