/// CampanaOut del backend: lo que una organización necesita reunir.
class CampanaModel {
  final String id;
  final String titulo;
  final String descripcion;
  // alimentos | ropa | medicamentos | agua | dinero | otro
  final String categoria;
  final double meta;
  final double recaudado;
  final String unidad;
  final DateTime fechaFin;

  const CampanaModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.meta,
    required this.recaudado,
    required this.unidad,
    required this.fechaFin,
  });

  factory CampanaModel.fromJson(Map<String, dynamic> json) => CampanaModel(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        descripcion: json['descripcion'] as String,
        categoria: json['categoria'] as String,
        meta: (json['meta'] as num).toDouble(),
        recaudado: (json['recaudado'] as num).toDouble(),
        unidad: json['unidad'] as String,
        fechaFin: DateTime.parse(json['fecha_fin'] as String),
      );

  /// Avance de 0 a 1 (puede pasar de la meta: se muestra lleno).
  double get avance => meta <= 0 ? 0 : (recaudado / meta).clamp(0, 1).toDouble();

  String get fechaFinTexto =>
      '${fechaFin.day.toString().padLeft(2, '0')}/${fechaFin.month.toString().padLeft(2, '0')}/${fechaFin.year}';
}
