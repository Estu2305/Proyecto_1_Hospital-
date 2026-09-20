BEGIN;
SET search_path TO hospital, public;

-- Registra la solicitud de una cirugia urgente o programada.
CREATE TABLE solicitud_cirugia (
    solicitud_cirugia_id BIGINT GENERATED ALWAYS AS IDENTITY,
    paciente_id BIGINT NOT NULL,
    hospital_id BIGINT NOT NULL,
    cirujano_id BIGINT NOT NULL,
    episodio_atencion_id BIGINT,
    fecha_solicitud TIMESTAMPTZ NOT NULL,
    caracter VARCHAR(10) NOT NULL,
    historia_clinica TEXT NOT NULL,
    procedimiento_propuesto TEXT NOT NULL,
    duracion_estimada_minutos INTEGER NOT NULL,
    tipo_anestesia VARCHAR(80) NOT NULL,
    observaciones TEXT,
    CONSTRAINT pk_solicitud_cirugia PRIMARY KEY (solicitud_cirugia_id),
    CONSTRAINT uq_solicitud_paciente UNIQUE (solicitud_cirugia_id, paciente_id),
   
    CONSTRAINT ck_solicitud_caracter CHECK (caracter IN ('Urgente', 'Programado')),
    
    CONSTRAINT ck_solicitud_duracion CHECK (duracion_estimada_minutos > 0),
    
    CONSTRAINT ck_solicitud_historia CHECK (BTRIM(historia_clinica) <> ''),
    
    CONSTRAINT ck_solicitud_procedimiento CHECK (BTRIM(procedimiento_propuesto) <> ''),
    
    CONSTRAINT ck_solicitud_anestesia CHECK (BTRIM(tipo_anestesia) <> ''),
    CONSTRAINT fk_solicitud_paciente FOREIGN KEY (paciente_id)
        REFERENCES paciente (paciente_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_solicitud_hospital FOREIGN KEY (hospital_id)
        REFERENCES hospital (hospital_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_solicitud_cirujano FOREIGN KEY (cirujano_id)
        REFERENCES medico (medico_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_solicitud_episodio_hospital
        FOREIGN KEY (episodio_atencion_id, hospital_id)
        REFERENCES episodio_atencion (episodio_atencion_id, hospital_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Guarda la decision y razones del comite para una solicitud quirurgica.
CREATE TABLE evaluacion_solicitud_cirugia (
    evaluacion_solicitud_cirugia_id BIGINT GENERATED ALWAYS AS IDENTITY,
    solicitud_cirugia_id BIGINT NOT NULL,
    medico_evaluador_id BIGINT NOT NULL,
    fecha_evaluacion TIMESTAMPTZ NOT NULL,
    decision VARCHAR(10) NOT NULL,
    razones TEXT,
    CONSTRAINT pk_evaluacion_solicitud PRIMARY KEY (evaluacion_solicitud_cirugia_id),
    CONSTRAINT uq_evaluacion_solicitud UNIQUE (solicitud_cirugia_id),
    CONSTRAINT uq_evaluacion_solicitud_decision
        UNIQUE (evaluacion_solicitud_cirugia_id, solicitud_cirugia_id, decision),
    
    CONSTRAINT ck_evaluacion_decision CHECK (decision IN ('Aprobada', 'Rechazada')),
    
    CONSTRAINT ck_evaluacion_razones CHECK (
        decision <> 'Rechazada' OR NULLIF(BTRIM(razones), '') IS NOT NULL
    ),
    CONSTRAINT fk_evaluacion_solicitud FOREIGN KEY (solicitud_cirugia_id)
        REFERENCES solicitud_cirugia (solicitud_cirugia_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_evaluacion_medico FOREIGN KEY (medico_evaluador_id)
        REFERENCES medico (medico_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

