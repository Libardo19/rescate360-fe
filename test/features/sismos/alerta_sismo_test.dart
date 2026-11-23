import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rescate360/core/location/location_service.dart';
import 'package:rescate360/features/check_in/data/models/check_in_model.dart';
import 'package:rescate360/features/check_in/data/repositories/check_in_repository.dart';
import 'package:rescate360/features/sismos/presentation/views/alerta_sismo_screen.dart';

/// Repositorio falso: un "¿Estás bien?" pendiente que vence en 10 minutos y registra la respuesta.
class _RepoFalso implements CheckInRepository {
  final respuestas = <bool>[];
  final CheckInModel _pendiente = CheckInModel(
    id: 'c1',
    motivo: 'sismo',
    estado: 'pendiente',
    venceEn: DateTime.now().add(const Duration(minutes: 10)),
    creadoEn: DateTime.now(),
  );

  @override
  Future<CheckInModel?> pendiente() async => respuestas.isEmpty ? _pendiente : null;

  @override
  Future<CheckInModel> responder(String id, {required bool aSalvo, double? lat, double? lng}) async {
    respuestas.add(aSalvo);
    return _pendiente;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// GPS falso: siempre en Valledupar.
class _GpsFalso extends LocationService {
  @override
  Future<({double lat, double lng})> ubicacionActual() async => (lat: 10.47, lng: -73.25);
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

  await cargar('Roboto', ['roboto-regular.ttf', 'roboto-medium.ttf', 'roboto-bold.ttf', 'roboto-black.ttf']);
  await cargar('MaterialIcons', ['materialicons-regular.otf']);
}

Future<_RepoFalso> _abrir(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final repo = _RepoFalso();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      checkInRepositoryProvider.overrideWithValue(repo),
      locationServiceProvider.overrideWithValue(_GpsFalso()),
    ],
    child: MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const AlertaSismoScreen(
                  titulo: 'SISMO FUERTE de magnitud 6.4',
                  mensaje: '10 km N de Valledupar, Colombia.',
                ),
              )),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('abrir'));
  // Las ondas se repiten sin fin: se avanza a mano hasta que termine la entrada
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  return repo;
}

void main() {
  setUpAll(_cargarFuentes);

  testWidgets('la alerta SOS pregunta "¿Estás bien?" con la cuenta regresiva', (tester) async {
    await _abrir(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('¿Estás bien?'), findsOneWidget);
    expect(find.text('SISMO FUERTE de magnitud 6.4'), findsOneWidget);
    expect(find.textContaining('enviaremos tu SOS automáticamente'), findsOneWidget);
    expect(find.textContaining(RegExp(r'^(09|10):\d\d$')), findsOneWidget);
    expect(AlertaSismoScreen.abierta, isTrue);
  });

  testWidgets('"Sí, estoy bien" responde a salvo y cierra la alerta', (tester) async {
    final repo = await _abrir(tester);
    await tester.tap(find.text('Sí, estoy bien'));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(repo.respuestas, [true]);
    expect(find.text('¿Estás bien?'), findsNothing);
    expect(AlertaSismoScreen.abierta, isFalse);
  });

  testWidgets('"No, necesito ayuda" pide el SOS por el "¿Estás bien?"', (tester) async {
    final repo = await _abrir(tester);
    await tester.tap(find.text('No, necesito ayuda'));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(repo.respuestas, [false]);
  });
}
