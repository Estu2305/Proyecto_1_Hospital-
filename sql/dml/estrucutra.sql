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

-- Centraliza las direcciones de hospitales, personas e instituciones.
CREATE TABLE IF NOT EXISTS direccion (
    direccion_id BIGINT GENERATED ALWAYS AS IDENTITY,
    municipio_id INTEGER NOT NULL,
    detalle VARCHAR(250) NOT NULL,
    zona VARCHAR(20),
    codigo_postal VARCHAR(10),
    area VARCHAR(10) NOT NULL,
    CONSTRAINT pk_direccion PRIMARY KEY (direccion_id),
   
    CONSTRAINT ck_direccion_detalle_no_vacio
        CHECK (BTRIM(detalle) <> ''),
   
    CONSTRAINT ck_direccion_area
        CHECK (area IN ('Urbana', 'Rural')),
    CONSTRAINT fk_direccion_municipio
        FOREIGN KEY (municipio_id)
        REFERENCES municipio (municipio_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- Registra los Establecimientos de Hospitales de Occidente.
CREATE TABLE IF NOT EXISTS hospital (
    hospital_id BIGINT GENERATED ALWAYS AS IDENTITY,
    direccion_id BIGINT NOT NULL,
    codigo VARCHAR(15) NOT NULL,
    nombre VARCHAR(120) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    correo VARCHAR(120),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_hospital PRIMARY KEY (hospital_id),
    CONSTRAINT uq_hospital_codigo UNIQUE (codigo),
    CONSTRAINT uq_hospital_nombre UNIQUE (nombre),
   
    CONSTRAINT ck_hospital_codigo_no_vacio
        CHECK (BTRIM(codigo) <> ''),
   
    CONSTRAINT ck_hospital_nombre_no_vacio
        CHECK (BTRIM(nombre) <> ''),
   
    CONSTRAINT ck_hospital_telefono_formato
        CHECK (telefono ~ '^[-+() 0-9]{8,20}$'),
   
    CONSTRAINT ck_hospital_correo_formato
        CHECK (correo IS NULL OR correo ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'),
    CONSTRAINT fk_hospital_direccion
        FOREIGN KEY (direccion_id)
        REFERENCES direccion (direccion_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- Registra las cuatro unidades medicas que funcionan en cada hospital.
CREATE TABLE IF NOT EXISTS unidad_medica (
    unidad_medica_id BIGINT GENERATED ALWAYS AS IDENTITY,
    hospital_id BIGINT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    ubicacion VARCHAR(150),
    telefono_extension VARCHAR(10),
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_unidad_medica PRIMARY KEY (unidad_medica_id),
    CONSTRAINT uq_unidad_medica_hospital_tipo UNIQUE (hospital_id, tipo),
    
    CONSTRAINT ck_unidad_medica_tipo
        CHECK (tipo IN ('Consulta Externa', 'Emergencias', 'Cirugia', 'Hospitalizacion')),
    
    CONSTRAINT ck_unidad_medica_nombre_no_vacio
        CHECK (BTRIM(nombre) <> ''),
    CONSTRAINT fk_unidad_medica_hospital
        FOREIGN KEY (hospital_id)
        REFERENCES hospital (hospital_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- Cataloga los servicios y tipos de atencion medica ofrecidos.
CREATE TABLE IF NOT EXISTS servicio_medico (
    servicio_medico_id SMALLINT GENERATED ALWAYS AS IDENTITY,
    nombre VARCHAR(120) NOT NULL,
    categoria VARCHAR(25) NOT NULL,
    descripcion VARCHAR(300),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_servicio_medico PRIMARY KEY (servicio_medico_id),
    CONSTRAINT uq_servicio_medico_nombre UNIQUE (nombre),
   
    CONSTRAINT ck_servicio_medico_categoria
        CHECK (categoria IN ('Consulta Externa', 'Emergencias', 'Cirugia', 'Hospitalizacion', 'General')),
   
    CONSTRAINT ck_servicio_medico_nombre_no_vacio
        CHECK (BTRIM(nombre) <> '')
);

-- Resuelve la relacion muchos a muchos entre unidades y servicios.
CREATE TABLE IF NOT EXISTS unidad_servicio (
    unidad_medica_id BIGINT NOT NULL,
    servicio_medico_id SMALLINT NOT NULL,
    costo_base NUMERIC(12,2) NOT NULL DEFAULT 0,
    disponible BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_unidad_servicio
        PRIMARY KEY (unidad_medica_id, servicio_medico_id),
  
    CONSTRAINT ck_unidad_servicio_costo_base
        CHECK (costo_base >= 0),
    CONSTRAINT fk_unidad_servicio_unidad
        FOREIGN KEY (unidad_medica_id)
        REFERENCES unidad_medica (unidad_medica_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_unidad_servicio_servicio
        FOREIGN KEY (servicio_medico_id)
        REFERENCES servicio_medico (servicio_medico_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- Registra clinicas, camillas, quirofanos, salas y camas hospitalarias.
CREATE TABLE IF NOT EXISTS espacio_hospitalario (
    espacio_hospitalario_id BIGINT GENERATED ALWAYS AS IDENTITY,
    hospital_id BIGINT NOT NULL,
    unidad_medica_id BIGINT,
    codigo VARCHAR(20) NOT NULL,
    tipo VARCHAR(15) NOT NULL,
    nombre VARCHAR(100),
    estado VARCHAR(20) NOT NULL DEFAULT 'Disponible',
    costo_diario NUMERIC(12,2),
    CONSTRAINT pk_espacio_hospitalario PRIMARY KEY (espacio_hospitalario_id),
    CONSTRAINT uq_espacio_hospitalario_codigo UNIQUE (hospital_id, codigo),
    
    CONSTRAINT ck_espacio_hospitalario_tipo
        CHECK (tipo IN ('Clinica', 'Camilla', 'Quirofano', 'Sala', 'Cama')),
    
    CONSTRAINT ck_espacio_hospitalario_estado
        CHECK (estado IN ('Disponible', 'Ocupado', 'Mantenimiento', 'Inactivo')),
    
    CONSTRAINT ck_espacio_hospitalario_costo_diario
        CHECK (costo_diario IS NULL OR costo_diario >= 0),
    
    CONSTRAINT ck_espacio_hospitalario_codigo_no_vacio
        CHECK (BTRIM(codigo) <> ''),
    CONSTRAINT fk_espacio_hospitalario_hospital
        FOREIGN KEY (hospital_id)
        REFERENCES hospital (hospital_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_espacio_hospitalario_unidad
        FOREIGN KEY (unidad_medica_id)
        REFERENCES unidad_medica (unidad_medica_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

-- Registra establecimientos externos utilizados en referencias y traslados.
CREATE TABLE IF NOT EXISTS institucion_externa (
    institucion_externa_id BIGINT GENERATED ALWAYS AS IDENTITY,
    direccion_id BIGINT,
    nombre VARCHAR(150) NOT NULL,
    tipo VARCHAR(30) NOT NULL,
    telefono VARCHAR(20),
    CONSTRAINT pk_institucion_externa PRIMARY KEY (institucion_externa_id),
    CONSTRAINT uq_institucion_externa_nombre UNIQUE (nombre),
    
    CONSTRAINT ck_institucion_externa_tipo
        CHECK (tipo IN ('Hospital', 'Clinica', 'Laboratorio', 'Organizacion', 'Otra')),
    
    CONSTRAINT ck_institucion_externa_nombre_no_vacio
        CHECK (BTRIM(nombre) <> ''),
    
    CONSTRAINT ck_institucion_externa_telefono_formato
        CHECK (telefono IS NULL OR telefono ~ '^[-+() 0-9]{8,20}$'),
    CONSTRAINT fk_institucion_externa_direccion
        FOREIGN KEY (direccion_id)
        REFERENCES direccion (direccion_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);