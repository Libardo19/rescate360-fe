/// Guía de emergencia (GuiaOut del backend): pasos a seguir por tipo de emergencia.
class GuiaModel {
  final String id;
  final String titulo;
  // sismo, inundacion, incendio, accidente, deslizamiento, robo, medica, desaparecidos, general
  final String categoria;
  final List<String> pasos;

  const GuiaModel({required this.id, required this.titulo, required this.categoria, required this.pasos});

  factory GuiaModel.fromJson(Map<String, dynamic> json) => GuiaModel(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        categoria: json['categoria'] as String,
        pasos: (json['pasos'] as List).cast<String>(),
      );
}
