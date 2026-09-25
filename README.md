# RESCATE360 — App móvil (Flutter)

Plataforma de apoyo y coordinación comunitaria ante emergencias. Este repositorio contiene la **app móvil** para Android e iOS, que consume la API de [rescate360-be](https://github.com/Libardo19/rescate360-be).

> RESCATE360 es una herramienta de apoyo comunitario. **No sustituye** a los organismos oficiales de atención de emergencias. En caso de riesgo vital: línea **123**.

Universidad Popular del Cesar · Ingeniería de Software II
Equipo: Libardo José Acosta García, Sergio Eli Saucedo, Oscar Javier Ávila Ovallos

> **Estado:** solo estructura de carpetas y archivos vacíos. Todavía no hay código. Las carpetas `android/`, `ios/` y el `pubspec.yaml` se generan con `flutter create --org co.rescate360 --project-name rescate360 .` cuando arranque el desarrollo.

---

## Stack

| Pieza | Tecnología |
|---|---|
| Lenguaje / framework | Dart + **Flutter** (una sola base para Android e iOS) |
| Arquitectura | **MVVM** por feature (`data/` + `presentation/viewmodels` + `presentation/views`) |
| Estado | `flutter_riverpod` |
| HTTP | `dio` (REST/JSON) |
| Almacenamiento local | `drift` o `sqflite` (cola offline y caché) + `flutter_secure_storage` (JWT) |
| Mapa y ubicación | `google_maps_flutter` + `geolocator` |
| Notificaciones | `firebase_messaging` |
| Contingencia sin conexión | `connectivity_plus`, `workmanager`, `telephony` (SMS Android), `nearby_connections` |
| Otros | `image_picker`, `intl` |

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
