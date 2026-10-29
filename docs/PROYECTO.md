# RESCATE360: explicación completa del proyecto

> Estado al 29-oct-2026, con todas las ramas del Sprint 4 subidas.
> Proyecto de la UPC para Ingeniería de Software II.
> Equipo: **Libardo** (backend y conexión de la app), **Sergio** (backend hasta el Sprint 3; ahora solo Firebase), **Oscar** (app Flutter) y **Elkin** (panel web React).

---

## 1. ¿Qué es RESCATE360?

Es una plataforma para coordinar la respuesta a emergencias (inundaciones, sismos, incendios, accidentes, personas desaparecidas) entre tres actores:

| Actor | Usa | Para qué |
|---|---|---|
| **Ciudadano** | App móvil | Pedir ayuda, apretar el SOS, reportar incidentes, buscar personas desaparecidas, ver alertas y el mapa, decir si está bien después de un sismo |
| **Voluntario** | App móvil | Ver los casos de su organización, tomarlos y cerrarlos |
| **Administrador** (de una organización: Bomberos, Cruz Roja, Defensa Civil…) | Panel web | Verificar reportes, gestionar voluntarios, publicar alertas y zonas de riesgo, centros, campañas de donación y auditoría |
| **Super admin** | Panel web | Todo el sistema: organizaciones, administradores, enrutar casos sin organización, guía de emergencia y simulacros |

La idea central: **un caso entra (solicitud, SOS o reporte), la IA lo clasifica y lo envía a la organización correcta, la organización lo atiende, y el ciudadano ve el avance**. Si no hay internet, el mensaje viaja por Bluetooth de teléfono en teléfono.

```
┌─────────────┐   HTTPS/JSON   ┌──────────────────────────────┐   ┌────────────┐
│ App Flutter │ ─────────────▶ │  API FastAPI (rescate360-be) │──▶│ PostgreSQL │
│ (ciudadano, │ ◀───────────── │  routes→controllers→services │   │ + PostGIS  │
│  voluntario)│                │  →repositories               │   └────────────┘
└──────┬──────┘                └──────┬───────────────────────┘
       │ Bluetooth (sin red)          │ encola jobs
       ▼                              ▼
┌─────────────┐                ┌──────────────┐   ┌──────────────────────────┐
│ Otros       │                │ Redis        │──▶│ Celery worker + beat     │
│ teléfonos   │                └──────────────┘   │ IA (Gemini), SMS (Twilio)│
└─────────────┘                                   │ push (Firebase), sismos  │
┌─────────────┐   HTTPS/JSON                      │ (USGS), vencimientos     │
│ Panel web   │ ─────────────▶ (misma API)        └──────────────────────────┘
│ React       │
└─────────────┘
```

---

## 2. Repositorios y cómo levantar todo

| Repo | Contenido | Ruta local |
|---|---|---|
| `Libardo19/rescate360-be` | API, base de datos, jobs | `Documents/rescate360-be` |
| `Libardo19/rescate360-fe` | App Flutter (`lib/`) y panel web (`rescate360-web/`) | `Documents/rescate360-fe` |

**Ramas:** `develop` (donde se integra todo) y `main` (la versión de entrega; se actualiza al final). Cada trabajo va en `feature/<tema>-<nombre>` y entra por PR.

### Backend (Docker)
```bash
cd rescate360-be
docker compose up -d                       # db (:5435), redis, api (:8000), worker, beat, pgadmin (:5050)
docker compose exec api alembic upgrade head
docker compose exec api python -m scripts.seed.crear_super_admin   # usa SUPER_ADMIN_* del .env
docker compose exec api python -m scripts.seed.datos_demo          # datos de Valledupar (SEED_DEMO_PASSWORD)
docker compose exec api pytest -q                                  # 538 pruebas
```
La documentación interactiva de la API está en `http://localhost:8000/docs`.

### Panel web
```bash
cd rescate360-fe/rescate360-web
npm ci
npm run dev          # http://localhost:5173 (usa .env.local → API local)
npm run dev:tunel    # usa .env.tunel → API compartida por túnel de Cloudflare
```

### App
```bash
cd rescate360-fe
flutter run -d chrome                      # navegador (API en localhost)
flutter run                                # emulador Android (API en 10.0.2.2)
.\scripts\correr-celular.ps1               # celular físico por USB, con la IP de la PC detectada sola
flutter test                               # 23 pruebas
```
Para el celular físico: abre una vez el puerto 8000 con `scripts\abrir-puerto-api.ps1` (como administrador). Los detalles están en `docs/PRUEBA_MOVIL.md`.

### Variables de entorno (solo en `.env`, nunca en el repo)

| Variable | Para qué | Sin ella… |
|---|---|---|
| `JWT_SECRET` | Firmar los tokens | No arranca |
| `GEMINI_API_KEY` | IA que clasifica | Se usa el clasificador por reglas |
| `TWILIO_*` | SMS (SOS, recuperar contraseña, "¿Estás bien?") | El SMS solo queda en el log |
| `SMTP_*` / `MAIL_*` | Correo de recuperación | Solo queda en el log |
| `FIREBASE_CREDENTIALS_PATH` | Push a los teléfonos | Solo queda en el log (**tarea pendiente de Sergio**) |
| `SUPER_ADMIN_*`, `SEED_DEMO_PASSWORD` | Usuarios iniciales y de demo | El seed no corre |
| `APP_ENV=local` | CORS abierto a localhost y simulacro de sismos | — |

---

## 3. Backend (`rescate360-be`)

### 3.1 Tecnologías
- **FastAPI** (Python 3.12) y **Pydantic v2** para validar.
- **SQLAlchemy 2** + **GeoAlchemy2** sobre **PostgreSQL + PostGIS**, para las ubicaciones y los círculos. Las versiones de la BD las fijó el equipo y no se cambian.
- **Alembic** para las migraciones, escritas a mano (`0001` → `0021`).
- **JWT** (PyJWT) con access y refresh token; las contraseñas con **bcrypt**.
- **Celery + Redis**: un worker para los jobs por evento y beat para los periódicos.
- Integraciones: **Gemini** (IA), **Twilio** (SMS), **Firebase Admin** (push), **SMTP** (correo) y el **feed del USGS** (sismos).

### 3.2 Arquitectura en 4 capas (la misma en todos los módulos)

```
app/
├── routes/        verbo + ruta + response_model + rol requerido. Nada más.
├── controllers/   HTTP: lee el usuario, la BD, el query o el form, y llama al service. Sin SQL.
├── services/      reglas de negocio y permisos. Aquí se hace db.commit() y se encolan los jobs.
├── repositories/  solo consultas SQLAlchemy (select, flush, bloqueos FOR UPDATE).
├── schemas/       Pydantic: lo que entra (…In) y lo que sale (…Out), con mensajes en español.
├── models/        tablas SQLAlchemy (con sus índices y CHECKs, iguales a las migraciones).
├── integrations/  servicios externos (ia_client, twilio_client, firebase_client, correo_client,
│                  storage_client, sismos_client). Sin credenciales, solo escriben en el log.
├── jobs/          eventos/ (se encolan) y programados/ (beat).
├── middlewares/   auth (JWT), roles, auditoría, errores y validación.
├── core/          configuración, base de datos, seguridad, celery, logging, excepciones.
└── utils/         geo (puntos, círculos, distancias), paginación, teléfonos E.164.
```

**Convenciones:**
- **Errores:** siempre `{detalle, codigo}`. `NoEncontrado`=404, `SinPermiso`=403, `Conflicto`=409 y `DatosInvalidos`=422.
- **Roles:** `require_role(...)` en la ruta; `alcance_organizacion(usuario)` limita al admin y al voluntario a su organización.
- **Organización efectiva** de un caso: la manual (la que elige el super admin) prevalece sobre la que sugirió la IA.
- **Jobs:** se encolan *después* del commit y con `encolar()`, que no rompe la petición si Redis está caído.
- **Auditoría:** un trigger de Postgres (`fn_auditoria`) guarda cada cambio en tablas sensibles, sin contraseñas, códigos ni la llave offline.
- **Teléfonos** siempre en E.164 (`+573001234567`).

### 3.3 Roles y permisos

| | Ciudadano | Voluntario | Administrador | Super admin |
|---|---|---|---|---|
| Solicitudes / SOS | crea y ve las suyas, puede cancelar | ve y toma las de su organización | las de su organización | todas; las enruta |
| Reportes | crea y ve los suyos (y los verificados) | los de su organización | verifica, rechaza o marca como duplicado | todos; los enruta |
| Usuarios | su perfil | su perfil | invita voluntarios de su organización | crea organizaciones y administradores |
| Alertas y zonas | ve | ve | publica en su organización | global |
| Dashboard | — | su organización + sus tareas | su organización | global y por organización |
| Auditoría | — | — | lo que hizo su organización | todo |
| Guía de emergencia | lee | lee | lee | edita |
| Sismos | ve; responde "¿Estás bien?" | igual | ve el resumen por sismo | igual + simulacro |

Esta matriz está probada en `tests/integration/test_seed_y_permisos.py`.

### 3.4 Módulos y endpoints

| Módulo | Endpoints principales | Qué hace |
|---|---|---|
| **auth** | `POST /auth/registro, /login, /refresh-token, /activar, /recuperar, /restablecer` | El registro público siempre crea un ciudadano, con el consentimiento de datos. Los voluntarios y admins se activan con un código de invitación. La contraseña se recupera por SMS o correo |
| **usuarios** | `GET/PATCH /usuarios/me`, `/me/password`, `/me/ubicacion`, `/me/consentimientos`, `/me/dispositivo`, `/me/contactos-emergencia`, `/me/datos`, `DELETE /me`; `GET/POST/PATCH /usuarios` (panel) | Perfil, ubicación (con autorización), token push, contactos de emergencia (máx. 5), **Ley 1581** (exportar y borrar la cuenta anonimizando) |
| **organizaciones** | CRUD + `/organizaciones/{id}/administradores` | Solo super admin. El sistema nunca queda sin super admin |
| **solicitudes_ayuda** | `POST /solicitudes-ayuda`, `/sos`, `GET`, `PATCH …/estado`, `…/prioridad`, `…/organizacion`, `POST …/cancelar` | Pedir ayuda y SOS (el SOS nace crítico y manda un **SMS a los contactos**) |
| **asignaciones** | `POST /solicitudes-ayuda/{id}/asignar`, `/reportes/{id}/asignar`, `GET /asignaciones/mias`, `PATCH /asignaciones/{id}` | El voluntario toma un caso y lo cierra |
| **reportes** | `POST /reportes` (multipart con fotos y video), `GET`, `/tipos`, `PATCH …/verificar · rechazar · marcar-duplicado · organizacion · prioridad` | Incidentes. El tipo es texto: hay una lista sugerida o el usuario escribe uno propio |
| **IA** | jobs `clasificar_prioridad_ia` y `clasificar_reporte_ia` | Gemini sugiere la prioridad y la organización; si falla, se usa el clasificador por reglas. Lo manual siempre prevalece |
| **mapa** | `GET /mapa?lat&lng&radio_m&capas&desde` | Una sola respuesta con las capas solicitudes, reportes, zonas, alertas y sismos. Los casos de otros salen aproximados (~200 m) y la app consulta cada 15 s |
| **personas_desaparecidas** | `POST` (con foto), `GET` (búsqueda sin tildes), `GET /{id}`, `PATCH`, `PATCH /{id}/estado` | Ficha completa. La foto de un menor solo la ven el autor y los admins (Ley 1098). El contacto solo sale en el detalle, con el aviso legal (Mecanismo de Búsqueda Urgente) |
| **centros_ayuda** | CRUD | Albergues y puntos de ayuda (de Sergio) |
| **zonas_peligrosas** | CRUD | Círculos de riesgo con nivel y estado (de Sergio) |
| **alertas** | `POST/GET/PATCH /alertas`, `POST …/cancelar` | Círculo con nivel, vigencia y origen (manual o sismo). `GET ?lat&lng` trae las que te cubren. Se avisa por push a quien esté dentro |
| **sismos** | `GET /sismos`, `/sismos/{id}`, `POST /sismos/simular` | Feed del USGS cada minuto (Colombia). Desde M4.5 publica una alerta automática y abre un "¿Estás bien?" |
| **check-ins** | `GET /check-ins/pendiente`, `POST /check-ins`, `POST /check-ins/{id}/responder`, `GET /check-ins` | "¿Estás bien?" con vencimiento. "Necesito ayuda" crea un SOS; si no respondes, se avisa a tus contactos |
| **offline** | `GET /usuarios/me/llave-offline`, `POST /offline/sync`, `POST /offline/relevo` | Mensajes firmados (HMAC) que llegan sin conexión o por Bluetooth (origen `mesh`) |
| **donaciones** | `GET/POST/PATCH /campanas`, `GET/POST /donaciones`, `PATCH …/estado` | Campañas con lo recaudado y el registro de lo recibido. **La app no cobra** |
| **dashboard** | `GET /dashboard` | Números según el rol + actividad reciente |
| **auditoria** | `GET /auditoria` | Historial de cambios, solo de lectura |
| **guia_emergencia** | `GET /guia-emergencia`, CRUD (super admin) | Qué hacer en cada emergencia, más las líneas 123, 119, 132, 144 y 141 |

### 3.5 Jobs (Celery)

| Job | Cuándo | Qué hace |
|---|---|---|
| `clasificar_prioridad_ia` / `clasificar_reporte_ia` | Al crear una solicitud o un reporte | Prioridad y organización (IA o reglas) |
| `enviar_sms_respaldo` | Al crear un SOS | SMS con la ubicación a los contactos de emergencia |
| `notificar_alerta_zona` | Al publicar una alerta | Push a quien esté dentro del círculo (ubicación de menos de 24 h) |
| `notificar_voluntarios_cercanos` | Cuando un reporte ya tiene organización | Push a los voluntarios a menos de 5 km |
| `notificar_persona_encontrada` | Cuando marcan a la persona como encontrada | Push a quien la reportó |
| `procesar_lote_offline` | Al llegar mensajes sin conexión | Crea el SOS o actualiza el "¿Estás bien?" |
| `sincronizar_sismos` | Cada 60 s | Feed del USGS; alerta y check-ins para los sismos fuertes |
| `vencer_check_ins` | Cada 60 s | "Sin respuesta" y SMS a los contactos |
| `expirar_alertas` | Cada 5 min | Las vencidas pasan a `expirada` |
| `marcar_reportes_no_verificables` | Cada hora | Los pendientes de más de 72 h pasan a `no_verificable` |
| `limpiar_datos_retencion` | Cada día, 3:30 | Borra las ubicaciones y los mensajes offline de más de 30 días |

### 3.6 Base de datos

Tablas principales:
- **Personas y organizaciones:** `usuarios`, `organizaciones`, `consentimientos`, `dispositivos`, `contactos_emergencia`.
- **Casos:** `solicitudes_ayuda`, `reportes` + `evidencias_reporte`, `asignaciones`, `personas_desaparecidas`.
- **Territorio y avisos:** `centros_ayuda`, `zonas_peligrosas`, `alertas`, `eventos_sismicos`, `check_ins`.
- **Otras:** `cola_alertas_offline`, `campanas`, `donaciones`, `guia_emergencia` y `auditoria`.

Las ubicaciones son `POINT` y las zonas `POLYGON` (SRID 4326) con índice GiST. Las distancias se calculan en metros reales, casteando a `geography`.

**Migraciones:**

| # | Qué | # | Qué |
|---|---|---|---|
| 0001–0003 | PostGIS, esquema, índices y trigger de auditoría | 0012 | Clasificación de la IA en reportes |
| 0004–0007 | Solicitudes (tipo, estado, dirección) y asignaciones | 0013 | Ficha de personas desaparecidas |
| 0008 | Fecha de la ubicación del usuario | 0014 | Contactos y baja de usuarios |
| 0009 | Código de usuario, activación y recuperación | 0015–0016 | Zonas como círculo + endurecimiento |
| 0010 | Reportes con evidencias y verificación | 0017 | Alertas con círculo, estado y vigencia |
| 0011 | Centros de ayuda | 0018–0019 | Sismos y check-ins |
| | | 0020–0021 | Relevo offline y donaciones |

### 3.7 Pruebas
- **538 pruebas** con pytest, en `tests/integration` (una BD `rescate360_test` aparte; cada prueba hace rollback) y `tests/unit`.
- **Nunca llaman servicios reales:** la fixture `sin_servicios_externos` vacía Twilio, el correo y Gemini.
- **Antes de cada PR:** `pytest`, `alembic check` (el modelo y las migraciones coinciden) y la bajada y subida de cada migración nueva.

---

## 4. App móvil (`rescate360-fe/lib`)

### 4.1 Tecnologías
- **Flutter** (Dart) con **Riverpod 2**, **dio** (HTTP) y **flutter_secure_storage** (tokens y llave offline).
- **Mapa:** **flutter_map** + OpenStreetMap, sin API key; ubicación con **geolocator**.
- **Modo sin conexión:** **nearby_connections** (Bluetooth), **crypto** (firma HMAC), **permission_handler**, **connectivity_plus** y **shared_preferences**.

### 4.2 Estructura

```
lib/
├── app/          tema (colores, textos), router de rutas con nombre, i18n (español/inglés)
├── core/
│   ├── config/       Env.apiBaseUrl: localhost en Chrome, 10.0.2.2 en el emulador; se cambia con --dart-define
│   ├── network/      ApiClient (dio) + endpoints.dart + interceptores (token y refresh automático; errores)
│   ├── errors/       ApiException: convierte {detalle, codigo} y "sin conexión" en un mensaje
│   ├── storage/      SecureStorage: tokens, usuario y llave offline cifrados
│   ├── location/     LocationService: permisos, posición actual y seguimiento
│   ├── offline/      mensaje firmado, cola local, conectividad, subida, relevo Bluetooth
│   └── permissions/  permisos de Bluetooth y "dispositivos cercanos"
├── shared/       widgets comunes (PrimaryButton, CampoTexto…) y modelos (UsuarioModel, Rol)
└── features/<f>/
    ├── data/          datasources (llaman a la API) → repositories → models (fromJson)
    └── presentation/  viewmodels (Riverpod) → views (pantallas de Oscar) → widgets
```

**Patrón de cada feature:**
1. El **datasource** llama a la API.
2. El **repository** lo expone a la app.
3. El **viewmodel** (`AsyncNotifier` o `FutureProvider`) guarda el estado; sus acciones devuelven el mensaje de error o `null`.
4. La **pantalla** muestra carga, error con "Reintentar" y la lista con "deslizar para actualizar".

### 4.3 Qué hace cada feature

| Feature | Pantallas | Conectado a |
|---|---|---|
| `auth` | Bienvenida, login, registro (con consentimiento), activar cuenta, recuperar contraseña | `/auth/*` |
| `home` | Inicio, **SOS** (mantener presionado 3 s; con el botón "Modo emergencia") | `/solicitudes-ayuda/sos`, `/check-ins` |
| `solicitudes_ayuda` | Pedir ayuda, mis solicitudes (cancelar) | `/solicitudes-ayuda` |
| `reportes` | Reportar incidente (fotos, video, tipo propio), mis reportes | `/reportes` |
| `mapa` | Mapa en vivo con filtros, búsqueda y "mi ubicación" | `/mapa` (cada 15 s) |
| `alertas` | En mi zona / todas, con color por nivel | `/alertas` |
| `check_in` | **"¿Estás bien?"** a pantalla completa con cuenta regresiva | `/check-ins` (consulta cada 60 s) |
| `sin_conexion` | Configuración → Modo sin conexión (relevo, cola, "entregar ahora") | `/offline/*` |
| `personas_desaparecidas` | Lista (buscadas / encontradas), ficha, registrar con foto, marcar encontrada | `/personas-desaparecidas` |
| `perfil` | Mis datos, contactos de emergencia, privacidad (Ley 1581), configuración | `/usuarios/me/*` |
| `guia_emergencia` | Guía por emergencia (con la guía local de respaldo sin red) | `/guia-emergencia` |
| `donaciones` | Campañas vigentes con su avance | `/campanas` |
| `voluntario` | Inicio, incidentes de su organización, mapa, mis tareas | `/solicitudes-ayuda`, `/asignaciones` |
| `centros_ayuda`, `zonas_peligrosas` | Pantallas de Oscar | Capas del mapa |

**Navegación por rol:** el ciudadano entra a `PrincipalScreen` (Inicio, Mapa, Reportes, Más) y el voluntario a `VoluntarioScreen`. Las dos están envueltas en `VigilanteCheckIn`, que pregunta por el "¿Estás bien?" y arranca el modo sin conexión.

### 4.4 Modo sin conexión (cómo funciona)
1. Con internet, la app guarda una **llave secreta** del usuario (`/usuarios/me/llave-offline`).
2. Si el SOS o el "¿Estás bien?" no salen por falta de red, la app arma un **mensaje pequeño firmado** (HMAC-SHA256 de `uuid|usuario|tipo|lat|lng|fecha`) y lo guarda en la cola.
3. El **relevo Bluetooth** (Nearby) busca teléfonos con RESCATE360 cerca y les pasa la cola. Cada uno suma un salto (máximo 8) y descarta lo que tiene más de 24 h.
4. El primer teléfono con internet lo sube a `/offline/relevo`. El backend **verifica la firma** (nadie puede inventar ni cambiar el SOS de otro), descarta los repetidos y crea el SOS con `origen = mesh`, con su SMS.

Es una prueba de concepto **solo para Android**; la demo con 3 teléfonos está en `docs/PRUEBA_MOVIL.md`.

---

## 5. Panel web (`rescate360-fe/rescate360-web`)

### 5.1 Tecnologías
**React 19** + **Vite**, **TypeScript**, **Tailwind CSS v4** (tokens `panel-*`), **react-router** y **react-leaflet** para los mapas.

### 5.2 Estructura
```
src/
├── pages/landing/      página pública de presentación
├── pages/login/        login y recuperar contraseña
├── pages/admin/        Dashboard, Solicitudes, Reportes, Mapa, Usuarios, Alertas, Zonas,
│                       Centros, Desaparecidos, Donaciones, Auditoría
├── pages/superadmin/   Dashboard global y Organizaciones (+ administradores)
├── layouts/            barra lateral y encabezado según el rol
├── routes/             rutas y menús por rol (admin / super admin)
├── context/            AuthContext: sesión, tokens y rol
├── services/api.ts     fetch con refresh automático del token ante un 401, ApiError y USE_MOCK
└── types/              contratos en TypeScript (snake_case, iguales al backend)
```

### 5.3 Estado de conexión del panel

| Pantalla | Estado |
|---|---|
| Login, usuarios, organizaciones, administradores, solicitudes, reportes (con la sugerencia de la IA y la prioridad manual), mapa | ✅ Conectadas a la API |
| Dashboard, auditoría, alertas, zonas, centros, desaparecidos, donaciones | El backend ya existe. **Las conecta Elkin** con los contratos de las PR |

`VITE_USE_MOCK=true` usa datos de prueba y `false` usa la API real (`VITE_API_URL`).

---

## 6. Flujos de punta a punta

**Pedir ayuda:**
1. El ciudadano pide ayuda en la app (`POST /solicitudes-ayuda`).
2. El job de IA la clasifica (prioridad y organización).
3. El admin de esa organización la ve en el panel, y un voluntario la toma en la app (`/asignar`).
4. El ciudadano ve "en proceso", y el voluntario la cierra.

**SOS:** el ciudadano mantiene el botón 3 s → la solicitud nace **crítica** y de rescate → SMS a sus contactos de emergencia → se enruta a la organización de rescate.

**Reporte:**
1. El ciudadano reporta un incidente con fotos.
2. La IA lo clasifica y se avisa por push a los voluntarios cercanos de la organización.
3. El admin lo verifica, lo rechaza o lo marca como duplicado. Verificado, pasa a ser público en el mapa.
4. Si nadie lo revisa en 72 h, queda `no_verificable`.

**Sismo:**
1. El feed del USGS trae un M5.2 cerca de Valledupar.
2. Se publica una alerta automática (círculo de 20 km) y se avisa por push a quien esté dentro.
3. A quienes estén en el círculo se les abre "¿Estás bien?" con 10 minutos para responder:
   - **"Estoy a salvo"**: queda registrado;
   - **"Necesito ayuda"**: se crea un SOS;
   - **sin respuesta**: se manda un SMS a sus contactos con la última ubicación.
4. El panel ve el resumen: a salvo, pidió ayuda o no respondió.

**Sin internet:** A (en modo avión) aprieta el SOS → el mensaje firmado pasa por Bluetooth a B y de B a C → C tiene datos y lo sube → el backend verifica la firma de A y crea su SOS (`mesh`) con el SMS.

**Persona desaparecida:**
1. Un familiar publica la ficha con la foto autorizada.
2. La comunidad la ve; si es menor, la foto queda protegida.
3. Cuando la marcan como encontrada, se avisa por push a quien la reportó.

---

## 7. Aspectos legales que el sistema cumple
- **Ley 1581 de 2012 (datos personales):**
  - consentimiento en el registro y para compartir la ubicación y publicar fotos;
  - "exportar mis datos" y "eliminar mi cuenta" (se anonimiza, y también se limpia en la auditoría);
  - retención de 30 días para las ubicaciones.
- **Ley 1098 de 2006 (infancia):** la foto de un menor desaparecido no es pública.
- **Desaparición forzada:** cada ficha trae el aviso del Mecanismo de Búsqueda Urgente (Ley 971 de 2005) y la indicación de que no hay que esperar 72 horas.
- **Sismos:** se dice que la fuente es pública (USGS/SGC) y que **no es una alerta temprana oficial**.
- **Donaciones:** la app no maneja dinero; solo registra.

---

## 8. Pendiente
1. **Firebase (Sergio):** proyecto, credenciales en `.env` y `firebase_messaging` en la app (registrar el token con `POST /usuarios/me/dispositivo`). Después, probar el push con teléfonos reales.
2. **Elkin:** conectar en el panel el dashboard, la auditoría, las alertas, las zonas, los centros, los desaparecidos y las donaciones.
3. **Mergear** las PR que quedan en orden y luego `develop → main`.
4. **Correo propio de RESCATE360** para la recuperación de contraseña (SMTP en `.env`).
5. **Opcional:**
   - respaldo por SMS entrante (Twilio webhook) para cuando hay señal pero no datos;
   - feed del Servicio Geológico Colombiano, si publica uno consumible.

---

## 9. Documentos relacionados
- `RESCATE360_pendientes_libardo.md`: tareas y estado por sprint.
- `RESCATE360_instrucciones_codex.md`: traspaso técnico detallado (arquitectura, reglas y tareas).
- `RESCATE360_mapa_offline_sismos.md`: diseño del mapa, los sismos y el modo sin conexión.
- `rescate360-be/docs/PLAN_BACKEND.md`: plan y reparto del backend.
- `rescate360-fe/docs/PRUEBA_MOVIL.md`: cómo probar en el celular, por túnel y la demo Bluetooth.
- `rescate360-fe/docs/CONEXION_TUNEL.md`: compartir la API con el equipo.
