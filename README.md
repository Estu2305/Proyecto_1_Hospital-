# Proyecto 1 — Base de Datos Hospitalaria

Proyecto individual del curso **Sistema de Base de Datos 1**. El repositorio contiene el diseño y la implementación en PostgreSQL de una base de datos para la cadena **Hospitales de Occidente**.

El sistema modela la organización hospitalaria, personas y personal, expediente clínico, consulta externa, emergencias, cirugía, hospitalización, facturación y evaluación de calidad.

## Resultados verificados

- PostgreSQL 16.
- 64 tablas en el esquema `hospital`.
- 124 llaves foráneas.
- 159 restricciones `CHECK` documentadas.
- Datos ficticios para cuatro escenarios clínicos.
- Roles de administración y consulta.
- Pruebas automatizadas V01–V14 completadas correctamente.
- Respaldo probado mediante restauración completa.

## Estructura del repositorio

```text
Proyecto 1/
├── backup/
│   └── hospitales_occidente.backup
├── documentacion/
│   ├── Proyecto 1.md
│   ├── Proyecto Base de Datos H.docx
│   └── Proyecto Base de Datos H.pdf
├── modelo/
│   ├── modelo_hospitalario.drawio
│   └── Imagenes de los Diagramas/
├── sql/
│   ├── ddl/
│   ├── dml/
│   ├── dcl/
│   └── pruebas/
├── .gitignore
└── README.md
```

## Tecnologías utilizadas

- PostgreSQL 16.
- Docker Desktop.
- DBeaver Community Edition o `psql`.
- draw.io para el modelo Barker.
- Git y GitHub.

## Creación del contenedor

Desde PowerShell, solicitar la contraseña sin dejarla escrita en el historial:

```powershell
$dbPassword = Read-Host "Escribe la contraseña de PostgreSQL"
```

Crear el contenedor:

```powershell
docker run --name postgres-hospital `
  --restart unless-stopped `
  -e POSTGRES_USER=postgres `
  -e "POSTGRES_PASSWORD=$dbPassword" `
  -e POSTGRES_DB=hospitales_occidente `
  -p 127.0.0.1:5434:5432 `
  -v hospital_datos:/var/lib/postgresql/data `
  -d postgres:16
```

Comprobar que esté funcionando:

```powershell
docker ps --filter "name=postgres-hospital"
```

## Instalación desde los scripts SQL

Los scripts deben ejecutarse en este orden:

1. `sql/ddl/estructura.sql`
2. `sql/ddl/nucleo_clinico.sql`
3. `sql/ddl/consulta_emergencia.sql`
4. `sql/ddl/cirugia.sql`
5. `sql/ddl/hospitalizacion.sql`
6. `sql/ddl/facturacion_calidad.sql`
7. `sql/dml/datos_prueba.sql`
8. `sql/dcl/roles_privilegios.sql`
9. `sql/pruebas/verificacion.sql`

Copiar y ejecutar cada archivo con el siguiente patrón:

```powershell
docker cp ".\sql\ddl\estructura.sql" postgres-hospital:/tmp/estructura.sql

docker exec -it postgres-hospital psql `
  -X -v ON_ERROR_STOP=1 `
  -U postgres `
  -d hospitales_occidente `
  -f /tmp/estructura.sql
```

Se debe repetir el patrón respetando el orden anterior y ajustando la ruta y el nombre del archivo.

> `datos_prueba.sql` está diseñado para ejecutarse una sola vez sobre una base recién creada. Volver a ejecutarlo sobre los mismos datos puede producir errores por valores únicos duplicados.

## Verificación

Copiar y ejecutar las pruebas:

```powershell
docker cp ".\sql\pruebas\verificacion.sql" postgres-hospital:/tmp/verificacion.sql

docker exec -it postgres-hospital psql `
  -X -v ON_ERROR_STOP=1 `
  -U postgres `
  -d hospitales_occidente `
  -f /tmp/verificacion.sql
```

Las pruebas V01–V14 deben mostrar `correcto = t`.

## Roles y privilegios

El archivo `sql/dcl/roles_privilegios.sql` configura los roles del proyecto. Entre las verificaciones principales se encuentran:

- `hospital_lectura`: puede consultar las tablas, pero no insertar datos.
- `hospital_admin`: administra el esquema y puede insertar, actualizar y eliminar datos.
- El esquema `hospital` y sus tablas pertenecen a `hospital_admin`.

## Respaldo

Generar un respaldo en formato personalizado:

```powershell
docker exec postgres-hospital pg_dump `
  -U postgres `
  -d hospitales_occidente `
  -Fc `
  -f /tmp/hospitales_occidente.backup

docker cp postgres-hospital:/tmp/hospitales_occidente.backup `
  ".\backup\hospitales_occidente.backup"
```

## Restauración completa

Copiar el respaldo al contenedor y crear una base vacía:

```powershell
docker cp ".\backup\hospitales_occidente.backup" `
  postgres-hospital:/tmp/hospitales_occidente.backup

docker exec postgres-hospital createdb `
  -U postgres hospitales_prueba_completa
```

Restaurar estructura, datos, propietarios y privilegios:

```powershell
docker exec postgres-hospital pg_restore `
  -U postgres `
  -d hospitales_prueba_completa `
  --single-transaction `
  --exit-on-error `
  /tmp/hospitales_occidente.backup
```

La restauración completa fue validada con 64 tablas, 4 pacientes, 4 unidades médicas, 4 facturas y los privilegios esperados.

## Modelo de datos

El archivo editable se encuentra en `modelo/modelo_hospitalario.drawio`. La carpeta `modelo/Imagenes de los Diagramas/` contiene el mapa completo y las vistas por módulo utilizadas en la documentación.

El modelo emplea notación Barker para representar entidades, atributos, obligatoriedad, cardinalidades y relaciones.

## Documentación

El documento final editable se encuentra en `documentacion/Proyecto Base de Datos H.docx`, y su versión de entrega en `documentacion/Proyecto Base de Datos H.pdf`.

Todos los nombres y registros utilizados para las pruebas son ficticios y se incluyen únicamente con fines académicos.
