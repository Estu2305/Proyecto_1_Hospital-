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

    INSERT INTO servicio_medico (nombre, categoria)
        VALUES ('Consulta general de demostracion', 'Consulta Externa')
        RETURNING servicio_medico_id INTO v_sce;
    INSERT INTO servicio_medico (nombre, categoria)
        VALUES ('Estabilizacion de demostracion', 'Emergencias')
        RETURNING servicio_medico_id INTO v_surg;
    INSERT INTO servicio_medico (nombre, categoria)
        VALUES ('Procedimiento quirurgico de demostracion', 'Cirugia')
        RETURNING servicio_medico_id INTO v_scir;
    INSERT INTO servicio_medico (nombre, categoria)
        VALUES ('Estadia de demostracion', 'Hospitalizacion')
        RETURNING servicio_medico_id INTO v_shosp;
    INSERT INTO unidad_servicio (unidad_medica_id, servicio_medico_id, costo_base)
        VALUES (v_ce,v_sce,200), (v_urg,v_surg,500),
               (v_cir,v_scir,2500), (v_hospit,v_shosp,350);

    INSERT INTO espacio_hospitalario (hospital_id, unidad_medica_id, codigo, tipo)
        VALUES (v_hosp,v_ce,'CL-01','Clinica')
        RETURNING espacio_hospitalario_id INTO v_clinica;
    INSERT INTO espacio_hospitalario (hospital_id, unidad_medica_id, codigo, tipo)
        VALUES (v_hosp,v_urg,'CAM-01','Camilla')
        RETURNING espacio_hospitalario_id INTO v_camilla;
    INSERT INTO espacio_hospitalario (hospital_id, unidad_medica_id, codigo, tipo)
        VALUES (v_hosp,v_cir,'QX-01','Quirofano')
        RETURNING espacio_hospitalario_id INTO v_quirofano;
    INSERT INTO espacio_hospitalario
        (hospital_id, unidad_medica_id, codigo, tipo, costo_diario)
        VALUES (v_hosp,v_hospit,'CAMA-01','Cama',350)
        RETURNING espacio_hospitalario_id INTO v_cama;

    -- Cuatro pacientes ficticios, dos medicos y una enfermera.
    INSERT INTO persona (direccion_id,nombres,apellidos,dpi,fecha_nacimiento,sexo,telefono)
        VALUES (v_dir,'Alma','Ejemplo Uno','9000000000001','1998-04-10','Femenino','55550001')
        RETURNING persona_id INTO v_p1;
    INSERT INTO persona (direccion_id,nombres,apellidos,dpi,fecha_nacimiento,sexo,telefono)
        VALUES (v_dir,'Bruno','Ejemplo Dos','9000000000002','1987-06-21','Masculino','55550002')
        RETURNING persona_id INTO v_p2;
    INSERT INTO persona (direccion_id,nombres,apellidos,dpi,fecha_nacimiento,sexo,telefono)
        VALUES (v_dir,'Clara','Ejemplo Tres','9000000000003','2001-11-03','Femenino','55550003')
        RETURNING persona_id INTO v_p3;
    INSERT INTO persona (direccion_id,nombres,apellidos,dpi,fecha_nacimiento,sexo,telefono)
        VALUES (v_dir,'Dario','Ejemplo Cuatro','9000000000004','1979-02-14','Masculino','55550004')
        RETURNING persona_id INTO v_p4;
    INSERT INTO paciente (paciente_id,numero_expediente)
        VALUES (v_p1,'EXP-001'),(v_p2,'EXP-002'),(v_p3,'EXP-003'),(v_p4,'EXP-004');

    INSERT INTO persona (direccion_id,nombres,apellidos,dpi,fecha_nacimiento,sexo)
        VALUES (v_dir,'Elena','Medica Ficticia','9000000000005','1980-03-03','Femenino')
        RETURNING persona_id INTO v_m1;
    INSERT INTO persona (direccion_id,nombres,apellidos,dpi,fecha_nacimiento,sexo)
        VALUES (v_dir,'Fabian','Cirujano Ficticio','9000000000006','1975-08-19','Masculino')
        RETURNING persona_id INTO v_m2;
    INSERT INTO medico (medico_id,numero_colegiado,clase_medico)
        VALUES (v_m1,'COL-DEMO-01','Interno'),(v_m2,'COL-DEMO-02','Residente');
    INSERT INTO medico_hospital (medico_id,hospital_id,condicion,fecha_inicio)
        VALUES (v_m1,v_hosp,'Interno','2026-01-01'),
               (v_m2,v_hosp,'Residente','2026-01-01');
    INSERT INTO especialidad (nombre) VALUES ('Medicina General de Prueba')
        RETURNING especialidad_id INTO v_especialidad;
    INSERT INTO medico_especialidad (medico_id,especialidad_id,es_principal)
        VALUES (v_m1,v_especialidad,TRUE);
    INSERT INTO especialidad (nombre) VALUES ('Cirugia General de Prueba')
        RETURNING especialidad_id INTO v_especialidad;
    INSERT INTO medico_especialidad (medico_id,especialidad_id,es_principal)
        VALUES (v_m2,v_especialidad,TRUE);
    INSERT INTO persona (direccion_id,nombres,apellidos,dpi,fecha_nacimiento,sexo)
        VALUES (v_dir,'Gabriela','Enfermera Ficticia','9000000000007','1990-09-09','Femenino')
        RETURNING persona_id INTO v_enfermero_persona;
    INSERT INTO empleado (persona_id,hospital_id,codigo_empleado,tipo_empleado,fecha_contratacion)
        VALUES (v_enfermero_persona,v_hosp,'ENF-DEMO-01','Enfermero','2026-01-01')
        RETURNING empleado_id INTO v_empleado;
    INSERT INTO enfermero (enfermero_id,numero_registro,nivel)
        VALUES (v_empleado,'REG-DEMO-01','Registrado');
