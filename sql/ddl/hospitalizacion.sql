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