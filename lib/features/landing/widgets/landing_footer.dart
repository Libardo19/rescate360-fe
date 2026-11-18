import 'package:flutter/material.dart';
import 'package:rescate360/features/landing/presentation/landing_actions.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/rescate_logo.dart';
import 'landing_section.dart';

class LandingFooter extends StatelessWidget {
  const LandingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    const estilo =
        TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondary);
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: SectionContainer(
        vertical: 40,
        child: Wrap(
          spacing: 40,
          runSpacing: 24,
          alignment: WrapAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RescateLogo(),
                SizedBox(height: 8),
                Text(
                    'Universidad Popular del Cesar · Ingeniería de Software II',
                    style: estilo),
              ],
            ),
            Wrap(
              spacing: 20,
              runSpacing: 8,
              children: [
                for (final e in const [
                  ('Cómo funciona', LandingActions.rutaComoFunciona),
                  ('Ciudadanos', LandingActions.rutaCiudadanos),
                  ('Organizaciones', LandingActions.rutaOrganizaciones),
                ])
                  InkWell(
                    onTap: () => LandingActions.ir(context, e.$2),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(e.$1, style: estilo),
                    ),
                  ),
              ],
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 420),
              child: Text(
                'Libardo José Acosta García, Sergio Eli Saucedo,Oscar Javier Ávila Ovallos y Elkin Andres Bacci Cabrera.\n'
                'En riesgo vital, llama al 123.',
                style: estilo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
