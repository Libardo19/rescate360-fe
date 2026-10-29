import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rescate360/features/auth/data/repositories/auth_repository.dart';
import 'package:rescate360/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:rescate360/features/solicitudes_ayuda/data/models/solicitud_ayuda_model.dart';
import 'package:rescate360/features/voluntario/presentation/viewmodels/voluntario_viewmodel.dart';
import 'package:rescate360/features/voluntario/presentation/views/inicio_voluntario_screen.dart';
import 'package:rescate360/features/voluntario/presentation/widgets/barra_voluntario.dart';
import 'package:rescate360/shared/models/rol.dart';
import 'package:rescate360/shared/models/usuario_model.dart';

class _RepoNulo implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

SolicitudAyudaModel _caso(String id) => SolicitudAyudaModel(
      id: id,
      tipo: 'medica',
      origen: 'manual',
      descripcion: 'Caso de prueba',
      lat: 10.46,
      lng: -73.25,
      estado: 'pendiente',
      prioridad: 'alta',
      creadoEn: DateTime(2026, 10, 29),
    );

/// Carga Roboto y los íconos de Material del SDK para que las capturas se vean reales
/// (sin esto, flutter_test dibuja cada letra como un bloque).
Future<void> _cargarFuentes() async {
  final fuentes = '${Platform.environment['FLUTTER_ROOT'] ?? '../flutter'}/bin/cache/artifacts/material_fonts';
  Future<void> cargar(String familia, List<String> archivos) async {
    final loader = FontLoader(familia);
    for (final a in archivos) {
      final bytes = File('$fuentes/$a').readAsBytesSync();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
  }

  await cargar('Roboto', ['roboto-regular.ttf', 'roboto-medium.ttf', 'roboto-bold.ttf', 'roboto-black.ttf']);
  await cargar('MaterialIcons', ['materialicons-regular.otf']);
}

Widget _app({double escalaTexto = 1}) {
  final auth = AuthViewModel(_RepoNulo())
    ..actualizarUsuario(const UsuarioModel(id: 'u1', nombre: 'Carlos Díaz', correo: 'c@demo.co', rol: Rol.voluntario));
  return ProviderScope(
    overrides: [
      authViewModelProvider.overrideWith((ref) => auth),
      casosOrganizacionProvider.overrideWith((ref) async => [_caso('a'), _caso('b'), _caso('c')]),
      misTareasProvider.overrideWith((ref) async => []),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
      home: MediaQuery.withClampedTextScaling(
        minScaleFactor: escalaTexto,
        maxScaleFactor: escalaTexto,
        child: Scaffold(body: InicioVoluntarioScreen(onIrAPestana: (_) {})),
      ),
    ),
  );
}

void main() {
  setUpAll(_cargarFuentes);

  for (final (nombre, ancho, alto, escala) in [
    ('telefono', 390.0, 844.0, 1.0),
    ('pequeno_letra_grande', 360.0, 780.0, 1.3),
  ]) {
    testWidgets('inicio del voluntario: $nombre sin desbordes', (tester) async {
      tester.view.physicalSize = Size(ancho * 3, alto * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app(escalaTexto: escala));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Hola, Carlos'), findsOneWidget);
      expect(find.text('3'), findsOneWidget); // incidentes
      expect(find.text('0'), findsOneWidget); // asignaciones activas
    });
  }

  testWidgets('barra inferior: el botón de ubicación abre el mapa', (tester) async {
    // Teléfono Android típico: 360×800 dp con barra de estado y barra de gestos.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    tester.view.padding = const FakeViewPadding(top: 72, bottom: 48);
    tester.view.viewPadding = const FakeViewPadding(top: 72, bottom: 48);
    addTearDown(tester.view.reset);

    var indice = 0;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith((ref) => AuthViewModel(_RepoNulo())
          ..actualizarUsuario(const UsuarioModel(id: 'u1', nombre: 'Carlos', correo: 'c@demo.co', rol: Rol.voluntario))),
        casosOrganizacionProvider.overrideWith((ref) async => [_caso('a'), _caso('b'), _caso('c')]),
        misTareasProvider.overrideWith((ref) async => []),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: indice == 2
                ? const Center(child: Text('MAPA'))
                : InicioVoluntarioScreen(onIrAPestana: (i) => setState(() => indice = i)),
            bottomNavigationBar: BarraVoluntario(indice: indice, onTap: (i) => setState(() => indice = i)),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.bySemanticsLabel('Mapa'));
    await tester.pumpAndSettle();
    expect(indice, 2);
    expect(find.text('MAPA'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('inicio del voluntario: costo de construir y pintar', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final reloj = Stopwatch()..start();
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    reloj.stop();

    // Un frame en reposo (sin animaciones pendientes) no debería reconstruir nada caro.
    final frame = Stopwatch()..start();
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    frame.stop();
    // ignore: avoid_print
    print('primer render + entrada: ${reloj.elapsedMilliseconds} ms · '
        '60 frames en reposo: ${frame.elapsedMilliseconds} ms '
        '(${(frame.elapsedMicroseconds / 60 / 1000).toStringAsFixed(2)} ms/frame)');
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
