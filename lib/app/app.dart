import 'package:flutter/material.dart';
import 'router.dart';
import 'theme/app_theme.dart';

/// Widget raíz de la aplicación RESCATE360.
class RescateApp extends StatelessWidget {
  const RescateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RESCATE360',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro,
      themeMode: ThemeMode.light,
      initialRoute: AppRouter.inicial,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
