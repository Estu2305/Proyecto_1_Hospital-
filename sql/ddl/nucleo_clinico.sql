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
    
    -- Limita estado a los valores permitidos.
    CONSTRAINT ck_episodio_estado CHECK (estado IN ('Abierto', 'Cerrado')),
    
    -- Exige que motivo apertura contenga texto.
    CONSTRAINT ck_episodio_fechas CHECK (fecha_cierre IS NULL OR fecha_cierre >= fecha_apertura),
    
    -- Exige que motivo apertura contenga texto.
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
    
    -- Exige que motivo ingreso contenga texto.
    CONSTRAINT ck_ingreso_estado CHECK (estado IN ('Abierto', 'Cerrado')),
    
    -- Exige que motivo ingreso contenga texto.
    CONSTRAINT ck_ingreso_motivo CHECK (BTRIM(motivo_ingreso) <> ''),
    
    -- Exige que diagnostico presuntivo contenga texto.
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
    
    -- Exige que nombre contenga texto.
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
    
    -- Exige que motivo egreso contenga texto.
    CONSTRAINT ck_egreso_codigo CHECK (codigo_egreso IN ('Vivo', 'Muerto', 'Embarazo', 'Parto')),
    
    -- Exige que motivo egreso contenga texto.
    CONSTRAINT ck_egreso_sin_consentimiento CHECK (
        (sin_consentimiento_medico AND NULLIF(BTRIM(motivo_sin_consentimiento), '') IS NOT NULL)
        OR (NOT sin_consentimiento_medico AND motivo_sin_consentimiento IS NULL)
    ),
    
    -- Exige que motivo egreso contenga texto.
    CONSTRAINT ck_egreso_motivo CHECK (BTRIM(motivo_egreso) <> ''),
    CONSTRAINT fk_egreso_ingreso FOREIGN KEY (ingreso_id)
        REFERENCES ingreso (ingreso_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_egreso_medico FOREIGN KEY (medico_asignado_id)
        REFERENCES medico (medico_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_egreso_institucion FOREIGN KEY (institucion_referida_id)
        REFERENCES institucion_externa (institucion_externa_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Asocia diagnosticos principales y secundarios a un egreso.
CREATE TABLE egreso_diagnostico (
    egreso_id BIGINT NOT NULL,
    diagnostico_id BIGINT NOT NULL,
    tipo VARCHAR(10) NOT NULL,
    observaciones TEXT,
    CONSTRAINT pk_egreso_diagnostico PRIMARY KEY (egreso_id, diagnostico_id),
    -- Distingue el diagnostico principal de los secundarios.
    CONSTRAINT ck_egreso_diagnostico_tipo CHECK (tipo IN ('Principal', 'Secundario')),
    CONSTRAINT fk_egreso_diagnostico_egreso FOREIGN KEY (egreso_id)
        REFERENCES egreso (egreso_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_egreso_diagnostico_diagnostico FOREIGN KEY (diagnostico_id)
        REFERENCES diagnostico (diagnostico_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Registra un traslado entre unidades de la cadena o hacia otra institucion.
CREATE TABLE traslado (
    traslado_id BIGINT GENERATED ALWAYS AS IDENTITY,
    episodio_atencion_id BIGINT NOT NULL,
    ingreso_origen_id BIGINT,
    medico_indicador_id BIGINT NOT NULL,
    unidad_origen_id BIGINT NOT NULL,
    unidad_destino_id BIGINT,
    institucion_destino_id BIGINT,
    servicio_destino_id SMALLINT,
    fecha_traslado TIMESTAMPTZ NOT NULL,
    tipo VARCHAR(10) NOT NULL,
    motivo TEXT NOT NULL,
    codigo_traslado VARCHAR(40) NOT NULL,
    CONSTRAINT pk_traslado PRIMARY KEY (traslado_id),
    CONSTRAINT uq_traslado_codigo UNIQUE (codigo_traslado),
    -- Diferencia un traslado interno de uno externo.
    CONSTRAINT ck_traslado_tipo CHECK (tipo IN ('Interno', 'Externo')),
    -- Interno requiere unidad destino; externo requiere institucion externa.
    CONSTRAINT ck_traslado_destino CHECK (
        (tipo = 'Interno' AND unidad_destino_id IS NOT NULL AND institucion_destino_id IS NULL)
        OR (tipo = 'Externo' AND unidad_destino_id IS NULL AND institucion_destino_id IS NOT NULL)
    ),
    -- Impide indicar la misma unidad como origen y destino internos.
    CONSTRAINT ck_traslado_unidades_distintas CHECK (
        unidad_destino_id IS NULL OR unidad_origen_id <> unidad_destino_id
    ),
    -- El motivo del traslado debe estar documentado.
    CONSTRAINT ck_traslado_motivo CHECK (BTRIM(motivo) <> ''),
    CONSTRAINT fk_traslado_episodio FOREIGN KEY (episodio_atencion_id)
        REFERENCES episodio_atencion (episodio_atencion_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_traslado_ingreso_episodio
        FOREIGN KEY (ingreso_origen_id, episodio_atencion_id)
        REFERENCES ingreso (ingreso_id, episodio_atencion_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_traslado_medico FOREIGN KEY (medico_indicador_id)
        REFERENCES medico (medico_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_traslado_origen FOREIGN KEY (unidad_origen_id)
        REFERENCES unidad_medica (unidad_medica_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_traslado_destino FOREIGN KEY (unidad_destino_id)
        REFERENCES unidad_medica (unidad_medica_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_traslado_institucion FOREIGN KEY (institucion_destino_id)
        REFERENCES institucion_externa (institucion_externa_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_traslado_servicio FOREIGN KEY (servicio_destino_id)
        REFERENCES servicio_medico (servicio_medico_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Conserva el consentimiento para traslado, cirugia u hospitalizacion.
CREATE TABLE consentimiento_general (
    consentimiento_general_id BIGINT GENERATED ALWAYS AS IDENTITY,
    episodio_atencion_id BIGINT NOT NULL,
    firmante_persona_id BIGINT NOT NULL,
    medico_solicitante_id BIGINT NOT NULL,
    tipo VARCHAR(17) NOT NULL,
    fecha TIMESTAMPTZ NOT NULL,
    aceptado BOOLEAN NOT NULL,
    descripcion_procedimiento TEXT NOT NULL,
    observaciones TEXT,
    CONSTRAINT pk_consentimiento_general PRIMARY KEY (consentimiento_general_id),
    -- Limita el consentimiento a los procedimientos generales indicados.
    CONSTRAINT ck_consentimiento_general_tipo
        CHECK (tipo IN ('Traslado', 'Cirugia', 'Hospitalizacion')),
    -- Exige una descripcion clara del procedimiento aceptado o rechazado.
    CONSTRAINT ck_consentimiento_general_descripcion
        CHECK (BTRIM(descripcion_procedimiento) <> ''),
    CONSTRAINT fk_consentimiento_episodio FOREIGN KEY (episodio_atencion_id)
        REFERENCES episodio_atencion (episodio_atencion_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_consentimiento_firmante FOREIGN KEY (firmante_persona_id)
        REFERENCES persona (persona_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_consentimiento_medico FOREIGN KEY (medico_solicitante_id)
        REFERENCES medico (medico_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Como maximo puede existir un diagnostico principal por egreso.
CREATE UNIQUE INDEX uq_egreso_un_diagnostico_principal
    ON egreso_diagnostico (egreso_id)
    WHERE tipo = 'Principal';

COMMIT;
