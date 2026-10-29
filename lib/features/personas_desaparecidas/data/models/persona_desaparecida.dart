import 'package:flutter/painting.dart';
import '../../../../core/network/api_client.dart';

/// Estado del caso, igual que el backend: `buscando` o `encontrado`.
enum EstadoPersona {
  buscando('buscando'),
  encontrada('encontrado');

  const EstadoPersona(this.valor);

  final String valor;

  static EstadoPersona desde(String valor) => EstadoPersona.values
      .firstWhere((e) => e.valor == valor, orElse: () => EstadoPersona.buscando);
}

/// Sexo: lo que muestra la app ↔ lo que guarda el backend.
const sexosPersona = {'Mujer': 'femenino', 'Hombre': 'masculino', 'Otro': 'otro'};

String _sexoParaMostrar(String? valor) => sexosPersona.entries
    .firstWhere((e) => e.value == valor, orElse: () => const MapEntry('', ''))
    .key;

/// Formato dd/MM/yyyy sin depender de paquetes externos.
String formatearFecha(DateTime fecha) {
  final dia = fecha.day.toString().padLeft(2, '0');
  final mes = fecha.month.toString().padLeft(2, '0');
  return '$dia/$mes/${fecha.year}';
}

/// Fecha AAAA-MM-DD para la API.
String fechaApi(DateTime fecha) =>
    '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';

class PersonaDesaparecida {
  final String id;
  final String nombre;
  final int edad;
  final String sexo;
  final String? estatura;
  final DateTime fechaVista;
  final String lugar;
  final String descripcion;
  final String? senasParticulares;
  final String? vestimenta;
  // El contacto solo llega en el detalle (GET /personas-desaparecidas/{id}); en la lista va vacío
  final String contactoNombre;
  final String contactoTelefono;
  final EstadoPersona estado;
  // URL relativa al API. Null si no hay foto o si es de un menor y no la podemos ver (Ley 1098)
  final String? fotoUrl;
  final bool fotoOculta;
  final bool esMenor;
  // La reporté yo / la puedo editar y marcar como encontrada (yo o un administrador)
  final bool esMia;
  final bool puedeGestionar;
  // Aviso legal del detalle (no esperar 72 horas, Mecanismo de Búsqueda Urgente)
  final String? aviso;

  const PersonaDesaparecida({
    required this.id,
    required this.nombre,
    required this.edad,
    required this.sexo,
    required this.fechaVista,
    required this.lugar,
    required this.descripcion,
    required this.estado,
    this.contactoNombre = '',
    this.contactoTelefono = '',
    this.estatura,
    this.senasParticulares,
    this.vestimenta,
    this.fotoUrl,
    this.fotoOculta = false,
    this.esMenor = false,
    this.esMia = false,
    this.puedeGestionar = false,
    this.aviso,
  });

  /// PersonaOut del backend
  factory PersonaDesaparecida.fromJson(Map<String, dynamic> json) =>
      PersonaDesaparecida(
        id: json['id'] as String,
        nombre: json['nombre'] as String,
        edad: (json['edad'] as num?)?.toInt() ?? 0,
        sexo: _sexoParaMostrar(json['sexo'] as String?),
        estatura: json['estatura'] as String?,
        fechaVista: json['fecha_vista'] != null
            ? DateTime.parse(json['fecha_vista'] as String)
            : DateTime.parse(json['creado_en'] as String).toLocal(),
        lugar: (json['lugar'] as String?) ?? '',
        descripcion: json['descripcion'] as String,
        senasParticulares: json['senas_particulares'] as String?,
        vestimenta: json['vestimenta'] as String?,
        contactoNombre: (json['contacto_nombre'] as String?) ?? '',
        contactoTelefono: (json['contacto_telefono'] as String?) ?? '',
        estado: EstadoPersona.desde(json['estado'] as String),
        fotoUrl: json['foto_url'] as String?,
        fotoOculta: json['foto_oculta'] as bool? ?? false,
        esMenor: json['es_menor'] as bool? ?? false,
        esMia: json['es_mia'] as bool? ?? false,
        puedeGestionar: json['puede_gestionar'] as bool? ?? false,
        aviso: json['aviso'] as String?,
      );

  ImageProvider? get imagen =>
      fotoUrl == null ? null : NetworkImage(urlArchivo(fotoUrl!));

  String get iniciales {
    final partes =
        nombre.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (partes.isEmpty) return '?';
    final primera = partes.first[0];
    final segunda = partes.length > 1 ? partes[1][0] : '';
    return (primera + segunda).toUpperCase();
  }

  String get fechaVistaTexto => formatearFecha(fechaVista);

  String get haceCuanto {
    final dias = DateTime.now().difference(fechaVista).inDays;
    if (dias <= 0) return 'Hoy';
    if (dias == 1) return 'Ayer';
    if (dias < 30) return 'Hace $dias días';
    final meses = dias ~/ 30;
    if (meses < 12) return meses == 1 ? 'Hace 1 mes' : 'Hace $meses meses';
    final anios = dias ~/ 365;
    return anios == 1 ? 'Hace 1 año' : 'Hace $anios años';
  }
}
