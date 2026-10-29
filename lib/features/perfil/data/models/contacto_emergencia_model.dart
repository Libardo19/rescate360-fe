/// Contacto de emergencia: recibe un SMS con la ubicación cuando la persona activa el SOS.
class ContactoEmergencia {
  final String id;
  final String nombre;
  final String? parentesco;
  // E.164 (+573001234567), como lo devuelve el backend
  final String telefono;

  const ContactoEmergencia({
    required this.id,
    required this.nombre,
    required this.telefono,
    this.parentesco,
  });

  factory ContactoEmergencia.fromJson(Map<String, dynamic> json) => ContactoEmergencia(
        id: json['id'] as String,
        nombre: json['nombre'] as String,
        telefono: json['telefono'] as String,
        parentesco: json['parentesco'] as String?,
      );
}

/// Resumen de GET /usuarios/me/datos (Ley 1581): cuánto guarda RESCATE360 de la persona.
class ResumenMisDatos {
  final int consentimientos;
  final int contactos;
  final int dispositivos;
  final int solicitudes;
  final int reportes;
  final int personasReportadas;
  final bool tieneUbicacion;

  const ResumenMisDatos({
    required this.consentimientos,
    required this.contactos,
    required this.dispositivos,
    required this.solicitudes,
    required this.reportes,
    required this.personasReportadas,
    required this.tieneUbicacion,
  });

  factory ResumenMisDatos.fromJson(Map<String, dynamic> json) {
    int contar(String clave) => (json[clave] as List).length;
    return ResumenMisDatos(
      consentimientos: contar('consentimientos'),
      contactos: contar('contactos_emergencia'),
      dispositivos: contar('dispositivos'),
      solicitudes: contar('solicitudes'),
      reportes: contar('reportes'),
      personasReportadas: contar('personas_reportadas'),
      tieneUbicacion: (json['ubicacion'] as Map<String, dynamic>)['ubicacion_actual'] != null,
    );
  }
}
