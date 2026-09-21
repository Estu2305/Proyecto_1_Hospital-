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

    -- Consulta externa: cita realizada, diagnostico, receta, laboratorio y pago.
    INSERT INTO horario_consulta (medico_id,unidad_medica_id,clinica_id,dia_semana,hora_inicio,hora_fin)
        VALUES (v_m1,v_ce,v_clinica,2,'08:00','12:00');
    INSERT INTO cita
        (paciente_id,medico_id,unidad_medica_id,clinica_id,fecha_hora,canal,tipo,estado,precio_base)
        VALUES (v_p1,v_m1,v_ce,v_clinica,'2026-09-15 09:00:00-06','Telefono',
                'Primera','Realizada',200)
        RETURNING cita_id INTO v_cita;
    INSERT INTO historial_estado_cita (cita_id,estado_nuevo)
        VALUES (v_cita,'Programada');
    INSERT INTO historial_estado_cita (cita_id,estado_anterior,estado_nuevo)
        VALUES (v_cita,'Programada','Realizada');
    INSERT INTO consulta_externa (cita_id,fecha_atencion,diagnostico,orientacion_paciente)
        VALUES (v_cita,'2026-09-15 09:10:00-06',
                'Evaluacion general ficticia sin hallazgos criticos',
                'Orientacion preventiva de demostracion')
        RETURNING consulta_externa_id INTO v_consulta;
    INSERT INTO medicamento (nombre,presentacion)
        VALUES ('Medicamento Modelo','Tableta ficticia')
        RETURNING medicamento_id INTO v_medicamento;
    INSERT INTO receta (consulta_externa_id,fecha_emision,fecha_proxima_cita)
        VALUES (v_consulta,'2026-09-15','2026-10-15')
        RETURNING receta_id INTO v_receta;
    INSERT INTO receta_detalle (receta_id,medicamento_id,dosis,frecuencia,duracion_dias)
        VALUES (v_receta,v_medicamento,'Una tableta','Cada 24 horas',3);
    INSERT INTO orden_laboratorio (consulta_externa_id,fecha_emision)
        VALUES (v_consulta,'2026-09-15 09:20:00-06')
        RETURNING orden_laboratorio_id INTO v_orden;
    INSERT INTO orden_laboratorio_detalle (orden_laboratorio_id,examen)
        VALUES (v_orden,'Examen general ficticio');
    INSERT INTO factura (numero_factura,paciente_id,hospital_id,consulta_externa_id,descripcion)
        VALUES ('FAC-DEMO-001',v_p1,v_hosp,v_consulta,'Consulta externa de demostracion')
        RETURNING factura_id INTO v_f;
    INSERT INTO factura_detalle (factura_id,concepto,cantidad,precio_unitario)
        VALUES (v_f,'Primera consulta',1,200);
    INSERT INTO pago (factura_id,unidad_recepcion_id,fecha_pago,monto,metodo)
        VALUES (v_f,v_ce,'2026-09-15 09:45:00-06',200,'Efectivo');
    UPDATE factura SET estado='Pagada' WHERE factura_id=v_f;

    -- Emergencia: ingreso, triaje, procedimiento, egreso y dos cuotas.
    INSERT INTO episodio_atencion (paciente_id,hospital_id,fecha_apertura,motivo_apertura)
        VALUES (v_p2,v_hosp,'2026-09-16 07:00:00-06','Atencion urgente simulada')
        RETURNING episodio_atencion_id INTO v_ep2;
    INSERT INTO ingreso (episodio_atencion_id,hospital_id,unidad_medica_id,
        servicio_medico_id,medico_encargado_id,espacio_hospitalario_id,
        fecha_ingreso,motivo_ingreso,diagnostico_presuntivo)
        VALUES (v_ep2,v_hosp,v_urg,v_surg,v_m1,v_camilla,
                '2026-09-16 07:05:00-06','Evaluacion inmediata ficticia',
                'Necesidad de observacion clinica')
        RETURNING ingreso_id INTO v_i2;
    INSERT INTO atencion_emergencia (ingreso_id,fecha_evaluacion,prioridad,estado_clinico,resultado)
        VALUES (v_i2,'2026-09-16 07:07:00-06',2,
                'Paciente ficticio consciente','Estabilizado')
        RETURNING atencion_emergencia_id INTO v_emergencia;
    INSERT INTO procedimiento_emergencia (nombre,tipo,costo_base)
        VALUES ('Observacion y estabilizacion ficticia','Basico',500)
        RETURNING procedimiento_emergencia_id INTO v_proc;
    INSERT INTO emergencia_procedimiento
        (atencion_emergencia_id,procedimiento_emergencia_id,medico_id,
         fecha_realizacion,costo_aplicado)
        VALUES (v_emergencia,v_proc,v_m1,'2026-09-16 07:30:00-06',500);
    INSERT INTO diagnostico (codigo,nombre)
        VALUES ('DEMO-001','Diagnostico clinico ficticio')
        RETURNING diagnostico_id INTO v_diag;
    INSERT INTO egreso (ingreso_id,medico_asignado_id,fecha_egreso,motivo_egreso,codigo_egreso)
        VALUES (v_i2,v_m1,'2026-09-16 11:00:00-06','Alta tras estabilizacion','Vivo')
        RETURNING egreso_id INTO v_egreso;
    INSERT INTO egreso_diagnostico (egreso_id,diagnostico_id,tipo)
        VALUES (v_egreso,v_diag,'Principal');
    UPDATE ingreso SET estado='Cerrado' WHERE ingreso_id=v_i2;
    UPDATE episodio_atencion
        SET estado='Cerrado',fecha_cierre='2026-09-16 11:00:00-06'
        WHERE episodio_atencion_id=v_ep2;
    INSERT INTO factura (numero_factura,paciente_id,hospital_id,ingreso_id,descripcion)
        VALUES ('FAC-DEMO-002',v_p2,v_hosp,v_i2,'Servicio de emergencias de demostracion')
        RETURNING factura_id INTO v_f;
    INSERT INTO factura_detalle (factura_id,concepto,cantidad,precio_unitario)
        VALUES (v_f,'Estabilizacion',1,500);
    INSERT INTO plan_pago (factura_id,numero_cuotas,fecha_inicio)
        VALUES (v_f,2,'2026-09-16') RETURNING plan_pago_id INTO v_plan;
    INSERT INTO cuota (plan_pago_id,numero,fecha_vencimiento,monto)
        VALUES (v_plan,1,'2026-09-16',250) RETURNING cuota_id INTO v_cuota;
    INSERT INTO pago (factura_id,plan_pago_id,cuota_id,unidad_recepcion_id,
        fecha_pago,monto,metodo)
        VALUES (v_f,v_plan,v_cuota,v_hospit,'2026-09-16 11:10:00-06',250,'Efectivo');
    UPDATE cuota SET estado='Pagada' WHERE cuota_id=v_cuota;
    UPDATE factura SET estado='Parcial' WHERE factura_id=v_f;
    INSERT INTO cuota (plan_pago_id,numero,fecha_vencimiento,monto)
        VALUES (v_plan,2,'2026-10-16',250);

    -- Cirugia: solicitud aprobada, quirofano, equipo y control preoperatorio.
    INSERT INTO episodio_atencion (paciente_id,hospital_id,fecha_apertura,motivo_apertura)
        VALUES (v_p3,v_hosp,'2026-09-17 07:00:00-06','Procedimiento simulado')
        RETURNING episodio_atencion_id INTO v_ep3;
    INSERT INTO solicitud_cirugia
        (paciente_id,hospital_id,cirujano_id,episodio_atencion_id,fecha_solicitud,
         caracter,historia_clinica,procedimiento_propuesto,duracion_estimada_minutos,tipo_anestesia)
        VALUES (v_p3,v_hosp,v_m2,v_ep3,'2026-09-17 07:10:00-06','Programado',
                'Antecedentes ficticios revisados','Intervencion simulada',60,'General')
        RETURNING solicitud_cirugia_id INTO v_solicitud;
    INSERT INTO evaluacion_solicitud_cirugia
        (solicitud_cirugia_id,medico_evaluador_id,fecha_evaluacion,decision)
        VALUES (v_solicitud,v_m1,'2026-09-17 07:30:00-06','Aprobada')
        RETURNING evaluacion_solicitud_cirugia_id INTO v_evaluacion;
    INSERT INTO cirugia (solicitud_cirugia_id,evaluacion_solicitud_cirugia_id,
        quirofano_id,fecha_programada,fecha_inicio,fecha_fin,estado,procedimiento_realizado)
        VALUES (v_solicitud,v_evaluacion,v_quirofano,'2026-09-17 09:00:00-06',
                '2026-09-17 09:00:00-06','2026-09-17 10:00:00-06','Finalizada',
                'Intervencion ficticia concluida')
        RETURNING cirugia_id INTO v_cirugia;
    INSERT INTO participante_cirugia (cirugia_id,persona_id,rol)
        VALUES (v_cirugia,v_m2,'Cirujano'),(v_cirugia,v_m1,'Anestesiologo'),
               (v_cirugia,v_enfermero_persona,'Enfermero');
    INSERT INTO recurso (nombre,categoria,tipo,material,costo_unitario)
        VALUES ('Insumo esteril ficticio','Insumo','Quirurgico','Material de prueba',100)
        RETURNING recurso_id INTO v_recurso;
    INSERT INTO solicitud_recurso (solicitud_cirugia_id,recurso_id,cantidad)
        VALUES (v_solicitud,v_recurso,1);
    INSERT INTO uso_recurso_cirugia
        (cirugia_id,recurso_id,cantidad,costo_unitario_aplicado,fecha_uso)
        VALUES (v_cirugia,v_recurso,1,100,'2026-09-17 09:20:00-06');
    INSERT INTO consentimiento_quirurgico
        (cirugia_id,medico_firmante_id,firmante_persona_id,calidad_firmante,
         procedimiento,objetivo,caracteristicas,riesgos,fecha_obtencion,
         firma_medico_confirmada,firma_paciente_o_representante_confirmada)
        VALUES (v_cirugia,v_m2,v_p3,'Paciente','Intervencion simulada',
                'Prueba academica','Procedimiento sin pacientes reales',
                'Riesgos ficticios explicados','2026-09-17 08:00:00-06',TRUE,TRUE);
    INSERT INTO chequeo_preanestesico
        (cirugia_id,medico_evaluador_id,anestesista_id,
         clasificacion_asa,plan_anestesia,fecha_evaluacion,firma_evaluador_confirmada)
        VALUES (v_cirugia,v_m2,v_m1,'I','Plan simulado',
                '2026-09-17 08:10:00-06',TRUE);
    INSERT INTO etapa_cirugia
        (cirugia_id,enfermero_responsable_id,etapa,fecha_inicio,fecha_fin,
         fecha_envio_secretaria)
        VALUES (v_cirugia,v_empleado,'Preoperatorio','2026-09-17 08:00:00-06',
                '2026-09-17 09:00:00-06','2026-09-17 11:00:00-06')
        RETURNING etapa_cirugia_id INTO v_etapa;
    INSERT INTO item_control_quirurgico (etapa,grupo,descripcion,tipo_resultado)
        VALUES ('Preoperatorio','Entrada','Identidad confirmada','ExitoFalla')
        RETURNING item_control_quirurgico_id INTO v_item;
    INSERT INTO resultado_control_quirurgico
        (etapa_cirugia_id,item_control_quirurgico_id,etapa,resultado,
         fecha_registro,registrado_por_enfermero_id)
        VALUES (v_etapa,v_item,'Preoperatorio','Exito',
                '2026-09-17 08:20:00-06',v_empleado);
    INSERT INTO ingreso (episodio_atencion_id,hospital_id,unidad_medica_id,
        servicio_medico_id,medico_encargado_id,espacio_hospitalario_id,
        fecha_ingreso,motivo_ingreso,diagnostico_presuntivo)
        VALUES (v_ep3,v_hosp,v_cir,v_scir,v_m2,v_quirofano,
                '2026-09-17 08:45:00-06','Cirugia programada',
                'Diagnostico quirurgico simulado')
        RETURNING ingreso_id INTO v_i3;
    INSERT INTO egreso (ingreso_id,medico_asignado_id,fecha_egreso,motivo_egreso,codigo_egreso)
        VALUES (v_i3,v_m2,'2026-09-17 12:00:00-06','Alta posoperatoria','Vivo');
    UPDATE ingreso SET estado='Cerrado' WHERE ingreso_id=v_i3;
    INSERT INTO factura (numero_factura,paciente_id,hospital_id,ingreso_id,descripcion)
        VALUES ('FAC-DEMO-003',v_p3,v_hosp,v_i3,'Cirugia de demostracion')
        RETURNING factura_id INTO v_f;
    INSERT INTO factura_detalle (factura_id,concepto,cantidad,precio_unitario)
        VALUES (v_f,'Procedimiento quirurgico',1,2500),
               (v_f,'Insumo esteril',1,100);
    INSERT INTO pago (factura_id,unidad_recepcion_id,fecha_pago,monto,metodo)
        VALUES (v_f,v_cir,'2026-09-17 12:15:00-06',2600,'Tarjeta');
    UPDATE factura SET estado='Pagada' WHERE factura_id=v_f;