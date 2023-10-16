ALTER SESSION SET "_ORACLE_SCRIPT" = true;

SET SERVEROUTPUT ON

CONN ILERNA_PAC / i1234;
SET SERVEROUTPUT ON
---------------------------------------------------------------
-- 1)   GESTIÓN DE USUARIOS Y ROLES ---------------------------
---------------------------------------------------------------
-- CREAR ROLE "ROL_GESTOR" 
-- Creamos el rol y le damos los accesos
CREATE ROLE rol_gestor;
GRANT CREATE SESSION TO rol_gestor;
GRANT ALTER, INSERT, UPDATE, SELECT ON asignaturas_pac TO rol_gestor;

-- CREAR USUARIO "GESTOR" 
CREATE USER GESTOR IDENTIFIED BY g1234;
-- ASIGNAR ROL A USUARIO
GRANT rol_gestor TO gestor;
-- CONECTAR CON EL NUEVO USARIO
CONN GESTOR / g1234;
SET SERVEROUTPUT ON
-- REALIZAR LAS MODIFICACIONES DEL EJERCICIO
--Elimino campo creditos
ALTER TABLE ilerna_pac.asignaturas_pac DROP COLUMN creditos;
--Añadir campo ciclo
ALTER TABLE ilerna_pac.asignaturas_pac ADD ciclo VARCHAR(3);
--Insertar registro
INSERT INTO ilerna_pac.asignaturas_pac VALUES ('DAX_M02B','MP2.Bases de datos B','Emilio Saurina','DAX');
--Modificar dato de Ciclo
UPDATE ilerna_pac.asignaturas_pac SET ciclo = 'DAM';

SHOW USER;

-- CONECTAR DE NUEVO CON EL USUARIO ILERNA_PAC
CONN ILERNA_PAC / i1234;
SET SERVEROUTPUT ON
SHOW USER;

---------------------------------------------------------------
-- 2)	PROCEDIMIENTOS ---------------------------------------- 
---------------------------------------------------------------
-- ELIMINAR PROCEDIMIENTO ANTES DE CREARLO POR SI YA ESTA CREADO
DROP PROCEDURE RANKING_JUGADOR;
-- CREAR PROCEDIMIENTO "RANKING_JUGADOR"
CREATE OR REPLACE PROCEDURE ranking_jugador (
-- ponemos los parametros de entrada y salida
    id_jugad IN jugadores_pac.id_jugador%TYPE,
    num_puntos IN jugadores_pac.puntos%TYPE,
    nombre_par OUT jugadores_pac.nombre%TYPE,
    apellido_par OUT jugadores_pac.apellidos%TYPE,
    puntos_totales_par OUT jugadores_pac.puntos%TYPE,
    ranking_act OUT ranking_pac.nombre_ranking%TYPE
) IS 
--Creamos las variables para almacenar la info
    valor_nombre     jugadores_pac.nombre%TYPE;
    valor_apellido   jugadores_pac.apellidos%TYPE;
    valor_puntos     jugadores_pac.puntos%TYPE;
    ranking          ranking_pac.nombre_ranking%TYPE;
BEGIN
--Realizamos select para guardar la info en las variables del id que introducimos   
SELECT
    nombre,
    apellidos,
    puntos
INTO 
  valor_nombre,
  valor_apellido,
  valor_puntos
  
FROM 
    jugadores_pac
WHERE
    id_jugador = id_jugad;
    
   --Sumamos los puntos que introducimos con los que ya tiene 
    valor_puntos:=valor_puntos + num_puntos; 
   --Le damos valor a las variables de salida 
    nombre_par:=valor_nombre;
    apellido_par:=valor_apellido;
    puntos_totales_par:=valor_puntos;
--Comprobamos los puntos totales con el ranking al cual pertenece
IF valor_puntos<=1000
THEN ranking := 'Bronze';
ranking_act:=ranking;

ELSIF valor_puntos<=2000
THEN ranking :='Plata';
ranking_act:=ranking;

ELSIF valor_puntos<=3000
THEN ranking :='Oro';
ranking_act:=ranking;

ELSIF valor_puntos<=4000
THEN ranking :='Platino';
ranking_act:=ranking;

ELSIF valor_puntos<=99999
THEN ranking:='Diamante';
ranking_act:=ranking;

END IF;
    
 END ranking_jugador;
/

---------------------------------------------------------------
-- 3)	FUNCIONES --------------------------------------------- 
---------------------------------------------------------------
-- ELIMINAR FUNCION ANTES DE CREARLA POR SI YA ESTA CREADA
DROP FUNCTION JUGADORES_POR_RANKING;
-- CREAR FUNCION "JUGADORES_POR_RANKING"
CREATE OR REPLACE FUNCTION jugadores_por_ranking (
--parametro de entrada
    nom_ranking IN ranking_pac.nombre_ranking%TYPE
)RETURN INT
AS
--variables donde almacenamod la info
total_jugadores INT;
valor_puntos_min jugadores_pac.puntos%TYPE;
valor_puntos_max jugadores_pac.puntos%TYPE;
BEGIN
--Con el select almacenamos en las variables los puntos minimos y maximos del ranking que le pasamos
    SELECT   
    puntos_max,
    puntos_min
INTO 
  valor_puntos_max,
  valor_puntos_min
  
FROM 
    ranking_pac
WHERE
    nombre_ranking=nom_ranking;
    --Contamos en la tabla jugadores cuantos jugadores estan entre el rango de puntos minimos y maximos
    --Almacenamos el numeor de jugadores en la variable total_jugadores
    SELECT COUNT(*)INTO total_jugadores FROM jugadores_pac WHERE puntos<=valor_puntos_max AND puntos>=valor_puntos_min;
--Devolvemos el resultado    
RETURN total_jugadores;
END jugadores_por_ranking;
/


---------------------------------------------------------------
-- 4)	TRIGGERS ---------------------------------------------- 
---------------------------------------------------------------
-- ELIMINAR TRIGGER ANTES DE CREARLo POR SI YA ESTA CREADo
DROP TRIGGER ACTUALIZA_RANKING_JUGADOR;
-- CREAR TRIGGER "ACTUALIZA_RANKING_JUGADOR"
CREATE OR REPLACE TRIGGER actualiza_ranking_jugador
--Salta el disparador despues de insertar o modificar
AFTER INSERT OR UPDATE ON jugadores_pac
FOR EACH ROW
DECLARE
--Declaramos variables para almacenar la informacion que necesitamos
puntos      jugadores_pac.puntos%TYPE;
ranking     ranking_pac.nombre_ranking%TYPE;
dif_puntos  jugadores_pac.puntos%TYPE;

BEGIN
--Los puntos van a ser igual a los que introducimos
   puntos:= :new.puntos;
--Para saber la variación de puntos hacemos la diferencia entre nuevos y antiguos
   dif_puntos:= :new.puntos - :old.puntos;
--Realizamos un CASE para que haga la instrucción que corresponda   
    CASE
    --Cuando insertamos
    WHEN inserting THEN 
    --Comprobamos rango de puntos
         IF puntos<=1000 THEN ranking := 'Bronze';
         ELSIF puntos<=2000 THEN ranking :='Plata';
         ELSIF puntos<=3000 THEN ranking :='Oro';
         ELSIF puntos<=4000 THEN ranking :='Platino';
         ELSIF puntos<=99999 THEN ranking:='Diamante';
         END IF;
   
    dbms_output.put_line('REGISTO INSERTADO: A fecha de '||sysdate||'. El jugador '||:new.nombre||' '
                        ||:new.apellidos||' está en el nivel '||ranking
                        ||' con un total de '||:new.puntos||' puntos');
    --Cuando modificamos                       
    WHEN updating THEN
    --Sumamos a los puntos antiguos los nuevos puntos introducidos
     puntos:=:old.puntos + :new.puntos;
        --Comprobamos rango de puntos
        IF puntos<=1000 THEN ranking := 'Bronze';
        ELSIF puntos<=2000 THEN ranking :='Plata';
        ELSIF puntos<=3000 THEN ranking :='Oro';
        ELSIF puntos<=4000 THEN ranking :='Platino';
        ELSIF puntos<=99999 THEN ranking:='Diamante';
        END IF;
    --Comprobamos si los puntos estan entre los parametros permitidos
    IF puntos NOT BETWEEN 0 AND 99999 THEN
    raise_application_error(-20010, 'La puntuación esta fuera del rango permitido de 0 a 99999 puntos');
    END IF;
   
    dbms_output.put_line('REGISTRO MODIFICADO: A fecha de '||sysdate||'. El jugador '||:old.nombre||' '
                        ||:old.apellidos||' está en el nivel '||ranking
                        ||' con un total de '||puntos||' puntos.'
                        ||' Con una variación de '||dif_puntos||' puntos, '|| 
                        'respecto la puntuación anterior.');
    END CASE;
END actualiza_ranking_jugador;
/
---------------------------------------------------------------
-- 5)   BLOQUES ANÓNIMOS PARA PRUEBAS ------------------------- 
---------------------------------------------------------------
SHOW USER;

-- COMPROBACIÓN GESTIÓN USUARIOS Y ROLES
EXECUTE dbms_output.put_line('-- COMPROBACIÓN GESTIÓN USUARIOS Y ROLES --');
DECLARE
--Creamos las variables para almacenar la información
    id_asig     asignaturas_pac.id_asignatura%TYPE;
    nombre_asig asignaturas_pac.nombre_asignatura%TYPE;
    nombre_profe    asignaturas_pac.nombre_profesor%TYPE;
BEGIN
    id_asig:='DAX_M02B';
--Select para almacenar la información segun el id asignatura pasado    
SELECT 
    nombre_asignatura,
    nombre_profesor
INTO
    nombre_asig,
    nombre_profe
FROM
    asignaturas_pac
WHERE
    id_asignatura=id_asig;
    dbms_output.put_line('El profesor de '||nombre_asig
                          ||' se llama '||nombre_profe);
  --Excepción en caso de que no encuentre el ID  
EXCEPTION 
    WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('ID asignatura no existente');
    
END;

/
-- COMPROBACIÓN DE TRIGGER ACTUALIZA_RANKING_JUGADOR
EXECUTE dbms_output.put_line('-- COMPROBACIÓN DE TRIGGER ACTUALIZA_RANKING_JUGADOR --');
DECLARE
--Creamos variables para guardar la información necesaria
nuevos_puntos   jugadores_pac.puntos%TYPE;
n_id_jugador    jugadores_pac.id_jugador%TYPE;
id_comprobar    jugadores_pac.id_jugador%TYPE;
BEGIN
--Insertamos un nuevo registro
INSERT INTO jugadores_pac VALUES(11,'Pepito','Ortiz Pérez',0);

nuevos_puntos:=&puntos;
n_id_jugador:=11;
--Select para comprobar si ID existe en la tabla, si no lo encuentra lanza error
SELECT jugadores_pac.id_jugador INTO id_comprobar FROM jugadores_pac WHERE n_id_jugador=jugadores_pac.id_jugador; 
--Realizamos la modificación
UPDATE jugadores_pac set jugadores_pac.puntos=puntos+nuevos_puntos WHERE n_id_jugador=jugadores_pac.id_jugador; 
--En caso de que el ID no exista lanza el error
    EXCEPTION 
    WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('El jugador con id '||n_id_jugador||' no existe en la base de datos');
END;


/
-- COMPROBACIÓN DEL PROCEDIMIENTO RANKING_JUGADOR
EXECUTE dbms_output.put_line('-- COMPROBACIÓN DEL PROCEDIMIENTO RANKING_JUGADOR --');
DECLARE
--Declaramos las variables de entrada y salida que pide el procedimiento
    valor_id             jugadores_pac.id_jugador%TYPE;
    puntos               jugadores_pac.puntos%TYPE; 
    nombre_par           jugadores_pac.nombre%TYPE;
    apellido_par         jugadores_pac.apellidos%TYPE;
    puntos_totales_par   jugadores_pac.puntos%TYPE;
    ranking_act          ranking_pac.nombre_ranking%TYPE;
BEGIN
--Damos valor a las variables de entrada
    valor_id:=&id;
    puntos:=&puntos;
    
  --Llamamos al procedimiento pasando los parametros  
    ranking_jugador(valor_id,puntos,nombre_par,apellido_par,puntos_totales_par,ranking_act);
   
    dbms_output.put_line ('El jugador: ' ||nombre_par||' ' ||apellido_par ||', tendrá '
                     ||puntos_totales_par ||' puntos y pasa al nivel de ranking '||ranking_act);
  --En el caso de que no encuentre el jugador lanza error  
EXCEPTION 
    WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('No se encuentra al jugador');
END;
/

-- COMPROBACIÓN DE LA FUNCION JUGADORES_POR_RANKING
EXECUTE dbms_output.put_line('-- COMPROBACIÓN DE LA FUNCION JUGADORES_POR_RANKING --');

DECLARE
--Declaración variables
total INT;
ranking VARCHAR2 (20);

BEGIN
--Damos valor a las variables llamando a la función
ranking:=&ranking;
total := jugadores_por_ranking(ranking);
dbms_output.put_line ('En el ranking '||ranking|| ' tenemos a ' ||total||' jugadores');
--Si el ranking no existe lanzará un error
EXCEPTION 
    WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('El ranking introducido no existe');
END;
/




