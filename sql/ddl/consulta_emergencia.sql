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

-- Registra recetas emitidas durante una consulta.
CREATE TABLE receta (
    receta_id BIGINT GENERATED ALWAYS AS IDENTITY,
    consulta_externa_id BIGINT NOT NULL,
    fecha_emision DATE NOT NULL,
    fecha_proxima_cita DATE,
    indicaciones TEXT,
    CONSTRAINT pk_receta PRIMARY KEY (receta_id),
   
    CONSTRAINT ck_receta_proxima_cita CHECK (
        fecha_proxima_cita IS NULL OR fecha_proxima_cita >= fecha_emision
    ),
    CONSTRAINT fk_receta_consulta FOREIGN KEY (consulta_externa_id)
        REFERENCES consulta_externa (consulta_externa_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Cataloga medicamentos con su presentacion farmacologica.
CREATE TABLE medicamento (
    medicamento_id BIGINT GENERATED ALWAYS AS IDENTITY,
    nombre VARCHAR(120) NOT NULL,
    presentacion VARCHAR(100) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_medicamento PRIMARY KEY (medicamento_id),
    CONSTRAINT uq_medicamento_nombre_presentacion UNIQUE (nombre, presentacion),
    
    CONSTRAINT ck_medicamento_nombre CHECK (BTRIM(nombre) <> ''),
    
    CONSTRAINT ck_medicamento_presentacion CHECK (BTRIM(presentacion) <> '')
);

-- Detalla el medicamento, dosis y duracion indicada en una receta.
CREATE TABLE receta_detalle (
    receta_detalle_id BIGINT GENERATED ALWAYS AS IDENTITY,
    receta_id BIGINT NOT NULL,
    medicamento_id BIGINT NOT NULL,
    dosis VARCHAR(100) NOT NULL,
    frecuencia VARCHAR(100) NOT NULL,
    duracion_dias SMALLINT NOT NULL,
    instrucciones TEXT,
    CONSTRAINT pk_receta_detalle PRIMARY KEY (receta_detalle_id),
    
    CONSTRAINT ck_receta_detalle_duracion CHECK (duracion_dias > 0),
    
    CONSTRAINT ck_receta_detalle_dosis CHECK (BTRIM(dosis) <> ''),
    
    CONSTRAINT ck_receta_detalle_frecuencia CHECK (BTRIM(frecuencia) <> ''),
    CONSTRAINT fk_receta_detalle_receta FOREIGN KEY (receta_id)
        REFERENCES receta (receta_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_receta_detalle_medicamento FOREIGN KEY (medicamento_id)
        REFERENCES medicamento (medicamento_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Registra ordenes de laboratorio solicitadas durante la consulta.
CREATE TABLE orden_laboratorio (
    orden_laboratorio_id BIGINT GENERATED ALWAYS AS IDENTITY,
    consulta_externa_id BIGINT NOT NULL,
    fecha_emision TIMESTAMPTZ NOT NULL,
    indicaciones TEXT,
    estado VARCHAR(12) NOT NULL DEFAULT 'Pendiente',
    CONSTRAINT pk_orden_laboratorio PRIMARY KEY (orden_laboratorio_id),
   
    CONSTRAINT ck_orden_laboratorio_estado CHECK (
        estado IN ('Pendiente', 'Realizada', 'Cancelada')
    ),
    CONSTRAINT fk_orden_consulta FOREIGN KEY (consulta_externa_id)
        REFERENCES consulta_externa (consulta_externa_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Detalla los examenes incluidos en una orden de laboratorio.
CREATE TABLE orden_laboratorio_detalle (
    orden_laboratorio_detalle_id BIGINT GENERATED ALWAYS AS IDENTITY,
    orden_laboratorio_id BIGINT NOT NULL,
    examen VARCHAR(150) NOT NULL,
    observaciones TEXT,
    CONSTRAINT pk_orden_laboratorio_detalle PRIMARY KEY (orden_laboratorio_detalle_id),
   
    CONSTRAINT ck_orden_detalle_examen CHECK (BTRIM(examen) <> ''),
    CONSTRAINT fk_orden_detalle_orden FOREIGN KEY (orden_laboratorio_id)
        REFERENCES orden_laboratorio (orden_laboratorio_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Registra la evaluacion, prioridad y resultado de un ingreso por emergencia.
CREATE TABLE atencion_emergencia (
    atencion_emergencia_id BIGINT GENERATED ALWAYS AS IDENTITY,
    ingreso_id BIGINT NOT NULL,
    fecha_evaluacion TIMESTAMPTZ NOT NULL,
    prioridad SMALLINT NOT NULL,
    estado_clinico TEXT NOT NULL,
    resultado TEXT,
    CONSTRAINT pk_atencion_emergencia PRIMARY KEY (atencion_emergencia_id),
    CONSTRAINT uq_atencion_emergencia_ingreso UNIQUE (ingreso_id),
    
    CONSTRAINT ck_emergencia_prioridad CHECK (prioridad BETWEEN 1 AND 5),
    
    CONSTRAINT ck_emergencia_estado_clinico CHECK (BTRIM(estado_clinico) <> ''),
    CONSTRAINT fk_emergencia_ingreso FOREIGN KEY (ingreso_id)
        REFERENCES ingreso (ingreso_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Cataloga los procedimientos basicos y especializados de emergencias.
CREATE TABLE procedimiento_emergencia (
    procedimiento_emergencia_id BIGINT GENERATED ALWAYS AS IDENTITY,
    nombre VARCHAR(180) NOT NULL,
    tipo VARCHAR(15) NOT NULL,
    descripcion TEXT,
    costo_base NUMERIC(12,2) NOT NULL DEFAULT 0,
    CONSTRAINT pk_procedimiento_emergencia PRIMARY KEY (procedimiento_emergencia_id),
    CONSTRAINT uq_procedimiento_emergencia_nombre UNIQUE (nombre),
    -- Diferencia la atencion basica de la especializada.
    CONSTRAINT ck_procedimiento_emergencia_tipo CHECK (tipo IN ('Basico', 'Especializado')),
    -- El costo base no puede ser negativo.
    CONSTRAINT ck_procedimiento_emergencia_costo CHECK (costo_base >= 0),
    -- Exige un nombre para el procedimiento.
    CONSTRAINT ck_procedimiento_emergencia_nombre CHECK (BTRIM(nombre) <> '')
);

-- Documenta los procedimientos realizados a un paciente en emergencia.
CREATE TABLE emergencia_procedimiento (
    emergencia_procedimiento_id BIGINT GENERATED ALWAYS AS IDENTITY,
    atencion_emergencia_id BIGINT NOT NULL,
    procedimiento_emergencia_id BIGINT NOT NULL,
    medico_id BIGINT NOT NULL,
    fecha_realizacion TIMESTAMPTZ NOT NULL,
    resultado TEXT,
    costo_aplicado NUMERIC(12,2) NOT NULL,
    CONSTRAINT pk_emergencia_procedimiento PRIMARY KEY (emergencia_procedimiento_id),
    -- El costo historico aplicado no puede ser negativo.
    CONSTRAINT ck_emergencia_procedimiento_costo CHECK (costo_aplicado >= 0),
    CONSTRAINT fk_emergencia_procedimiento_atencion FOREIGN KEY (atencion_emergencia_id)
        REFERENCES atencion_emergencia (atencion_emergencia_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_emergencia_procedimiento_catalogo FOREIGN KEY (procedimiento_emergencia_id)
        REFERENCES procedimiento_emergencia (procedimiento_emergencia_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_emergencia_procedimiento_medico FOREIGN KEY (medico_id)
        REFERENCES medico (medico_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Registra la espera por camilla segun prioridad y orden de llegada.
CREATE TABLE cola_emergencia (
    cola_emergencia_id BIGINT GENERATED ALWAYS AS IDENTITY,
    atencion_emergencia_id BIGINT NOT NULL,
    fecha_inicio TIMESTAMPTZ NOT NULL,
    fecha_fin TIMESTAMPTZ,
    prioridad SMALLINT NOT NULL,
    estado VARCHAR(12) NOT NULL DEFAULT 'Esperando',
    CONSTRAINT pk_cola_emergencia PRIMARY KEY (cola_emergencia_id),
    -- La prioridad de espera va de uno a cinco.
    CONSTRAINT ck_cola_prioridad CHECK (prioridad BETWEEN 1 AND 5),
    -- Limita los estados de la cola de espera.
    CONSTRAINT ck_cola_estado CHECK (estado IN ('Esperando', 'Asignado', 'Cancelado')),
    -- El fin de espera debe ser posterior al inicio.
    CONSTRAINT ck_cola_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
    -- Solo la espera activa carece de fecha final.
    CONSTRAINT ck_cola_cierre CHECK (
        (estado = 'Esperando' AND fecha_fin IS NULL)
        OR (estado <> 'Esperando' AND fecha_fin IS NOT NULL)
    ),
    CONSTRAINT fk_cola_atencion FOREIGN KEY (atencion_emergencia_id)
        REFERENCES atencion_emergencia (atencion_emergencia_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Un paciente no puede estar dos veces en la cola activa de una atencion.
CREATE UNIQUE INDEX uq_cola_emergencia_activa
    ON cola_emergencia (atencion_emergencia_id)
    WHERE estado = 'Esperando';

COMMIT;