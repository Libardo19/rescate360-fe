import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Barra de navegación inferior: Inicio · Mapa · Reportes · Más.
/// Solo "Inicio" está conectado a una pantalla real por ahora; las demás
/// pestañas quedan preparadas (onTap) para conectarse en las siguientes
/// iteraciones sin tener que rehacer este widget.
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Inicio'),
    _NavItem(icon: Icons.map_rounded, label: 'Mapa'),
    _NavItem(icon: Icons.description_rounded, label: 'Reportes'),
    _NavItem(icon: Icons.more_horiz_rounded, label: 'Más'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final selected = index == currentIndex;
            final color = selected ? AppColors.primary : AppColors.textMuted;
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onTap(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, color: color, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
