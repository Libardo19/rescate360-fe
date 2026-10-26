import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/etiqueta_estado.dart';

class CentroAyuda {
  final String nombre;
  final String distancia;
  final String direccion;
  final String tipo;
  final IconData icono;
  final Color color;

  const CentroAyuda({
    required this.nombre,
    required this.distancia,
    required this.direccion,
    required this.tipo,
    required this.icono,
    required this.color,
  });
}

// Datos de ejemplo hasta conectar la API.
const List<CentroAyuda> _centrosEjemplo = [
  CentroAyuda(
    nombre: 'Centro de Acopio San José',
    distancia: '2.1 km',
    direccion: 'Calle 12 #8-45',
    tipo: 'Centro de acopio',
    icono: Icons.inventory_2_outlined,
    color: AppColors.info,
  ),
  CentroAyuda(
    nombre: 'Albergue Municipal',
    distancia: '3.4 km',
    direccion: 'Carrera 7 #20-10',
    tipo: 'Albergue',
    icono: Icons.home_outlined,
    color: AppColors.success,
  ),
  CentroAyuda(
    nombre: 'Puesto de Salud El Prado',
    distancia: '4.2 km',
    direccion: 'Calle 15 #11-30',
    tipo: 'Centro médico',
    icono: Icons.local_hospital_outlined,
    color: AppColors.danger,
  ),
];

/// Centros de ayuda (mockup 11). La vista de mapa se conecta después.
class CentrosAyudaScreen extends StatefulWidget {
  const CentrosAyudaScreen({super.key});

  @override
  State<CentrosAyudaScreen> createState() => _CentrosAyudaScreenState();
}

class _CentrosAyudaScreenState extends State<CentrosAyudaScreen> {
  String _consulta = '';

  List<CentroAyuda> get _visibles {
    final q = _consulta.trim().toLowerCase();
    if (q.isEmpty) return _centrosEjemplo;
    return _centrosEjemplo.where((c) {
      return c.nombre.toLowerCase().contains(q) ||
          c.direccion.toLowerCase().contains(q) ||
          c.tipo.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final lista = _visibles;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Centros de ayuda', style: AppTextStyles.h2),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: TextField(
                style: AppTextStyles.body,
                onChanged: (v) => setState(() => _consulta = v),
                decoration: const InputDecoration(
                  hintText: 'Buscar centros de ayuda...',
                  prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                ),
              ),
            ),
            Expanded(
              child: lista.isEmpty
                  ? const Center(
                      child: Text('No encontramos centros con esa búsqueda',
                          style: AppTextStyles.bodySecondary),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: lista.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final c = lista[i];
                        return InkWell(
                          onTap: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Próximamente')),
                          ),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: AppColors.surfaceBorder),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: c.color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(c.icono, color: c.color),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.nombre,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text('${c.distancia} · ${c.direccion}',
                                          style: AppTextStyles.bodySecondary),
                                      const SizedBox(height: 6),
                                      EtiquetaEstado(
                                          texto: c.tipo, color: c.color),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right,
                                    color: AppColors.textMuted),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
