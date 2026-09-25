BEGIN;
SET search_path TO hospital, public;

-- Registra una estadia hospitalaria vinculada a la ficha de ingreso.
CREATE TABLE hospitalizacion (
    hospitalizacion_id BIGINT GENERATED ALWAYS AS IDENTITY,
    ingreso_id BIGINT NOT NULL,
    medico_encargado_id BIGINT NOT NULL,
    fecha_alta_prevista TIMESTAMPTZ,
    fecha_alta_real TIMESTAMPTZ,
    costo_diario_aplicado NUMERIC(12,2) NOT NULL,
    observaciones TEXT,
    CONSTRAINT pk_hospitalizacion PRIMARY KEY (hospitalizacion_id),
    CONSTRAINT uq_hospitalizacion_ingreso UNIQUE (ingreso_id),
   
    -- Impide valores negativos en costo diario aplicado.
    CONSTRAINT ck_hospitalizacion_costo CHECK (costo_diario_aplicado >= 0),
    CONSTRAINT fk_hospitalizacion_ingreso FOREIGN KEY (ingreso_id)
        REFERENCES ingreso (ingreso_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_hospitalizacion_medico FOREIGN KEY (medico_encargado_id)
        REFERENCES medico (medico_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Conserva las camas utilizadas y sus intervalos en una hospitalizacion.
CREATE TABLE asignacion_cama (
    asignacion_cama_id BIGINT GENERATED ALWAYS AS IDENTITY,
    hospitalizacion_id BIGINT NOT NULL,
    cama_id BIGINT NOT NULL,
    fecha_inicio TIMESTAMPTZ NOT NULL,
    fecha_fin TIMESTAMPTZ,
    observaciones TEXT,
    CONSTRAINT pk_asignacion_cama PRIMARY KEY (asignacion_cama_id),
    
    -- Valida la secuencia cronologica de asignacion cama fechas.
    CONSTRAINT ck_asignacion_cama_fechas CHECK (
        fecha_fin IS NULL OR fecha_fin > fecha_inicio
    ),
    CONSTRAINT fk_asignacion_cama_hospitalizacion FOREIGN KEY (hospitalizacion_id)
        REFERENCES hospitalizacion (hospitalizacion_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_asignacion_cama_espacio FOREIGN KEY (cama_id)
        REFERENCES espacio_hospitalario (espacio_hospitalario_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Registra atenciones y procedimientos prestados durante la estadia.
CREATE TABLE hospitalizacion_servicio (
    hospitalizacion_servicio_id BIGINT GENERATED ALWAYS AS IDENTITY,
    hospitalizacion_id BIGINT NOT NULL,
    servicio_medico_id SMALLINT NOT NULL,
    medico_id BIGINT NOT NULL,
    fecha_servicio TIMESTAMPTZ NOT NULL,
    descripcion TEXT NOT NULL,
    costo_aplicado NUMERIC(12,2) NOT NULL,
    CONSTRAINT pk_hospitalizacion_servicio PRIMARY KEY (hospitalizacion_servicio_id),
   
    -- Exige que descripcion contenga texto.
    CONSTRAINT ck_hospitalizacion_servicio_descripcion CHECK (BTRIM(descripcion) <> ''),
   
    -- Impide valores negativos en costo aplicado.
    CONSTRAINT ck_hospitalizacion_servicio_costo CHECK (costo_aplicado >= 0),
    CONSTRAINT fk_hospitalizacion_servicio_estadia FOREIGN KEY (hospitalizacion_id)
        REFERENCES hospitalizacion (hospitalizacion_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_hospitalizacion_servicio_catalogo FOREIGN KEY (servicio_medico_id)
        REFERENCES servicio_medico (servicio_medico_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_hospitalizacion_servicio_medico FOREIGN KEY (medico_id)
        REFERENCES medico (medico_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Conserva cantidades y costos de insumos usados en hospitalizacion.
CREATE TABLE hospitalizacion_insumo (
    hospitalizacion_insumo_id BIGINT GENERATED ALWAYS AS IDENTITY,
    hospitalizacion_id BIGINT NOT NULL,
    recurso_id BIGINT NOT NULL,
    fecha_uso TIMESTAMPTZ NOT NULL,
    cantidad NUMERIC(10,2) NOT NULL,
    costo_unitario_aplicado NUMERIC(12,2) NOT NULL,
    observaciones TEXT,
    CONSTRAINT pk_hospitalizacion_insumo PRIMARY KEY (hospitalizacion_insumo_id),
   
    -- Exige que cantidad sea mayor que cero.
    CONSTRAINT ck_hospitalizacion_insumo_cantidad CHECK (cantidad > 0),
    
    -- Impide valores negativos en costo unitario aplicado.
    CONSTRAINT ck_hospitalizacion_insumo_costo CHECK (costo_unitario_aplicado >= 0),
    CONSTRAINT fk_hospitalizacion_insumo_estadia FOREIGN KEY (hospitalizacion_id)
        REFERENCES hospitalizacion (hospitalizacion_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_hospitalizacion_insumo_recurso FOREIGN KEY (recurso_id)
        REFERENCES recurso (recurso_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Un mismo paciente solo puede tener una asignacion de cama activa por estadia.
CREATE UNIQUE INDEX uq_asignacion_activa_hospitalizacion
    ON asignacion_cama (hospitalizacion_id) WHERE fecha_fin IS NULL;

-- Una cama solo puede tener una asignacion activa.
CREATE UNIQUE INDEX uq_asignacion_activa_cama
    ON asignacion_cama (cama_id) WHERE fecha_fin IS NULL;

COMMIT;
