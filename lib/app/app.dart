import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/push_notification_service.dart';
import '../features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../features/perfil/presentation/viewmodels/ajustes_viewmodel.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'theme/modo_oscuro.dart';

/// Widget ra��z de la aplicaci��n RESCATE360.
/// Aplica el idioma y el modo oscuro elegidos en Configuraci��n.
class RescateApp extends ConsumerStatefulWidget {
  const RescateApp({super.key});

  @override
  ConsumerState<RescateApp> createState() => _RescateAppState();
}

class _RescateAppState extends ConsumerState<RescateApp> {
  @override
  void initState() {
    super.initState();
    PushNotificationService()
      ..alRecibirAlerta = _alRecibirAlerta
      ..initialize();
  }

  /// Push de alerta: la urgente (sismo muy fuerte y estoy en la zona) abre la alerta SOS a
  /// pantalla completa; la informativa (estoy lejos) se muestra como aviso o abre las alertas.
  void _alRecibirAlerta({required bool urgente, required bool abrio, required String titulo, required String cuerpo}) {
    final navegador = AppRouter.navigatorKey.currentState;
    if (navegador == null || !ref.read(authViewModelProvider).autenticado) return;
    if (urgente) {
      navegador.pushNamed(AppRouter.alertaSismo, arguments: {'titulo': titulo, 'mensaje': cuerpo});
    } else if (abrio) {
      navegador.pushNamed(AppRouter.alertas);
    } else {
      ScaffoldMessenger.maybeOf(navegador.context)?.showSnackBar(SnackBar(
        duration: const Duration(seconds: 8),
        content: Text('$titulo · $cuerpo'),
        action: SnackBarAction(label: 'Ver', onPressed: () => navegador.pushNamed(AppRouter.alertas)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ajustes = ref.watch(ajustesProvider);

    // Al cerrar sesión (o si vence y no se puede renovar) se vuelve a la bienvenida
    ref.listen<AuthState>(authViewModelProvider, (antes, ahora) {
      if ((antes?.autenticado ?? false) && !ahora.autenticado) {
        AppRouter.navigatorKey.currentState
            ?.pushNamedAndRemoveUntil(AppRouter.inicial, (_) => false);
      }
    });

    return MaterialApp(
      title: 'RESCATE360',
      navigatorKey: AppRouter.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro,
      themeMode: ThemeMode.light,
      locale: Locale(ajustes.idioma),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final sistemaOscuro =
            MediaQuery.platformBrightnessOf(context) == Brightness.dark;
        final oscuro = switch (ajustes.modoTema) {
          ModoTema.claro => false,
          ModoTema.oscuro => true,
          ModoTema.sistema => sistemaOscuro,
        };
        final contenido = child ?? const SizedBox.shrink();

        return EstadoOscuro(
          oscuro: oscuro,
          child: oscuro
              ? ColorFiltered(
                  colorFilter: filtroModoOscuro,
                  child: contenido,
                )
              : contenido,
        );
      },
      initialRoute: AppRouter.inicial,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
