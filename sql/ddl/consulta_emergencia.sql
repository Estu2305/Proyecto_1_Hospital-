BEGIN;
SET search_path TO hospital, public;

-- Registra los horarios matutinos de consulta de los medicos por clinica.
CREATE TABLE horario_consulta (
    horario_consulta_id BIGINT GENERATED ALWAYS AS IDENTITY,
    medico_id BIGINT NOT NULL,
    unidad_medica_id BIGINT NOT NULL,
    clinica_id BIGINT NOT NULL,
    dia_semana SMALLINT NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_horario_consulta PRIMARY KEY (horario_consulta_id),
    CONSTRAINT uq_horario_consulta UNIQUE (medico_id, clinica_id, dia_semana, hora_inicio),
   
    CONSTRAINT ck_horario_dia CHECK (dia_semana BETWEEN 1 AND 7),
  
    CONSTRAINT ck_horario_matutino CHECK (hora_inicio >= TIME '06:00'
        AND hora_fin <= TIME '12:00' AND hora_fin > hora_inicio),
    CONSTRAINT fk_horario_medico FOREIGN KEY (medico_id)
        REFERENCES medico (medico_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_horario_unidad FOREIGN KEY (unidad_medica_id)
        REFERENCES unidad_medica (unidad_medica_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_horario_clinica FOREIGN KEY (clinica_id)
        REFERENCES espacio_hospitalario (espacio_hospitalario_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Registra citas programadas, realizadas, reprogramadas y canceladas.
CREATE TABLE cita (
    cita_id BIGINT GENERATED ALWAYS AS IDENTITY,
    paciente_id BIGINT NOT NULL,
    medico_id BIGINT NOT NULL,
    unidad_medica_id BIGINT NOT NULL,
    clinica_id BIGINT NOT NULL,
    cita_anterior_id BIGINT,
    fecha_hora TIMESTAMPTZ NOT NULL,
    canal VARCHAR(10) NOT NULL,
    tipo VARCHAR(12) NOT NULL,
    estado VARCHAR(15) NOT NULL DEFAULT 'Programada',
    precio_base NUMERIC(12,2) NOT NULL,
    aplica_recargo_cancelacion BOOLEAN NOT NULL DEFAULT FALSE,
    motivo_cancelacion TEXT,
    fecha_registro TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_cita PRIMARY KEY (cita_id),
    CONSTRAINT uq_cita_medico_hora UNIQUE (medico_id, fecha_hora),
    CONSTRAINT uq_cita_clinica_hora UNIQUE (clinica_id, fecha_hora),
   
    CONSTRAINT ck_cita_canal CHECK (canal IN ('Telefono', 'Correo', 'Recepcion')),
   
    CONSTRAINT ck_cita_tipo CHECK (tipo IN ('Primera', 'Reconsulta', 'Referida')),
   
    CONSTRAINT ck_cita_estado CHECK (estado IN ('Programada', 'Realizada', 'Reprogramada', 'Cancelada')),
    
    CONSTRAINT ck_cita_precio CHECK (precio_base >= 0),
    
    CONSTRAINT ck_cita_cancelacion CHECK (
        estado <> 'Cancelada' OR NULLIF(BTRIM(motivo_cancelacion), '') IS NOT NULL
    ),
   
    CONSTRAINT ck_cita_anterior_distinta CHECK (cita_anterior_id IS NULL OR cita_anterior_id <> cita_id),
    CONSTRAINT fk_cita_paciente FOREIGN KEY (paciente_id)
        REFERENCES paciente (paciente_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_cita_medico FOREIGN KEY (medico_id)
        REFERENCES medico (medico_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_cita_unidad FOREIGN KEY (unidad_medica_id)
        REFERENCES unidad_medica (unidad_medica_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_cita_clinica FOREIGN KEY (clinica_id)
        REFERENCES espacio_hospitalario (espacio_hospitalario_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_cita_anterior FOREIGN KEY (cita_anterior_id)
        REFERENCES cita (cita_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Conserva el historial de transiciones y sus motivos para cada cita.
CREATE TABLE historial_estado_cita (
    historial_estado_cita_id BIGINT GENERATED ALWAYS AS IDENTITY,
    cita_id BIGINT NOT NULL,
    estado_anterior VARCHAR(15),
    estado_nuevo VARCHAR(15) NOT NULL,
    fecha_cambio TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    motivo TEXT,
    CONSTRAINT pk_historial_estado_cita PRIMARY KEY (historial_estado_cita_id),
    
    CONSTRAINT ck_historial_estado_anterior CHECK (estado_anterior IS NULL OR
        estado_anterior IN ('Programada', 'Realizada', 'Reprogramada', 'Cancelada')),
    
    CONSTRAINT ck_historial_estado_nuevo CHECK (estado_nuevo IN
        ('Programada', 'Realizada', 'Reprogramada', 'Cancelada')),
    CONSTRAINT fk_historial_cita FOREIGN KEY (cita_id)
        REFERENCES cita (cita_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Documenta la consulta realizada, su diagnostico y observaciones.
CREATE TABLE consulta_externa (
    consulta_externa_id BIGINT GENERATED ALWAYS AS IDENTITY,
    cita_id BIGINT NOT NULL,
    fecha_atencion TIMESTAMPTZ NOT NULL,
    diagnostico TEXT NOT NULL,
    datos_interes TEXT,
    observaciones TEXT,
    orientacion_paciente TEXT,
    CONSTRAINT pk_consulta_externa PRIMARY KEY (consulta_externa_id),
    CONSTRAINT uq_consulta_externa_cita UNIQUE (cita_id),
    
    CONSTRAINT ck_consulta_diagnostico CHECK (BTRIM(diagnostico) <> ''),
    CONSTRAINT fk_consulta_cita FOREIGN KEY (cita_id)
        REFERENCES cita (cita_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

