

# **Modelado y Gestión de una Base de Datos Hospitalaria**

## **Laboratorio**

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

## **Proyecto 1**

7 de septiembre de 2,026

# **Contenido**

[**Objetivos	3**](#objetivos)

[Objetivos Generales	3](#objetivos-generales)

[Objetivos Específicos	3](#objetivos-específicos)

[**Descripción de la actividad	4**](#descripción-de-la-actividad)

[Actividades registradas por unidad	10](#actividades-registradas-por-unidad)

[Consulta externa	10](#consulta-externa)

[Emergencias	13](#emergencias)

[Cirugía	14](#cirugía)

[Hospitalización	22](#hospitalización)

[**Importante**	**24**](#importante)

[Documentos entregables	25](#documentos-entregables)

[Fecha de entrega	26](#fecha-de-entrega)

# 

# **Objetivos**

## **Objetivos Generales**

* Aplicar conceptos avanzados en sistemas de gestión de bases de datos.  
* Desarrollar modelado de datos como parte del análisis del problema.  
* Utilizar SQL como lenguaje de programación para la gestión de bases de datos.

## **Objetivos Específicos**

* Manejo de la integridad de datos.  
* Creación de estructura de datos.  
* Definición de modelos conceptuales y lógicos de datos.  
* Utilización de notaciones para modelado de datos.  
* Creación de sentencias SQL para la definición y manipulación de los datos.  
* Aplicación de sentencias de control de acceso (DCL) para la gestión de usuarios y privilegios.

# **Descripción de la actividad**

La cadena de Hospitales de Occidente lo ha contratado para crear la base de datos que almacenará la información referente a las actividades dentro de cada hospital, como la administración de personal y el registro de pacientes. La organización también reúne y mantiene un archivo para las calificaciones de cada hospital, médico, enfermero y encargados, y así conocer en cualquier momento la calidad del servicio de cada hospital. El objetivo principal de la base de datos es llevar un control diario de las actividades dentro de cada hospital.

Cada hospital está dividido en 4 unidades principales de atención médica:

* Consulta externa  
* Emergencias  
* Cirugía  
* Hospitalización

Sin importar la unidad en la que se encuentre un paciente, al haber terminado todo proceso, se emite una factura como comprobante de los servicios brindados, con una breve pero clara descripción, que se genera al momento de cancelar el servicio obtenido.

Como primera instancia, se le comparte una ficha de ingreso, una ficha de egreso y una ficha de traslado que es utilizada por parte de todas las unidades (con excepción de consulta externa), es decir, cada unidad utiliza la misma estructura para registrar el ingreso de pacientes y su egreso.

**Ficha de Ingreso**

**Hospital**

* Información específica del hospital  
* Dirección

**Paciente**

* Nombres y apellidos del paciente  
* No. de expediente  
* Edad  
  * Años  
* Fecha de nacimiento  
* Sexo  
  * Masculino  
  * Femenino  
* DPI  
* Teléfono  
* Dirección habitual  
  * Municipio  
  * Departamento  
  * Área  
    * Urbana  
    * Rural  
* Encargado  
  * Nombre  
  * Parentesco  
  * DPI  
  * Teléfono  
  * Dirección habitual  
    * Municipio  
    * Departamento  
    * Área  
      * Urbana  
      * Rural

**Ingreso**

* Motivo de ingreso  
* Unidad médica  
  * Nombre (cirugía, emergencias, hospitalización)  
  * Atención médica a recibir (tipo de servicio)  
* Fecha  
  * Día  
  * Mes  
  * Año  
  * Hora  
* Médico encargado  
  * Nombre  
  * DPI  
  * Teléfono  
  * Dirección habitual  
    * Municipio  
    * Departamento  
    * Área  
      * Urbana  
      * Rural  
  * Especialidad  
* Camilla / Quirófano asignado  
* Diagnóstico presuntivo de ingreso

**Ficha de Egreso**

**Hospital**

* Información específica del hospital  
* Dirección

**Paciente**

* Nombre  
* DPI  
* Sexo  
  * Masculino  
  * Femenino  
* Edad  
  * Años  
* Fecha de nacimiento  
* Estado civil  
* Dirección  
  * Municipio  
  * Departamento  
  * Área  
    * Urbana  
    * Rural

**Egreso**

* Diagnóstico principal del egreso  
* Diagnósticos secundarios  
* Motivo de egreso  
* Unidad médica  
  * Nombre (cirugía, emergencias, hospitalización)  
  * Atención médica a recibir (tipo de servicio)  
* Fecha  
  * Día  
  * Mes  
  * Año  
  * Hora  
* Médico asignado  
  * Nombre  
  * DPI  
  * Especialidad  
* Camilla / Quirófano asignado  
* Código de egreso (vivo, muerto, embarazo, parto)  
* Egreso sin consentimiento médico  
  * Sí o no  
  * Motivo  
* Número de días hospitalizado (opcional)  
* Operaciones / Intervenciones quirúrgicas (opcional)  
  * Ficha clínica: consentimiento informado firmado, y evaluación preanestésica.  
* Código de traslado (opcional)  
* Referido a otro hospital o establecimiento (opcional)

Ficha de Traslado

* Fecha  
  * Día  
  * Mes  
  * Año  
  * Hora  
* Paciente  
  * Nombre  
  * DPI  
  * Sexo  
    * Masculino  
    * Femenino  
  * Edad  
    * Años  
  * Fecha de nacimiento  
  * Estado civil  
  * Dirección  
    * Municipio  
    * Departamento  
    * Área  
      * Urbana  
      * Rural  
* Médico que indica  
  * Nombre  
  * DPI  
  * Especialidad  
* Unidad origen  
  * Nombre (cirugía, emergencias, hospitalización, otro)  
  * Atención médica a recibir (tipo de servicio)  
  * Hospital  
    * Información específica  
    * Dirección  
  * Interno o externo (de la institución)  
* Unidad destino  
  * Nombre (cirugía, emergencias, hospitalización, otro)  
  * Atención médica a recibir (tipo de servicio)  
  * Hospital  
    * Información específica  
    * Dirección  
    * Interno o externo (de la institución)

## **Actividades registradas por unidad**

La cadena de hospitales le ha brindado información acerca de las actividades que se registran en cada uno de sus hospitales, que se describen a continuación.

### **Consulta externa**

La Consulta Externa de los Hospitales de Occidente cuenta actualmente con (al menos un) un médico en cada una de las siguientes especialidades:

* Cardiología  
* Dermatología  
* Fisioterapia  
* Ginecología Oncológica  
* Hematología  
* Medicina Física y Rehabilitación  
* Medicina General  
* Nutrición y Dietética  
* Odontología General  
* Oftalmología  
* Psicología  
* Pediatría  
* Urología  
* Terapia del Lenguaje

Las consultas están disponibles únicamente en el turno matutino (variando según el horario del médico especializado), brindando atención médica a pacientes programados, o referidos, independientemente de la procedencia o de otras instituciones.

En la consulta externa se pretende que el paciente salga satisfecho con la atención, otorgándole una receta médica para sus procedimientos, una buena orientación para el paciente y familiares, una cita próxima para dar seguimiento a los problemas de salud, así como también órdenes de laboratorio según padecimientos.

**Receta médica**

* Fecha  
  * Día  
  * Mes  
  * Año  
* Médico  
  * Nombre  
  * Especialidad  
* Paciente  
  * Nombre  
  * Dirección  
* Prescripción  
  * Medicamento(s)  
    * Nombre  
    * Dosis  
    * Duración  
* Próxima cita  
  * Día  
  * Mes  
  * Año  
* Clínica  
  * Hospital  
  * Número de clínica

Si el médico obtiene un diagnóstico crítico que requiera la hospitalización para un paciente, deberá solicitar el consentimiento del paciente o del encargado para trasladar al paciente a la unidad para su correcto tratamiento. También si el médico considera necesaria la intervención quirúrgica, necesitará el consentimiento del paciente o el encargado, para trasladarlo a la unidad. Estos procedimientos de traslado de unidad son registrados en la ficha de traslado.

Cada consulta realizada es registrada y se paga lo adeudado en la recepción del médico. Si se ha realizado un traslado de unidad, de igual manera se cancela la totalidad de la consulta.

Se lleva un registro de las citas programadas y de las consultas realizadas. Las citas programadas pueden ser canceladas, y se debe llevar un control de esto, indicando si las programadas han sido realizadas, reprogramadas o canceladas.

**Ficha de cita programada**

* Nombres del paciente  
* Dirección  
* Teléfono  
* Médico encargado  
* Fecha y hora  
* Clínica o consultorio

**Ficha de consulta del paciente**

* Nombres del paciente  
* Dirección  
* Teléfono  
* Sexo  
* Fecha de nacimiento  
* No. de seguro social  
* Médico encargado  
* Fecha  
* Diagnóstico  
* Otros datos de interés  
* Notas u observaciones

Las citas para consulta externa se asignan vía telefónica a través del número telefónico de Hospitales de Occidente, a través de su correo institucional, o a través de la recepción general del hospital, que a su vez notificará a la recepción del médico correspondiente a la cita. Cada cita tendrá un costo, el cual dependerá del médico, y si es reconsulta el costo será de un 75% de lo establecido en la primera consulta. En caso de que el paciente sea referido por una institución, la cita tendrá un costo del 80%.

Es importante mencionar a los pacientes que si la cita es cancelada, este debe notificarlo para obtener una nueva cita o de lo contrario se le hará un sobrecargo del 10% sobre la siguiente cita.

### **Emergencias**

El servicio de emergencias tiene como objetivo principal recibir, estabilizar o atender al paciente que requiera una atención médica inmediata en tiempo adecuado, con los recursos humanos y técnicos necesarios.

El ingreso de los pacientes al hospital será en la recepción de pacientes de emergencia, la cual brinda atención médica las 24 horas, los 365 días del año, con turnos de 12 horas, contando con al menos 2 médicos por turno. La atención brindada en emergencias es por medio de médicos de medicina general, para el tratamiento y seguimiento de enfermedades crónicas, estabilizando a los pacientes para decidir si es necesaria la intervención de médicos especialistas o únicamente se requiere de tratamiento básico. Entre los servicios especializados se ofrecen los mismos ofrecidos en consulta externa. Entre los servicios básicos de emergencias que ofrece cada hospital de la institución están:

* Aislamiento y control de la vía aérea y ventilación  
* Control cardiocirculatorio  
* Atención de pacientes politraumatizados  
* Manejo, control y administración de drogas protocolizadas  
* Procedimientos de control y observación  
* Procedimientos terapéuticos/diagnósticos  
* Procedimientos diagnósticos

En la recepción de pacientes se deberán entregar los requisitos para la respectiva revisión del paciente. El médico realizará la evaluación de los pacientes según su estado clínico dándole prioridad a los de mayor gravedad o urgencia, para brindarles la atención inmediata. Al ingresar un paciente, se le asigna una camilla específica; en caso de que no se disponga de camillas libres se deberá esperar por turnos y urgencia.

Se deberá registrar por medio de la ficha de ingreso el estado actual de los pacientes al ingresar a la unidad hospitalaria.

Al haber realizado un diagnóstico se proporciona información clara y completa, al paciente o familiares, sobre sus patologías, procedimientos diagnósticos, procesos terapéuticos y quirúrgicos que requiera el usuario, solicitando su respectivo consentimiento informado según proceda. Si se requiere de hospitalización o cirugía, se realizará el procedimiento de traslado de unidad, registrando estos procedimientos en la ficha de traslado.

Sin importar el caso (egreso, hospitalización o cirugía), se debe llenar la ficha de egreso con el diagnóstico brindado por parte del médico encargado.

Cada hospital definirá un costo resultante de la atención médica de emergencia dependiendo del servicio brindado. Se podrá cancelar el costo total de la emergencia en cuotas, desde un único pago hasta 12 pagos divididos por mes. El pago deberá realizarse en la recepción del área de hospitalización.

### **Cirugía**

El servicio de Cirugía tiene cuatro quirófanos habilitados para realizar el mayor número de procedimientos quirúrgicos.

Las intervenciones quirúrgicas son realizadas por médicos residentes, médicos internos o médicos externos según la situación lo requiera. Los médicos externos, a diferencia de los médicos residentes e internos (que también pueden estar laborando en otras unidades de los hospitales de la institución o del mismo hospital), no están contratados para laborar en el hospital sino pertenecen a otra institución u organización, y son llamados exclusivamente para realizar cirugías en un área especializada. Cada hospital cuenta actualmente con al menos un médico de las siguientes especialidades:

* Cirugía Cardiovascular (Adulto y Pediátrica)  
* Cirugía de la Mano  
* Cirugía General  
* Videolaparoscopia Quirúrgica  
* Cirugía Ginecológica  
* Cirugía Neurológica  
* Cirugía Oftalmológica  
* Cirugía Oncológica  
* Cirugía Ortopédica  
* Cirugía Otorrinolaringológica  
* Cirugía Pediátrica  
* Cirugía Plástica  
* Cirugía de Tórax  
* Cirugía Urológica

Las cirugías están disponibles para realizarse en horario matutino y vespertino, con un horario definido para cirugías programadas, y un horario flexible para cirugías de emergencia.

En las cirugías también intervienen practicantes de medicina, enfermeros registrados o practicantes de enfermería, según sea decidido por el encargado de la cirugía. Cada cirugía está definida por un proceso quirúrgico, preoperatorio, intraoperatorio y postoperatorio, y es en este proceso donde un enfermero encargado registra la información brindada por el paciente, los médicos y el cumplimiento de los procesos dentro de cada etapa, con su descripción y hora de registro. Una vez finalizado cada proceso de la cirugía, se documenta y se envía a secretaría de la institución, con el nombre del enfermero que recabó la información y la fecha.

En el quirófano, la responsabilidad del paciente debe ser compartida entre todo el equipo de salud, de manera que cada uno de ellos (cirujano, anestesiólogo, enfermeros, etc.) realice eficientemente su labor.

**Preoperatoria**

Se define como preoperatorio al período que comprende el estudio y preparación del paciente para la intervención quirúrgica. El mismo empieza con la entrevista inicial del cirujano con su paciente, que representa uno de los momentos estratégicos de la relación. Termina el preoperatorio al iniciarse la anestesia en la sala de operaciones, momento en el que se inicia el intraoperatorio.

El conocimiento del paciente por parte del cirujano comienza con la elaboración de la historia clínica, que incluye un interrogatorio y una exploración física.

**Interrogatorio**

El interrogatorio puede ser directo (si la información se obtiene del paciente) o indirecto (cuando la información procede de un familiar o amigo del enfermo):

* Ficha de identificación  
  * Nombre  
  * Sexo  
  * Edad  
  * Estado civil  
  * Religión  
  * Ocupación  
  * Lugar de nacimiento  
  * Lugar de residencia  
* Antecedentes heredofamiliares  
* Antecedentes personales no patológicos  
* Antecedentes patológicos  
* Padecimiento actual  
* Interrogatorio por aparatos y sistemas  
* Síntomas generales y terapéutica empleada  
* Estudios previos

**Exploración física**

* Signos vitales  
* Exploración general  
* Exploración sistematizada de  
  * Cabeza  
  * Cuello  
  * Tórax  
  * Abdomen  
  * Extremidades  
  * Columna vertebral  
  * Cavidades: bucal, vaginal, rectal y conducto auditivo externo

El cirujano deberá enviar una solicitud hacia la institución definida como un agendamiento quirúrgico, el cual deberá ser aprobado por un comité médico encargado de revisarlos. En caso de que no cumpla con las condiciones de la institución, la solicitud ingresa a una base definida como cirugías rechazadas, indicando el cirujano y las razones de la causa. En caso de que sea aprobada la solicitud, se agenda hora y pabellón solicitado.

**Agendamiento Quirúrgico**

* Nombres del paciente  
* DPI  
* Edad  
* Carácter: urgente o programado  
* Historia clínica  
* Tipo de procedimientos a realizar  
* Nombre del cirujano  
* Tiempo estimado de la intervención  
* Tipo de anestesia  
* Requerimientos de equipos, insumos e instrumental  
* Fecha y hora de la solicitud

**Insumo**

* Nombre  
* Descripción  
* Material  
* Tipo (médico, quirúrgico, otro)

**Instrumento**

* Nombre  
* Descripción  
* Tipo (médico, quirúrgico, otro)  
* Función (corte, contenido, hemostática, retractor, accesorio, implante, otro)

**Equipo**

* Nombre  
* Descripción  
* Tipo (médico, quirúrgico, otro)  
* Función (exploración, diagnóstico, tratamiento, rehabilitación, otro)

Si la solicitud fue aprobada, se procede a realizar el chequeo de consentimiento informado, un chequeo preanestésico y una planificación de la etapa preoperatoria.

**Chequeo de consentimiento informado**

* Nombre específico del procedimiento  
* Objetivo del procedimiento  
* Características del procedimiento  
* Posibles riesgos del procedimiento  
* Nombre y firma del médico que realizará el procedimiento  
* Nombre y firma del paciente, familiar, tutor o representante legal según corresponda  
* Fecha de obtención del consentimiento

**Chequeo preanestésico**

* Identificación del paciente  
* Clasificación del riesgo que plantea la anestesia (ASA)  
* Nombre y firma del cirujano o médico tratante que clasifica el ASA  
* Plan de anestesia  
* Nombre del médico o anestesista

Posterior al chequeo, de no existir problemas, se debe ir registrando el éxito o fallo de cada uno de los siguientes aspectos.

**Planificación**

* Disponibilidad de tabla quirúrgica  
* Preparación de equipos y quirófano previo al ingreso del paciente  
* Recepción y acogida de paciente en el quirófano

**Entrada**

* Brazalete de identificación del paciente: el paciente confirma su nombre, el procedimiento a realizar y el lado o segmento a operar  
* Ficha clínica: exámenes de laboratorio, consentimiento informado firmado, y evaluación preanestésica  
* Confirmación de arsenal instrumental y estéril, implantes y equipos necesarios están disponibles y operativos  
* El anestesista comprueba la disponibilidad de los medicamentos, drogas y materiales necesarios para la técnica anestésica

**Intraoperatorio**

Comienza cuando el paciente es llevado a quirófano con la inducción de la anestesia y termina al finalizar el acto quirúrgico.

Al momento de entrar al quirófano, se registra toda la información del paciente en la ficha de ingreso.

Se debe confirmar la preparación del paciente en el quirófano, los procedimientos y el cumplimiento de protocolos, para lo cual se debe chequear los siguientes aspectos.

**Chequeo en quirófano**

* Presencia completa de equipo quirúrgico  
* Traslado correcto de camilla a mesa quirúrgica  
* Posicionamiento correcto en mesa operatoria  
* Placa instalada en el lugar correcto

**Procedimientos de pausa quirúrgica**

* Confirmación de todo el equipo de quirófano  
* Confirmación del paciente  
* Confirmación de buenas condiciones de esterilidad  
* Revisión de máquina de anestesia  
* Confirmación de suministro de anestesia  
* Cirujano indica plan quirúrgico  
* Incisión

Se lleva un registro de los procedimientos llevados a cabo durante la cirugía, con valores aceptables, medianamente aceptables y no aceptables.

**Gestión de cuidados intraoperatoria**

* Registro de balance hídrico  
* Registro de seguridad en administración de medicamentos  
* Registro de transfusión de sangre

Se lleva un registro de los procedimientos con el éxito o falla de los siguientes aspectos.

Salida Quirúrgica

* El cirujano anuncia el fin de los procedimientos quirúrgicos  
* Confirmación de procedimiento quirúrgico efectivamente realizado  
* Confirmación de que el conteo del instrumental es satisfactorio  
* Cierre de la incisión

**Postoperatorio**

Es el período que transcurre entre el final de una operación y la completa recuperación del paciente, o la recuperación parcial del mismo, con secuelas, pudiendo, en caso de fracasar la terapéutica, finalizar con la muerte.

Se lleva un registro de los procedimientos, el éxito o falla de los siguientes aspectos.

Ingreso a sala de recuperación

* Condiciones de evolución durante la cirugía (sin complicaciones, complicaciones, complicaciones graves)  
* Confirmación del tipo de cama para el paciente  
* Confirmación de la disposición de infraestructura  
  * Cama post anestésica  
  * Gases clínicos  
  * Bombas de infusión  
  * Monitores  
  * Electrodos  
* Confirmación de la disposición de personal  
* Confirmación de la disposición de insumos  
  * Medicamentos disponibles  
  * Portasueros

La sala de recuperación estará definida por una sala de hospitalización, que dependerá del médico encargado, quien definirá el tiempo y estadía de hospitalización, registrando la información en la ficha de traslado y la ficha de egreso.

**Traslado seguro**

* Signos vitales dentro de los límites normales  
* Zona operatoria limpia  
* Documentación del paciente  
  * Ficha clínica: exámenes de laboratorio, consentimiento informado firmado, y evaluación preanestésica  
  * Chequeo preanestésico  
* Sueros de mantención pasando correctamente

Si alguno de los pacientes presenta signos vitales fuera de los límites normales durante uno de los procesos de la cirugía, será redirigido a emergencias para ser estabilizado, registrando estos procedimientos en la ficha de traslado y la ficha de egreso.

Cada hospital definirá un costo resultante de la cirugía dependiendo del tipo de cirugía y el total de insumos utilizados por los médicos durante la operación. Se podrá cancelar el costo total de la cirugía en cuotas, desde un único pago hasta 12 pagos divididos por mes. El pago deberá realizarse en la recepción de la división de cirugía.

### **Hospitalización**

Esta unidad está orientada a proporcionar cuidados básicos y especializados seguros en un ambiente hospitalario confortable, que permita la recuperación de los pacientes, ofreciendo servicios con recurso humano calificado.

Al servicio de hospitalización se puede acceder por ingreso directo, cuando el médico desde su consultorio de Consulta Externa o Emergencia ordena la hospitalización según el caso, o por traslado a partir de una cirugía si lo requiere.

La unidad de hospitalización tiene un número de camillas habilitadas que dependerá de cada hospital de la institución, y dispone de un equipo profesional calificado para la atención de pacientes con patologías de alto nivel de complejidad. Los servicios que se ofrecen son los siguientes:

* Hematología  
* Medicina interna  
* Neumología  
* Neurología  
* Oncología  
* Ortopedia  
* Pediatría  
* Unidad de cuidados intermedios  
* Unidad de cuidado crítico de adultos

Se deberá registrar por medio de la ficha de ingreso el estado actual de los pacientes al ingresar a la unidad hospitalaria. Así también se deberá llevar un registro obligatorio del egreso de los pacientes por medio de la ficha de egreso.

Cada hospital definirá un costo resultante de hospitalización dependiendo del número de días internado, el costo por día dentro de las instalaciones, el costo total del servicio de atención médica definido por su tipo, y el total de insumos médicos utilizados en los días internados. Se podrá cancelar el costo total de la hospitalización en cuotas, desde un único pago hasta 12 pagos divididos por mes. El pago deberá realizarse en la recepción del área de hospitalización.

# **Importante**

* Se debe utilizar una herramienta gráfica para la creación del modelo de datos, en notación de Barker. Se recomienda DBeaver Community Edition (gratuito, permite modelar y hacer ingeniería inversa del esquema) o un diagramador en línea gratuito como dbdiagram.io, drawSQL o draw.io/diagrams.net. También puede utilizar herramientas como MySQL Workbench, SQL Server Management Studio si lo prefiere.   
* Utilizar como sistema gestor de base de datos PostgreSQL (versión 16 o superior; se recomienda utilizar la versión estable más reciente disponible al momento de instalar, actualmente la serie 18.x).  
* El desarrollo del proyecto es individual.  
* Las copias obtendrán nota de cero y se notificará a coordinación.  
* El código y los modelos implementados deberán ser comprendidos en su totalidad por el estudiante; se podrán realizar preguntas orales de defensa sobre cualquier parte del proyecto.  
* Se deben realizar inserciones de datos en la base de datos para la comprobación del proyecto.  
* Todos los datos de pacientes, médicos y encargados que se inserten deben ser ficticios. No se debe utilizar información real de personas (nombres, DPI, teléfonos, direcciones, etc.) para las pruebas del proyecto.  
* Se debe implementar control de acceso a nivel de base de datos (DCL): como mínimo, cree un rol o usuario con privilegios de solo lectura (por ejemplo, para auditoría o consulta de reportes) y un rol o usuario con privilegios administrativos completos sobre el esquema.  
* Toda restricción de dominio identificable en las fichas (por ejemplo: Sexo limitado a 'Masculino'/'Femenino', Área limitada a 'Urbana'/'Rural', Código de egreso limitado a sus valores válidos, Carácter de cirugía limitado a 'Urgente'/'Programado', rangos de edad, etc.) debe implementarse con restricciones CHECK en el DDL, no solo validarse por convención.  
* Para cada llave foránea del modelo, debe definirse y justificarse explícitamente su acción referencial ante DELETE y UPDATE (CASCADE, RESTRICT, NO ACTION, SET NULL o SET DEFAULT), según el significado real de la relación en el negocio. No se aceptará dejar el comportamiento por defecto del motor sin haberlo decidido conscientemente.  
* El código SQL entregado (DDL y DML) debe estar comentado de forma breve: cada tabla con un comentario de una línea indicando su propósito, y cada restricción CHECK con un comentario corto indicando qué válida. No es necesario repetir en el código la justificación completa de las acciones referenciales de las llaves foráneas: esa justificación detallada debe quedar únicamente en el diccionario de datos del documento PDF, para no duplicar la misma información en dos lugares.

## **Documentos entregables**

* **Modelo de datos**: se debe adjuntar el archivo de creación (ej. XML/archivo nativo de la herramienta utilizada) y una o varias imágenes del resultado obtenido del modelo (JPG o PNG).  
  * Notación de Barker.  
  * El modelo debe indicar claramente los atributos obligatorios y opcionales de cada entidad, los identificadores únicos (simples y compuestos), y las relaciones muchos a muchos resueltas mediante su entidad asociativa correspondiente.  
* **Sentencias SQL**: se debe adjuntar en un archivo por cada una de las diferentes sentencias utilizadas en la definición, manipulación y control de acceso a los datos (.sql).  
  * **DDL**: definición de la base de datos, incluyendo restricciones CHECK de dominio y acciones referenciales (CASCADE, RESTRICT, etc.) en las llaves foráneas.  
  * **DML**: inserciones de datos.  
  * **DCL**: creación de roles/usuarios y asignación de privilegios.  
* **Documento PDF**: se debe adjuntar en un documento (PDF) la o las imágenes del modelo obtenido, las sentencias SQL (DDL, DML y DCL) utilizadas, y el diccionario de datos descrito abajo.  
* **Diccionario de datos:** se debe incluir en el documento PDF una tabla por cada entidad/tabla del modelo, con las columnas: Atributo, Tipo de dato, Llave (PK / FK / —), Nulos (Sí/No), Descripción y, únicamente en las filas que sean llave foránea, Acción referencial en DELETE, Acción referencial en UPDATE y Justificación (una línea, basada en la regla de negocio correspondiente).  
* **Respaldo de la base de datos:** se debe adjuntar un archivo de respaldo (backup) generado con las herramientas del SGBD (por ejemplo, **`pg_dump`** en PostgreSQL) que contenga tanto la estructura como los datos de prueba insertados.

## **Fecha de entrega**

* **Fecha**: lunes 28 de septiembre de 2026\.  
* **Hora**: 23:59 hrs.  
* **Medio de entrega**: se debe entregar mediante un repositorio Git privado (GitHub o GitLab). El enlace al repositorio como la documentación, debe compartirse también por Teams, en la tarea asignada, como respaldo.  
  * El repositorio debe organizarse en carpetas:   
    * modelo/ (archivo nativo e imágenes del diagrama)  
    * sql/ddl/, sql/dml/, sql/dcl/,   
    * backup/   
    * documentacion/ (PDF con diccionario de datos).  
  * Debe incluirse un archivo README.md breve que describa el contenido de cada carpeta.  
  * Se espera un historial de commits que refleje avance progresivo del proyecto (no se aceptará un repositorio con un único commit final). El historial de commits podrá tomarse en cuenta como evidencia de trabajo individual y de que el estudiante comprende lo que entrega.  
* No habrá prórroga ni cambio de fecha por ningún motivo.