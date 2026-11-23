# Prueba desde teléfonos físicos

La app se conecta al API por HTTPS y el API consulta PostgreSQL. El teléfono nunca
se conecta directamente a PostgreSQL. `10.0.2.2` solo sirve para el emulador Android;
`localhost` en un teléfono apunta al propio teléfono.

## APK para el equipo

La configuración compartida está en `config/demo.json`; contiene una URL pública,
sin claves ni contraseñas. Desde la raíz del repo:

```powershell
.\scripts\compilar-apk.ps1
```

El script comprueba HTTPS y `/health/ready`, compila en release con ofuscación y
genera un APK por arquitectura en `build/app/outputs/flutter-apk/app-*-release.apk`.
Compartir el APK correspondiente al teléfono (`arm64-v8a` en la mayoría de los
dispositivos recientes) o todos. Conservar `build/symbols`: permite leer stack
traces de la app ofuscada; no subirlo al repo. `minifyEnabled` y `shrinkResources`
ya están activos en `android/app/build.gradle.kts`. Instalar sobre la anterior y
probar registro/login con una cuenta de prueba propia, en Wi-Fi y datos móviles.

Para ejecutar desde Flutter con el mismo API:

```bash
flutter run --dart-define-from-file=config/demo.json
```

Cambiar `.env` no modifica un APK ya instalado: la URL se incorpora al compilar.
No compilar el APK compartido sin `--dart-define-from-file`; el valor por defecto
de desarrollo es el emulador. Los builds release mantienen HTTPS obligatorio.

## API en Azure

`config/demo.json` ya trae el FQDN de Azure desplegado
(`https://rescate360-api.agreeabletree-830cccf5.westus2.azurecontainerapps.io`).
Si se redepliega en otra suscripción, actualizar la URL con el FQDN que imprime
`deploy.ps1` en el backend, volver a compilar e instalar. No hace falta tener el PC
encendido: la API, PostgreSQL y Redis viven en Azure.

Para revisar la conexión, abrir la URL de `API_BASE_URL` seguida de `/health/ready`
desde el navegador del teléfono. Debe mostrar `status: ok`, PostGIS y Redis.

## Panel web y datos

El panel usa el API real por defecto. Para apuntarlo al mismo entorno, definir las
variables antes de compilar o de arrancar Vite:

```powershell
$env:VITE_API_URL = 'https://rescate360-api.<region>.azurecontainerapps.io'
$env:VITE_USE_MOCK = 'false'
```

No crear `rescate360-web/.env.local`: no está ignorado por Git. Los administradores deben ingresar con su cuenta
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
