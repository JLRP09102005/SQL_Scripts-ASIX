DELIMITER //

CREATE PROCEDURE sp_AddTeamPenalty ( IN p_penalty_type VARCHAR(20), IN p_penalty_value DECIMAL(7,2), IN p_vehicle_id INT, IN p_team_id INT, IN p_race_id INT )
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    #Declarar un exit handler for SQLEXCEPTION
        #Rollback a los cambios de la transaccion
        #Signal SQLSTATE '45034' usando la variable "v_error_message" como mensaje de error
        #Resignal en caso de ser error de la transaccion
    
    #Comprobar que ninguno de los parametros sea null (futura funcion)
    #Comprobar que ningun string este vacio (futura funcion)
        #Comprobar que "penalty_type" esta dentro de los valores ['POINTS','TIME','DSQ','DNF'] (funcion futura)
    #Comprobar con un if exists y un select si el parametro "p_vehicle_id" existe en la tabla de vehiculos (funcion futura)
    #Comprobar con un if exists y un select si el parametro "p_team_id" existe en la tabla de equipos (funcion futura)
    #Comprobar con un if exists y un select si el parametro "p_race_id" existe en la tabla de carreras (funcion futura)
    
    ##Comienzo de transaccion

    #Comprobar el estado del penalty (POINTS,TIME,DNF)
    #-Se calcula los puntos de resultado restado al del penalty y se actualiza
    #-Despues de calcular e insertar, insertar en en la variable affected_rows cuantos registros fueron afectados
    #-En el caso de que no sea correcto el estado de penalty enviar un signal sqlstate 45000

    #Comprobar si affected_rows tiene registros afectados
    #-En el caso de no tenerlosenviar un signal sqlstate avisando de esto

    ##Final de transaccion

END //

CREATE PROCEDURE sp_AddPilotPenalty ( IN p_penalty_type VARCHAR(20), IN p_penalty_value DECIMAL(7,2), IN p_result_id INT )
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN
    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Rollback a los cambios de la transaccion
        #Signal SQLSTATE '45035' usando la variable "v_error_message" como mensaje de error
        #Resignal en caso de ser error de la transaccion

    #Comprobar que ninguno de los parametros sea null (futura funcion)
    #Comprobar que ningun string este vacio (futura funcion)
    #Comprobar que "p_penalty_type" esta dentro de los valores ['POINTS','TIME','DSQ','DNF'] (funcion futura)
    #Comprobar con un if exists y un select si el parametro "p_result_id" existe en la tabla de resultados (funcion futura)

    ##Comienzo de la transaccion

    #Comprobar el estado del penalty (POINTS,TIME,DNF)
    #-Se calcula los puntos de resultado restado al del penalty y se actualiza
    #-Despues de calcular e insertar, insertar en en la variable affected_rows cuantos registros fueron afectados
    #-En el caso de que no sea correcto el estado de penalty enviar un signal sqlstate 45000

    #Comprobar si affected_rows tiene registros afectados
    #-En el caso de no tenerlosenviar un signal sqlstate avisando de esto

    ##Final de transaccion

END //

CREATE PROCEDURE sp_GetPenaltyBasicInfo ( IN p_id_penalty INT, OUT p_penalty_type VARCHAR(20), OUT p_penalty_applies VARCHAR(20), OUT p_penalty_value DECIMAL(7,2) )
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto

    #Declarar un exit handler for SQLEXCEPTION
        #Signal SQLSTATE '45036' usando la variable "v_error_message" como mensaje de error
        #Resignal en caso de ser error de la transaccion
    
    #Comprobar que ninguno de los parametros sea null (futura funcion)
    #Comprobar con un if exists y un select si el parametro "p_id_penalty" existe en la tabla de penalties (funcion futura)

    #Select de penalty_type, penalty_applies_to y penalty_value de la tabla de penalties donde el id coincida con "p_id_penalty" guardando los resultados en los parametros OUT "p_penalty_type", "p_penalty_applies" y "p_penalty_value"

END //

CREATE PROCEDURE sp_GetResultsForeignInfo ( IN p_result_id INT, OUT p_vehicle_id INT, OUT p_team_id INT, OUT p_race_id INT )
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Signal SQLSTATE '45037' usando la variable "v_error_message" como mensaje de error
        #Resignal en caso de ser error de la transaccion
    
    #Comprobar que ninguno de los parametros sea null (futura funcion)
    #Comprobar con un if exists y un select si el parametro "p_result_id" existe en la tabla de resultados (funcion futura)

    #Select de id_vehicle, id_team e id_race de la tabla de results donde el id coincida con "p_result_id" guardando los resultados en los parametros OUT "p_vehicle_id", "p_team_id" y "p_race_id"

END //

CREATE PROCEDURE sp_ProcessResultPenalty ( IN p_id_penalty INT, IN p_id_result INT )
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "penalty_type" de tipo VARCHAR(20) por defecto con valor 'POINTS'
    #Declarar una variable "penalty_applies" de tipo VARCHAR(20) por defecto con valor 'PILOT'
    #Declarar una variable "penalty_value" de tipo DECIMAL(7,2) por defecto con valor 0
    #Declarar una variable "vehicle_id" de tipo INT por defecto con valor NULL
    #Declarar una variable "team_id" de tipo INT por defecto con valor NULL
    #Declarar una variable "race_id" de tipo INT por defecto con valor NULL
    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Signal SQLSTATE '45038' usando la variable "v_error_message" como mensaje de error
        #Resignal en caso de ser error de la transaccion

    #Comprobar que ninguno de los parametros sea null (futura funcion)
    #Comprobar con un if exists y un select si el parametro "p_id_penalty" existe en la tabla de penalties (funcion futura)
    #Comprobar con un if exists y un select si el parametro "p_result_id" existe en la tabla de resultados (funcion futura)

    #LLamada al procedimiento GetPenaltyBasicInfo
    #LLamada al procedimiento GetResultsForeignInfo

    #Condicional if que compruebe si la penalizacion se aplica al piloto o al equipo
    #-En el caso de que se aplique al piloto se llama al procedimiento AddPilotPenalty
    #-En el caso de que se aplique al equipo se llama al procedimiento AddTeamPenalty

END //

CREATE PROCEDURE sp_AddResultPoints(IN p_race_id INT, IN p_result_id INT, IN p_result_points TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Rollback a los cambios de la transaccion
        #Signal SQLSTATE '45039' usando la variable "v_error_message" como mensaje de error
        #Resignal en caso de ser error de la transaccion

    #Comprobar que ninguno de los parametros sea null (futura funcion)
    #Comprobar con un if exists y un select si el parametro "p_race_id" existe en la tabla de carreras (funcion futura)
    #Comprobar con un if exists y un select si el parametro "p_result_id" existe en la tabla de resultados (funcion futura)
    #Comprobar que "p_result_points" no sea un valor negativo (futura funcion)
    
    ##Comienza la transaccion

    #Actualizar los puntos en la tabla de results donde el id del resultado coincida con "p_result_id" y el id de la carrera coincida con "p_race_id"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se insertaron los datos y guarda el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Final de la transaccion

END //

CREATE PROCEDURE sp_UpdateLeaderPoints (IN p_new_id_race INT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_done" de tipo TINYINT(1) y valor por defecto 0
    #Declarar una variable "v_cur_id_result" de tipo INT con valor por defecto 0
    #Declarar una variable "v_position" de tipo TINYINT con valor por defecto 1
    #Declarar una variable "v_position_points" de tipo TINYINT con valor por defecto 25
    #Declarar una variable "v_position_points_mult" de tipo DECIMAL(3,1) CON VALOR POR DEFECTO 1
    #Declarar una variable "v_points_calc_result" de tipo TINYINT con valor por defecto 0
    #Declarar una variable "v_new_id_race" de tipo INT con valor por defecto NULL
    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto

    #Declarar un cursor para un nselect de todos los resultados de una carrera X

    #Declarar un continue handler para un valor not found con un set de v_done a 1

    ##Declarar un exit handler for SQLEXCEPTION
        #Cerrar el cursor en caso de que este abierto
        #Rollback a los cambios de la transaccion
        #Signal SQLSTATE '45042' usando la variable "v_error_message" como mensaje de error
        #Resignal en caso de ser error de la transaccion

    #Comprobar con un if exists y un select si el parametro "p_new_id_race" existe en la tabla de carreras (funcion futura)
    
    ##Comienza la transaccion

    #Llamada a la funcion fn_GetPositionsPointsMultiplier para guardar el resultado en la variable v_position_points_mult

    #Abrir el cursor
    ##Bucle while para las 10 primeras iteraciones de posiciones y mientras que v_done sea diferente de 1
        #Hacer un fetch a la variable v_cur_id_result del cursor cur_times\
        #Llamada a la funcion fn_GetLeaderboardPointsCalc e introducir el resultado en la variable v_points_calc_result

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
    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45001' usando la variable "v_error_message" como mensaje de error
        #Resignal en caso de ser error de la transaccion

    #Comprobar con un if que ninguno de los datos sea null (futura funcion)
    #Comprobar que ningun string este vacio (futura funcion)
    #Comprobar con un if que la longitud del circuito sea razonable (futura funcion)
    #Comprobar que la direccion del circuito esta dentro de dos valores concretos ['CLOCKWISE','COUNTERCLOCKWISE'] (futura funcion)
    #Comprobar que no haya un registro ya existente del circuito en la tabla de circuitos con un select (futura funcion)

    ##Comienza la transaccion

    #Insertar los datos comprobados en la tabla de circuitos

    #Hacer un select con la funcion ROW_COUNT y comprobar si se insertaron los datos y guarda el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_UpdateCircuitData (IN p_circuit_id INT, IN p_circuit_name VARCHAR(100), IN p_country VARCHAR(50), IN p_length_km DECIMAL(3,2), IN p_direction CHAR(20), OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    #Declarar un continue handler for NOT FOUND con un signal que dé un mensaje diciendo que el circuito no existe
    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback a los cambios de la transaccion
        #Signal SQLSTATE '45012' usando la variable "v_error_message" como mensaje de error
        #Resignal en caso de ser error de la transaccion

    #Comprobar con un if que ninguno de los datos sea null (futura funcion)
    #Comprobar que ningun string este vacio (futura funcion)
    #Comprobar con un if que la longitud del circuito sea razonable (futura funcion)
    #Comprobar que la direccion del circuito esta dentro de dos valores concretos ['CLOCKWISE','COUNTERCLOCKWISE'] (futura funcion)
    #Comprobar que existe un registro con "p_circuit_id" en la tabla de circuitos con un SELECT (futura funcion)
    #Comprobar que el nuevo nombre no este duplicado en otro registro distinto al que se actualiza (futura funcion)

    ##Comienza la transaccion

    #Actualizar los datos comprobados en la tabla de circuitos donde el id coincida con "p_circuit_id"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se actualizaron los datos y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_DeleteCircuitData (IN p_circuit_id INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    #Declarar un continue handler for NOT FOUND con un signal que dé un mensaje diciendo que el circuito no existe
    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback a los cambios de la transaccion
        #Signal SQLSTATE '45013' usando la variable "v_error_message" como mensaje de error
        #Resignal en caso de ser error de la transaccion


    #Comprobar con un if que "p_circuit_id" no sea null (futura funcion)
    #Comprobar que existe un registro con "p_circuit_id" en la tabla de circuitos con un SELECT (futura funcion)
    #Comprobar que el circuito no tiene registros dependientes en otras tablas (futura funcion, integridad referencial)

    ##Comienza la transaccion

    #Eliminar de la tabla de circuitos el registro donde el id coincida con "p_circuit_id"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se elimino el registro y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_InsertInscriptionData (IN p_id_vehicle INT, IN p_id_race INT, IN p_id_team INT, IN p_vehicles_quantity TINYINT, IN p_registered_at TIMESTAMP, OUT p_spstate TINYINT)
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

    #Hacer un select con la funcion ROW_COUNT y comprobar si se insertaron los datos y guarda el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler
    
    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_UpdateInscriptionData (IN p_id_inscription INT, IN p_id_vehicle INT, IN p_id_race INT, IN p_id_team INT, IN p_vehicles_quantity TINYINT, IN p_registered_at TIMESTAMP, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45014' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que la fecha de registro sea correcta y cumpla con el formato (futura funcion)
    #Comprobar que la cantidad de coches a registrar sea mayor que 0 (futura funcion)
    #Comprobar que el id de la inscripcion existe en la tabla de inscripciones con un select (futura funcion)
    #Comprobar que el id del vehiculo existe en la tabla de vehiculos con un select (futura funcion)
    #Comprobar que el id de la carrera existe en la tabla de carreras con un select (futura funcion)
    #Comprobar que el id del equipo existe con un select a la tabla de equipos (futura funcion)

    ##Comienza la transaccion

    #Actualizar los datos en la tabla de inscripciones donde el id coincida con "p_id_inscription"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se actualizaron los datos y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_DeleteInscriptionData (IN p_id_inscription INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45015' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que "p_id_inscription" no sea nulo (futura funcion)
    #Comprobar que el id de la inscripcion existe en la tabla de inscripciones con un select (futura funcion)

    ##Comienza la transaccion

    #Eliminar de la tabla de inscripciones el registro donde el id coincida con "p_id_inscription"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se elimino el registro y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_InsertManufacturerData (IN p_manufacturer_name VARCHAR(100), IN p_manufacturer_country VARCHAR(50), OUT p_spstate TINYINT)
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

    #Hacer un select con la funcion ROW_COUNT y comprobar si se insertaron los datos y guarda el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler
    
    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_UpdateManufacturerData (IN p_id_manufacturer INT, IN p_manufacturer_name VARCHAR(100), IN p_manufacturer_country VARCHAR(50), OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45016' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que todos los parametros de tipo string no esten vacios (futura funcion)
    #Comprobar que el id del fabricante existe en la tabla de fabricantes con un select (futura funcion)

    ##Comienza la transaccion

    #Actualizar los datos en la tabla de fabricantes donde el id coincida con "p_id_manufacturer"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se actualizaron los datos y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_DeleteManufacturerData (IN p_id_manufacturer INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45017' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que "p_id_manufacturer" no sea nulo (futura funcion)
    #Comprobar que el id del fabricante existe en la tabla de fabricantes con un select (futura funcion)
    #Comprobar que el fabricante no tiene vehiculos asociados en la tabla de vehiculos (futura funcion, integridad referencial)

    ##Comienza la transaccion

    #Eliminar de la tabla de fabricantes el registro donde el id coincida con "p_id_manufacturer"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se elimino el registro y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1


END //

CREATE PROCEDURE sp_InsertPenaltyData (IN p_penalty_type CHAR(30), IN p_reason VARCHAR(100), IN p_penalty_value DECIMAL(7,2), IN p_penalty_applies_to VARCHAR(30), OUT p_spstate TINYINT)
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
    
    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que los parametros de tipo string no esten vacios (futura funcion)
    #Comprobar que el "p_penalty_value" tenga un valor razonablke y no sea 0 o negativo (futura funcion)
    #Comprobar que el "p_penalty_applies_to" solo contiene ['TEAM','PILOT'] (futura funcion)

    #Comienza la transaccion

    #Insert de los datos pasados como parametros a la tabla de penalties

    #Hacer un select con la funcion ROW_COUNT y comprobar si se insertaron los datos y guarda el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler
    
    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_UpdatePenaltyData (IN p_id_penalty INT, IN p_penalty_type CHAR(30), IN p_reason VARCHAR(100), IN p_penalty_value DECIMAL(7,2), IN p_penalty_applies_to VARCHAR(30), OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45018' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que los parametros de tipo string no esten vacios (futura funcion)
    #Comprobar que el "p_penalty_value" tenga un valor razonable y no sea 0 o negativo (futura funcion)
    #Comprobar que el "p_penalty_applies_to" solo contiene ['TEAM','PILOT'] (futura funcion)
    #Comprobar que el id de la penalty existe en la tabla de penalties con un select (futura funcion)

    ##Comienza la transaccion

    #Actualizar los datos en la tabla de penalties donde el id coincida con "p_id_penalty"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se actualizaron los datos y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_DeletePenaltyData (IN p_id_penalty INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45019' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que "p_id_penalty" no sea nulo (futura funcion)
    #Comprobar que el id de la penalty existe en la tabla de penalties con un select (futura funcion)
    #Comprobar que la penalty no tiene registros asociados en otras tablas (futura funcion, integridad referencial)

    ##Comienza la transaccion

    #Eliminar de la tabla de penalties el registro donde el id coincida con "p_id_penalty"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se elimino el registro y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_InsertPilotCategoriesData (IN p_pilot_category_name VARCHAR(50), IN p_pilot_category_description VARCHAR(100), IN p_min_age TINYINT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45005' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion
    
    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que los parametros de tipo string no esten vacios (futura funcion)
    #Comprobar que el "p_min_age" tenga un valor razonable y no sea 0 o negativo (futura funcion)

    #Comienza la transaccion

    #Insert de los datos pasados como parametros a la tabla de pilot_categories

    #Hacer un select con la funcion ROW_COUNT y comprobar si se insertaron los datos y guarda el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler
    
    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_UpdatePilotCategoriesData (IN p_id_pilot_category INT, IN p_pilot_category_name VARCHAR(50), IN p_pilot_category_description VARCHAR(100), IN p_min_age TINYINT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45020' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que los parametros de tipo string no esten vacios (futura funcion)
    #Comprobar que el "p_min_age" tenga un valor razonable y no sea 0 o negativo (futura funcion)
    #Comprobar que el id de la categoria existe en la tabla de pilot_categories con un select (futura funcion)

    ##Comienza la transaccion

    #Actualizar los datos en la tabla de pilot_categories donde el id coincida con "p_id_pilot_category"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se actualizaron los datos y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_DeletePilotCategoriesData (IN p_id_pilot_category INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45021' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que "p_id_pilot_category" no sea nulo (futura funcion)
    #Comprobar que el id de la categoria existe en la tabla de pilot_categories con un select (futura funcion)
    #Comprobar que la categoria no tiene pilotos asociados en la tabla de pilotos (futura funcion, integridad referencial)

    ##Comienza la transaccion

    #Eliminar de la tabla de pilot_categories el registro donde el id coincida con "p_id_pilot_category"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se elimino el registro y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_InsertPilotData (IN p_pilot_name VARCHAR(100), IN p_pilot_age TINYINT, IN p_id_pilot_category INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45006' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion
    
    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que los parametros de tipo string no esten vacios (futura funcion)
    #Comprobar que el "p_pilot_age" tenga un valor razonable y no sea 0 o negativo (futura funcion)
    #Comprobar que la "p_id_pilot_category" existe con un if not exists de un select con esa id a la tabla de categoria de pilotos

    #Comienza la transaccion

    #Insert de los datos pasados como parametros a la tabla de pilots

    #Hacer un select con la funcion ROW_COUNT y comprobar si se insertaron los datos y guarda el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler
    
    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_UpdatePilotData (IN p_id_pilot INT, IN p_pilot_name VARCHAR(100), IN p_pilot_age TINYINT, IN p_id_pilot_category INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45022' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que los parametros de tipo string no esten vacios (futura funcion)
    #Comprobar que el "p_pilot_age" tenga un valor razonable y no sea 0 o negativo (futura funcion)
    #Comprobar que el "p_id_pilot" existe con un if not exists de un select con esa id a la tabla de pilots
    #Comprobar que la "p_id_pilot_category" existe con un if not exists de un select con esa id a la tabla de categoria de pilotos

    ##Comienza la transaccion

    #Actualizar los datos en la tabla de pilots donde el id coincida con "p_id_pilot"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se actualizaron los datos y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_DeletePilotData (IN p_id_pilot INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45023' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que "p_id_pilot" no sea nulo (futura funcion)
    #Comprobar que el "p_id_pilot" existe con un if not exists de un select con esa id a la tabla de pilots
    #Comprobar que el piloto no tiene inscripciones asociadas en la tabla de inscripciones (futura funcion, integridad referencial)
    #Comprobar que el piloto no tiene penalizaciones asociadas en la tabla de penalties (futura funcion, integridad referencial)

    ##Comienza la transaccion

    #Eliminar de la tabla de pilots el registro donde el id coincida con "p_id_pilot"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se elimino el registro y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_InsertPilotInscriptionData (IN p_id_pilot INT, IN p_id_vehicle INT, IN p_id_race INT, IN p_id_team INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45007' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion
    
    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que la "p_id_pilot" existe con un if not exists de un select con esa id a la tabla de pilotos
    #Comprobar que la "p_id_vehicle" existe con un if not exists de un select con esa id a la tabla de vehiculos
    #Comprobar que la "p_id_race" existe con un if not exists de un select con esa id a la tabla de carreras
    #Comprobar que la "p_id_team" existe con un if not exists de un select con esa id a la tabla de equipos

    #Comienza la transaccion

    #Insert de los datos pasados como parametros a la tabla de pilot_inscriptions

    #Hacer un select con la funcion ROW_COUNT y comprobar si se insertaron los datos y guarda el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler
    
    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_UpdatePilotInscriptionData (IN p_id_pilot_inscription INT, IN p_id_pilot INT, IN p_id_vehicle INT, IN p_id_race INT, IN p_id_team INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45024' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que la "p_id_pilot_inscription" existe con un if not exists de un select con esa id a la tabla de pilot_inscriptions
    #Comprobar que la "p_id_pilot" existe con un if not exists de un select con esa id a la tabla de pilotos
    #Comprobar que la "p_id_vehicle" existe con un if not exists de un select con esa id a la tabla de vehiculos
    #Comprobar que la "p_id_race" existe con un if not exists de un select con esa id a la tabla de carreras
    #Comprobar que la "p_id_team" existe con un if not exists de un select con esa id a la tabla de equipos

    ##Comienza la transaccion

    #Actualizar los datos en la tabla de pilot_inscriptions donde el id coincida con "p_id_pilot_inscription"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se actualizaron los datos y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_DeletePilotInscriptionData (IN p_id_pilot_inscription INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45025' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que "p_id_pilot_inscription" no sea nulo (futura funcion)
    #Comprobar que la "p_id_pilot_inscription" existe con un if not exists de un select con esa id a la tabla de pilot_inscriptions
    #Comprobar que la inscripcion no tiene penalizaciones asociadas en la tabla de penalties (futura funcion, integridad referencial)
    #Comprobar que la inscripcion no tiene resultados asociados en la tabla de resultados (futura funcion, integridad referencial)

    ##Comienza la transaccion

    #Eliminar de la tabla de pilot_inscriptions el registro donde el id coincida con "p_id_pilot_inscription"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se elimino el registro y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_InsertRaceData (IN p_event_name VARCHAR(100), IN p_event_date DATETIME, IN p_event_duration TIME, IN p_id_circuit INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45008' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion
    
    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que los parametros de tipo string no esten vacios (futura funcion)
    #Comprobar que "p_event_date" este dentro de unos valores razonables (como por ejemplo el mismo anyo)
    #Comprobar que "p_event_duration" no sea 0 ni tenga un valor minimo muy bajo
    #Comprobar que el id del circuito es correcto con un if not exists y un select a la tabla de cuircuitos con el id de parametro

    #Comienza la transaccion

    #Insert de los datos pasados como parametros a la tabla de races

    #Hacer un select con la funcion ROW_COUNT y comprobar si se insertaron los datos y guarda el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler
    
    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_UpdateRaceData (IN p_id_race INT, IN p_event_name VARCHAR(100), IN p_event_date DATETIME, IN p_event_duration TIME, IN p_id_circuit INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45026' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que los parametros de tipo string no esten vacios (futura funcion)
    #Comprobar que "p_event_date" este dentro de unos valores razonables (como por ejemplo el mismo anyo)
    #Comprobar que "p_event_duration" no sea 0 ni tenga un valor minimo muy bajo
    #Comprobar que el "p_id_race" existe con un if not exists y un select a la tabla de races con el id de parametro
    #Comprobar que el id del circuito es correcto con un if not exists y un select a la tabla de circuitos con el id de parametro

    ##Comienza la transaccion

    #Actualizar los datos en la tabla de races donde el id coincida con "p_id_race"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se actualizaron los datos y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_DeleteRaceData (IN p_id_race INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45027' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que "p_id_race" no sea nulo (futura funcion)
    #Comprobar que el "p_id_race" existe con un if not exists y un select a la tabla de races con el id de parametro
    #Comprobar que la carrera no tiene inscripciones asociadas en la tabla de inscripciones (futura funcion, integridad referencial)
    #Comprobar que la carrera no tiene pilot_inscriptions asociadas en la tabla de pilot_inscriptions (futura funcion, integridad referencial)
    #Comprobar que la carrera no tiene resultados asociados en la tabla de resultados (futura funcion, integridad referencial)

    ##Comienza la transaccion

    #Eliminar de la tabla de races el registro donde el id coincida con "p_id_race"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se elimino el registro y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_InsertResultData (
    IN p_position INT, 
    IN p_final_time TIME, 
    IN p_penalty_time TIME, 
    IN p_base_points_team INT, 
    IN p_base_points_pilot INT, 
    IN p_penalty_points_team INT, 
    IN p_id_vehicle INT, 
    IN p_id_race INT,
    IN p_id_team INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45009' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion
    
    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que "p_position" este dentro de las posiciones posibles del leaderboard (futura funcion)
    #Comprobar que "p_final_time" este dentro de unos valores razonables de tiempo (futura funcion)
    #Comprobar que todos los parametros que tengan que ver con los puntos no sean negativos (futura funcion)
    #Comprobar que la "p_id_vehicle" existe con un if not exists de un select con esa id a la tabla de vehiculos
    #Comprobar que la "p_id_race" existe con un if not exists de un select con esa id a la tabla de carreras
    #Comprobar que la "p_id_team" existe con un if not exists de un select con esa id a la tabla de equipos

    #Comienza la transaccion

    #Insert de los datos pasados como parametros a la tabla de results

    #Hacer un select con la funcion ROW_COUNT y comprobar si se insertaron los datos y guarda el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler
    
    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_UpdateResultData (
    IN p_id_result INT,
    IN p_position INT,
    IN p_final_time TIME,
    IN p_penalty_time TIME,
    IN p_base_points_team INT,
    IN p_base_points_pilot INT,
    IN p_penalty_points_team INT,
    IN p_id_vehicle INT,
    IN p_id_race INT,
    IN p_id_team INT,
    OUT p_spstate TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45028' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que "p_position" este dentro de las posiciones posibles del leaderboard (futura funcion)
    #Comprobar que "p_final_time" este dentro de unos valores razonables de tiempo (futura funcion)
    #Comprobar que todos los parametros que tengan que ver con los puntos no sean negativos (futura funcion)
    #Comprobar que el "p_id_result" existe con un if not exists de un select con esa id a la tabla de results
    #Comprobar que la "p_id_vehicle" existe con un if not exists de un select con esa id a la tabla de vehiculos
    #Comprobar que la "p_id_race" existe con un if not exists de un select con esa id a la tabla de carreras
    #Comprobar que la "p_id_team" existe con un if not exists de un select con esa id a la tabla de equipos

    ##Comienza la transaccion

    #Actualizar los datos en la tabla de results donde el id coincida con "p_id_result"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se actualizaron los datos y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_DeleteResultData (IN p_id_result INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45029' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que "p_id_result" no sea nulo (futura funcion)
    #Comprobar que el "p_id_result" existe con un if not exists de un select con esa id a la tabla de results

    ##Comienza la transaccion

    #Eliminar de la tabla de results el registro donde el id coincida con "p_id_result"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se elimino el registro y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_InsertTeamData (IN p_team_name VARCHAR(100), IN p_mechanic_num TINYINT, IN p_id_manufacturer INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45010' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion
    
    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que los parametros de tipo string no esten vacios (futura funcion)
    #Comprobar "p_mechanic_num" no se pase de X numero de mecanicos (futura funcion)
    #Comprobar que el fabricante existe con un if not exists y un select a la tabla de fabricantes con el parametro "p_id_manufacturer"

    #Comienza la transaccion

    #Insert de los datos pasados como parametros a la tabla de teams

    #Hacer un select con la funcion ROW_COUNT y comprobar si se insertaron los datos y guarda el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler
    
    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_UpdateTeamData (IN p_id_team INT, IN p_team_name VARCHAR(100), IN p_mechanic_num TINYINT, IN p_id_manufacturer INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45030' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que los parametros de tipo string no esten vacios (futura funcion)
    #Comprobar "p_mechanic_num" no se pase de X numero de mecanicos (futura funcion)
    #Comprobar que el "p_id_team" existe con un if not exists y un select a la tabla de teams con el parametro "p_id_team"
    #Comprobar que el fabricante existe con un if not exists y un select a la tabla de fabricantes con el parametro "p_id_manufacturer"

    ##Comienza la transaccion

    #Actualizar los datos en la tabla de teams donde el id coincida con "p_id_team"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se actualizaron los datos y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_DeleteTeamData (IN p_id_team INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45031' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que "p_id_team" no sea nulo (futura funcion)
    #Comprobar que el "p_id_team" existe con un if not exists y un select a la tabla de teams con el parametro "p_id_team"
    #Comprobar que el equipo no tiene inscripciones asociadas en la tabla de inscripciones (futura funcion, integridad referencial)
    #Comprobar que el equipo no tiene pilot_inscriptions asociadas en la tabla de pilot_inscriptions (futura funcion, integridad referencial)
    #Comprobar que el equipo no tiene resultados asociados en la tabla de results (futura funcion, integridad referencial)

    ##Comienza la transaccion

    #Eliminar de la tabla de teams el registro donde el id coincida con "p_id_team"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se elimino el registro y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_InsertVehicleData (IN p_model VARCHAR(100), IN p_specifications_url VARCHAR(1024), OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45011' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion
    
    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que los parametros de tipo string no esten vacios (futura funcion)
    #Comprobar con un if LOAD_FILE que el archivo especificado en el URL existe (preguntar a Quim)

    #Comienza la transaccion

    #Insert de los datos pasados como parametros a la tabla de vehicles

    #Hacer un select con la funcion ROW_COUNT y comprobar si se insertaron los datos y guarda el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler
    
    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_UpdateVehicleData (IN p_id_vehicle INT, IN p_model VARCHAR(100), IN p_specifications_url VARCHAR(1024), OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45032' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que los parametros de tipo string no esten vacios (futura funcion)
    #Comprobar con un if LOAD_FILE que el archivo especificado en el URL existe (preguntar a Quim)
    #Comprobar que el "p_id_vehicle" existe con un if not exists y un select a la tabla de vehicles con el parametro "p_id_vehicle"

    ##Comienza la transaccion

    #Actualizar los datos en la tabla de vehicles donde el id coincida con "p_id_vehicle"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se actualizaron los datos y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_DeleteVehicleData (IN p_id_vehicle INT, OUT p_spstate TINYINT)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45033' usando la variable "v_error_message"
        #Resignal en el caso de que el error sea por parte de la transaccion

    #Comprobar que "p_id_vehicle" no sea nulo (futura funcion)
    #Comprobar que el "p_id_vehicle" existe con un if not exists y un select a la tabla de vehicles con el parametro "p_id_vehicle"
    #Comprobar que el vehiculo no tiene inscripciones asociadas en la tabla de inscripciones (futura funcion, integridad referencial)
    #Comprobar que el vehiculo no tiene pilot_inscriptions asociadas en la tabla de pilot_inscriptions (futura funcion, integridad referencial)
    #Comprobar que el vehiculo no tiene resultados asociados en la tabla de results (futura funcion, integridad referencial)

    ##Comienza la transaccion

    #Eliminar de la tabla de vehicles el registro donde el id coincida con "p_id_vehicle"

    #Hacer un select con la funcion ROW_COUNT y comprobar si se elimino el registro y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END //

CREATE PROCEDURE sp_GetRaceLeaderboard(IN p_id_race INT, IN p_race_date DATETIME)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45040' usando la variable "v_error_message"

    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que la carrera existe con un if not exists y un select a la tabla de carreras con el parametro "p_id_race" (futura funcion)
    #Comprobar que el parametro "p_race_date" tenga un valor coherente (futura funcion)

    #Select de posicion, nombre del piloto, nombre del equipo, tiempo final,
    #tiempo de penalizacion, puntos base del piloto y puntos base del equipo
    #de la tabla de results con inner join a races filtrando por "p_id_race"
    #y por fecha de carrera igual a "p_race_date"
    #ordenado por posicion de forma ascendente

END //

CREATE PROCEDURE sp_GetPilotSeasonStats(IN p_id_pilot INT, IN p_season_date DATETIME)
DETERMINISTIC
READS SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Rollback de los cambios de la transaccion
        #Signal SQLSTATE '45041' usando la variable "v_error_message"

    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que el piloto existe con un if not exists y un select a la tabla de pilotos con el parametro "p_id_pilot" (futura funcion)
    #Comprobar que el parametro "p_season_date" tenga un valor coherente (futura funcion)

    #Select de puntos del piloto, nombre, vehiculo, equipo from carreras where p_season_date inner join a inscripciones, resultados y pilotos junto a sus inscripciones

END //


##He hecho algunos procedimientos GET, pero se podrian hacer muchos mas
##Procedimiento de comprobacion de inscripcion

##Procedimiento de insercion y modificacion de datos en tablas de auditoria (EXAMPLE)
/* CREATE TABLE audit_log (
    id_audit      INT AUTO_INCREMENT PRIMARY KEY,
    table_name    VARCHAR(100)                    NOT NULL,
    action        ENUM('INSERT','UPDATE','DELETE') NOT NULL,
    record_id     INT                             NOT NULL,
    changed_by    VARCHAR(100)                    NOT NULL,
    changed_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_data      JSON                            NULL,
    new_data      JSON                            NULL
); */
/* CREATE PROCEDURE sp_AuditLog (
    IN p_table_name VARCHAR(100),
    IN p_action     ENUM('INSERT','UPDATE','DELETE'),
    IN p_record_id  INT,
    IN p_changed_by VARCHAR(100),
    IN p_old_data   JSON,
    IN p_new_data   JSON,
    OUT p_spstate   TINYINT
)
NOT DETERMINISTIC
MODIFIES SQL DATA
SQL SECURITY INVOKER
BEGIN

    #Declarar una variable "v_error_message" de tipo VARCHAR(255) con valor '' por defecto
    #Declarar una variable "v_affected_rows" de tipo INT con valor 0 por defecto

    ##Declarar un exit handler for SQLEXCEPTION
        #Hacer un set a la variable "p_spstate" de valor 0
        #Signal SQLSTATE '45099' usando la variable "v_error_message"
        #Resignal en caso de ser error de la transaccion

    #Comprobar que ninguno de los parametros sea nulo (futura funcion)
    #Comprobar que "p_table_name" no este vacio (futura funcion)
    #Comprobar que "p_action" este dentro de los valores permitidos ['INSERT','UPDATE','DELETE'] (futura funcion)

    ##Comienza la transaccion

    #Insertar en la tabla de auditoria: tabla afectada, accion, id del registro,
    #usuario que hizo el cambio, timestamp automatico, datos anteriores (JSON) y datos nuevos (JSON)

    #Hacer un select con ROW_COUNT y guardar el resultado en "v_affected_rows"
    #If de comprobacion para ver si "v_affected_rows" es mayor que 0
        #En el caso de que no lo sea, generar signal que sea captado por el handler

    ##Fin de la transaccion

    #Hacer un set a la variable "p_spstate" de valor 1

END // */