-- CREAR PROCEDIMIENTO "RANKING_JUGADOR"
CREATE OR REPLACE PROCEDURE ranking_jugador (
    id_jugad IN jugadores_pac.id_jugador%TYPE,
    num_puntos IN jugadores_pac.puntos%TYPE,
    nombre_par OUT jugadores_pac.nombre%TYPE,
    apellido_par OUT jugadores_pac.apellidos%TYPE,
    puntos_totales_par OUT jugadores_pac.puntos%TYPE,
    ranking_act OUT ranking_pac.nombre_ranking%TYPE
) IS 
    valor_nombre     jugadores_pac.nombre%TYPE;
    valor_apellido   jugadores_pac.apellidos%TYPE;
    valor_puntos     jugadores_pac.puntos%TYPE;
    ranking          ranking_pac.nombre_ranking%TYPE;
BEGIN
    
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
    
    valor_puntos:=valor_puntos + num_puntos; 
    nombre_par:=valor_nombre;
    apellido_par:=valor_apellido;
    puntos_totales_par:=valor_puntos;

IF valor_puntos<=1000
THEN ranking := 'Bronce';
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


--Comprobación procedimiento

DECLARE
    valor_id             jugadores_pac.id_jugador%TYPE;
    puntos               jugadores_pac.puntos%TYPE; 
    nombre_par           jugadores_pac.nombre%TYPE;
    apellido_par         jugadores_pac.apellidos%TYPE;
    puntos_totales_par   jugadores_pac.puntos%TYPE;
    ranking_act          ranking_pac.nombre_ranking%TYPE;
BEGIN
    valor_id:=&id;
    puntos:=&puntos;
    
    
    ranking_jugador(valor_id,puntos,nombre_par,apellido_par,puntos_totales_par,ranking_act);
   
    dbms_output.put_line ('El jugador: ' ||nombre_par||' ' ||apellido_par ||', tendrá '
                     ||puntos_totales_par ||' puntos y pasa al nivel de ranking '||ranking_act);
    
EXCEPTION 
    WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('No se encuentra al jugador');
END;

/

DROP PROCEDURE ranking_jugador2;

-- Comprobacion funcion

DECLARE
total INT;
ranking VARCHAR2 (20);

BEGIN
ranking:=&ranking;
total := jugadores_por_ranking(ranking);
dbms_output.put_line ('En el ranking '||ranking|| ' tenemos a ' ||total||' jugadores');
EXCEPTION 
    WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('El ranking introducido no existe');
END;
/

-- COMPROBACIÓN GESTIÓN USUARIOS Y ROLES
    
DECLARE
    id_asig     asignaturas_pac.id_asignatura%TYPE;
    nombre_asig asignaturas_pac.nombre_asignatura%TYPE;
    nombre_profe    asignaturas_pac.nombre_profesor%TYPE;
BEGIN
    id_asig:='DAX_M02B';
    
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
    
EXCEPTION 
    WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('ID asignatura no existente');
    
END;
/

-- Creación trigger
CREATE OR REPLACE TRIGGER actualiza_ranking_jugador
AFTER INSERT OR UPDATE ON jugadores_pac
FOR EACH ROW
DECLARE
puntos      jugadores_pac.puntos%TYPE;
ranking     ranking_pac.nombre_ranking%TYPE;
dif_puntos  jugadores_pac.puntos%TYPE;

BEGIN
   puntos:= :new.puntos;
   dif_puntos:= :new.puntos - :old.puntos;
   
    CASE
    WHEN inserting THEN 
         IF puntos<=1000
         THEN ranking := 'Bronze';

         ELSIF puntos<=2000
         THEN ranking :='Plata';

         ELSIF puntos<=3000
         THEN ranking :='Oro';

         ELSIF puntos<=4000
         THEN ranking :='Platino';

         ELSIF puntos<=99999
         THEN ranking:='Diamante';

         END IF;
   
    dbms_output.put_line('REGISTO INSERTADO: A fecha de '||sysdate||'. El jugador '||:new.nombre||' '
                        ||:new.apellidos||' está en el nivel '||ranking
                        ||' con un total de '||:new.puntos||' puntos');
                        
    
    WHEN updating THEN
     puntos:=:old.puntos + :new.puntos;
     
        IF puntos<=1000
        THEN ranking := 'Bronze';

        ELSIF puntos<=2000
        THEN ranking :='Plata';

        ELSIF puntos<=3000
        THEN ranking :='Oro';

        ELSIF puntos<=4000
        THEN ranking :='Platino';

        ELSIF puntos<=99999
        THEN ranking:='Diamante';

        END IF;
    
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
-- ejemplo compi
/*CREATE OR REPLACE TRIGGER cambio_ranking_jugador
BEFORE INSERT OR UPDATE
ON jugadores_pac2
DECLARE
v_fecha 	varchar(50);
v_id		 jugadores_pac.id_jugador%type;
v_puntos	jugadores_pac.puntos%type;
v_nombre	jugadores_pac.nombre%type;
v_apellidos	jugadores_pac.apellidos%type;
v_puntos_Act	jugadores_pac.puntos%type;
v_ranking_nuevo	ranking_pac.nombre_ranking%type;
BEGIN
SELECT to_char(sysdate) INTO v_fecha FROM dual;
dbms_output.put_line ('A fecha de ' || v_fecha || '. El jugador ' || v_nombre || ' ' || v_apellidos || ' está en el nivel '
||v_ranking_nuevo || ' con un total de ' ||v_puntos_act || ' puntos');
END;*/


--Bloque anónimo para probar trigger

DECLARE

nuevos_puntos   jugadores_pac.puntos%TYPE;
n_id_jugador    jugadores_pac.id_jugador%TYPE;
id_comprobar    jugadores_pac.id_jugador%TYPE;
BEGIN

INSERT INTO jugadores_pac VALUES(11,'Pepito','Ortiz Pérez',0);

nuevos_puntos:=&puntos;
n_id_jugador:=11;

SELECT jugadores_pac.id_jugador INTO id_comprobar FROM jugadores_pac WHERE n_id_jugador=jugadores_pac.id_jugador; 
UPDATE jugadores_pac set jugadores_pac.puntos=puntos+nuevos_puntos WHERE n_id_jugador=jugadores_pac.id_jugador; 

    EXCEPTION 
    WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('El jugador con id '||n_id_jugador||' no existe en la base de datos');
END;
/

DELETE from jugadores_pac WHERE id_jugador=11;

DROP TRIGGER actualiza_ranking_jugador;

DROP TABLE jugadores_pac2;