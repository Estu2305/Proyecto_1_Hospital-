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

-- Permite distribuir el costo de un ingreso en una a doce cuotas.
CREATE TABLE plan_pago (
    plan_pago_id BIGINT GENERATED ALWAYS AS IDENTITY,
    factura_id BIGINT NOT NULL,
    numero_cuotas SMALLINT NOT NULL,
    fecha_inicio DATE NOT NULL,
    estado VARCHAR(12) NOT NULL DEFAULT 'Activo',
    CONSTRAINT pk_plan_pago PRIMARY KEY (plan_pago_id),
    CONSTRAINT uq_plan_pago_factura UNIQUE (factura_id),
    CONSTRAINT uq_plan_pago_factura_ref UNIQUE (plan_pago_id, factura_id),
 
    CONSTRAINT ck_plan_pago_cuotas CHECK (numero_cuotas BETWEEN 1 AND 12),
  
    CONSTRAINT ck_plan_pago_estado CHECK (estado IN ('Activo', 'Liquidado', 'Cancelado')),
    CONSTRAINT fk_plan_pago_factura FOREIGN KEY (factura_id)
        REFERENCES factura (factura_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Registra los vencimientos y montos de un plan de pago.
CREATE TABLE cuota (
    cuota_id BIGINT GENERATED ALWAYS AS IDENTITY,
    plan_pago_id BIGINT NOT NULL,
    numero SMALLINT NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    monto NUMERIC(12,2) NOT NULL,
    estado VARCHAR(12) NOT NULL DEFAULT 'Pendiente',
    CONSTRAINT pk_cuota PRIMARY KEY (cuota_id),
    CONSTRAINT uq_cuota_numero UNIQUE (plan_pago_id, numero),
    CONSTRAINT uq_cuota_plan_ref UNIQUE (cuota_id, plan_pago_id),
   
    CONSTRAINT ck_cuota_numero CHECK (numero BETWEEN 1 AND 12),
   
    CONSTRAINT ck_cuota_monto CHECK (monto > 0),
   
    CONSTRAINT ck_cuota_estado CHECK (estado IN ('Pendiente', 'Parcial', 'Pagada')),
    CONSTRAINT fk_cuota_plan FOREIGN KEY (plan_pago_id)
        REFERENCES plan_pago (plan_pago_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Documenta los pagos recibidos y la recepcion donde se cobraron.
CREATE TABLE pago (
    pago_id BIGINT GENERATED ALWAYS AS IDENTITY,
    factura_id BIGINT NOT NULL,
    plan_pago_id BIGINT,
    cuota_id BIGINT,
    unidad_recepcion_id BIGINT NOT NULL,
    fecha_pago TIMESTAMPTZ NOT NULL,
    monto NUMERIC(12,2) NOT NULL,
    metodo VARCHAR(15) NOT NULL,
    referencia VARCHAR(80),
    CONSTRAINT pk_pago PRIMARY KEY (pago_id),
   
    CONSTRAINT ck_pago_monto CHECK (monto > 0),
   
    CONSTRAINT ck_pago_metodo CHECK (
        metodo IN ('Efectivo', 'Tarjeta', 'Transferencia', 'Deposito')
    ),
  
    CONSTRAINT ck_pago_plan_cuota CHECK (cuota_id IS NULL OR plan_pago_id IS NOT NULL),
    CONSTRAINT fk_pago_factura FOREIGN KEY (factura_id)
        REFERENCES factura (factura_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_pago_plan_factura FOREIGN KEY (plan_pago_id, factura_id)
        REFERENCES plan_pago (plan_pago_id, factura_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_pago_cuota_plan FOREIGN KEY (cuota_id, plan_pago_id)
        REFERENCES cuota (cuota_id, plan_pago_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_pago_recepcion FOREIGN KEY (unidad_recepcion_id)
        REFERENCES unidad_medica (unidad_medica_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Recoge la opinion de un paciente sobre su atencion en un hospital.
CREATE TABLE evaluacion_calidad (
    evaluacion_calidad_id BIGINT GENERATED ALWAYS AS IDENTITY,
    paciente_id BIGINT NOT NULL,
    hospital_id BIGINT NOT NULL,
    ingreso_id BIGINT,
    consulta_externa_id BIGINT,
    fecha_evaluacion TIMESTAMPTZ NOT NULL,
    observaciones TEXT,
    CONSTRAINT pk_evaluacion_calidad PRIMARY KEY (evaluacion_calidad_id),
    
    CONSTRAINT ck_evaluacion_calidad_origen CHECK (
        (ingreso_id IS NOT NULL AND consulta_externa_id IS NULL)
        OR (ingreso_id IS NULL AND consulta_externa_id IS NOT NULL)
    ),
    CONSTRAINT fk_calidad_paciente FOREIGN KEY (paciente_id)
        REFERENCES paciente (paciente_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_calidad_hospital FOREIGN KEY (hospital_id)
        REFERENCES hospital (hospital_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_calidad_ingreso FOREIGN KEY (ingreso_id)
        REFERENCES ingreso (ingreso_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_calidad_consulta FOREIGN KEY (consulta_externa_id)
        REFERENCES consulta_externa (consulta_externa_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Califica a un hospital o a una persona participante de la atencion.
CREATE TABLE evaluacion_objetivo (
    evaluacion_objetivo_id BIGINT GENERATED ALWAYS AS IDENTITY,
    evaluacion_calidad_id BIGINT NOT NULL,
    hospital_objetivo_id BIGINT,
    persona_objetivo_id BIGINT,
    nota SMALLINT NOT NULL,
    comentario TEXT,
    CONSTRAINT pk_evaluacion_objetivo PRIMARY KEY (evaluacion_objetivo_id),
   
    CONSTRAINT ck_evaluacion_objetivo_unico CHECK (
        (hospital_objetivo_id IS NOT NULL AND persona_objetivo_id IS NULL)
        OR (hospital_objetivo_id IS NULL AND persona_objetivo_id IS NOT NULL)
    ),
    
    CONSTRAINT ck_evaluacion_nota CHECK (nota BETWEEN 1 AND 5),
    CONSTRAINT fk_objetivo_evaluacion FOREIGN KEY (evaluacion_calidad_id)
        REFERENCES evaluacion_calidad (evaluacion_calidad_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_objetivo_hospital FOREIGN KEY (hospital_objetivo_id)
        REFERENCES hospital (hospital_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_objetivo_persona FOREIGN KEY (persona_objetivo_id)
        REFERENCES persona (persona_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Evita calificar dos veces al mismo hospital en una evaluacion.
CREATE UNIQUE INDEX uq_calidad_hospital_objetivo
    ON evaluacion_objetivo (evaluacion_calidad_id, hospital_objetivo_id)
    WHERE hospital_objetivo_id IS NOT NULL;

-- Evita calificar dos veces a la misma persona en una evaluacion.
CREATE UNIQUE INDEX uq_calidad_persona_objetivo
    ON evaluacion_objetivo (evaluacion_calidad_id, persona_objetivo_id)
    WHERE persona_objetivo_id IS NOT NULL;

COMMIT;