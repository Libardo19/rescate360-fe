import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rescate360/core/location/location_service.dart';
import 'package:rescate360/features/alertas/data/models/alerta_model.dart';
import 'package:rescate360/features/alertas/presentation/viewmodels/alertas_viewmodel.dart';
import 'package:rescate360/features/home/presentation/views/home_screen.dart';
import 'package:rescate360/features/home/presentation/widgets/barra_ciudadano.dart';
import 'package:rescate360/features/mapa/data/models/marcador_mapa_model.dart';
import 'package:rescate360/features/mapa/data/repositories/mapa_repository.dart';
import 'package:rescate360/features/mapa/presentation/viewmodels/mapa_viewmodel.dart';

class _RepoMapa implements MapaRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Ubicacion implements LocationService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// El mismo estado que tendría el mapa en vivo, sin GPS ni red.
class _MapaFijo extends MapaViewModel {
  _MapaFijo(MapaState estado) : super(_RepoMapa(), _Ubicacion()) {
    state = estado;
  }

  @override
  Future<void> iniciar() async {}

  @override
  Future<void> iniciarSiHaceFalta() async {}

  @override
  Future<void> recargar() async {}
}

MarcadorMapaModel _punto(String id, String capa, double lat, double lng) => MarcadorMapaModel(
      id: id,
      capa: capa,
      tipo: capa,
      titulo: 'Punto $id',
      detalle: '',
      estado: 'pendiente',
      lat: lat,
      lng: lng,
      aproximada: false,
      propio: false,
      activo: true,
    );

AlertaModel _alerta(String id) => AlertaModel(
      id: id,
      titulo: 'Alerta $id',
      tipo: 'inundacion',
      mensaje: '',
      nivel: NivelAlerta.values.first,
      estado: 'activa',
      origen: 'manual',
      lat: 10.46,
      lng: -73.25,
      radioM: 1000,
      creadaEn: DateTime(2026, 11, 9),
      expiraEn: DateTime(2026, 11, 10),
    );

const _conUbicacion = MapaState(
  posicion: (lat: 10.4631, lng: -73.2532),
  cargando: false,
);

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

Widget _app({required MapaState mapa, double escalaTexto = 1, VoidCallback? onAbrirMapa}) {
  return ProviderScope(
    overrides: [
      mapaViewModelProvider.overrideWith((ref) => _MapaFijo(mapa)),
      alertasProvider.overrideWith((ref) async => AlertasData(enMiZona: [_alerta('a'), _alerta('b')], todas: const [])),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
      home: MediaQuery.withClampedTextScaling(
        minScaleFactor: escalaTexto,
        maxScaleFactor: escalaTexto,
        child: Scaffold(
          body: HomeScreen(nombreUsuario: 'Oscar', onAbrirMapa: onAbrirMapa ?? () {}),
          bottomNavigationBar: BarraCiudadano(indice: 0, onTap: (_) {}),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // El mapa guarda sus teselas en caché: en las pruebas se le da una carpeta temporal
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => Directory.systemTemp.path,
    );
    await _cargarFuentes();
  });

  final conPuntos = _conUbicacion.copyWith(puntos: {
    for (final p in [
      _punto('r1', 'reporte', 10.466, -73.257),
      _punto('r2', 'reporte', 10.4605, -73.2490),
      _punto('s1', 'solicitud', 10.4660, -73.2475),
      _punto('c1', 'centro', 10.4590, -73.2560),
      _punto('z1', 'zona', 10.4680, -73.2520),
    ])
      p.id: p,
  });

  for (final (nombre, ancho, alto, escala) in [
    ('telefono', 390.0, 844.0, 1.0),
    ('pequeno_letra_grande', 360.0, 760.0, 1.3),
  ]) {
    testWidgets('inicio del ciudadano: $nombre sin desbordes', (tester) async {
      tester.view.physicalSize = Size(ancho * 3, alto * 3);
      tester.view.devicePixelRatio = 3;
      tester.view.padding = const FakeViewPadding(top: 72, bottom: 48);
      tester.view.viewPadding = const FakeViewPadding(top: 72, bottom: 48);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app(mapa: conPuntos, escalaTexto: escala));
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      expect(find.text('Hola, Oscar'), findsOneWidget);
      // Números reales: 2 alertas, 2 incidentes y 1 centro de los puntos del mapa
      expect(find.text('Hay 2 alertas activas en tu zona'), findsOneWidget);
      expect(find.textContaining('2 incidentes'), findsOneWidget);
    });
  }

  testWidgets('la vista previa del mapa y la búsqueda abren la pestaña Mapa', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    var abiertas = 0;
    await tester.pumpWidget(_app(mapa: conPuntos, onAbrirMapa: () => abiertas++));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.bySemanticsLabel('Buscar incidentes, personas y lugares en el mapa'));
    await tester.tap(find.text('Ver mapa'));
    await tester.ensureVisible(find.text('Mapa de incidentes cercanos'));
    await tester.tap(find.text('Mapa de incidentes cercanos'));
    expect(abiertas, 3);
  });

  testWidgets('sin ubicación la vista previa lo explica y deja reintentar', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(
      mapa: const MapaState(cargando: false, error: 'Activa el GPS para ver el mapa.'),
    ));
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
    expect(find.text('Activa el GPS para ver el mapa.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    // Sin ubicación no se inventan números: incidentes y centros quedan en "–"
    expect(find.text('–'), findsAtLeastNWidgets(2));
    expect(find.text('0'), findsNothing);
  });
}
