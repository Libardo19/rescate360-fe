# Prueba desde teléfonos físicos

> Cómo publicar el API con un túnel y cómo se conectan los compañeros: ver `docs/CONEXION_TUNEL.md`.

La app se conecta al API por HTTPS y el API consulta PostgreSQL. El teléfono nunca
se conecta directamente a PostgreSQL. `10.0.2.2` solo sirve para el emulador Android;
`localhost` en un teléfono apunta al propio teléfono.

## APK para el equipo

La configuración compartida está en `config/demo.json`; contiene una URL pública,
sin claves ni contraseñas. Desde la raíz del repo:

```powershell
.\scripts\compilar-apk.ps1
```

El script comprueba HTTPS y `/health/ready` antes de compilar. Compartir el archivo
`build/app/outputs/flutter-apk/app-release.apk`. Instalar esta compilación sobre
la anterior y probar registro/login con una cuenta de prueba propia. Comprobar
tanto Wi-Fi como datos móviles. No hace falta conectar el teléfono por USB.

Para ejecutar desde Flutter con el mismo API:

```bash
flutter run --dart-define-from-file=config/demo.json
```

Cambiar `.env` no modifica un APK ya instalado: la URL se incorpora al compilar.
No compilar el APK compartido sin `--dart-define-from-file`; el valor por defecto
de desarrollo es el emulador. Los builds release mantienen HTTPS obligatorio.

## Alcance de la conexión temporal

La URL de `config/demo.json` es un túnel de pruebas de Cloudflare hacia el PC de
Libardo. Funciona desde cualquier red con acceso a Internet mientras permanezcan
encendidos el PC, Docker, API, worker y cloudflared. No es un despliegue permanente.
Si se reinicia el túnel cambia la URL: actualizar el JSON y volver a compilar e instalar.

Para revisar la conexión, abrir la URL de `API_BASE_URL` seguida de `/health/ready`
desde el navegador del teléfono. Debe mostrar `status: ok`, PostGIS y Redis.

## Panel web y datos

El panel usa el API real por defecto. Para apuntarlo al mismo entorno, crear
`rescate360-web/.env.local` con:

```dotenv
VITE_API_URL=https://tackle-pac-momentum-redhead.trycloudflare.com
VITE_USE_MOCK=false
```

Reiniciar Vite después del cambio. Los administradores deben ingresar con su cuenta
de administrador; el registro móvil crea ciudadanos. Reportes y solicitudes se
guardan en la misma base y se listan según el rol y la organización asignada.
La IA clasifica de forma asíncrona: refrescar los listados unos segundos después.
`VITE_USE_MOCK=true` se reserva para trabajar explícitamente con datos simulados.

La comprobación de backend está en `scripts/probar_ia_real.py` de rescate360-be:
valida registro/login/perfil, Gemini en el worker, SOS, idempotencia, prioridad
manual y los endpoints de listados y mapa. Los casos sintéticos llevan `PRUEBA IA`.

## Modo sin conexión: relevo por Bluetooth (prueba de concepto, solo Android)

Hacen falta 3 teléfonos Android con la app instalada y la sesión iniciada **una vez con internet**. En ese momento la app guarda la llave para firmar mensajes.

1. En los 3: **Más → Configuración → Modo sin conexión → "Ayudar a pasar mensajes por Bluetooth"**. Acepta los permisos de Bluetooth, dispositivos cercanos y ubicación.
2. Pon **A** y **B** en modo avión, pero con el **Bluetooth encendido**. **C** queda con datos.
3. En **A**: mantén presionado el SOS. Sale "Sin internet: tu SOS se guardó y se está pasando por Bluetooth".
4. Acerca **A** a **B** (0–10 m), y después **B** a **C**. Cada salto suma 1 y el máximo es 8.
5. **C** lo sube solo a `POST /offline/relevo`. El backend verifica la firma de A, crea el SOS con `origen = mesh` y manda el SMS a los contactos de emergencia de A.

Para el "¿Estás bien?" el flujo es el mismo: si A responde sin red, la respuesta viaja igual.

**Limitaciones:**
- solo Android, porque Nearby no habla con iOS;
- los teléfonos intermedios deben tener la app abierta y el modo activo;
- gasta batería.

## Celular físico contra el backend de tu PC (misma Wi-Fi)

1. Backend arriba: `docker compose up -d` en `rescate360-be`. Si el registro da "error interno", revisar `docker compose logs api`: una columna que falta se arregla con `docker compose exec api alembic upgrade head`.
2. Una sola vez, en PowerShell **como administrador**: `.\scripts\abrir-puerto-api.ps1`. Abre el puerto 8000 solo para la red local. Sin esto, el celular muestra "No hay conexión".
3. Conectar el celular por USB (depuración USB activada) y ejecutar: `.\scripts\correr-celular.ps1`. Detecta la IP de la PC y corre `flutter run --dart-define=API_BASE_URL=http://<IP>:8000`.

Si Gradle se cierra solo al compilar, es por falta de memoria: `android/gradle.properties` usa `-Xmx2G` para equipos de 8 a 16 GB de RAM. Conviene cerrar Chrome y los emuladores mientras compila.
