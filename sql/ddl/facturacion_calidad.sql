BEGIN;
SET search_path TO hospital, public;

-- Registra el comprobante de una consulta o de un ingreso hospitalario.
CREATE TABLE factura (
    factura_id BIGINT GENERATED ALWAYS AS IDENTITY,
    numero_factura VARCHAR(30) NOT NULL,
    paciente_id BIGINT NOT NULL,
    hospital_id BIGINT NOT NULL,
    ingreso_id BIGINT,
    consulta_externa_id BIGINT,
    fecha_emision TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    descripcion VARCHAR(300) NOT NULL,
    estado VARCHAR(12) NOT NULL DEFAULT 'Pendiente',
    CONSTRAINT pk_factura PRIMARY KEY (factura_id),
    CONSTRAINT uq_factura_numero UNIQUE (numero_factura),
    CONSTRAINT uq_factura_ingreso UNIQUE (ingreso_id),
    CONSTRAINT uq_factura_consulta UNIQUE (consulta_externa_id),
    
    CONSTRAINT ck_factura_origen CHECK (
        (ingreso_id IS NOT NULL AND consulta_externa_id IS NULL)
        OR (ingreso_id IS NULL AND consulta_externa_id IS NOT NULL)
    ),
    
    CONSTRAINT ck_factura_estado CHECK (estado IN ('Pendiente', 'Parcial', 'Pagada', 'Anulada')),
    
    CONSTRAINT ck_factura_descripcion CHECK (BTRIM(descripcion) <> ''),
    CONSTRAINT fk_factura_paciente FOREIGN KEY (paciente_id)
        REFERENCES paciente (paciente_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_factura_hospital FOREIGN KEY (hospital_id)
        REFERENCES hospital (hospital_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_factura_ingreso FOREIGN KEY (ingreso_id)
        REFERENCES ingreso (ingreso_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_factura_consulta FOREIGN KEY (consulta_externa_id)
        REFERENCES consulta_externa (consulta_externa_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Desglosa los servicios e insumos con precio historico aplicado.
CREATE TABLE factura_detalle (
    factura_detalle_id BIGINT GENERATED ALWAYS AS IDENTITY,
    factura_id BIGINT NOT NULL,
    concepto VARCHAR(250) NOT NULL,
    cantidad NUMERIC(10,2) NOT NULL,
    precio_unitario NUMERIC(12,2) NOT NULL,
    porcentaje_descuento NUMERIC(5,2) NOT NULL DEFAULT 0,
    porcentaje_recargo NUMERIC(5,2) NOT NULL DEFAULT 0,
    subtotal NUMERIC(14,2) GENERATED ALWAYS AS (
        ROUND(cantidad * precio_unitario *
            (1 - porcentaje_descuento / 100 + porcentaje_recargo / 100), 2)
    ) STORED,
    CONSTRAINT pk_factura_detalle PRIMARY KEY (factura_detalle_id),
    
    CONSTRAINT ck_factura_detalle_concepto CHECK (BTRIM(concepto) <> ''),
    
    CONSTRAINT ck_factura_detalle_cantidad CHECK (cantidad > 0),
    
    CONSTRAINT ck_factura_detalle_precio CHECK (precio_unitario >= 0),
    
    CONSTRAINT ck_factura_detalle_descuento CHECK (porcentaje_descuento BETWEEN 0 AND 100),
  
    CONSTRAINT ck_factura_detalle_recargo CHECK (porcentaje_recargo BETWEEN 0 AND 100),
    CONSTRAINT fk_factura_detalle_factura FOREIGN KEY (factura_id)
        REFERENCES factura (factura_id) ON DELETE RESTRICT ON UPDATE CASCADE
);