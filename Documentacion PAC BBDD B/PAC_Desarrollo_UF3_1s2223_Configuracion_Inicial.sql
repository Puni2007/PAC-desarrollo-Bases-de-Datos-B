---------------------------------------------------------------
-- CONFIGURACIÓN INICIAL -------------------------------------- 
-- Creación de Usuario, tablas y registros para la PAC -------
---------------------------------------------------------------

ALTER SESSION SET "_ORACLE_SCRIPT" = true;
---------------------------------------------------------------
-- USUARIO ILERNA_PAC ----------------------------------------- 
---------------------------------------------------------------
CREATE USER ILERNA_PAC IDENTIFIED BY i1234;

GRANT ALL PRIVILEGES TO ILERNA_PAC;

CONN ILERNA_PAC / i1234

---------------------------------------------------------------
-- TABLA ASIGNATURAS_PAC -------------------------------------- 
---------------------------------------------------------------
-- Borramos la tabla si en caso de que exista
DROP TABLE asignaturas_pac;
-- Creamos la tabla
CREATE TABLE asignaturas_pac (
    id_asignatura     VARCHAR(11) PRIMARY KEY,
    nombre_asignatura VARCHAR(20),
    nombre_profesor   VARCHAR(30),
    creditos          NUMBER(2)
);

---------------------------------------------------------------
-- TABLA RANKING_PAC ------------------------------------------ 
---------------------------------------------------------------
-- Borramos la tabla si en caso de que exista
DROP TABLE ranking_pac;
-- Creamos la tabla
CREATE TABLE ranking_pac (
    id_ranking     NUMBER(2) PRIMARY KEY,
    nombre_ranking VARCHAR(20),
    puntos_min     NUMBER(10),
    puntos_max     NUMBER(10)
);

---------------------------------------------------------------
-- TABLA JUGADORES_PAC ---------------------------------------- 
---------------------------------------------------------------
-- Borramos la tabla si en caso de que exista
DROP TABLE jugadores_pac;
-- Creamos la tabla
CREATE TABLE jugadores_pac (
    id_jugador NUMBER(2) PRIMARY KEY,
    nombre     VARCHAR(20),
    apellidos  VARCHAR(30),
    puntos     NUMBER(10, 2)
);

-- VALORES DE RANKING

INSERT INTO ranking_pac VALUES (
    1,
    'Bronze',
    0,
    1000
);

INSERT INTO ranking_pac VALUES (
    2,
    'Plata',
    1001,
    2000
);

INSERT INTO ranking_pac VALUES (
    3,
    'Oro',
    2001,
    3000
);

INSERT INTO ranking_pac VALUES (
    4,
    'Platino',
    3001,
    4000
);

INSERT INTO ranking_pac VALUES (
    5,
    'Diamante',
    4001,
    99999
);

-- VALORES DE JUGADORES

INSERT INTO jugadores_pac VALUES (
    1,
    'Antonio',
    'Garcia Melero',
    250
);

INSERT INTO jugadores_pac VALUES (
    2,
    'Juan',
    'Suarez Jimeno',
    2350
);

INSERT INTO jugadores_pac VALUES (
    3,
    'Alonso',
    'Valencia Morales',
    1800
);

INSERT INTO jugadores_pac VALUES (
    4,
    'Fermin',
    'Lopez Galera',
    2050
);

INSERT INTO jugadores_pac VALUES (
    5,
    'Dolores',
    'Remiro Soria',
    1360
);

INSERT INTO jugadores_pac VALUES (
    6,
    'Maria',
    'Blazquez Ortiz',
    1520
);

INSERT INTO jugadores_pac VALUES (
    7,
    'Manuel',
    'Soledad Niera',
    1060
);

INSERT INTO jugadores_pac VALUES (
    8,
    'Lurdes',
    'Giro Bueno',
    960
);

INSERT INTO jugadores_pac VALUES (
    9,
    'Sofia',
    'Torres Liro',
    5900
);

INSERT INTO jugadores_pac VALUES (
    10,
    'Joan',
    'Polero Guerrero',
    2900
);