import 'package:flutter/material.dart';

/// Sismo de GET /sismos (feed público del USGS, de todo el mundo).
/// Solo los de Colombia generan alerta; los demás son informativos.
class SismoModel {
  final String id;
  final String fuente; // usgs | sgc | simulado
  final double magnitud;
  final double? profundidadKm;
  final String lugar;
  final double lat;
  final double lng;
  final DateTime ocurridoEn;
  final bool enColombia;
  final bool alerto;
  final double? distanciaM; // desde mi ubicación, si el backend la conoce

  const SismoModel({
    required this.id,
    required this.fuente,
    required this.magnitud,
    this.profundidadKm,
    required this.lugar,
    required this.lat,
    required this.lng,
    required this.ocurridoEn,
    required this.enColombia,
    required this.alerto,
    this.distanciaM,
  });

  factory SismoModel.fromJson(Map<String, dynamic> json) {
    final epicentro = json['epicentro'] as Map<String, dynamic>;
    return SismoModel(
      id: json['id'] as String,
      fuente: json['fuente'] as String,
      magnitud: (json['magnitud'] as num).toDouble(),
      profundidadKm: (json['profundidad_km'] as num?)?.toDouble(),
      lugar: json['lugar'] as String,
      lat: (epicentro['lat'] as num).toDouble(),
      lng: (epicentro['lng'] as num).toDouble(),
      ocurridoEn: DateTime.parse(json['ocurrido_en'] as String).toLocal(),
      enColombia: json['en_colombia'] as bool? ?? false,
      alerto: json['alerta_id'] != null,
      distanciaM: (json['distancia_m'] as num?)?.toDouble(),
    );
  }

  String get haceCuanto {
    final minutos = DateTime.now().difference(ocurridoEn).inMinutes;
    if (minutos < 1) return 'hace un momento';
    if (minutos < 60) return 'hace $minutos min';
    final horas = minutos ~/ 60;
    return horas < 24 ? 'hace $horas h' : 'hace ${horas ~/ 24} d';
  }

  String? get distanciaTexto {
    final d = distanciaM;
    if (d == null) return null;
    return d < 1000 ? 'a ${d.round()} m de ti' : 'a ${(d / 1000).round()} km de ti';
  }
}

/// Color por magnitud (el mismo del panel web y del mapa).
Color colorMagnitud(double m) {
  if (m >= 6) return const Color(0xFFB91C1C);
  if (m >= 4.5) return const Color(0xFFEA580C);
  if (m >= 2.5) return const Color(0xFFF59E0B);
  return const Color(0xFFA3A3A3);
}

/// Diámetro del punto en el mapa según la magnitud.
double tamanoMagnitud(double m) => (6 + m * 4.2).clamp(8, 40).toDouble();
