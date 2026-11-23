import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:rescate360/features/voluntario/presentation/views/incidentes_voluntario_screen.dart';
import 'package:rescate360/features/voluntario/presentation/views/asignaciones_voluntario_screen.dart';
import 'package:rescate360/features/voluntario/presentation/viewmodels/voluntario_viewmodel.dart';
import 'package:rescate360/features/voluntario/presentation/viewmodels/voluntario_local_viewmodel.dart';
import 'package:rescate360/features/voluntario/data/models/asignacion_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rescate360/core/network/api_client.dart';
import 'package:rescate360/features/mapa/data/models/marcador_mapa_model.dart';
import 'package:rescate360/features/mapa/presentation/widgets/detalle_punto_sheet.dart';
import 'package:rescate360/features/solicitudes_ayuda/data/models/solicitud_ayuda_model.dart';
import 'package:rescate360/features/voluntario/presentation/widgets/encabezado_casos.dart';
import 'package:rescate360/features/voluntario/presentation/widgets/tarjeta_incidente.dart';
import 'package:rescate360/shared/widgets/galeria_fotos.dart';

void main() {
  test('El voluntario conserva fotos por tipo aunque no venga el MIME', () {
    final caso = SolicitudAyudaModel.desdeReporte({
      'id': 'reporte-1',
      'tipo': 'incendio',
      'descripcion': 'Humo',
      'ubicacion': {'lat': 4.7, 'lng': -74.0},
      'estado': 'verificado',
      'prioridad_ia': 'alta',
      'creado_en': '2026-11-16T12:00:00Z',
      'evidencias': [
        {'tipo': 'foto', 'url': '/uploads/foto.jpg'},
        {'tipo': 'video', 'mime': 'video/mp4', 'url': '/uploads/video.mp4'},
      ],
    });
    expect(caso.evidenciaImagenes, ['/uploads/foto.jpg']);
  });

  testWidgets('La foto del voluntario resuelve la ruta contra el API',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
      body: SizedBox(
          width: 72, height: 72, child: FotoRed(url: '/uploads/foto.jpg')),
    )));
    final imagen = tester.widget<Image>(find.byType(Image));
    expect((imagen.image as NetworkImage).url, urlArchivo('/uploads/foto.jpg'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final ancho in [320.0, 390.0]) {
    testWidgets('Encabezado y tarjeta caben a $ancho px', (tester) async {
      tester.view.physicalSize = Size(ancho, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: ListView(children: [
        EncabezadoCasos(
            titulo: 'Incidentes',
            subtitulo: 'Tu ayuda empieza con un caso',
            cifras: const [
              (valor: 12, etiqueta: 'Abiertos', icono: Icons.layers_outlined),
              (valor: 8, etiqueta: 'Reportes', icono: Icons.article_outlined),
              (
                valor: 2,
                etiqueta: 'A tu cargo',
                icono: Icons.assignment_outlined
              ),
            ],
            etiquetas: const ['Todos', 'Cercanos', 'Asignados'],
            indice: 1,
            onCambiar: (_) {}),
        Padding(
            padding: const EdgeInsets.all(16),
            child: TarjetaIncidente(
              solicitud: SolicitudAyudaModel(
                  id: '1',
                  clase: 'reporte',
                  tipo: 'incendio',
                  origen: 'reporte',
                  descripcion:
                      'Descripción larga de un incendio en una vivienda de la comunidad.',
                  lat: 4.7,
                  lng: -74,
                  direccion: 'Una dirección extensa en la zona del incidente',
                  estado: 'verificado',
                  prioridad: 'alta',
                  creadoEn: DateTime(2026, 11, 16)),
              etiqueta: 'En curso',
              distancia: 'A 1.2 km',
              onTap: () {},
            )),
      ]))));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('La ficha compartida permite al voluntario abrir el caso',
      (tester) async {
    var abierto = false;
    await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
            home: Builder(
      builder: (context) => Scaffold(
          body: TextButton(
              onPressed: () => mostrarDetallePunto(
                    context,
                    punto: const MarcadorMapaModel(
                        id: '1',
                        capa: 'solicitud',
                        tipo: 'rescate',
                        titulo: 'Rescate',
                        detalle: 'Necesita ayuda',
                        estado: 'pendiente',
                        lat: 4.7,
                        lng: -74,
                        aproximada: false,
                        propio: true,
                        activo: true),
                    distancia: 'A 1 km',
                    onCentrar: () {},
                    onAbrirCaso: () => abierto = true,
                  ),
              child: const Text('Abrir'))),
    ))));
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Gestionar este caso'));
    await tester.tap(find.text('Gestionar este caso'));
    await tester.pumpAndSettle();
    expect(abierto, isTrue);
    expect(tester.takeException(), isNull);
  });

  for (final historial in [false, true]) {
    testWidgets(
        historial
            ? 'Historial filtra atendidas y canceladas'
            : 'Incidentes busca y filtra reportes', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      if (const bool.fromEnvironment('GUARDAR_VISTAS')) {
        await tester.runAsync(() async {
        final font = FontLoader('Roboto');
        font.addFont(File('C:/Windows/Fonts/segoeui.ttf')
            .readAsBytes()
            .then((b) => ByteData.sublistView(b)));
        await font.load();
        });
      }
      final caso = SolicitudAyudaModel(
          id: 'reporte-1',
          clase: 'reporte',
          tipo: 'incendio',
          tipoEtiqueta: 'Incendio',
          origen: 'reporte',
          descripcion:
              'Se observa humo en una vivienda. Se necesita apoyo de la organización.',
          lat: 4.7,
          lng: -74,
          direccion: 'Calle 12 · Barrio San José',
          estado: 'verificado',
          prioridad: 'alta',
          creadoEn: DateTime.now().subtract(const Duration(minutes: 25)));
      final sos = SolicitudAyudaModel(
          id: 'sos-1',
          tipo: 'rescate',
          origen: 'sos',
          descripcion: 'Una persona solicita ayuda urgente en su ubicación.',
          lat: 4.7,
          lng: -74,
          direccion: 'Carrera 8 · Centro',
          estado: 'pendiente',
          prioridad: 'critica',
          creadoEn: DateTime.now());
      final activa = AsignacionModel(
          id: 'activa',
          reporteId: caso.id,
          estado: 'activa',
          asignadoEn: DateTime.now(),
          solicitud: caso);
      final cerrada = AsignacionModel(
          id: 'cerrada',
          reporteId: caso.id,
          estado: 'finalizada',
          asignadoEn: DateTime.now(),
          cerradaEn: DateTime.now(),
          solicitud: caso);
      await tester.pumpWidget(ProviderScope(
          overrides: [
            casosOrganizacionProvider.overrideWith((ref) async => [caso, sos]),
            misTareasProvider.overrideWith((ref) async => [activa]),
            historialTareasProvider.overrideWith((ref) async => [cerrada]),
            miUbicacionProvider.overrideWith((ref) async => null),
          ],
          child: MaterialApp(
              home: Scaffold(
                  body: RepaintBoundary(
            key: const ValueKey('vista'),
            child: historial
                ? const AsignacionesVoluntarioScreen()
                : const IncidentesVoluntarioScreen(),
          )))));
      await tester.pumpAndSettle();
      if (historial) {
        await tester.tap(find.text('Historial').last);
        await tester.pumpAndSettle();
        expect(find.text('Incendio'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      if (const bool.fromEnvironment('GUARDAR_VISTAS')) {
        final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('vista')));
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(historial
              ? 'build/voluntario-historial.png'
              : 'build/voluntario-incidentes.png');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      if (historial) {
        await tester.tap(find.text('Canceladas'));
        await tester.pumpAndSettle();
        expect(find.text('Incendio'), findsNothing);
      } else {
        await tester.enterText(find.byType(TextField), 'San José');
        await tester.pumpAndSettle();
        expect(find.text('Incendio'), findsOneWidget);
        expect(find.text('EMERGENCIA SOS'), findsNothing);
      }
      expect(tester.takeException(), isNull);
    });
  }
}
