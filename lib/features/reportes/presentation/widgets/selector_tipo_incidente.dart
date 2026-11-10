import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/selector_tipo.dart';

/// Tipos de incidente, compartidos por el formulario y la lista de reportes.
/// Es la misma lista sugerida del backend (GET /reportes/tipos) con sus íconos; "otro" permite
/// escribir un tipo de emergencia que no está en la lista.
const List<OpcionTipo> tiposIncidente = [
  OpcionTipo(
    id: 'accidente',
    etiqueta: 'Accidente',
    icono: Icons.directions_car_outlined,
    color: AppColors.danger,
  ),
  OpcionTipo(
    id: 'robo',
    etiqueta: 'Robo',
    icono: Icons.shopping_bag_outlined,
    color: AppColors.primary,
  ),
  OpcionTipo(
    id: 'inundacion',
    etiqueta: 'Inundación',
    icono: Icons.water_drop_outlined,
    color: AppColors.info,
  ),
  OpcionTipo(
    id: 'deslizamiento',
    etiqueta: 'Deslizamiento',
    icono: Icons.terrain,
    color: AppColors.warning,
  ),
  OpcionTipo(
    id: 'incendio',
    etiqueta: 'Incendio',
    icono: Icons.local_fire_department_outlined,
    color: AppColors.danger,
  ),
  OpcionTipo(
    id: 'sismo',
    etiqueta: 'Sismo',
    icono: Icons.vibration,
    color: AppColors.warning,
  ),
  OpcionTipo(
    id: 'otro',
    etiqueta: 'Otro',
    icono: Icons.more_horiz,
    color: AppColors.textSecondary,
  ),
];

/// Arma las opciones con la lista del backend (íconos locales) y "Otro" al final.
List<OpcionTipo> opcionesTipo(
    List<({String valor, String etiqueta})> delBackend) {
  const otro = OpcionTipo(
      id: 'otro',
      etiqueta: 'Otro',
      icono: Icons.more_horiz,
      color: AppColors.textSecondary);
  return [
    for (final t in delBackend)
      OpcionTipo(
        id: t.valor,
        etiqueta: t.etiqueta,
        icono: buscarTipoIncidente(t.valor)?.icono ?? Icons.report_outlined,
        color: buscarTipoIncidente(t.valor)?.color ?? AppColors.textSecondary,
      ),
    otro,
  ];
}

/// Busca un tipo por su id. Devuelve null si no existe.
OpcionTipo? buscarTipoIncidente(String id) {
  for (final tipo in tiposIncidente) {
    if (tipo.id == id) return tipo;
  }
  return null;
}
