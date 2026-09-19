/*
Archivo: estructura.sql
Motor: PostgreSQL 16 o superior
Bloque 1: Organizacion, ubicacion, presonas y personal
*/

BEGIN;

CREATE SCHEMA IF NOT EXISTS hospital;
SET search_path TO hospital, public;

-- Organicacion y Ubicacion--

-- Catalogo de departamentos --
CREATE TABLE IF NOT EXISTS departamento (
   departamento_id SMALLINT GENERATED ALWAYS AS IDENTITY,
   nombre VARCHAR(60) NOT NULL,
   CONSTRAINT pk_departamento PRIMARY KEY (departamento_id),
   CONSTRAINT uq_departamento_nombre UNIQUE (nombre),

   CONSTRAINT cK_departamento_nombre_no_vacio
      CHECK (BTRIM(nombre) <> '')
);

-- Municipio y departamento pertenecen --
CREATE TABLE IF NOT EXISTS municipio (
    municipio_id INTEGER GENERATED ALWAYS AS IDENTITY,
    departamento_id SMALLINT NOT NULL,
    nombre VARCHAR(80) NOT NULL,
    CONSTRAINT pk_municipio PRIMARY KEY (municipio_id),
    CONSTRAINT uq_municipio_departamento_nombre
        UNIQUE (departamento_id, nombre),
    -- Valida que el nombre no sea una cadena vacia.
    CONSTRAINT ck_municipio_nombre_no_vacio
        CHECK (BTRIM(nombre) <> ''),
    CONSTRAINT fk_municipio_departamento
        FOREIGN KEY (departamento_id)
        REFERENCES departamento (departamento_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);
