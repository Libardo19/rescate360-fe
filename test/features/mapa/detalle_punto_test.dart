import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rescate360/core/errors/exceptions.dart';
import 'package:rescate360/features/mapa/data/models/marcador_mapa_model.dart';
import 'package:rescate360/features/mapa/presentation/widgets/detalle_punto_sheet.dart';
import 'package:rescate360/features/reportes/data/models/reporte_model.dart';

MarcadorMapaModel _punto({String capa = 'reporte'}) => MarcadorMapaModel(
      id: 'r1',
      capa: capa,
      tipo: 'incendio',
      titulo: capa == 'reporte' ? 'Incendio' : 'Centro de salud',
      detalle: 'Descripción corta…',
      estado: capa == 'reporte' ? 'verificado' : 'activo',
      prioridad: 'alta',
      lat: 10.46,
      lng: -73.25,
      aproximada: false,
      propio: true,
      activo: true,
    );

ReporteCiudadano _reporte({List<String> fotos = const [], int videos = 0}) => ReporteCiudadano(
      id: 'r1',
      tipo: 'incendio',
      tipoEtiqueta: 'Incendio',
      descripcion: 'Se está quemando una casa en la calle 12. Hay humo y los vecinos están afuera.',
      fecha: DateTime.now().subtract(const Duration(minutes: 25)),
      lugar: 'Calle 12 #4-30',
      esMio: true,
      estado: EstadoReporteCiudadano.verificado,
      fotos: fotos,
      videos: videos,
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

/// Abre la hoja del [punto] con el detalle que devuelve [detalle].
Future<void> _abrir(WidgetTester tester, MarcadorMapaModel punto, Future<ReporteCiudadano> Function() detalle) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(ProviderScope(
    overrides: [detalleReporteProvider.overrideWith((ref, id) => detalle())],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => mostrarDetallePunto(context, punto: punto, distancia: 'A 350 m de ti', onCentrar: () {}),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('abrir'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  setUpAll(_cargarFuentes);

  testWidgets('un incidente con fotos muestra la galería y la información completa', (tester) async {
    await _abrir(tester, _punto(), () async => _reporte(fotos: ['/uploads/a.jpg', '/uploads/b.jpg', '/uploads/c.jpg'], videos: 1));

    expect(tester.takeException(), isNull);
    expect(find.text('1/3'), findsOneWidget);
    expect(find.text('Toca para ampliar'), findsOneWidget);
    // La descripción completa del backend, no la corta del mapa
    expect(find.textContaining('los vecinos están afuera'), findsOneWidget);
    expect(find.text('Calle 12 #4-30'), findsOneWidget);
    expect(find.text('1 video adjunto'), findsOneWidget);
    expect(find.text('Verificado'), findsOneWidget);
    expect(find.text('Prioridad alta'), findsOneWidget);
    expect(find.text('Tuyo'), findsOneWidget);

    // Al tocar la foto se abre el visor a pantalla completa
    await tester.tap(find.byType(PageView).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('1 de 3'), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsWidgets);
  });

  testWidgets('un incidente sin fotos lo dice', (tester) async {
    await _abrir(tester, _punto(), () async => _reporte());

    expect(tester.takeException(), isNull);
    expect(find.text('Este reporte no tiene fotos'), findsOneWidget);
  });

  testWidgets('si no carga el detalle, deja lo del mapa y permite reintentar', (tester) async {
    await _abrir(tester, _punto(), () async => throw ApiException.sinConexion);

    expect(tester.takeException(), isNull);
    expect(find.text('Descripción corta…'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('un punto que no es incidente no pide fotos', (tester) async {
    var pedidos = 0;
    await _abrir(tester, _punto(capa: 'centro'), () async {
      pedidos++;
      return _reporte();
    });

    expect(tester.takeException(), isNull);
    expect(pedidos, 0);
    expect(find.text('Centro de salud'), findsOneWidget);
    expect(find.text('Cómo llegar'), findsOneWidget);
  });
}
