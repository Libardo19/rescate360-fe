import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/perfil/presentation/viewmodels/ajustes_viewmodel.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'theme/modo_oscuro.dart';

/// Widget raíz de la aplicación RESCATE360.
/// Aplica el idioma y el modo oscuro elegidos en Configuración.
class RescateApp extends ConsumerWidget {
  const RescateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ajustes = ref.watch(ajustesProvider);

    return MaterialApp(
      title: 'RESCATE360',
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
