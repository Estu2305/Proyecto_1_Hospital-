/*
Archivo: estructura.sql
Motor: PostgreSQL 16 o superior
Bloque 1: Organizacion, ubicacion, presonas y personal
*/

BEGIN;

CREATE SCHEMA IF NOT EXISTS hospital;
SET search_path TO hospital, public;

--1. Organicacion y Ubicacion--

-- Catalogo de departamentos --
CREATE TABLE IF NOT EXISTS departamento (
   departamento_id SMALLINT GENERATED ALWAYS AS IDENTITY,
   nombre VARCHAR(60) NOT NULL,
   CONSTRAINT pk_departamento PRIMARY KEY (departamento_id),
   CONSTRAINT uq_departamento_nombre UNIQUE (nombre),

   -- Exige que nombre contenga texto.
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
   
    -- Exige que detalle contenga texto.
    CONSTRAINT ck_direccion_detalle_no_vacio
        CHECK (BTRIM(detalle) <> ''),
   
    -- Limita area a los valores permitidos.
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
   
    -- Exige que codigo contenga texto.
    CONSTRAINT ck_hospital_codigo_no_vacio
        CHECK (BTRIM(codigo) <> ''),
   
    -- Exige que nombre contenga texto.
    CONSTRAINT ck_hospital_nombre_no_vacio
        CHECK (BTRIM(nombre) <> ''),
   
    -- Valida el formato establecido para hospital telefono.
    CONSTRAINT ck_hospital_telefono_formato
        CHECK (telefono ~ '^[-+() 0-9]{8,20}$'),
   
    -- Valida el formato establecido para hospital correo.
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
    
    -- Exige que nombre contenga texto.
    CONSTRAINT ck_unidad_medica_tipo
        CHECK (tipo IN ('Consulta Externa', 'Emergencias', 'Cirugia', 'Hospitalizacion')),
    
    -- Exige que nombre contenga texto.
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
   
    -- Exige que nombre contenga texto.
    CONSTRAINT ck_servicio_medico_categoria
        CHECK (categoria IN ('Consulta Externa', 'Emergencias', 'Cirugia', 'Hospitalizacion', 'General')),
   
    -- Exige que nombre contenga texto.
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
  
    -- Impide valores negativos en costo base.
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
    
    -- Limita tipo a los valores permitidos.
    CONSTRAINT ck_espacio_hospitalario_tipo
        CHECK (tipo IN ('Clinica', 'Camilla', 'Quirofano', 'Sala', 'Cama')),
    
    -- Exige que codigo contenga texto.
    CONSTRAINT ck_espacio_hospitalario_estado
        CHECK (estado IN ('Disponible', 'Ocupado', 'Mantenimiento', 'Inactivo')),
    
    -- Exige que codigo contenga texto.
    CONSTRAINT ck_espacio_hospitalario_costo_diario
        CHECK (costo_diario IS NULL OR costo_diario >= 0),
    
    -- Exige que codigo contenga texto.
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
    
    -- Exige que nombre contenga texto.
    CONSTRAINT ck_institucion_externa_tipo
        CHECK (tipo IN ('Hospital', 'Clinica', 'Laboratorio', 'Organizacion', 'Otra')),
    
    -- Exige que nombre contenga texto.
    CONSTRAINT ck_institucion_externa_nombre_no_vacio
        CHECK (BTRIM(nombre) <> ''),
    
    -- Valida el formato establecido para institucion externa telefono.
    CONSTRAINT ck_institucion_externa_telefono_formato
        CHECK (telefono IS NULL OR telefono ~ '^[-+() 0-9]{8,20}$'),
    CONSTRAINT fk_institucion_externa_direccion
        FOREIGN KEY (direccion_id)
        REFERENCES direccion (direccion_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

-- 2. PERSONAS, PACIENTES Y PERSONAL --

-- Centraliza la informacion comun de pacientes, encargados y trabajadores.
CREATE TABLE IF NOT EXISTS persona (
    persona_id BIGINT GENERATED ALWAYS AS IDENTITY,
    direccion_id BIGINT,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    dpi CHAR(13),
    fecha_nacimiento DATE NOT NULL,
    sexo VARCHAR(10) NOT NULL,
    estado_civil VARCHAR(15),
    telefono VARCHAR(20),
    correo VARCHAR(120),
    CONSTRAINT pk_persona PRIMARY KEY (persona_id),
    CONSTRAINT uq_persona_dpi UNIQUE (dpi),
    
    -- Exige que nombres contenga texto.
    CONSTRAINT ck_persona_nombres_no_vacios
        CHECK (BTRIM(nombres) <> ''),
    
    -- Exige que apellidos contenga texto.
    CONSTRAINT ck_persona_apellidos_no_vacios
        CHECK (BTRIM(apellidos) <> ''),
    
    -- Limita sexo a los valores permitidos.
    CONSTRAINT ck_persona_sexo
        CHECK (sexo IN ('Masculino', 'Femenino')),
    
    -- Limita estado civil a los valores permitidos.
    CONSTRAINT ck_persona_estado_civil
        CHECK (estado_civil IS NULL OR estado_civil IN ('Soltero', 'Casado', 'Unido', 'Divorciado', 'Viudo')),
    
    -- Valida la secuencia cronologica de persona fecha nacimiento.
    CONSTRAINT ck_persona_fecha_nacimiento
        CHECK (fecha_nacimiento >= DATE '1900-01-01'),
    
    -- Valida el formato establecido para persona dpi.
    CONSTRAINT ck_persona_dpi_formato
        CHECK (dpi IS NULL OR dpi ~ '^[0-9]{13}$'),
    
    -- Valida el formato establecido para persona telefono.
    CONSTRAINT ck_persona_telefono_formato
        CHECK (telefono IS NULL OR telefono ~ '^[-+() 0-9]{8,20}$'),
    
    -- Valida el formato establecido para persona correo.
    CONSTRAINT ck_persona_correo_formato
        CHECK (correo IS NULL OR correo ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'),
    CONSTRAINT fk_persona_direccion
        FOREIGN KEY (direccion_id)
        REFERENCES direccion (direccion_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

-- Amplia a persona con los datos administrativos propios de un paciente.
CREATE TABLE IF NOT EXISTS paciente (
    paciente_id BIGINT,
    numero_expediente VARCHAR(25) NOT NULL,
    numero_seguro_social VARCHAR(30),
    fecha_registro DATE NOT NULL DEFAULT CURRENT_DATE,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_paciente PRIMARY KEY (paciente_id),
    CONSTRAINT uq_paciente_expediente UNIQUE (numero_expediente),
    CONSTRAINT uq_paciente_seguro_social UNIQUE (numero_seguro_social),
    
    -- Exige que numero expediente contenga texto.
    CONSTRAINT ck_paciente_expediente_no_vacio
        CHECK (BTRIM(numero_expediente) <> ''),
    CONSTRAINT fk_paciente_persona
        FOREIGN KEY (paciente_id)
        REFERENCES persona (persona_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- Relaciona cada paciente con uno o varios encargados autorizados.
CREATE TABLE IF NOT EXISTS encargado_paciente (
    encargado_paciente_id BIGINT GENERATED ALWAYS AS IDENTITY,
    paciente_id BIGINT NOT NULL,
    encargado_persona_id BIGINT NOT NULL,
    parentesco VARCHAR(40) NOT NULL,
    es_principal BOOLEAN NOT NULL DEFAULT FALSE,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_encargado_paciente PRIMARY KEY (encargado_paciente_id),
    CONSTRAINT uq_encargado_paciente_relacion
        UNIQUE (paciente_id, encargado_persona_id),
    
    -- Exige que parentesco contenga texto.
    CONSTRAINT ck_encargado_paciente_parentesco_no_vacio
        CHECK (BTRIM(parentesco) <> ''),
    
    -- Garantiza la coherencia de encargado paciente personas distintas.
    CONSTRAINT ck_encargado_paciente_personas_distintas
        CHECK (paciente_id <> encargado_persona_id),
    CONSTRAINT fk_encargado_paciente_paciente
        FOREIGN KEY (paciente_id)
        REFERENCES paciente (paciente_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_encargado_paciente_persona
        FOREIGN KEY (encargado_persona_id)
        REFERENCES persona (persona_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- Registra personal contratado directamente por un hospital.
CREATE TABLE IF NOT EXISTS empleado (
    empleado_id BIGINT GENERATED ALWAYS AS IDENTITY,
    persona_id BIGINT NOT NULL,
    hospital_id BIGINT NOT NULL,
    codigo_empleado VARCHAR(20) NOT NULL,
    tipo_empleado VARCHAR(25) NOT NULL,
    fecha_contratacion DATE NOT NULL,
    fecha_finalizacion DATE,
    estado_laboral VARCHAR(15) NOT NULL DEFAULT 'Activo',
    CONSTRAINT pk_empleado PRIMARY KEY (empleado_id),
    CONSTRAINT uq_empleado_hospital_codigo UNIQUE (hospital_id, codigo_empleado),
    CONSTRAINT uq_empleado_persona_hospital UNIQUE (persona_id, hospital_id),
    
    -- Limita tipo empleado a los valores permitidos.
    CONSTRAINT ck_empleado_tipo
        CHECK (tipo_empleado IN ('Medico', 'Enfermero', 'Practicante', 'Recepcionista', 'Administrativo', 'Otro')),
    
    -- Exige que codigo empleado contenga texto.
    CONSTRAINT ck_empleado_estado_laboral
        CHECK (estado_laboral IN ('Activo', 'Suspendido', 'Finalizado')),
    
    -- Exige que codigo empleado contenga texto.
    CONSTRAINT ck_empleado_fechas
        CHECK (fecha_finalizacion IS NULL OR fecha_finalizacion >= fecha_contratacion),
    
    -- Exige que codigo empleado contenga texto.
    CONSTRAINT ck_empleado_codigo_no_vacio
        CHECK (BTRIM(codigo_empleado) <> ''),
    CONSTRAINT fk_empleado_persona
        FOREIGN KEY (persona_id)
        REFERENCES persona (persona_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_empleado_hospital
        FOREIGN KEY (hospital_id)
        REFERENCES hospital (hospital_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- Cataloga especialidades medicas de consulta externa, emergencia y cirugia.
CREATE TABLE IF NOT EXISTS especialidad (
    especialidad_id SMALLINT GENERATED ALWAYS AS IDENTITY,
    nombre VARCHAR(120) NOT NULL,
    descripcion VARCHAR(300),
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_especialidad PRIMARY KEY (especialidad_id),
    CONSTRAINT uq_especialidad_nombre UNIQUE (nombre),
    
    -- Exige que nombre contenga texto.
    CONSTRAINT ck_especialidad_nombre_no_vacio
        CHECK (BTRIM(nombre) <> '')
);

-- Registra los datos profesionales de medicos internos, residentes o externos.
CREATE TABLE IF NOT EXISTS medico (
    medico_id BIGINT,
    numero_colegiado VARCHAR(25) NOT NULL,
    clase_medico VARCHAR(12) NOT NULL,
    institucion_externa_id BIGINT,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_medico PRIMARY KEY (medico_id),
    CONSTRAINT uq_medico_numero_colegiado UNIQUE (numero_colegiado),
    
    -- Limita clase medico a los valores permitidos.
    CONSTRAINT ck_medico_clase
        CHECK (clase_medico IN ('Residente', 'Interno', 'Externo')),
    
    -- Exige que numero colegiado contenga texto.
    CONSTRAINT ck_medico_institucion_externa
        CHECK (
            (clase_medico = 'Externo' AND institucion_externa_id IS NOT NULL)
            OR (clase_medico IN ('Residente', 'Interno') AND institucion_externa_id IS NULL)
        ),
    
    -- Exige que numero colegiado contenga texto.
    CONSTRAINT ck_medico_colegiado_no_vacio
        CHECK (BTRIM(numero_colegiado) <> ''),
    CONSTRAINT fk_medico_persona
        FOREIGN KEY (medico_id)
        REFERENCES persona (persona_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_medico_institucion_externa
        FOREIGN KEY (institucion_externa_id)
        REFERENCES institucion_externa (institucion_externa_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- Resuelve la relacion muchos a muchos entre medicos y especialidades.
CREATE TABLE IF NOT EXISTS medico_especialidad (
    medico_id BIGINT NOT NULL,
    especialidad_id SMALLINT NOT NULL,
    es_principal BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT pk_medico_especialidad
        PRIMARY KEY (medico_id, especialidad_id),
    CONSTRAINT fk_medico_especialidad_medico
        FOREIGN KEY (medico_id)
        REFERENCES medico (medico_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_medico_especialidad_especialidad
        FOREIGN KEY (especialidad_id)
        REFERENCES especialidad (especialidad_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- Registra la vinculacion de un medico con uno o varios hospitales.
CREATE TABLE IF NOT EXISTS medico_hospital (
    medico_hospital_id BIGINT GENERATED ALWAYS AS IDENTITY,
    medico_id BIGINT NOT NULL,
    hospital_id BIGINT NOT NULL,
    condicion VARCHAR(12) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_medico_hospital PRIMARY KEY (medico_hospital_id),
    CONSTRAINT uq_medico_hospital_vinculo UNIQUE (medico_id, hospital_id, fecha_inicio),
    
    -- Limita condicion a los valores permitidos.
    CONSTRAINT ck_medico_hospital_condicion
        CHECK (condicion IN ('Residente', 'Interno', 'Externo')),
    
    -- Valida la secuencia cronologica de medico hospital fechas.
    CONSTRAINT ck_medico_hospital_fechas
        CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
    CONSTRAINT fk_medico_hospital_medico
        FOREIGN KEY (medico_id)
        REFERENCES medico (medico_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_medico_hospital_hospital
        FOREIGN KEY (hospital_id)
        REFERENCES hospital (hospital_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- Especializa a un empleado con los datos profesionales de enfermeria.
CREATE TABLE IF NOT EXISTS enfermero (
    enfermero_id BIGINT,
    numero_registro VARCHAR(25),
    nivel VARCHAR(12) NOT NULL,
    CONSTRAINT pk_enfermero PRIMARY KEY (enfermero_id),
    CONSTRAINT uq_enfermero_numero_registro UNIQUE (numero_registro),
    
    -- Exige que numero registro contenga texto.
    CONSTRAINT ck_enfermero_nivel
        CHECK (nivel IN ('Registrado', 'Practicante')),
    
    -- Exige que numero registro contenga texto.
    CONSTRAINT ck_enfermero_registro_segun_nivel
        CHECK (
            (nivel = 'Registrado' AND numero_registro IS NOT NULL AND BTRIM(numero_registro) <> '')
            OR nivel = 'Practicante'
        ),
    CONSTRAINT fk_enfermero_empleado
        FOREIGN KEY (enfermero_id)
        REFERENCES empleado (empleado_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- Especializa a un empleado que realiza practica profesional de medicina.
CREATE TABLE IF NOT EXISTS practicante_medicina (
    practicante_id BIGINT,
    institucion_educativa VARCHAR(150) NOT NULL,
    numero_carnet VARCHAR(30) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    CONSTRAINT pk_practicante_medicina PRIMARY KEY (practicante_id),
    CONSTRAINT uq_practicante_medicina_carnet UNIQUE (institucion_educativa, numero_carnet),
    
    -- Exige que institucion educativa contenga texto.
    CONSTRAINT ck_practicante_institucion_no_vacia
        CHECK (BTRIM(institucion_educativa) <> ''),
    
    -- Exige que numero carnet contenga texto.
    CONSTRAINT ck_practicante_carnet_no_vacio
        CHECK (BTRIM(numero_carnet) <> ''),
    
    -- Valida la secuencia cronologica de practicante fechas.
    CONSTRAINT ck_practicante_fechas
        CHECK (fecha_fin >= fecha_inicio),
    CONSTRAINT fk_practicante_medicina_empleado
        FOREIGN KEY (practicante_id)
        REFERENCES empleado (empleado_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- Registra los turnos asignados al personal en una unidad medica.
CREATE TABLE IF NOT EXISTS turno_personal (
    turno_personal_id BIGINT GENERATED ALWAYS AS IDENTITY,
    empleado_id BIGINT NOT NULL,
    unidad_medica_id BIGINT NOT NULL,
    fecha DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    estado VARCHAR(12) NOT NULL DEFAULT 'Programado',
    CONSTRAINT pk_turno_personal PRIMARY KEY (turno_personal_id),
    CONSTRAINT uq_turno_personal_asignacion
        UNIQUE (empleado_id, unidad_medica_id, fecha, hora_inicio),
    
    -- Limita estado a los valores permitidos.
    CONSTRAINT ck_turno_personal_horas
        CHECK (hora_fin > hora_inicio),
    
    -- Limita estado a los valores permitidos.
    CONSTRAINT ck_turno_personal_estado
        CHECK (estado IN ('Programado', 'Cumplido', 'Cancelado')),
    CONSTRAINT fk_turno_personal_empleado
        FOREIGN KEY (empleado_id)
        REFERENCES empleado (empleado_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_turno_personal_unidad
        FOREIGN KEY (unidad_medica_id)
        REFERENCES unidad_medica (unidad_medica_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- Solo puede existir un encargado principal activo por paciente.
CREATE UNIQUE INDEX IF NOT EXISTS uq_encargado_principal_activo
    ON encargado_paciente (paciente_id)
    WHERE es_principal = TRUE AND activo = TRUE;

-- Solo puede existir una especialidad principal por medico.
CREATE UNIQUE INDEX IF NOT EXISTS uq_medico_especialidad_principal
    ON medico_especialidad (medico_id)
    WHERE es_principal = TRUE;

COMMIT;


