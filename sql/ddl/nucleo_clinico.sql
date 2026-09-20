BEGIN;
SET search_path TO hospital, public;

-- Estas claves compuestas permiten comprobar el hospital de la unidad y el espacio.
ALTER TABLE unidad_medica
    ADD CONSTRAINT uq_unidad_medica_id_hospital UNIQUE (unidad_medica_id, hospital_id);

ALTER TABLE espacio_hospitalario
    ADD CONSTRAINT uq_espacio_id_hospital UNIQUE (espacio_hospitalario_id, hospital_id);

-- Agrupa las atenciones de un paciente en un hospital durante un episodio.
CREATE TABLE episodio_atencion (
    episodio_atencion_id BIGINT GENERATED ALWAYS AS IDENTITY,
    paciente_id BIGINT NOT NULL,
    hospital_id BIGINT NOT NULL,
    fecha_apertura TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_cierre TIMESTAMPTZ,
    estado VARCHAR(12) NOT NULL DEFAULT 'Abierto',
    motivo_apertura TEXT NOT NULL,
    CONSTRAINT pk_episodio_atencion PRIMARY KEY (episodio_atencion_id),
    CONSTRAINT uq_episodio_hospital UNIQUE (episodio_atencion_id, hospital_id),
    
    CONSTRAINT ck_episodio_estado CHECK (estado IN ('Abierto', 'Cerrado')),
    
    CONSTRAINT ck_episodio_fechas CHECK (fecha_cierre IS NULL OR fecha_cierre >= fecha_apertura),
    
    CONSTRAINT ck_episodio_cierre CHECK (
        (estado = 'Abierto' AND fecha_cierre IS NULL)
        OR (estado = 'Cerrado' AND fecha_cierre IS NOT NULL)
    ),
    -- El motivo de apertura debe contener texto.
    CONSTRAINT ck_episodio_motivo CHECK (BTRIM(motivo_apertura) <> ''),
    CONSTRAINT fk_episodio_paciente FOREIGN KEY (paciente_id)
        REFERENCES paciente (paciente_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_episodio_hospital FOREIGN KEY (hospital_id)
        REFERENCES hospital (hospital_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Registra el ingreso de un paciente a emergencias, cirugia u hospitalizacion.
CREATE TABLE ingreso (
    ingreso_id BIGINT GENERATED ALWAYS AS IDENTITY,
    episodio_atencion_id BIGINT NOT NULL,
    hospital_id BIGINT NOT NULL,
    unidad_medica_id BIGINT NOT NULL,
    servicio_medico_id SMALLINT NOT NULL,
    medico_encargado_id BIGINT NOT NULL,
    encargado_paciente_id BIGINT,
    espacio_hospitalario_id BIGINT,
    fecha_ingreso TIMESTAMPTZ NOT NULL,
    motivo_ingreso TEXT NOT NULL,
    diagnostico_presuntivo TEXT NOT NULL,
    estado VARCHAR(10) NOT NULL DEFAULT 'Abierto',
    CONSTRAINT pk_ingreso PRIMARY KEY (ingreso_id),
    CONSTRAINT uq_ingreso_episodio UNIQUE (ingreso_id, episodio_atencion_id),
    
    CONSTRAINT ck_ingreso_estado CHECK (estado IN ('Abierto', 'Cerrado')),
    
    CONSTRAINT ck_ingreso_motivo CHECK (BTRIM(motivo_ingreso) <> ''),
    
    CONSTRAINT ck_ingreso_diagnostico CHECK (BTRIM(diagnostico_presuntivo) <> ''),
    CONSTRAINT fk_ingreso_episodio_hospital
        FOREIGN KEY (episodio_atencion_id, hospital_id)
        REFERENCES episodio_atencion (episodio_atencion_id, hospital_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_ingreso_unidad_hospital
        FOREIGN KEY (unidad_medica_id, hospital_id)
        REFERENCES unidad_medica (unidad_medica_id, hospital_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_ingreso_unidad_servicio
        FOREIGN KEY (unidad_medica_id, servicio_medico_id)
        REFERENCES unidad_servicio (unidad_medica_id, servicio_medico_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_ingreso_medico FOREIGN KEY (medico_encargado_id)
        REFERENCES medico (medico_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_ingreso_encargado FOREIGN KEY (encargado_paciente_id)
        REFERENCES encargado_paciente (encargado_paciente_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_ingreso_espacio_hospital
        FOREIGN KEY (espacio_hospitalario_id, hospital_id)
        REFERENCES espacio_hospitalario (espacio_hospitalario_id, hospital_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Cataloga diagnosticos clinicos que pueden documentarse en el egreso.
CREATE TABLE diagnostico (
    diagnostico_id BIGINT GENERATED ALWAYS AS IDENTITY,
    codigo VARCHAR(25),
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    CONSTRAINT pk_diagnostico PRIMARY KEY (diagnostico_id),
    CONSTRAINT uq_diagnostico_codigo UNIQUE (codigo),
    
    CONSTRAINT ck_diagnostico_nombre CHECK (BTRIM(nombre) <> '')
);

-- Documenta el egreso de la unidad y su destino o motivo de salida.
CREATE TABLE egreso (
    egreso_id BIGINT GENERATED ALWAYS AS IDENTITY,
    ingreso_id BIGINT NOT NULL,
    medico_asignado_id BIGINT NOT NULL,
    institucion_referida_id BIGINT,
    fecha_egreso TIMESTAMPTZ NOT NULL,
    motivo_egreso TEXT NOT NULL,
    codigo_egreso VARCHAR(10) NOT NULL,
    sin_consentimiento_medico BOOLEAN NOT NULL DEFAULT FALSE,
    motivo_sin_consentimiento TEXT,
    operaciones_intervenciones TEXT,
    codigo_traslado VARCHAR(40),
    observaciones TEXT,
    CONSTRAINT pk_egreso PRIMARY KEY (egreso_id),
    CONSTRAINT uq_egreso_ingreso UNIQUE (ingreso_id),
    
    CONSTRAINT ck_egreso_codigo CHECK (codigo_egreso IN ('Vivo', 'Muerto', 'Embarazo', 'Parto')),
    
    CONSTRAINT ck_egreso_sin_consentimiento CHECK (
        (sin_consentimiento_medico AND NULLIF(BTRIM(motivo_sin_consentimiento), '') IS NOT NULL)
        OR (NOT sin_consentimiento_medico AND motivo_sin_consentimiento IS NULL)
    ),
    
    CONSTRAINT ck_egreso_motivo CHECK (BTRIM(motivo_egreso) <> ''),
    CONSTRAINT fk_egreso_ingreso FOREIGN KEY (ingreso_id)
        REFERENCES ingreso (ingreso_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_egreso_medico FOREIGN KEY (medico_asignado_id)
        REFERENCES medico (medico_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_egreso_institucion FOREIGN KEY (institucion_referida_id)
        REFERENCES institucion_externa (institucion_externa_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);