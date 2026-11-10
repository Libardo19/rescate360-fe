import '../../../../shared/models/usuario_model.dart';

/// SesionOut del backend: los dos tokens y el usuario.
class SesionModel {
  final String accessToken;
  final String refreshToken;
  final UsuarioModel usuario;

  const SesionModel({required this.accessToken, required this.refreshToken, required this.usuario});

  factory SesionModel.fromJson(Map<String, dynamic> json) => SesionModel(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
        usuario: UsuarioModel.fromJson(json['usuario'] as Map<String, dynamic>),
      );
}
