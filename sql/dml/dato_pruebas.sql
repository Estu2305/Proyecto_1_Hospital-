BEGIN;
SET search_path TO hospital, public;

DO $$
DECLARE
    v_dep SMALLINT; v_mun INTEGER; v_dir BIGINT; v_hosp BIGINT;
    v_ce BIGINT; v_urg BIGINT; v_cir BIGINT; v_hospit BIGINT;
    v_sce SMALLINT; v_surg SMALLINT; v_scir SMALLINT; v_shosp SMALLINT;
    v_clinica BIGINT; v_camilla BIGINT; v_quirofano BIGINT; v_cama BIGINT;
    v_p1 BIGINT; v_p2 BIGINT; v_p3 BIGINT; v_p4 BIGINT;
    v_m1 BIGINT; v_m2 BIGINT; v_enfermero_persona BIGINT; v_empleado BIGINT;
    v_cita BIGINT; v_consulta BIGINT; v_receta BIGINT; v_orden BIGINT;
    v_ep2 BIGINT; v_ep3 BIGINT; v_ep4 BIGINT;
    v_i2 BIGINT; v_i3 BIGINT; v_i4 BIGINT; v_emergencia BIGINT;
    v_solicitud BIGINT; v_evaluacion BIGINT; v_cirugia BIGINT;
    v_estadia BIGINT; v_recurso BIGINT; v_diag BIGINT; v_egreso BIGINT;
    v_f BIGINT; v_plan BIGINT; v_cuota BIGINT; v_calidad BIGINT;
    v_especialidad SMALLINT; v_medicamento BIGINT;
    v_proc BIGINT; v_item BIGINT; v_etapa BIGINT;
BEGIN
    -- Ubicacion y establecimiento ficticio.
    INSERT INTO departamento (nombre) VALUES ('Departamento de Ensayo')
        RETURNING departamento_id INTO v_dep;
    INSERT INTO municipio (departamento_id, nombre)
        VALUES (v_dep, 'Municipio Modelo') RETURNING municipio_id INTO v_mun;
    INSERT INTO direccion (municipio_id, detalle, area)
        VALUES (v_mun, 'Avenida Ficticia 10, sector de pruebas', 'Urbana')
        RETURNING direccion_id INTO v_dir;
    INSERT INTO hospital (direccion_id, codigo, nombre, telefono)
        VALUES (v_dir, 'HOSP-DEMO-01', 'Hospital Modelo de Occidente', '55550000')
        RETURNING hospital_id INTO v_hosp;

    INSERT INTO unidad_medica (hospital_id, nombre, tipo)
        VALUES (v_hosp, 'Consulta Externa Modelo', 'Consulta Externa')
        RETURNING unidad_medica_id INTO v_ce;
    INSERT INTO unidad_medica (hospital_id, nombre, tipo)
        VALUES (v_hosp, 'Emergencias Modelo', 'Emergencias')
        RETURNING unidad_medica_id INTO v_urg;
    INSERT INTO unidad_medica (hospital_id, nombre, tipo)
        VALUES (v_hosp, 'Cirugia Modelo', 'Cirugia')
        RETURNING unidad_medica_id INTO v_cir;
    INSERT INTO unidad_medica (hospital_id, nombre, tipo)
        VALUES (v_hosp, 'Hospitalizacion Modelo', 'Hospitalizacion')
        RETURNING unidad_medica_id INTO v_hospit;