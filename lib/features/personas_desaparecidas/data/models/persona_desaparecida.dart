import 'dart:typed_data';

/// Estado de un reporte de persona desaparecida.
/// [enRevision] es el estado inicial de los reportes nuevos hasta que se
/// verifiquen.
enum EstadoPersona { urgente, enInvestigacion, enRevision, encontrada }

/// Formato dd/MM/yyyy sin depender de paquetes externos.
String formatearFecha(DateTime fecha) {
  final dia = fecha.day.toString().padLeft(2, '0');
  final mes = fecha.month.toString().padLeft(2, '0');
  return '$dia/$mes/${fecha.year}';
}

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
  final String contactoNombre;
  final String contactoTelefono;
  final EstadoPersona estado;
  final Uint8List? foto;

  const PersonaDesaparecida({
    required this.id,
    required this.nombre,
    required this.edad,
    required this.sexo,
    required this.fechaVista,
    required this.lugar,
    required this.descripcion,
    required this.contactoNombre,
    required this.contactoTelefono,
    required this.estado,
    this.estatura,
    this.senasParticulares,
    this.vestimenta,
    this.foto,
  });

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
