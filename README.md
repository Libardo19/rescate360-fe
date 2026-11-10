# RESCATE360 — App móvil (Flutter)

Plataforma de apoyo y coordinación comunitaria ante emergencias. Este repositorio contiene la **app móvil** para Android e iOS, que consume la API de [rescate360-be](https://github.com/Libardo19/rescate360-be).

> RESCATE360 es una herramienta de apoyo comunitario. **No sustituye** a los organismos oficiales de atención de emergencias. En caso de riesgo vital: línea **123**.

Universidad Popular del Cesar · Ingeniería de Software II
Equipo: Libardo José Acosta García, Sergio Eli Saucedo, Oscar Javier Ávila Ovallos

> **Estado:** ambiente listo (dependencias, permisos Android/iOS, variables de entorno). Pantallas de bienvenida, login, registro e inicio en progreso.

---

## Stack

| Pieza | Tecnología |
|---|---|
| Lenguaje / framework | Dart + **Flutter** (una sola base para Android e iOS) |
| Arquitectura | **MVVM** por feature (`data/` + `presentation/viewmodels` + `presentation/views`) |
| Estado | `flutter_riverpod` |
| HTTP | `dio` (REST/JSON) |
| Almacenamiento local | `sqflite` (cola offline y caché) + `flutter_secure_storage` (JWT) |
| Mapa y ubicación | `flutter_map` + OpenStreetMap + `geolocator` |
| Notificaciones | `firebase_messaging` (semana 4) |
| Contingencia sin conexión | `connectivity_plus`; `workmanager`, SMS y `nearby_connections` en la semana 7 |
| Otros | `image_picker`, `url_launcher`, `intl`, `uuid` |

## Ambiente de desarrollo

**Pruebas del equipo en teléfonos (Wi-Fi o datos móviles):** ver
[docs/PRUEBA_MOVIL.md](docs/PRUEBA_MOVIL.md). Compilar con
`scripts/compilar-apk.ps1` para incluir la URL HTTPS de `config/demo.json`.

> Guía paso a paso (backend + app) para montar el proyecto en tu PC: [AMBIENTACION.md](https://github.com/Libardo19/rescate360-be/blob/main/docs/AMBIENTACION.md).

La app **no corre en Docker**: se ejecuta en un emulador o celular con el SDK de Flutter instalado en el PC. En Docker solo va el backend ([rescate360-be](https://github.com/Libardo19/rescate360-be)).

Probado con **Flutter 3.44.9 / Dart 3.12.2** y Android SDK 36.

```bash
cp .env.example .env
flutter pub get
flutter run --dart-define-from-file=.env
```

- `.env` se lee en `lib/core/config/env.dart` (`API_BASE_URL`, `MAP_TILE_URL`, `EMERGENCY_LINE`). No guardar secretos ahí: todo lo que va en la app se puede extraer del APK.
- **API local:** con el backend arriba (`docker compose up -d`), el emulador Android llega a tu PC por `http://10.0.2.2:8000`. En un celular físico usa la IP de tu PC en la red (ej. `http://192.168.1.10:8000`).
- `http://` sin HTTPS solo está permitido en el build **debug** (`android/app/src/debug/AndroidManifest.xml`).
- **Permisos ya declarados:** Internet, ubicación (Android y iOS), cámara y galería (iOS), y abrir el marcador para llamar al 123.

### Mapa: `flutter_map` + OpenStreetMap

- **Sin API key ni tarjeta de crédito** (Google Maps exige cuenta de facturación en Google Cloud).
- Las teselas son configurables (`MAP_TILE_URL`), así que se puede cambiar de proveedor sin tocar código. También permite guardarlas en caché para usar el mapa **sin conexión**, algo importante en una emergencia.
- Usa `latlong2` → `LatLng(lat, lng)`. **Ojo:** GeoJSON/PostGIS devuelven `[lng, lat]`, al revés. Convertir en `data/models`.
- Los servidores públicos de OpenStreetMap son para desarrollo. Hay que configurar `userAgentPackageName` en el `TileLayer`, y en producción usar un proveedor (MapTiler, Stadia, etc.) o un servidor propio.

### Dependencias (`pubspec.yaml`)

| Paquete | Uso |
|---|---|
| `flutter_riverpod` 2.x | Estado (los viewmodels ya existentes usan la API 2.x; la 3.x queda para después) |
| `dio` | HTTP hacia la API |
| `flutter_map` + `latlong2` | Mapa de emergencia |
| `geolocator` | GPS |
| `flutter_secure_storage` | Token JWT |
| `sqflite` | Cola offline y caché local |
| `connectivity_plus` | Detectar si hay red |
| `image_picker` | Fotos de evidencia |
| `url_launcher` | Llamar al 123 y "Cómo llegar" |
| `intl` | Fechas y formatos |
| `uuid` | UUID generado en el dispositivo (deduplicación offline) |

**Se agregan más adelante**, porque necesitan configuración previa:
- `firebase_core` + `firebase_messaging` (semana 4): requieren crear el proyecto de Firebase y correr `flutterfire configure`.
- `workmanager`, SMS y `nearby_connections` (semana 7). `nearby_connections` **solo funciona en Android**, y el paquete `telephony` está sin mantenimiento. Hay que evaluar alternativas cuando se llegue ahí.

## Estructura

```
rescate360-fe/
├── lib/
│   ├── main.dart
│   ├── app/                        # App, router y tema (colores, tipografías)
│   ├── core/
│   │   ├── config/                 # Variables de entorno y constantes
│   │   ├── network/                # Cliente dio, endpoints e interceptores (JWT, errores)
│   │   ├── storage/                # Secure storage (token) y base local
│   │   ├── offline/                # Cola offline, sync worker, SMS de respaldo, nearby mesh, conectividad
│   │   ├── location/               # GPS
│   │   ├── notifications/          # Push (FCM)
│   │   ├── permissions/            # Ubicación, cámara, notificaciones
│   │   ├── media/                  # Selección de fotos
│   │   ├── errors/
│   │   └── utils/
│   ├── shared/
│   │   ├── models/                 # Usuario, rol
│   │   └── widgets/                # Aviso legal, badge de prioridad, bottom nav, etc.
│   └── features/<feature>/
│       ├── data/
│       │   ├── models/
│       │   ├── datasources/        # Llamadas a la API
│       │   └── repositories/
│       └── presentation/
│           ├── viewmodels/         # Riverpod
│           ├── views/              # Pantallas (*_screen.dart)
│           └── widgets/
├── assets/                         # images, icons, fonts
├── test/                           # Unitarias y de widgets
├── integration_test/               # Flujos completos
├── docs/
└── .github/workflows/              # CI
```

## Features y pantallas (según mockups)

| Feature | Pantallas | Iteración |
|---|---|---|
| `auth` | Bienvenida ("Juntos somos más fuertes"), Iniciar sesión, Crear cuenta (con autorización de datos) | MVP |
| `home` | Inicio: saludo, alerta destacada, accesos rápidos, alertas recientes | MVP |
| `mapa` | Mapa de emergencia con filtros (todos / zonas peligrosas / centros) y centro cercano | MVP |
| `reportes` | Reportar incidente (tipo, descripción 0/500, ubicación, fotos), Mis reportes, Detalle | MVP |
| `solicitudes_ayuda` | Solicitar ayuda (necesidad, descripción, **prioridad sugerida por IA**), Mis solicitudes, Detalle | MVP |
| `alertas` | Alertas y notificaciones | MVP |
| `centros_ayuda` | Centros de ayuda (búsqueda, filtros por recurso, distancia), Detalle, Guardados | MVP |
| `admin` | Panel, Verificar reportes, Revisar prioridades de IA, Gestionar usuarios | MVP |
| `personas_desaparecidas` | Lista/mapa, Registrar persona, Detalle | 2ª iteración |
| `zonas_peligrosas` | Zonas peligrosas | 2ª iteración |
| `donaciones` | Donaciones y necesidades | 2ª iteración |
| `guia_emergencia` | Guía (antes, durante y después), Detalle | 2ª iteración |
| `perfil` | Más, Mi perfil, Contactos de emergencia, Configuración, Ayuda, Privacidad de datos | MVP |

Navegación inferior: **Inicio · Mapa · Reportes · Más**.

## Modo sin conexión (`core/offline/`)

1. Todo reporte o solicitud se guarda primero en la cola local, con un UUID generado en el dispositivo.
2. `sync_worker` reintenta en segundo plano y envía el lote a `POST /offline/sync`.
3. Sin datos móviles: SMS directo (Android) o composer asistido (iOS).
4. Sin señal: intercambio con dispositivos cercanos (`nearby_mesh`). Es una **prueba de concepto**, no una red mesh completa.

## Requisitos legales que afectan a la app

- **Aviso visible** en el inicio y en el registro: no sustituye organismos oficiales; ante riesgo vital, llamar al 123 (`shared/widgets/disclaimer_banner.dart`).
- **Autorización de datos** con checkbox sin marcar al registrarse (Ley 1581/2012), en `consentimiento_datos_checkbox.dart`.
- **Permisos explicados antes de pedirlos**: ubicación, cámara y galería.
- **Consentimiento adicional** antes de publicar la foto de una persona identificable. Si es menor de edad, lo da un adulto responsable (Ley 1098/2006).
- **Personas desaparecidas**: aviso de que los casos de posible desaparición forzada se reportan a la Fiscalía, la Policía o Medicina Legal (SIRDEC), en `aviso_desaparicion_forzada.dart`.
- **IA**: mostrar que la prioridad es solo una sugerencia y que un administrador la revisa (`prioridad_ia_card.dart`).
- **Ubicación**: a otros ciudadanos solo se les muestra un punto aproximado.
- **Accesibilidad** (Ley 1618/2013, WCAG AA): contraste, texto escalable, etiquetas para lectores de pantalla, desde el MVP.

## Roadmap (8 semanas)

| Semana | Entregable |
|---|---|
| 1 | Esqueleto, navegación, login/registro |
| 2 | Mapa de emergencia + reportar incidente |
| 3 | Solicitar ayuda + seguimiento |
| 4 | Panel admin básico + alertas — **cierre MVP** |
| 5 | Personas desaparecidas + zonas peligrosas |
| 6 | Donaciones + guía de emergencia — **cierre 2ª iteración** |
| 7 | Cola offline + prototipo Nearby Connections |
| 8 | Pruebas integrales, accesibilidad, documentación y pitch |
