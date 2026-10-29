import 'package:flutter/material.dart';
import 'package:rescate360/features/landing/presentation/landing_actions.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/primary_button.dart';
import 'landing_section.dart';
import 'phone_mockup.dart';

// ============================ HERO ============================
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final escritorio = Responsive.esEscritorio(context);
    final movil = Responsive.esMovil(context);

    final telefono = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PhoneMockup(ancho: movil ? 270 : 300, inclinado: escritorio),
        const SizedBox(height: 16),
        const Text(
          'Toca las pestañas y los filtros: así se ve la app.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.7, -0.1),
          radius: 1.1,
          colors: [
            AppColors.primary.withValues(alpha: 0.28),
            Colors.transparent,
          ],
          stops: const [0, 0.7],
        ),
      ),
      child: SectionContainer(
        child: escritorio
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(flex: 11, child: _HeroTexto()),
                  const SizedBox(width: 48),
                  Expanded(flex: 9, child: Center(child: telefono)),
                ],
              )
            : Column(children: [
                const _HeroTexto(),
                const SizedBox(height: 40),
                telefono,
              ]),
      ),
    );
  }
}

class _HeroTexto extends StatelessWidget {
  const _HeroTexto();

  @override
  Widget build(BuildContext context) {
    final movil = Responsive.esMovil(context);
    final tamano =
        Responsive.valor(context, movil: 38.0, tablet: 50.0, escritorio: 60.0);
    final anchoBoton = movil ? double.infinity : 250.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: tamano,
                fontWeight: FontWeight.w800,
                height: 1.1,
                letterSpacing: -0.5,
                color: AppColors.textPrimary,
              ),
              children: const [
                TextSpan(text: 'Juntos somos '),
                TextSpan(
                    text: 'más fuertes',
                    style: TextStyle(color: AppColors.primary)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Coordinación comunitaria ante emergencias',
          style: TextStyle(
            fontSize: Responsive.valor(context, movil: 18.0, escritorio: 24.0),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF7AA6FF),
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 520),
          child: Text(
            'Reporta un incidente, pide ayuda y encuentra centros cercanos, '
            'incluso cuando se cae la señal.',
            style: TextStyle(
                fontSize: 17, height: 1.5, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 26),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: anchoBoton,
              child: PrimaryButton(
                label: 'Descargar app',
                icon: Icons.download_outlined,
                onPressed: () => LandingActions.descargarApp(context),
              ),
            ),
            SizedBox(
              width: anchoBoton,
              child: PrimaryButton(
                label: 'Conocer cómo funciona',
                icon: Icons.play_arrow_outlined,
                outlined: true,
                onPressed: () =>
                    LandingActions.ir(context, LandingActions.rutaComoFunciona),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              const Icon(Icons.phone_in_talk_outlined,
                  size: 18, color: AppColors.textSecondary),
              const Text('En riesgo vital llama al',
                  style:
                      TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              Semantics(
                button: true,
                label: 'Llamar al 123',
                child: InkWell(
                  onTap: LandingActions.llamar123,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Text('123',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ========================= FUNCIONES =========================
class FuncionesSection extends StatelessWidget {
  const FuncionesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SectionHeader(
            titulo: '¿Qué puedes hacer con RESCATE360?',
            subtitulo:
                'Cada función responde a algo concreto: avisar, pedir ayuda, orientarte y seguir funcionando.',
          ),
          ResponsiveGrid(children: [
            InfoCard(
              icono: Icons.report_outlined,
              color: AppColors.danger,
              titulo: 'Reportar un incidente',
              texto: 'Describe lo que pasa y comparte tu ubicación.',
            ),
            InfoCard(
              icono: Icons.sos,
              color: AppColors.danger,
              titulo: 'Solicitar ayuda',
              texto:
                  'Pide asistencia. El sistema sugiere una prioridad y una persona la revisa.',
            ),
            InfoCard(
              icono: Icons.map_outlined,
              color: AppColors.info,
              titulo: 'Ver emergencias cercanas',
              texto:
                  'Consulta centros de ayuda y puntos de interés en el mapa.',
            ),
            InfoCard(
              icono: Icons.notifications_active_outlined,
              color: AppColors.warning,
              titulo: 'Recibir alertas',
              texto: 'Entérate de las alertas publicadas para tu zona.',
            ),
            InfoCard(
              icono: Icons.menu_book_outlined,
              color: AppColors.success,
              titulo: 'Guías de emergencia',
              etiqueta: 'Próximamente',
              texto:
                  'Orientación sobre qué hacer antes, durante y después de una emergencia.',
            ),
            InfoCard(
              icono: Icons.cloud_off_outlined,
              color: AppColors.info,
              titulo: 'Reportar sin conexión',
              texto:
                  'Tu reporte se guarda en el teléfono y se envía cuando vuelva la señal.',
            ),
          ]),
        ],
      ),
    );
  }
}

// ============================ PASOS ============================
class PasosSection extends StatelessWidget {
  const PasosSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      banda: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            titulo: 'Un reporte, tres pasos',
            subtitulo:
                'Del aviso a la atención, con una persona siempre al final del proceso.',
          ),
          const ResponsiveGrid(tablet: 3, children: [
            _Paso(1, 'Reportas',
                'Describes lo que sucede y compartes tu ubicación aproximada.'),
            _Paso(2, 'Se prioriza',
                'La IA sugiere una prioridad. La decisión final es del administrador.'),
            _Paso(3, 'Se atiende',
                'La organización correspondiente gestiona la solicitud.'),
          ]),
          const SizedBox(height: 22),
          TextButton(
            onPressed: () =>
                LandingActions.ir(context, LandingActions.rutaComoFunciona),
            child: const Text('Ver el proceso completo →',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _Paso extends StatelessWidget {
  final int numero;
  final String titulo;
  final String texto;
  const _Paso(this.numero, this.titulo, this.texto);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: Text('$numero',
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 12),
          Text(titulo,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 4),
          Text(texto,
              style: const TextStyle(
                  fontSize: 15, height: 1.5, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ========================== AUDIENCIAS ==========================
class AudienciasSection extends StatelessWidget {
  const AudienciasSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(titulo: '¿Cómo quieres usar RESCATE360?'),
          ResponsiveGrid(escritorio: 2, children: [
            InfoCard(
              icono: Icons.smartphone,
              color: AppColors.info,
              titulo: 'Soy ciudadano o voluntario',
              texto:
                  'Usa la app móvil para reportar, pedir ayuda y consultar información de emergencia.',
              accion: 'Ver para ciudadanos →',
              onTap: () =>
                  LandingActions.ir(context, LandingActions.rutaCiudadanos),
            ),
            InfoCard(
              icono: Icons.apartment,
              color: AppColors.primary,
              titulo: 'Represento a una organización',
              texto:
                  'Coordina la respuesta desde el panel web: reportes, solicitudes, mapa y alertas.',
              accion: 'Ver para organizaciones →',
              onTap: () =>
                  LandingActions.ir(context, LandingActions.rutaOrganizaciones),
            ),
          ]),
        ],
      ),
    );
  }
}

// ============================ LEGAL ============================
class LegalSection extends StatelessWidget {
  const LegalSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SectionContainer(
      sinPaddingSuperior: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            titulo: 'Hecha con responsabilidad',
            subtitulo:
                'RESCATE360 apoya a la comunidad. No reemplaza a los organismos oficiales de emergencia.',
          ),
          ResponsiveGrid(tablet: 2, escritorio: 2, children: [
            _Legal('Aviso de emergencia',
                'Ante riesgo vital, llama al 123. La app no sustituye a las autoridades.'),
            _Legal('Tus datos, con tu permiso',
                'La autorización de tratamiento de datos (Ley 1581 de 2012) llega sin marcar.'),
            _Legal('Ubicación protegida',
                'A otros ciudadanos solo se les muestra un punto aproximado.'),
            _Legal('La IA sugiere, una persona decide',
                'Un administrador revisa la prioridad antes de actuar.'),
          ]),
        ],
      ),
    );
  }
}

class _Legal extends StatelessWidget {
  final String titulo;
  final String texto;
  const _Legal(this.titulo, this.texto);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(14),
        bottomRight: Radius.circular(14),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 3, color: AppColors.primary),
            Expanded(
              child: Container(
                color: AppColors.surface,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(texto,
                        style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================= CTA =============================
class CtaSection extends StatelessWidget {
  const CtaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      sinPaddingSuperior: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 44),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          children: [
            Text(
              'Lleva RESCATE360 en tu bolsillo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize:
                    Responsive.valor(context, movil: 24.0, escritorio: 34.0),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 520),
              child: Text(
                'Disponible para Android e iOS. Estamos en desarrollo: pronto tendrás el enlace de descarga.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, height: 1.5, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: 240,
              child: PrimaryButton(
                label: 'Descargar app',
                onPressed: () => LandingActions.descargarApp(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
