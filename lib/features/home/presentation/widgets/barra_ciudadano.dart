import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_colors.dart';

/// Barra inferior del ciudadano: Inicio, Mapa, Reportes y Más.
/// La pestaña activa se marca con una píldora azul que se desliza entre ellas.
class BarraCiudadano extends StatelessWidget {
  final int indice;
  final ValueChanged<int> onTap;

  const BarraCiudadano({super.key, required this.indice, required this.onTap});

  static const indiceMapa = 1;

  static const _pestanas = [
    (icono: Icons.home_outlined, activo: Icons.home_rounded, etiqueta: 'Inicio'),
    (icono: Icons.location_on_outlined, activo: Icons.location_on_rounded, etiqueta: 'Mapa'),
    (icono: Icons.assignment_outlined, activo: Icons.assignment_rounded, etiqueta: 'Reportes'),
    (icono: Icons.grid_view_outlined, activo: Icons.grid_view_rounded, etiqueta: 'Más'),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Color(0x14081C42), blurRadius: 24, offset: Offset(0, -6))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
          child: Row(
            children: [
              for (var i = 0; i < _pestanas.length; i++)
                Expanded(
                  child: _Pestana(
                    icono: indice == i ? _pestanas[i].activo : _pestanas[i].icono,
                    etiqueta: _pestanas[i].etiqueta,
                    activa: indice == i,
                    onTap: () {
                      if (indice != i) HapticFeedback.selectionClick();
                      onTap(i);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pestana extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final bool activa;
  final VoidCallback onTap;

  const _Pestana({required this.icono, required this.etiqueta, required this.activa, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = activa ? const Color(0xFF2F63E0) : AppColors.textMuted;
    final rapido = MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 220);

    return Semantics(
      selected: activa,
      button: true,
      label: etiqueta,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: rapido,
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          constraints: const BoxConstraints(minHeight: 50),
          decoration: BoxDecoration(
            color: activa ? const Color(0xFFE6EEFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            // La barra mide lo que su contenido: sin esto ocuparía toda la pantalla
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: rapido,
                curve: Curves.easeOutBack,
                scale: activa ? 1.08 : 1,
                child: Icon(icono, color: color, size: 23),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  etiqueta,
                  maxLines: 1,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: activa ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
