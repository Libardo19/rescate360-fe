import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/pestanas_segmentadas.dart';
import '../../data/models/persona_desaparecida.dart';
import '../viewmodels/personas_desaparecidas_viewmodel.dart';
import '../widgets/persona_card.dart';
import 'detalle_persona_screen.dart';
import 'registrar_persona_screen.dart';

class PersonasDesaparecidasScreen extends ConsumerStatefulWidget {
  const PersonasDesaparecidasScreen({super.key});

  @override
  ConsumerState<PersonasDesaparecidasScreen> createState() =>
      _PersonasDesaparecidasScreenState();
}

class _PersonasDesaparecidasScreenState
    extends ConsumerState<PersonasDesaparecidasScreen> {
  final _scroll = ScrollController();
  int _pestana = 0;
  bool _extendido = true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_alDesplazar);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  // El botón se encoge al bajar la lista y se expande al subir.
  void _alDesplazar() {
    if (!_scroll.hasClients) return;
    final direccion = _scroll.position.userScrollDirection;
    if (direccion == ScrollDirection.reverse && _extendido) {
      setState(() => _extendido = false);
    } else if (direccion == ScrollDirection.forward && !_extendido) {
      setState(() => _extendido = true);
    }
  }

  Future<void> _registrar() async {
    final publicado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const RegistrarPersonaScreen()),
    );
    if (publicado == true && mounted) {
      setState(() {
        _pestana = 0;
        _extendido = true;
      });
      if (_scroll.hasClients) _scroll.jumpTo(0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte publicado. Quedó en revisión.'),
        ),
      );
    }
  }

  void _abrirDetalle(PersonaDesaparecida persona) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetallePersonaScreen(persona: persona),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final personas = ref.watch(personasViewModelProvider);
    final lista = personas.where((p) {
      final encontrada = p.estado == EstadoPersona.encontrada;
      return _pestana == 0 ? !encontrada : encontrada;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Personas desaparecidas', style: AppTextStyles.h2),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _registrar,
        isExtended: _extendido,
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text(
          'Reportar persona',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
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
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _pestana == 0
                              ? 'No hay personas en búsqueda por ahora'
                              : 'Aún no hay personas encontradas',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySecondary,
                        ),
                      ),
                    )
                  : ListView.separated(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
                      itemCount: lista.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => PersonaCard(
                        persona: lista[i],
                        onTap: () => _abrirDetalle(lista[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
