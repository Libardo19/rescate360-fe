import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rescate360/features/auth/data/repositories/auth_repository.dart';
import 'package:rescate360/features/auth/presentation/views/bienvenida_screen.dart';
import 'package:rescate360/shared/models/usuario_model.dart';

/// Sin sesión guardada: la bienvenida muestra los botones.
class _RepoSinSesion implements AuthRepository {
  @override
  Future<UsuarioModel?> restaurarSesion() async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _cargarFuentes() async {
  final fuentes = '${Platform.environment['FLUTTER_ROOT'] ?? '../flutter'}/bin/cache/artifacts/material_fonts';
  Future<void> cargar(String familia, List<String> archivos) async {
    final loader = FontLoader(familia);
    for (final a in archivos) {
      loader.addFont(Future.value(ByteData.view(File('$fuentes/$a').readAsBytesSync().buffer)));
    }
    await loader.load();
  }

  await cargar('Roboto', ['roboto-regular.ttf', 'roboto-medium.ttf', 'roboto-bold.ttf']);
  await cargar('MaterialIcons', ['materialicons-regular.otf']);
}

void main() {
  setUpAll(_cargarFuentes);

  for (final (nombre, ancho, alto) in [('telefono', 360.0, 800.0), ('bajo', 360.0, 640.0)]) {
    testWidgets('bienvenida: $nombre', (tester) async {
      tester.view.physicalSize = Size(ancho * 3, alto * 3);
      tester.view.devicePixelRatio = 3;
      tester.view.padding = const FakeViewPadding(top: 72, bottom: 48);
      tester.view.viewPadding = const FakeViewPadding(top: 72, bottom: 48);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(_RepoSinSesion())],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
          home: const BienvenidaScreen(),
        ),
      ));
      // La imagen se decodifica fuera del reloj falso de las pruebas.
      await tester.runAsync(() async {
        await precacheImage(const AssetImage('assets/images/bienvenida.jpg'), tester.element(find.byType(BienvenidaScreen)));
      });
      // El logo tiene una animación que se repite: se avanza hasta después de la entrada
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
      expect(find.text('Iniciar sesión'), findsOneWidget);
      expect(find.text('Crear cuenta'), findsOneWidget);
    });
  }

  testWidgets('bienvenida: con "reducir movimiento" todo queda quieto', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(_RepoSinSesion())],
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
        home: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: BienvenidaScreen(),
        ),
      ),
    ));
    // Si el logo siguiera animándose en bucle, esto no terminaría nunca
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
