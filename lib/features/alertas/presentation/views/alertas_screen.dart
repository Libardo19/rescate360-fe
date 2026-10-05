import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/pestanas_segmentadas.dart';

class Alerta {
  final String titulo;
  final String detalle;
  final String hace;
  final IconData icono;
  final Color color;

  const Alerta({
    required this.titulo,
    required this.detalle,
    required this.hace,
    required this.icono,
    required this.color,
  });
}

// Datos de ejemplo hasta conectar la API.
const List<Alerta> _alertasActivas = [
  Alerta(
    titulo: 'Alerta de inundación',
    detalle: 'Río Magdalena · Zona urbana',
    hace: 'Hace 1 h',
    icono: Icons.water_drop_outlined,
    color: AppColors.danger,
  ),
  Alerta(
    titulo: 'Alerta de deslizamiento',
    detalle: 'Vía al corregimiento',
    hace: 'Hace 3 h',
    icono: Icons.terrain,
    color: AppColors.warning,
  ),
  Alerta(
    titulo: 'Alerta de seguridad',
    detalle: 'Robo en sector centro',
    hace: 'Hace 5 h',
    icono: Icons.shield_outlined,
    color: AppColors.info,
  ),
  Alerta(
    titulo: 'Alerta de clima',
    detalle: 'Lluvias fuertes en la región',
    hace: 'Hace 6 h',
    icono: Icons.cloud_outlined,
    color: AppColors.textMuted,
  ),
];

const List<Alerta> _alertasHistorial = [
  Alerta(
    titulo: 'Alerta de incendio',
    detalle: 'Zona rural · Vereda La Esperanza',
    hace: 'Hace 2 días',
    icono: Icons.local_fire_department_outlined,
    color: AppColors.danger,
  ),
  Alerta(
    titulo: 'Alerta de clima',
    detalle: 'Vendaval en el casco urbano',
    hace: 'Hace 4 días',
    icono: Icons.cloud_outlined,
    color: AppColors.textMuted,
  ),
];

class AlertasScreen extends StatefulWidget {
  const AlertasScreen({super.key});

  @override
  State<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  int _pestana = 0;

  void _verDetalle(Alerta alerta) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _IconoAlerta(alerta: alerta),
                const SizedBox(width: 12),
                Expanded(child: Text(alerta.titulo, style: AppTextStyles.h2)),
              ],
            ),
            const SizedBox(height: 16),
            Text(alerta.detalle, style: AppTextStyles.body),
            const SizedBox(height: 6),
            Text(alerta.hace, style: AppTextStyles.caption),
            const SizedBox(height: 16),
            const Text(
              'Mantente atento a las indicaciones de las autoridades y '
              'comparte esta información con tu comunidad.',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lista = _pestana == 0 ? _alertasActivas : _alertasHistorial;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Alertas', style: AppTextStyles.h2),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: PestanasSegmentadas(
                etiquetas: const ['Activas', 'Historial'],
                indice: _pestana,
                onCambiar: (i) => setState(() => _pestana = i),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                itemCount: lista.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _TarjetaAlerta(
                  alerta: lista[i],
                  onVerMas: () => _verDetalle(lista[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconoAlerta extends StatelessWidget {
  final Alerta alerta;
  const _IconoAlerta({required this.alerta});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: alerta.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(alerta.icono, color: alerta.color, size: 24),
    );
  }
}

class _TarjetaAlerta extends StatelessWidget {
  final Alerta alerta;
  final VoidCallback onVerMas;

  const _TarjetaAlerta({required this.alerta, required this.onVerMas});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconoAlerta(alerta: alerta),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alerta.titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(alerta.detalle, style: AppTextStyles.bodySecondary),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(alerta.hace, style: AppTextStyles.caption),
                    const Spacer(),
                    GestureDetector(
                      onTap: onVerMas,
                      child: const Text('Ver más', style: AppTextStyles.link),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
