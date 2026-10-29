import 'package:flutter_test/flutter_test.dart';
import 'package:rescate360/features/alertas/data/models/alerta_model.dart';
import 'package:rescate360/features/check_in/data/models/check_in_model.dart';
import 'package:rescate360/features/donaciones/data/models/donacion_model.dart';
import 'package:rescate360/features/mapa/data/models/marcador_mapa_model.dart';
import 'package:rescate360/features/perfil/data/models/contacto_emergencia_model.dart';
import 'package:rescate360/features/personas_desaparecidas/data/models/persona_desaparecida.dart';
import 'package:rescate360/features/reportes/data/models/reporte_model.dart';
import 'package:rescate360/features/solicitudes_ayuda/data/models/solicitud_ayuda_model.dart';
import 'package:rescate360/shared/models/rol.dart';
import 'package:rescate360/shared/models/usuario_model.dart';

// Respuestas tal como las devuelve el backend (rescate360-be)
void main() {
  test('UsuarioOut → UsuarioModel (y de vuelta para guardarlo en el teléfono)', () {
    final json = {
      'id': 'u1',
      'codigo': 'USR-001',
      'nombre': 'Marta Salcedo',
      'email': 'marta@demo.co',
      'telefono': '+573001234567',
      'rol': 'voluntario',
      'estado': 'activo',
      'organizacion_id': 'org-1',
      'ultimo_acceso': null,
      'creado_en': '2026-10-27T10:00:00Z',
    };
    final usuario = UsuarioModel.fromJson(json);
    expect(usuario.rol, Rol.voluntario);
    expect(usuario.primerNombre, 'Marta');
    expect(UsuarioModel.fromJson(usuario.toJson()).correo, 'marta@demo.co');
    expect(Rol.desde('super_admin').usaPanelWeb, isTrue);
  });

  test('SolicitudAyudaOut: la prioridad manual prevalece y solo se cancela si está abierta', () {
    final base = {
      'id': 's1',
      'usuario_id': 'u1',
      'descripcion': 'Solicitud de emergencia (SOS)',
      'direccion': null,
      'tipo': 'rescate',
      'ubicacion': {'lat': 10.46, 'lng': -73.25},
      'origen': 'sos',
      'prioridad_ia': 'critica',
      'prioridad_manual': null,
      'estado': 'pendiente',
      'creado_en': '2026-10-27T10:00:00Z',
    };
    final sos = SolicitudAyudaModel.fromJson(base);
    expect(sos.esSos, isTrue);
    expect(sos.titulo, 'SOS');
    expect(sos.prioridad, 'critica');
    expect(sos.cancelable, isTrue);

    final atendida = SolicitudAyudaModel.fromJson({...base, 'prioridad_manual': 'media', 'estado': 'atendida'});
    expect(atendida.prioridad, 'media');
    expect(atendida.cancelable, isFalse);
  });

  test('ReporteOut con un tipo escrito por el ciudadano y evidencias', () {
    final reporte = ReporteCiudadano.fromJson({
      'id': 'r1',
      'tipo': 'fuga de gas',
      'tipo_etiqueta': 'Fuga de gas',
      'descripcion': 'Olor fuerte a gas',
      'direccion': null,
      'ubicacion': {'lat': 10.4631, 'lng': -73.2532},
      'estado': 'rechazado',
      'motivo_rechazo': 'No se encontró la fuga',
      'evidencias': [
        {'id': 'e1', 'tipo': 'foto', 'url': '/uploads/reportes/a.jpg', 'mime': 'image/jpeg'},
        {'id': 'e2', 'tipo': 'video', 'url': '/uploads/reportes/b.mp4', 'mime': 'video/mp4'},
      ],
      'creado_en': '2026-10-27T10:00:00Z',
    });
    expect(reporte.tipoEtiqueta, 'Fuga de gas');
    expect(reporte.estado, EstadoReporteCiudadano.rechazado);
    expect(reporte.fotos, ['/uploads/reportes/a.jpg']);
    expect(reporte.videos, 1);
    expect(reporte.lugar, '10.4631, -73.2532');
    expect(reporte.esMio, isTrue);
  });

  test('PuntoMapa de GET /mapa', () {
    final punto = MarcadorMapaModel.fromJson({
      'id': 'p1',
      'capa': 'solicitud',
      'tipo': 'medica',
      'titulo': 'Ayuda médica',
      'detalle': 'Solicitud de ayuda en la zona (ubicación aproximada)',
      'estado': 'pendiente',
      'prioridad': 'alta',
      'lat': 10.462,
      'lng': -73.254,
      'radio_m': null,
      'aproximada': true,
      'propio': false,
      'activo': true,
      'actualizado_en': '2026-10-27T10:00:00Z',
    });
    expect(punto.aproximada, isTrue);
    expect(punto.radioM, isNull);
    expect(punto.activo, isTrue);
  });

  test('PersonaOut → PersonaDesaparecida (lista: sin contacto; foto de menor oculta)', () {
    final persona = PersonaDesaparecida.fromJson({
      'id': 'p1',
      'nombre': 'Lucía Herrera',
      'edad': 8,
      'sexo': 'femenino',
      'estatura': null,
      'fecha_vista': '2026-10-20',
      'lugar': 'Mercado nuevo',
      'descripcion': 'Cabello rizado',
      'senas_particulares': null,
      'vestimenta': null,
      'estado': 'buscando',
      'es_menor': true,
      'foto_url': null,
      'foto_oculta': true,
      'ubicacion': null,
      'contacto_nombre': null,
      'contacto_telefono': null,
      'es_mia': false,
      'puede_gestionar': false,
      'aviso': null,
      'encontrado_en': null,
      'creado_en': '2026-10-21T10:00:00Z',
      'actualizado_en': '2026-10-21T10:00:00Z',
    });
    expect(persona.sexo, 'Mujer');
    expect(persona.estado, EstadoPersona.buscando);
    expect(persona.fechaVista, DateTime(2026, 10, 20));
    expect(persona.contactoTelefono, '');
    expect(persona.imagen, isNull);
    expect(persona.fotoOculta, isTrue);
    expect(EstadoPersona.desde('encontrado'), EstadoPersona.encontrada);
    expect(fechaApi(DateTime(2026, 1, 5)), '2026-01-05');
  });

  test('ContactoOut y resumen de mis datos', () {
    final contacto = ContactoEmergencia.fromJson(
        {'id': 'c1', 'nombre': 'Ana', 'telefono': '+573001234567', 'parentesco': null, 'creado_en': '2026-10-28T10:00:00Z'});
    expect(contacto.telefono, '+573001234567');
    expect(contacto.parentesco, isNull);

    final resumen = ResumenMisDatos.fromJson({
      'perfil': {},
      'ubicacion': {'ubicacion_actual': null, 'ubicacion_actualizada_en': null},
      'consentimientos': [{}],
      'contactos_emergencia': [{}, {}],
      'dispositivos': [],
      'solicitudes': [{}],
      'reportes': [],
      'personas_reportadas': [],
      'generado_en': '2026-10-28T10:00:00Z',
    });
    expect(resumen.contactos, 2);
    expect(resumen.tieneUbicacion, isFalse);
  });

  test('AlertaOut → AlertaModel', () {
    final alerta = AlertaModel.fromJson({
      'id': 'a1',
      'titulo': 'Creciente del río',
      'tipo': 'inundacion',
      'mensaje': 'Sube a un lugar alto',
      'nivel': 'alto',
      'estado': 'activa',
      'origen': 'manual',
      'zona': {'lat': 10.46, 'lng': -73.25, 'radio_m': 2500},
      'expira_en': '2026-10-30T10:00:00Z',
      'creado_en': '2026-10-29T10:00:00Z',
      'actualizado_en': '2026-10-29T10:00:00Z',
      'organizacion_id': null,
      'propia': false,
    });
    expect(alerta.nivel, NivelAlerta.alto);
    expect(alerta.radioM, 2500);
    expect(alerta.radioTexto, '2.5 km');
  });

  test('CheckInOut → CheckInModel', () {
    final check = CheckInModel.fromJson({
      'id': 'c1',
      'motivo': 'sismo',
      'estado': 'pendiente',
      'evento_sismico_id': 's1',
      'ultima_ubicacion': {'lat': 10.46, 'lng': -73.25},
      'vence_en': '2026-10-29T10:10:00Z',
      'respondido_en': null,
      'solicitud_id': null,
      'creado_en': '2026-10-29T10:00:00Z',
    });
    expect(check.pendiente, isTrue);
    expect(check.eventoSismicoId, 's1');
  });

  test('CampanaOut → CampanaModel', () {
    final campana = CampanaModel.fromJson({
      'id': 'c1',
      'titulo': 'Mercados',
      'descripcion': 'Familias afectadas',
      'categoria': 'alimentos',
      'meta': 200,
      'unidad': 'mercados',
      'fecha_fin': '2026-11-15',
      'activa': true,
      'organizacion_id': null,
      'creado_en': '2026-10-29T10:00:00Z',
      'recaudado': 50,
      'propia': false,
    });
    expect(campana.avance, 0.25);
    expect(campana.fechaFinTexto, '15/11/2026');
  });
}
