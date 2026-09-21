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