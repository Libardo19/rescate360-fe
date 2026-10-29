# Probar con el API compartido por túnel

Una persona del equipo corre el backend en su PC y lo publica con un túnel de Cloudflare.
Los demás **no necesitan Docker ni el backend**: solo el frontend apuntando a esa URL.

```
[tu panel / tu app]  ──HTTPS──▶  https://xxxx.trycloudflare.com  ──▶  PC con el backend (API + BD + Redis + IA)
```

## Para los compañeros (panel y app)

Primero `git pull` de la rama, para recibir la URL actual del túnel.

**Panel web**
```bash
cd rescate360-web
npm ci              # solo la primera vez
npm run dev:tunel   # usa rescate360-web/.env.tunel
```
Abrir http://localhost:5173.

**App en Chrome**
```bash
flutter run -d chrome --dart-define-from-file=config/demo.json
```

**App en el celular** (en cualquier red, Wi-Fi o datos)
- Con el celular por USB: `flutter run --dart-define-from-file=config/demo.json`
- Sin cable: instalar el APK que comparte quien tiene el backend (ver `docs/PRUEBA_MOVIL.md`).

**Cuentas**
- Ciudadano: registrarse desde la app.
- Voluntario o administrador: pedirle un código de activación al administrador o al super admin, y activarlo en "Activa tu cuenta".
- Las credenciales del super admin se pasan por chat privado. Nunca van en el repo.

> Si sale "No hay conexión con el servidor", lo más probable es que la URL del túnel cambió: hay que hacer `git pull` otra vez.

## Para quien publica el backend

1. Levantar el backend (`docker compose up -d` en `rescate360-be`) y comprobar http://localhost:8000/health/ready.
2. Abrir el túnel y dejar la ventana abierta:
   ```powershell
   cloudflared tunnel --url http://localhost:8000
   ```
   Imprime una URL `https://xxxx.trycloudflare.com`.
3. Poner esa URL en el frontend y subirla:
   ```powershell
   .\scripts\usar-tunel.ps1 -Url https://xxxx.trycloudflare.com
   git add config/demo.json rescate360-web/.env.tunel
   git commit -m "chore: URL actual del túnel"
   git push
   ```
4. Avisar al equipo para que hagan `git pull`.

**Importante**
- La URL **cambia cada vez que se reinicia `cloudflared`**. Hay que repetir el paso 3.
- Mientras se prueba, la PC tiene que seguir prendida con Docker y el túnel abiertos.
- El backend debe tener `APP_ENV=local`, para aceptar el panel y la app de cada compañero desde su `localhost`.
- El APK lleva la URL **dentro**: si el túnel cambia, hay que volver a compilarlo.
- Para tener una URL fija hace falta un túnel con nombre (cuenta de Cloudflare y un dominio). El túnel rápido sirve para pruebas.
