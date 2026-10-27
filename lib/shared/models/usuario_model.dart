import 'rol.dart';

/// Usuario autenticado. Se arma desde UsuarioOut del backend (GET /usuarios/me o la sesión).
class UsuarioModel {
  final String id;
  final String codigo;
  final String nombre;
  final String correo;
  final String? telefono;
  final Rol rol;
  final String estado;
  final String? organizacionId;

  const UsuarioModel({
    required this.id,
    this.codigo = '',
    required this.nombre,
    required this.correo,
    this.telefono,
    this.rol = Rol.ciudadano,
    this.estado = 'activo',
    this.organizacionId,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) => UsuarioModel(
        id: json['id'] as String,
        codigo: json['codigo'] as String? ?? '',
        nombre: json['nombre'] as String,
        correo: json['email'] as String,
        telefono: json['telefono'] as String?,
        rol: Rol.desde(json['rol'] as String),
        estado: json['estado'] as String? ?? 'activo',
        organizacionId: json['organizacion_id'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'codigo': codigo,
        'nombre': nombre,
        'email': correo,
        'telefono': telefono,
        'rol': rol.valor,
        'estado': estado,
        'organizacion_id': organizacionId,
      };

  /// Primer nombre, usado en el saludo de la pantalla Home ("Hola, Oscar").
  String get primerNombre => nombre.trim().split(' ').first;
}
