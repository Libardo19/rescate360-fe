import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/etiqueta_estado.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/models/persona_desaparecida.dart';
import '../viewmodels/personas_desaparecidas_viewmodel.dart';
import '../widgets/estado_persona_ui.dart';

/// Detalle de una persona desaparecida: foto, datos, última vez que se le
/// vio, señas particulares y contacto de la familia.
///
/// Abre con la ficha de la lista y la completa con GET /personas-desaparecidas/{id},
/// que trae el contacto de la familia y el aviso legal.
class DetallePersonaScreen extends ConsumerWidget {
  final PersonaDesaparecida persona;

  const DetallePersonaScreen({super.key, required this.persona});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actual = ref.watch(personaDetalleProvider(persona.id)).valueOrNull ?? persona;
    return _DetallePersona(
      persona: actual,
      alCambiarEstado: actual.puedeGestionar
          ? () async {
              final nuevo = actual.estado == EstadoPersona.buscando
                  ? EstadoPersona.encontrada
                  : EstadoPersona.buscando;
              final error = await ref
                  .read(personasViewModelProvider.notifier)
                  .cambiarEstado(actual.id, nuevo);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(error ??
                    (nuevo == EstadoPersona.encontrada
                        ? 'Marcada como encontrada'
                        : 'La ficha volvió a búsqueda')),
              ));
            }
          : null,
    );
  }
}

class _DetallePersona extends StatelessWidget {
  final PersonaDesaparecida persona;
  // Solo para quien la reportó o un administrador
  final Future<void> Function()? alCambiarEstado;

  const _DetallePersona({required this.persona, this.alCambiarEstado});

  void _mostrarContacto(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tengo información', style: AppTextStyles.h2),
            const SizedBox(height: 10),
            const Text(
              'Si ves a la persona, no intentes retenerla ni enfrentar a '
              'nadie: avisa a la familia o llama a la línea 123.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 18),
            _FilaContacto(
              nombre: persona.contactoNombre,
              telefono: persona.contactoTelefono,
              onCopiar: () async {
                await Clipboard.setData(
                  ClipboardData(text: persona.contactoTelefono),
                );
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Teléfono copiado')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final datos = [
      '${persona.edad} años',
      persona.sexo,
      if (persona.estatura != null) persona.estatura!,
    ].join(' · ');

    final senas = persona.senasParticulares;
    final ropa = persona.vestimenta;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(
                label: 'Tengo información',
                icon: Icons.campaign_outlined,
                onPressed: () => _mostrarContacto(context),
              ),
              if (alCambiarEstado != null) ...[
                const SizedBox(height: 8),
                PrimaryButton(
                  label: persona.estado == EstadoPersona.buscando
                      ? 'Marcar como encontrada'
                      : 'Volver a búsqueda',
                  icon: persona.estado == EstadoPersona.buscando
                      ? Icons.check_circle_outline
                      : Icons.search,
                  outlined: true,
                  onPressed: alCambiarEstado,
                ),
              ],
            ],
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 340,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              expandedTitleScale: 1.3,
              titlePadding: const EdgeInsetsDirectional.only(
                start: 56,
                end: 16,
                bottom: 16,
              ),
              title: Text(
                persona.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              background: _FotoCabecera(persona: persona),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      EtiquetaEstado(
                        texto: persona.estado.etiqueta,
                        color: persona.estado.color,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(datos, style: AppTextStyles.bodySecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _Tarjeta(
                    icono: Icons.event_outlined,
                    titulo: 'Visto por última vez',
                    hijos: [
                      _Dato(
                        etiqueta: 'Fecha',
                        valor:
                            '${persona.fechaVistaTexto} · ${persona.haceCuanto}',
                      ),
                      _Dato(etiqueta: 'Lugar', valor: persona.lugar),
                      if (ropa != null)
                        _Dato(etiqueta: 'Vestimenta', valor: ropa),
                    ],
                  ),
                  _Tarjeta(
                    icono: Icons.description_outlined,
                    titulo: 'Descripción',
                    hijos: [
                      Text(persona.descripcion, style: AppTextStyles.body),
                    ],
                  ),
                  if (senas != null)
                    _Tarjeta(
                      icono: Icons.fingerprint,
                      titulo: 'Señas particulares',
                      hijos: [Text(senas, style: AppTextStyles.body)],
                    ),
                  _Tarjeta(
                    icono: Icons.contact_phone_outlined,
                    titulo: 'Contacto de la familia',
                    hijos: [
                      _FilaContacto(
                        nombre: persona.contactoNombre,
                        telefono: persona.contactoTelefono,
                        onCopiar: () async {
                          await Clipboard.setData(
                            ClipboardData(text: persona.contactoTelefono),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Teléfono copiado'),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline,
                          size: 18, color: AppColors.textMuted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          persona.aviso ??
                              'En una emergencia real, llama primero a la '
                                  'línea 123.',
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FotoCabecera extends StatelessWidget {
  final PersonaDesaparecida persona;

  const _FotoCabecera({required this.persona});

  @override
  Widget build(BuildContext context) {
    final foto = persona.imagen;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (foto != null)
          Image(image: foto, fit: BoxFit.cover)
        else
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: Center(
              child: persona.fotoOculta
                  // Ley 1098: la foto de un menor solo la ven la familia y los administradores
                  ? const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_outlined, size: 96, color: Colors.white38),
                        SizedBox(height: 8),
                        Text('Foto protegida: es menor de edad',
                            style: TextStyle(color: Colors.white70)),
                      ],
                    )
                  : const Icon(Icons.person, size: 140, color: Colors.white24),
            ),
          ),
        // Degradados para que el botón de volver y el nombre se lean.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x99000000), Color(0x00000000), Color(0xB3000000)],
              stops: [0.0, 0.4, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

class _Tarjeta extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final List<Widget> hijos;

  const _Tarjeta({
    required this.icono,
    required this.titulo,
    required this.hijos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icono, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Text(titulo, style: AppTextStyles.h2),
            ],
          ),
          const SizedBox(height: 14),
          ...hijos,
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _Dato({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(etiqueta, style: AppTextStyles.caption),
          const SizedBox(height: 2),
          Text(valor, style: AppTextStyles.body),
        ],
      ),
    );
  }
}

class _FilaContacto extends StatelessWidget {
  final String nombre;
  final String telefono;
  final VoidCallback onCopiar;

  const _FilaContacto({
    required this.nombre,
    required this.telefono,
    required this.onCopiar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nombre, style: AppTextStyles.body),
              const SizedBox(height: 2),
              Text(telefono, style: AppTextStyles.bodySecondary),
            ],
          ),
        ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          onPressed: onCopiar,
          icon: const Icon(Icons.copy, size: 16),
          label: const Text('Copiar'),
        ),
      ],
    );
  }
}
