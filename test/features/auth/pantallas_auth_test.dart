import 'package:fletway_mobile/app/theme.dart';
import 'package:fletway_mobile/core/auth/app_user.dart';
import 'package:fletway_mobile/core/auth/auth_repository.dart';
import 'package:fletway_mobile/features/auth/presentation/login_screen.dart';
import 'package:fletway_mobile/features/auth/presentation/registro_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import '../../support/fakes.dart';

void main() {
  late MockAuthRepository repo;

  setUpAll(() => registerFallbackValue(UserRole.cliente));
  setUp(() {
    repo = MockAuthRepository();
    configurarAuth(repo);
  });

  Future<void> montar(WidgetTester tester, Widget pantalla) async {
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(theme: FletwayTheme.light, home: pantalla),
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('valida antes de llamar a Supabase', (tester) async {
      await montar(tester, const LoginScreen());
      await tester.tap(find.text('Ingresar'));
      await tester.pump();

      expect(find.text('Ingresá tu email.'), findsOneWidget);
      expect(find.text('Ingresá tu contraseña.'), findsOneWidget);
      verifyNever(
        () => repo.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    testWidgets('muestra credenciales inválidas', (tester) async {
      when(
        () => repo.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        const AuthException('Invalid login', code: 'invalid_credentials'),
      );
      await montar(tester, const LoginScreen());

      await tester.enterText(
          find.byType(TextFormField).at(0), 'ana@ejemplo.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'secreto123');
      await tester.tap(find.text('Ingresar'));
      await tester.pumpAndSettle();

      expect(find.text('Email o contraseña incorrectos.'), findsOneWidget);
    });
  });

  group('RegistroScreen', () {
    Future<void> completar(WidgetTester tester) async {
      final campos = find.byType(TextFormField);
      await tester.enterText(campos.at(0), 'Tomás Torres');
      await tester.enterText(campos.at(1), '11 5555-0000');
      await tester.enterText(campos.at(2), 'tomas@ejemplo.com');
      await tester.enterText(campos.at(3), 'secreto123');
      await tester.enterText(campos.at(4), 'secreto123');
    }

    testWidgets('manda el rol y el teléfono normalizado en el signUp', (
      tester,
    ) async {
      when(
        () => repo.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          role: any(named: 'role'),
          nombreCompleto: any(named: 'nombreCompleto'),
          telefono: any(named: 'telefono'),
        ),
      ).thenAnswer((_) async => true);
      await montar(tester, const RegistroScreen(rol: UserRole.transportista));

      await completar(tester);
      await tester.tap(find.text('Crear cuenta'));
      await tester.pumpAndSettle();

      verify(
        () => repo.signUp(
          email: 'tomas@ejemplo.com',
          password: 'secreto123',
          role: UserRole.transportista,
          nombreCompleto: 'Tomás Torres',
          telefono: '1155550000',
        ),
      ).called(1);
    });

    testWidgets('las contraseñas tienen que coincidir', (tester) async {
      await montar(tester, const RegistroScreen(rol: UserRole.cliente));
      await completar(tester);
      await tester.enterText(find.byType(TextFormField).at(4), 'otraclave1');
      await tester.tap(find.text('Crear cuenta'));
      await tester.pump();

      expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
    });

    testWidgets('avisa si el email ya existe', (tester) async {
      when(
        () => repo.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          role: any(named: 'role'),
          nombreCompleto: any(named: 'nombreCompleto'),
          telefono: any(named: 'telefono'),
        ),
      ).thenThrow(
        const AuthException('exists', code: 'user_already_exists'),
      );
      await montar(tester, const RegistroScreen(rol: UserRole.cliente));
      await completar(tester);
      await tester.tap(find.text('Crear cuenta'));
      await tester.pumpAndSettle();

      expect(find.text('Ya existe una cuenta con ese email.'), findsOneWidget);
    });
  });
}
