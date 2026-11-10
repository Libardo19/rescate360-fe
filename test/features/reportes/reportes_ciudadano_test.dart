import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rescate360/features/reportes/data/models/reporte_model.dart';
import 'package:rescate360/features/reportes/presentation/viewmodels/reportes_viewmodel.dart';
import 'package:rescate360/features/reportes/presentation/views/detalle_reporte_screen.dart';
import 'package:rescate360/features/reportes/presentation/views/mis_reportes_screen.dart';

ReporteCiudadano _reporte(
  String id, {
  String tipo = 'incendio',
  bool esMio = false,
  EstadoReporteCiudadano estado = EstadoReporteCiudadano.verificado,
  List<String> fotos = const [],
  String? motivoRechazo,
}) =>
    ReporteCiudadano(
      id: id,
      tipo: tipo,
      descripcion: 'Descripción del reporte $id con suficiente texto para ocupar dos líneas en la tarjeta.',
      fecha: DateTime.now().subtract(const Duration(hours: 2)),
      lugar: 'Calle 12 #4-30, Valledupar',
      esMio: esMio,
      estado: estado,
      fotos: fotos,
      lat: 10.46,
      lng: -73.25,
      verificadoEn: estado == EstadoReporteCiudadano.verificado ? DateTime.now() : null,
      motivoRechazo: motivoRechazo,
    );

final _lista = [
  _reporte('a', esMio: true, estado: EstadoReporteCiudadano.pendiente, fotos: ['/uploads/a.jpg']),
  _reporte('b', tipo: 'inundacion'),
  _reporte('c', tipo: 'accidente', esMio: true, estado: EstadoReporteCiudadano.atendido),
  _reporte('d', tipo: 'robo', estado: EstadoReporteCiudadano.rechazado, esMio: true, motivoRechazo: 'Era una broma'),
];

class _ReportesFijos extends ReportesCiudadanoViewModel {
  @override
  Future<List<ReporteCiudadano>> build() async => _lista;
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

Widget _app(Widget home, {double escalaTexto = 1}) => ProviderScope(
      overrides: [
        reportesCiudadanoProvider.overrideWith(_ReportesFijos.new),
        // El detalle completo llega igual que el de la lista
        detalleReporteProvider.overrideWith((ref, id) async => _lista.firstWhere((r) => r.id == id)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
        home: MediaQuery.withClampedTextScaling(minScaleFactor: escalaTexto, maxScaleFactor: escalaTexto, child: home),
      ),
    );

void _pantalla(WidgetTester tester, double ancho, double alto) {
  tester.view.physicalSize = Size(ancho * 3, alto * 3);
  tester.view.devicePixelRatio = 3;
  tester.view.padding = const FakeViewPadding(top: 72, bottom: 48);
  tester.view.viewPadding = const FakeViewPadding(top: 72, bottom: 48);
  addTearDown(tester.view.reset);
}

void main() {
  setUpAll(_cargarFuentes);

  for (final (nombre, ancho, alto, escala) in [
    ('telefono', 390.0, 844.0, 1.0),
    ('pequeno_letra_grande', 360.0, 760.0, 1.3),
  ]) {
    testWidgets('lista de reportes: $nombre sin desbordes', (tester) async {
      _pantalla(tester, ancho, alto);
      await tester.pumpWidget(_app(const ReportesScreen(), escalaTexto: escala));
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      expect(find.text('Reportes'), findsOneWidget);
      expect(find.text('Verificado'), findsOneWidget);
    });
  }

  testWidgets('"Mis reportes" deja solo los tuyos', (tester) async {
    _pantalla(tester, 390, 844);
    await tester.pumpWidget(_app(const ReportesScreen()));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Mis reportes'));
    await tester.pump(const Duration(milliseconds: 400));
    // El de inundación es de otro ciudadano
    expect(find.text('Inundación'), findsOneWidget); // solo en los filtros
    expect(find.text('Tuyo'), findsNWidgets(3));
  });

  testWidgets('detalle de un reporte ajeno: seguimiento y sin datos de quien reportó', (tester) async {
    _pantalla(tester, 390, 844);
    await tester.pumpWidget(_app(DetalleReporteScreen(reporte: _lista[1])));
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
    expect(find.text('Verificado por la organización'), findsOneWidget);
    expect(find.text('Reportado por un ciudadano'), findsOneWidget);
    expect(find.text('Por su seguridad, su identidad no se muestra'), findsOneWidget);
    expect(find.text('Cómo llegar'), findsOneWidget);
  });

  testWidgets('detalle de un reporte rechazado muestra el motivo', (tester) async {
    _pantalla(tester, 360, 760);
    await tester.pumpWidget(_app(DetalleReporteScreen(reporte: _lista[3]), escalaTexto: 1.3));
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
    expect(find.text('Era una broma'), findsOneWidget);

    expect(find.text('Reportado por ti'), findsOneWidget);
  });
}
