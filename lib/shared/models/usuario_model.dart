/// Modelo básico del usuario autenticado.
/// Por ahora se llena con datos mock; cuando exista backend, se mapeará
/// desde la respuesta JSON de la API (ver core/network/api_client.dart).
class UsuarioModel {
  final String id;
  final String nombre;
  final String correo;
  final String? telefono;

  const UsuarioModel({
    required this.id,
    required this.nombre,
    required this.correo,
    this.telefono,
  });

  factory UsuarioModel.mock({
    required String nombre,
    required String correo,
    String? telefono,
  }) {
    return UsuarioModel(
      id: 'mock-${DateTime.now().millisecondsSinceEpoch}',
      nombre: nombre,
      correo: correo,
      telefono: telefono,
    );
  }

  /// Primer nombre, usado en el saludo de la pantalla Home ("Hola, Oscar").
  String get primerNombre => nombre.trim().split(' ').first;
}
