import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rescate360/features/auth/presentation/views/login_screen.dart';

void main() {
  testWidgets('el login valida el correo antes de llamar a la API', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: LoginScreen())));

    await tester.tap(find.text('Iniciar sesión').last);
    await tester.pump();
    expect(find.text('El correo es obligatorio'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'no-es-correo');
    await tester.tap(find.text('Iniciar sesión').last);
    await tester.pump();
    expect(find.text('Ingresa un correo válido'), findsOneWidget);

    // Accesos de la conexión: recuperar contraseña y activar cuenta de voluntario
    expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);
    expect(find.textContaining('Activa tu cuenta', findRichText: true), findsOneWidget);
  });
}
