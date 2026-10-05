import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/etiqueta_estado.dart';
import '../../../../shared/widgets/pestanas_segmentadas.dart';

enum EstadoPersona { urgente, enInvestigacion, encontrada }

class PersonaDesaparecida {
  final String nombre;
  final int edad;
  final String sexo;
  final String fechaVista;
  final String lugar;
  final EstadoPersona estado;

  const PersonaDesaparecida({
    required this.nombre,
    required this.edad,
    required this.sexo,
    required this.fechaVista,
    required this.lugar,
    required this.estado,
  });
}

// Datos de ejemplo hasta conectar la API.
const List<PersonaDesaparecida> _personasEjemplo = [
  PersonaDesaparecida(
    nombre: 'María Fernanda López',
    edad: 15,
    sexo: 'Mujer',
    fechaVista: '12/04/2025',
    lugar: 'Barrio El Prado',
    estado: EstadoPersona.urgente,
  ),
  PersonaDesaparecida(
    nombre: 'Carlos Andrés Rojas',
    edad: 32,
    sexo: 'Hombre',
    fechaVista: '10/04/2025',
    lugar: 'Vereda La Esperanza',
    estado: EstadoPersona.enInvestigacion,
  ),
  PersonaDesaparecida(
    nombre: 'Lucía Herrera',
    edad: 8,
    sexo: 'Mujer',
    fechaVista: '08/04/2025',
    lugar: 'Centro',
    estado: EstadoPersona.encontrada,
  ),
];

class PersonasDesaparecidasScreen extends StatefulWidget {
  const PersonasDesaparecidasScreen({super.key});

  @override
  State<PersonasDesaparecidasScreen> createState() =>
      _PersonasDesaparecidasScreenState();
}

class _PersonasDesaparecidasScreenState
    extends State<PersonasDesaparecidasScreen> {
  int _pestana = 0;

  @override
  Widget build(BuildContext context) {
    final lista = _personasEjemplo.where((p) {
      final encontrada = p.estado == EstadoPersona.encontrada;
      return _pestana == 0 ? !encontrada : encontrada;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Personas desaparecidas', style: AppTextStyles.h2),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: PestanasSegmentadas(
                etiquetas: const ['Buscadas', 'Encontradas'],
                indice: _pestana,
                onCambiar: (i) => setState(() => _pestana = i),
              ),
            ),
            Expanded(
              child: lista.isEmpty
                  ? const Center(
                      child: Text('No hay registros en esta sección',
                          style: AppTextStyles.bodySecondary),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: lista.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _TarjetaPersona(persona: lista[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaPersona extends StatelessWidget {
  final PersonaDesaparecida persona;
  const _TarjetaPersona({required this.persona});

  String get _iniciales {
    final partes = persona.nombre.trim().split(' ');
    final primera = partes.first.isNotEmpty ? partes.first[0] : '';
    final segunda = partes.length > 1 ? partes[1][0] : '';
    return (primera + segunda).toUpperCase();
  }

  (String, Color) get _estado {
    switch (persona.estado) {
      case EstadoPersona.urgente:
        return ('URGENTE', AppColors.danger);
      case EstadoPersona.enInvestigacion:
        return ('En investigación', AppColors.warning);
      case EstadoPersona.encontrada:
        return ('Encontrada', AppColors.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (textoEstado, colorEstado) = _estado;

    return InkWell(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Próximamente')),
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.surface,
              child: Text(_iniciales, style: AppTextStyles.h2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          persona.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      EtiquetaEstado(texto: textoEstado, color: colorEstado),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${persona.edad} años · ${persona.sexo}',
                      style: AppTextStyles.bodySecondary),
                  const SizedBox(height: 2),
                  Text('Vista por última vez: ${persona.fechaVista}',
                      style: AppTextStyles.caption),
                  Text(persona.lugar, style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
