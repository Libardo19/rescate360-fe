import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Pantalla de inicio del ciudadano (mockup 4).
class HomeScreen extends StatelessWidget {
  final String nombreUsuario;

  /// Dato de prueba hasta conectar el módulo de alertas.
  final int alertasActivas;

  const HomeScreen({
    super.key,
    this.nombreUsuario = 'Usuario',
    this.alertasActivas = 2,
  });

  void _proximamente(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Próximamente')),
    );
  }

  void _ir(BuildContext context, String ruta) {
    Navigator.of(context).pushNamed(ruta);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Encabezado(
          nombreUsuario: nombreUsuario,
          onBuscar: () => _proximamente(context),
          onNotificaciones: () => _ir(context, '/alertas'),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _AccionRapida(
                      icono: Icons.add_circle_outline,
                      etiqueta: 'Reportar incidente',
                      color: AppColors.danger,
                      onTap: () => _ir(context, '/reportar-incidente'),
                    ),
                    _AccionRapida(
                      icono: Icons.person_search_outlined,
                      etiqueta: 'Personas desaparecidas',
                      color: AppColors.info,
                      onTap: () => _ir(context, '/personas-desaparecidas'),
                    ),
                    _AccionRapida(
                      icono: Icons.volunteer_activism_outlined,
                      etiqueta: 'Solicitar ayuda',
                      color: AppColors.warning,
                      onTap: () => _ir(context, '/solicitar-ayuda'),
                    ),
                    _AccionRapida(
                      icono: Icons.notifications_active_outlined,
                      etiqueta: 'Ver alertas',
                      color: AppColors.success,
                      onTap: () => _ir(context, '/alertas'),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const Text('Cerca de ti', style: AppTextStyles.h2),
                const SizedBox(height: 12),
                const _VistaPreviaMapa(),
                const SizedBox(height: 18),
                _TarjetaInformativa(
                  alertasActivas: alertasActivas,
                  onTap: () => _ir(context, '/alertas'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Encabezado extends StatelessWidget {
  final String nombreUsuario;
  final VoidCallback onBuscar;
  final VoidCallback onNotificaciones;

  const _Encabezado({
    required this.nombreUsuario,
    required this.onBuscar,
    required this.onNotificaciones,
  });

  @override
  Widget build(BuildContext context) {
    final inicial =
        nombreUsuario.isNotEmpty ? nombreUsuario[0].toUpperCase() : 'U';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Text(inicial, style: AppTextStyles.h2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hola, $nombreUsuario',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Text(
                          'Tu seguridad también importa',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        onPressed: onNotificaciones,
                        icon: const Icon(
                          Icons.notifications_none,
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: onBuscar,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: AppColors.textMuted, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Buscar incidentes, personas, lugares...',
                          style: AppTextStyles.caption,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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

class _AccionRapida extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final Color color;
  final VoidCallback onTap;

  const _AccionRapida({
    required this.icono,
    required this.etiqueta,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icono, color: color, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                etiqueta,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Espacio reservado para el mapa. Se reemplaza cuando se construya el
/// módulo de mapa.
class _VistaPreviaMapa extends StatelessWidget {
  const _VistaPreviaMapa();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, color: AppColors.textMuted, size: 36),
          SizedBox(height: 8),
          Text('Mapa de incidentes cercanos',
              style: AppTextStyles.bodySecondary),
        ],
      ),
    );
  }
}

class _TarjetaInformativa extends StatelessWidget {
  final int alertasActivas;
  final VoidCallback onTap;

  const _TarjetaInformativa({
    required this.alertasActivas,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final texto = alertasActivas == 0
        ? 'No hay alertas activas en tu zona'
        : alertasActivas == 1
            ? 'Hay 1 alerta activa en tu zona'
            : 'Hay $alertasActivas alertas activas en tu zona';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.campaign_outlined,
                  color: AppColors.danger, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mantente informado', style: AppTextStyles.body),
                  const SizedBox(height: 2),
                  Text(texto, style: AppTextStyles.bodySecondary),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
