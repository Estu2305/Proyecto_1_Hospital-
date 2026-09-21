BEGIN;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'hospital_lectura') THEN
        CREATE ROLE hospital_lectura NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'hospital_admin') THEN
        CREATE ROLE hospital_admin NOLOGIN;
    END IF;
END
$$;

GRANT CONNECT ON DATABASE hospitales_occidente TO hospital_lectura, hospital_admin;
GRANT USAGE ON SCHEMA hospital TO hospital_lectura;
GRANT USAGE, CREATE ON SCHEMA hospital TO hospital_admin;

-- El rol administrativo pasa a ser propietario del esquema y sus tablas.
-- La propiedad permite ALTER y DROP, que GRANT ALL por si solo no concede.
DO $$
DECLARE
    objeto RECORD;
BEGIN
    FOR objeto IN
        SELECT c.relname, c.relkind
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'hospital'
          AND c.relkind IN ('r', 'p', 'v', 'm')
        ORDER BY c.relkind, c.relname
    LOOP
        CASE objeto.relkind
            WHEN 'r', 'p' THEN
                EXECUTE format('ALTER TABLE hospital.%I OWNER TO hospital_admin', objeto.relname);
            WHEN 'v' THEN
                EXECUTE format('ALTER VIEW hospital.%I OWNER TO hospital_admin', objeto.relname);
            WHEN 'm' THEN
                EXECUTE format('ALTER MATERIALIZED VIEW hospital.%I OWNER TO hospital_admin', objeto.relname);
        END CASE;
    END LOOP;
END
$$;
ALTER SCHEMA hospital OWNER TO hospital_admin;

-- Auditoría: consultas SELECT, sin INSERT, UPDATE, DELETE ni DDL.
GRANT SELECT ON ALL TABLES IN SCHEMA hospital TO hospital_lectura;

-- Administración de todos los objetos existentes en el esquema.
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA hospital TO hospital_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA hospital TO hospital_admin;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA hospital TO hospital_admin;

-- Los futuros objetos creados por postgres heredarán esos permisos.
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA hospital
    GRANT SELECT ON TABLES TO hospital_lectura;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA hospital
    GRANT ALL PRIVILEGES ON TABLES TO hospital_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA hospital
    GRANT ALL PRIVILEGES ON SEQUENCES TO hospital_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA hospital
    GRANT ALL PRIVILEGES ON FUNCTIONS TO hospital_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE hospital_admin IN SCHEMA hospital
    GRANT SELECT ON TABLES TO hospital_lectura;

COMMIT;