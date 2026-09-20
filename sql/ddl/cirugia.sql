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

-- Registra la cirugia aprobada, el quirofano y el horario asignado.
CREATE TABLE cirugia (
    cirugia_id BIGINT GENERATED ALWAYS AS IDENTITY,
    solicitud_cirugia_id BIGINT NOT NULL,
    evaluacion_solicitud_cirugia_id BIGINT NOT NULL,
    decision_requerida VARCHAR(10) NOT NULL DEFAULT 'Aprobada',
    quirofano_id BIGINT NOT NULL,
    fecha_programada TIMESTAMPTZ NOT NULL,
    fecha_inicio TIMESTAMPTZ,
    fecha_fin TIMESTAMPTZ,
    estado VARCHAR(12) NOT NULL DEFAULT 'Programada',
    procedimiento_realizado TEXT,
    CONSTRAINT pk_cirugia PRIMARY KEY (cirugia_id),
    CONSTRAINT uq_cirugia_solicitud UNIQUE (solicitud_cirugia_id),
    CONSTRAINT uq_cirugia_evaluacion UNIQUE (evaluacion_solicitud_cirugia_id),
    
    CONSTRAINT ck_cirugia_aprobada CHECK (decision_requerida = 'Aprobada'),
    
    CONSTRAINT ck_cirugia_estado CHECK (
        estado IN ('Programada', 'En curso', 'Finalizada', 'Cancelada')
    ),
    
    CONSTRAINT ck_cirugia_fechas CHECK (
        (fecha_fin IS NULL OR fecha_inicio IS NOT NULL)
        AND (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
    ),
    
    CONSTRAINT ck_cirugia_finalizada CHECK (
        estado <> 'Finalizada' OR
        (fecha_inicio IS NOT NULL AND fecha_fin IS NOT NULL
         AND NULLIF(BTRIM(procedimiento_realizado), '') IS NOT NULL)
    ),
    CONSTRAINT fk_cirugia_solicitud FOREIGN KEY (solicitud_cirugia_id)
        REFERENCES solicitud_cirugia (solicitud_cirugia_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_cirugia_evaluacion_aprobada
        FOREIGN KEY (evaluacion_solicitud_cirugia_id, solicitud_cirugia_id, decision_requerida)
        REFERENCES evaluacion_solicitud_cirugia
            (evaluacion_solicitud_cirugia_id, solicitud_cirugia_id, decision)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_cirugia_quirofano FOREIGN KEY (quirofano_id)
        REFERENCES espacio_hospitalario (espacio_hospitalario_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Resuelve la participacion de cirujanos, anestesistas y enfermeros.
CREATE TABLE participante_cirugia (
    participante_cirugia_id BIGINT GENERATED ALWAYS AS IDENTITY,
    cirugia_id BIGINT NOT NULL,
    persona_id BIGINT NOT NULL,
    rol VARCHAR(25) NOT NULL,
    observaciones TEXT,
    CONSTRAINT pk_participante_cirugia PRIMARY KEY (participante_cirugia_id),
    CONSTRAINT uq_participante_cirugia_rol UNIQUE (cirugia_id, persona_id, rol),
   
    CONSTRAINT ck_participante_rol CHECK (rol IN (
        'Cirujano', 'Anestesiologo', 'Enfermero',
        'Practicante medicina', 'Practicante enfermeria', 'Otro'
    )),
    CONSTRAINT fk_participante_cirugia FOREIGN KEY (cirugia_id)
        REFERENCES cirugia (cirugia_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_participante_persona FOREIGN KEY (persona_id)
        REFERENCES persona (persona_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Cataloga insumos, instrumentos y equipos utilizados en cirugia.
CREATE TABLE recurso (
    recurso_id BIGINT GENERATED ALWAYS AS IDENTITY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    categoria VARCHAR(11) NOT NULL,
    tipo VARCHAR(12) NOT NULL,
    material VARCHAR(100),
    funcion VARCHAR(20),
    costo_unitario NUMERIC(12,2) NOT NULL DEFAULT 0,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_recurso PRIMARY KEY (recurso_id),
    CONSTRAINT uq_recurso_nombre_categoria UNIQUE (nombre, categoria),
   
    CONSTRAINT ck_recurso_categoria CHECK (
        categoria IN ('Insumo', 'Instrumento', 'Equipo')
    ),
  
    CONSTRAINT ck_recurso_tipo CHECK (tipo IN ('Medico', 'Quirurgico', 'Otro')),
   
    CONSTRAINT ck_recurso_funcion CHECK (
        funcion IS NULL OR funcion IN (
            'Corte', 'Contenido', 'Hemostatica', 'Retractor',
            'Accesorio', 'Implante', 'Exploracion', 'Diagnostico',
            'Tratamiento', 'Rehabilitacion', 'Otro'
        )
    ),
  
    CONSTRAINT ck_recurso_costo CHECK (costo_unitario >= 0),
   
    CONSTRAINT ck_recurso_nombre CHECK (BTRIM(nombre) <> ''),
   
    CONSTRAINT ck_recurso_material_insumo CHECK (
        categoria <> 'Insumo' OR NULLIF(BTRIM(material), '') IS NOT NULL
    ),
   
    CONSTRAINT ck_recurso_funcion_equipo CHECK (
        categoria = 'Insumo' OR funcion IS NOT NULL
    )
);

-- Relaciona la solicitud con los recursos requeridos en el agendamiento.
CREATE TABLE solicitud_recurso (
    solicitud_cirugia_id BIGINT NOT NULL,
    recurso_id BIGINT NOT NULL,
    cantidad NUMERIC(10,2) NOT NULL,
    observaciones TEXT,
    CONSTRAINT pk_solicitud_recurso PRIMARY KEY (solicitud_cirugia_id, recurso_id),
  
    CONSTRAINT ck_solicitud_recurso_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_solicitud_recurso_solicitud FOREIGN KEY (solicitud_cirugia_id)
        REFERENCES solicitud_cirugia (solicitud_cirugia_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_solicitud_recurso_recurso FOREIGN KEY (recurso_id)
        REFERENCES recurso (recurso_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Conserva cantidades y costos historicos de recursos usados realmente.
CREATE TABLE uso_recurso_cirugia (
    uso_recurso_cirugia_id BIGINT GENERATED ALWAYS AS IDENTITY,
    cirugia_id BIGINT NOT NULL,
    recurso_id BIGINT NOT NULL,
    cantidad NUMERIC(10,2) NOT NULL,
    costo_unitario_aplicado NUMERIC(12,2) NOT NULL,
    fecha_uso TIMESTAMPTZ NOT NULL,
    observaciones TEXT,
    CONSTRAINT pk_uso_recurso_cirugia PRIMARY KEY (uso_recurso_cirugia_id),
    
    CONSTRAINT ck_uso_recurso_cantidad CHECK (cantidad > 0),
   
    CONSTRAINT ck_uso_recurso_costo CHECK (costo_unitario_aplicado >= 0),
    CONSTRAINT fk_uso_recurso_cirugia FOREIGN KEY (cirugia_id)
        REFERENCES cirugia (cirugia_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_uso_recurso_catalogo FOREIGN KEY (recurso_id)
        REFERENCES recurso (recurso_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Documenta el consentimiento informado especifico del procedimiento.
CREATE TABLE consentimiento_quirurgico (
    consentimiento_quirurgico_id BIGINT GENERATED ALWAYS AS IDENTITY,
    cirugia_id BIGINT NOT NULL,
    medico_firmante_id BIGINT NOT NULL,
    firmante_persona_id BIGINT NOT NULL,
    calidad_firmante VARCHAR(20) NOT NULL,
    procedimiento TEXT NOT NULL,
    objetivo TEXT NOT NULL,
    caracteristicas TEXT NOT NULL,
    riesgos TEXT NOT NULL,
    fecha_obtencion TIMESTAMPTZ NOT NULL,
    firma_medico_confirmada BOOLEAN NOT NULL,
    firma_paciente_o_representante_confirmada BOOLEAN NOT NULL,
    CONSTRAINT pk_consentimiento_quirurgico PRIMARY KEY (consentimiento_quirurgico_id),
    CONSTRAINT uq_consentimiento_quirurgico_cirugia UNIQUE (cirugia_id),
    
    CONSTRAINT ck_consentimiento_quirurgico_firmante CHECK (
        calidad_firmante IN ('Paciente', 'Familiar', 'Tutor', 'Representante')
    ),
    
    CONSTRAINT ck_consentimiento_quirurgico_procedimiento CHECK (BTRIM(procedimiento) <> ''),
   
    CONSTRAINT ck_consentimiento_quirurgico_objetivo CHECK (BTRIM(objetivo) <> ''),
    
    CONSTRAINT ck_consentimiento_quirurgico_caracteristicas CHECK (BTRIM(caracteristicas) <> ''),
    
    CONSTRAINT ck_consentimiento_quirurgico_riesgos CHECK (BTRIM(riesgos) <> ''),
    CONSTRAINT fk_consentimiento_quirurgico_cirugia FOREIGN KEY (cirugia_id)
        REFERENCES cirugia (cirugia_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_consentimiento_quirurgico_medico FOREIGN KEY (medico_firmante_id)
        REFERENCES medico (medico_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_consentimiento_quirurgico_persona FOREIGN KEY (firmante_persona_id)
        REFERENCES persona (persona_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Registra la clasificacion ASA y el plan de anestesia preoperatorio.
CREATE TABLE chequeo_preanestesico (
    chequeo_preanestesico_id BIGINT GENERATED ALWAYS AS IDENTITY,
    cirugia_id BIGINT NOT NULL,
    medico_evaluador_id BIGINT NOT NULL,
    anestesista_id BIGINT NOT NULL,
    clasificacion_asa VARCHAR(3) NOT NULL,
    plan_anestesia TEXT NOT NULL,
    fecha_evaluacion TIMESTAMPTZ NOT NULL,
    firma_evaluador_confirmada BOOLEAN NOT NULL,
    observaciones TEXT,
    CONSTRAINT pk_chequeo_preanestesico PRIMARY KEY (chequeo_preanestesico_id),
    CONSTRAINT uq_chequeo_preanestesico_cirugia UNIQUE (cirugia_id),
    
    CONSTRAINT ck_chequeo_asa CHECK (
        clasificacion_asa IN ('I', 'II', 'III', 'IV', 'V', 'VI')
    ),
    
    CONSTRAINT ck_chequeo_plan CHECK (BTRIM(plan_anestesia) <> ''),
    CONSTRAINT fk_chequeo_cirugia FOREIGN KEY (cirugia_id)
        REFERENCES cirugia (cirugia_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_chequeo_evaluador FOREIGN KEY (medico_evaluador_id)
        REFERENCES medico (medico_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_chequeo_anestesista FOREIGN KEY (anestesista_id)
        REFERENCES medico (medico_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Registra preoperatorio, intraoperatorio y postoperatorio de cada cirugia.
CREATE TABLE etapa_cirugia (
    etapa_cirugia_id BIGINT GENERATED ALWAYS AS IDENTITY,
    cirugia_id BIGINT NOT NULL,
    enfermero_responsable_id BIGINT NOT NULL,
    etapa VARCHAR(16) NOT NULL,
    fecha_inicio TIMESTAMPTZ NOT NULL,
    fecha_fin TIMESTAMPTZ,
    fecha_envio_secretaria TIMESTAMPTZ,
    observaciones TEXT,
    CONSTRAINT pk_etapa_cirugia PRIMARY KEY (etapa_cirugia_id),
    CONSTRAINT uq_etapa_cirugia_tipo UNIQUE (cirugia_id, etapa),
    CONSTRAINT uq_etapa_cirugia_tipo_ref UNIQUE (etapa_cirugia_id, etapa),
   
    CONSTRAINT ck_etapa_tipo CHECK (
        etapa IN ('Preoperatorio', 'Intraoperatorio', 'Postoperatorio')
    ),
   
    CONSTRAINT ck_etapa_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
   
    CONSTRAINT ck_etapa_envio CHECK (
        fecha_envio_secretaria IS NULL OR
        (fecha_fin IS NOT NULL AND fecha_envio_secretaria >= fecha_fin)
    ),
    CONSTRAINT fk_etapa_cirugia FOREIGN KEY (cirugia_id)
        REFERENCES cirugia (cirugia_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_etapa_enfermero FOREIGN KEY (enfermero_responsable_id)
        REFERENCES enfermero (enfermero_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

