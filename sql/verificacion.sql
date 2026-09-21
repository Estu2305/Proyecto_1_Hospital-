SET search_path TO hospital, public;

-- V01: deben existir las 64 tablas del modelo.
SELECT 'V01 tablas del esquema' AS prueba,
       COUNT(*)::TEXT AS resultado,
       (COUNT(*) = 64) AS correcto
FROM information_schema.tables
WHERE table_schema = 'hospital' AND table_type = 'BASE TABLE';

-- V02: se insertaron cuatro pacientes y cuatro unidades.
SELECT 'V02 pacientes y unidades' AS prueba,
       FORMAT('pacientes=%s, unidades=%s',
           (SELECT COUNT(*) FROM paciente),
           (SELECT COUNT(*) FROM unidad_medica)) AS resultado,
       (SELECT COUNT(*) FROM paciente) = 4
       AND (SELECT COUNT(*) FROM unidad_medica) = 4 AS correcto;

-- V03: cada uno de los cuatro tipos de unidad tiene un servicio.
SELECT 'V03 servicios por unidad' AS prueba,
       STRING_AGG(tipo || '=' || servicios::TEXT, ', ' ORDER BY tipo) AS resultado,
       COUNT(*) = 4 AND BOOL_AND(servicios > 0) AS correcto
FROM (
    SELECT u.tipo, COUNT(us.servicio_medico_id) AS servicios
    FROM unidad_medica u
    LEFT JOIN unidad_servicio us ON us.unidad_medica_id = u.unidad_medica_id
    GROUP BY u.tipo
) t;

-- V04: cita de consulta efectivamente realizada.
SELECT 'V04 consulta externa' AS prueba,
       COUNT(*)::TEXT AS resultado,
       (COUNT(*) >= 1) AS correcto
FROM consulta_externa ce
JOIN cita c ON c.cita_id = ce.cita_id
JOIN unidad_medica u ON u.unidad_medica_id = c.unidad_medica_id
WHERE u.tipo = 'Consulta Externa' AND c.estado = 'Realizada';

-- V05: al menos una emergencia ingresada con procedimiento aplicado.
SELECT 'V05 emergencia con procedimiento' AS prueba,
       COUNT(DISTINCT ae.atencion_emergencia_id)::TEXT AS resultado,
       COUNT(DISTINCT ae.atencion_emergencia_id) >= 1 AS correcto
FROM atencion_emergencia ae
JOIN ingreso i ON i.ingreso_id = ae.ingreso_id
JOIN unidad_medica u ON u.unidad_medica_id = i.unidad_medica_id
JOIN emergencia_procedimiento ep
  ON ep.atencion_emergencia_id = ae.atencion_emergencia_id
WHERE u.tipo = 'Emergencias';

-- V06: la cirugia corresponde a la solicitud evaluada y aprobada.
SELECT 'V06 cirugia aprobada' AS prueba,
       COUNT(*)::TEXT AS resultado,
       COUNT(*) >= 1 AS correcto
FROM cirugia c
JOIN evaluacion_solicitud_cirugia e
  ON e.evaluacion_solicitud_cirugia_id = c.evaluacion_solicitud_cirugia_id
 AND e.solicitud_cirugia_id = c.solicitud_cirugia_id
WHERE e.decision = 'Aprobada';

-- V07: existe hospitalizacion con cama y fechas de ocupacion.
SELECT 'V07 hospitalizacion con cama' AS prueba,
       COUNT(DISTINCT h.hospitalizacion_id)::TEXT AS resultado,
       COUNT(DISTINCT h.hospitalizacion_id) >= 1 AS correcto
FROM hospitalizacion h
JOIN asignacion_cama a ON a.hospitalizacion_id = h.hospitalizacion_id
JOIN ingreso i ON i.ingreso_id = h.ingreso_id
JOIN unidad_medica u ON u.unidad_medica_id = i.unidad_medica_id
WHERE u.tipo = 'Hospitalizacion';

-- V08: cuatro facturas de los cuatro escenarios.
SELECT 'V08 facturas por escenario' AS prueba,
       COUNT(*)::TEXT AS resultado,
       COUNT(*) = 4 AS correcto
FROM factura
WHERE numero_factura LIKE 'FAC-DEMO-%';

