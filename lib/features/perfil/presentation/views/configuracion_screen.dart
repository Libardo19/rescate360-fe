import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../app/i18n/textos.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/fila_opcion.dart';
import '../viewmodels/ajustes_viewmodel.dart';

/// Configuración: apariencia (claro, oscuro o automático), idioma,
/// notificaciones, permisos de ubicación y textos legales.
class ConfiguracionScreen extends ConsumerWidget {
  const ConfiguracionScreen({super.key});

  void _avisar(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  Future<void> _abrirAjustesUbicacion(BuildContext context) async {
    if (kIsWeb) {
      _avisar(context, context.t('cfg_ubicacion_web'));
      return;
    }
    await Geolocator.openAppSettings();
  }

  void _elegirIdioma(BuildContext context, WidgetRef ref, String actual) {
    final titulo = context.t('cfg_elige_idioma');

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 20, 8, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(titulo, style: AppTextStyles.h2),
              ),
              const SizedBox(height: 8),
              for (final idioma in const [('es', 'Español'), ('en', 'English')])
                ListTile(
                  leading: const Icon(Icons.language, color: AppColors.primary),
                  title: Text(idioma.$2),
                  trailing: actual == idioma.$1
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  onTap: () {
                    ref.read(ajustesProvider.notifier).cambiarIdioma(idioma.$1);
                    Navigator.of(ctx).pop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _abrirLegal(
    BuildContext context,
    String titulo,
    List<String> parrafos,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _TextoLegalScreen(titulo: titulo, parrafos: parrafos),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ajustes = ref.watch(ajustesProvider);
    final notifier = ref.read(ajustesProvider.notifier);
    final nombreIdioma = ajustes.idioma == 'en' ? 'English' : 'Español';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.t('cfg_titulo'), style: AppTextStyles.h2),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _Etiqueta(context.t('cfg_seccion_apariencia')),
            _SelectorTema(
              actual: ajustes.modoTema,
              onCambiar: notifier.cambiarTema,
            ),
            const SizedBox(height: 8),
            Text(context.t('cfg_tema_ayuda'), style: AppTextStyles.caption),
            const SizedBox(height: 22),
            _Etiqueta(context.t('cfg_seccion_preferencias')),
            GrupoOpciones(
              filas: [
                FilaOpcion(
                  icono: Icons.language,
                  titulo: context.t('cfg_idioma'),
                  subtitulo: nombreIdioma,
                  onTap: () => _elegirIdioma(context, ref, ajustes.idioma),
                ),
                FilaOpcion(
                  icono: Icons.notifications_none,
                  titulo: context.t('cfg_notif'),
                  subtitulo: context.t('cfg_notif_sub'),
                  onTap: () =>
                      Navigator.of(context).pushNamed('/notificaciones'),
                ),
                FilaOpcion(
                  icono: Icons.location_on_outlined,
                  titulo: context.t('cfg_ubicacion'),
                  subtitulo: context.t('cfg_ubicacion_sub'),
                  onTap: () => _abrirAjustesUbicacion(context),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _Etiqueta(context.t('cfg_seccion_legal')),
            GrupoOpciones(
              filas: [
                FilaOpcion(
                  icono: Icons.lock_outline,
                  titulo: context.t('cfg_privacidad'),
                  subtitulo: context.t('cfg_privacidad_sub'),
                  onTap: () => _abrirLegal(
                    context,
                    context.t('cfg_privacidad'),
                    [
                      context.t('legal_priv_1'),
                      context.t('legal_priv_2'),
                      context.t('legal_priv_3'),
                    ],
                  ),
                ),
                FilaOpcion(
                  icono: Icons.description_outlined,
                  titulo: context.t('cfg_terminos'),
                  onTap: () => _abrirLegal(
                    context,
                    context.t('cfg_terminos'),
                    [
                      context.t('legal_term_1'),
                      context.t('legal_term_2'),
                      context.t('legal_term_3'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  final String texto;

  const _Etiqueta(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 2),
      child: Text(
        texto.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

class _SelectorTema extends StatelessWidget {
  final ModoTema actual;
  final ValueChanged<ModoTema> onCambiar;

  const _SelectorTema({required this.actual, required this.onCambiar});

  @override
  Widget build(BuildContext context) {
    final opciones = [
      (ModoTema.claro, Icons.light_mode_outlined, context.t('cfg_tema_claro')),
      (ModoTema.oscuro, Icons.dark_mode_outlined, context.t('cfg_tema_oscuro')),
      (
        ModoTema.sistema,
        Icons.phone_android_outlined,
        context.t('cfg_tema_sistema')
      ),
    ];

    return Row(
      children: [
        for (var i = 0; i < opciones.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: _OpcionTema(
              icono: opciones[i].$2,
              etiqueta: opciones[i].$3,
              activa: actual == opciones[i].$1,
              onTap: () => onCambiar(opciones[i].$1),
            ),
          ),
        ],
      ],
    );
  }
}

class _OpcionTema extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final bool activa;
  final VoidCallback onTap;

  const _OpcionTema({
    required this.icono,
    required this.etiqueta,
    required this.activa,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: activa
              ? AppColors.primary.withOpacity(0.10)
              : AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: activa ? AppColors.primary : AppColors.surfaceBorder,
            width: activa ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icono,
              size: 26,
              color: activa ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(height: 8),
            Text(
              etiqueta,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: activa ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextoLegalScreen extends StatelessWidget {
  final String titulo;
  final List<String> parrafos;

  const _TextoLegalScreen({required this.titulo, required this.parrafos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(titulo, style: AppTextStyles.h2),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.t('cfg_legal_aviso'),
                      style: AppTextStyles.bodySecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            for (final parrafo in parrafos)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child:
                          Icon(Icons.circle, size: 7, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(parrafo, style: AppTextStyles.body)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
