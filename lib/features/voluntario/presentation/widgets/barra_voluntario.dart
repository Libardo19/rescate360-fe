import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_colors.dart';

/// Barra inferior del voluntario: Inicio, Incidentes, Mapa (botón central
/// elevado con el ícono de ubicación), Asignaciones y Más.
/// Los índices coinciden con las pestañas de VoluntarioScreen (2 = Mapa).
class BarraVoluntario extends StatelessWidget {
  final int indice;
  final ValueChanged<int> onTap;

  const BarraVoluntario({super.key, required this.indice, required this.onTap});

  static const indiceMapa = 2;

  void _ir(int i) {
    if (i != indice) HapticFeedback.selectionClick();
    onTap(i);
  }

  @override
  Widget build(BuildContext context) {
    final inferior = MediaQuery.paddingOf(context).bottom;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(color: Color(0x120F2A5C), blurRadius: 20, offset: Offset(0, -4)),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.only(bottom: inferior),
            child: SizedBox(
              height: 62,
              child: Row(
                children: [
                  _item(0, 'Inicio', Icons.home_outlined, Icons.home_rounded),
                  _item(1, 'Incidentes', Icons.warning_amber_outlined, Icons.warning_amber_rounded),
                  // Hueco del botón central.
                  const Expanded(child: SizedBox()),
                  _item(3, 'Asignaciones', Icons.assignment_outlined, Icons.assignment_rounded),
                  _item(4, 'Más', Icons.more_horiz_rounded, Icons.more_horiz_rounded),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -22,
          child: _BotonMapa(
            activo: indice == indiceMapa,
            onTap: () => _ir(indiceMapa),
          ),
        ),
      ],
    );
  }

  Widget _item(int i, String etiqueta, IconData icono, IconData iconoActivo) => Expanded(
        child: _ItemBarra(
          etiqueta: etiqueta,
          icono: icono,
          iconoActivo: iconoActivo,
          activo: indice == i,
          onTap: () => _ir(i),
        ),
      );
}

class _ItemBarra extends StatelessWidget {
  final String etiqueta;
  final IconData icono;
  final IconData iconoActivo;
  final bool activo;
  final VoidCallback onTap;

  const _ItemBarra({
    required this.etiqueta,
    required this.icono,
    required this.iconoActivo,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // textSecondary (y no textMuted) para que las etiquetas pasen 4.5:1 sobre blanco.
    final color = activo ? AppColors.primary : AppColors.textSecondary;

    return Semantics(
      button: true,
      selected: activo,
      label: etiqueta,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        highlightShape: BoxShape.circle,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(activo ? iconoActivo : icono, color: color, size: 24),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                etiqueta,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Indicador bajo la pestaña activa.
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: activo ? 28 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón redondo que sobresale de la barra y abre el mapa.
class _BotonMapa extends StatefulWidget {
  final bool activo;
  final VoidCallback onTap;

  const _BotonMapa({required this.activo, required this.onTap});

  @override
  State<_BotonMapa> createState() => _BotonMapaState();
}

class _BotonMapaState extends State<_BotonMapa> {
  bool _abajo = false;

  void _cambiar(bool abajo) {
    if (_abajo != abajo) setState(() => _abajo = abajo);
  }

  @override
  Widget build(BuildContext context) {
    final sinMovimiento = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      button: true,
      selected: widget.activo,
      label: 'Mapa',
      excludeSemantics: true,
      child: Tooltip(
        message: 'Mapa',
        child: Listener(
          onPointerDown: (_) => _cambiar(true),
          onPointerUp: (_) => _cambiar(false),
          onPointerCancel: (_) => _cambiar(false),
          child: AnimatedScale(
            scale: _abajo && !sinMovimiento ? 0.94 : 1,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            // Aro blanco que separa el botón del contenido que pasa por detrás.
            child: Container(
              width: 62,
              height: 62,
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Color(0x1A0F2A5C), blurRadius: 14, offset: Offset(0, 2)),
                ],
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.activo
                        ? const [Color(0xFF1E4C96), AppColors.primary]
                        : const [Color(0xFF214A8C), AppColors.primaryDark],
                  ),
                  // Activo: un borde claro marca que el mapa es la pestaña actual.
                  border: Border.all(
                    color: widget.activo ? const Color(0xFF34C3A8) : Colors.transparent,
                    width: 2.5,
                  ),
                ),
                child: Material(
                  type: MaterialType.transparency,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: widget.onTap,
                    child: Icon(
                      widget.activo ? Icons.location_on_rounded : Icons.location_on_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
