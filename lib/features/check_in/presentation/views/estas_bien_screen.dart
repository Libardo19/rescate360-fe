import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../viewmodels/check_in_viewmodel.dart';

/// "¿Estás bien?" a pantalla completa, con la cuenta regresiva hasta que se avise a los
/// contactos de emergencia.
class EstasBienScreen extends ConsumerStatefulWidget {
  const EstasBienScreen({super.key});

  @override
  ConsumerState<EstasBienScreen> createState() => _EstasBienScreenState();
}

class _EstasBienScreenState extends ConsumerState<EstasBienScreen> {
  Timer? _reloj;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _reloj = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _reloj?.cancel();
    super.dispose();
  }

  Future<void> _responder(bool aSalvo) async {
    setState(() => _enviando = true);
    final error = await ref.read(checkInProvider.notifier).responder(aSalvo: aSalvo);
    if (!mounted) return;
    if (error != null) {
      setState(() => _enviando = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    final mensajero = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    mensajero.showSnackBar(SnackBar(
      content: Text(aSalvo
          ? 'Gracias. Quedó registrado que estás a salvo.'
          : 'Pedimos ayuda con tu ubicación y avisamos a tus contactos de emergencia.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final check = ref.watch(checkInProvider);
    final restante = check == null ? Duration.zero : check.venceEn.difference(DateTime.now());
    final segundos = restante.isNegative ? 0 : restante.inSeconds;
    final reloj = '${(segundos ~/ 60).toString().padLeft(2, '0')}:${(segundos % 60).toString().padLeft(2, '0')}';

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.health_and_safety_outlined, size: 72, color: AppColors.warning),
                const SizedBox(height: 16),
                const Text('¿Estás bien?', textAlign: TextAlign.center, style: AppTextStyles.h1),
                const SizedBox(height: 10),
                Text(
                  check?.motivo == 'sismo' ? 'Hubo un sismo cerca de tu ubicación.' : 'Activaste el modo emergencia.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 24),
                Text(reloj, textAlign: TextAlign.center, style: AppTextStyles.h1.copyWith(color: AppColors.danger)),
                const SizedBox(height: 6),
                const Text(
                  'Si no respondes, avisaremos a tus contactos de emergencia con tu última ubicación.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
                const Spacer(),
                PrimaryButton(
                  label: 'Estoy a salvo',
                  icon: Icons.check_circle_outline,
                  loading: _enviando,
                  onPressed: _enviando ? null : () => _responder(true),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Necesito ayuda',
                  icon: Icons.sos,
                  outlined: true,
                  onPressed: _enviando ? null : () => _responder(false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
