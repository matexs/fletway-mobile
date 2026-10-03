import 'package:fletway_mobile/app/theme.dart';
import 'package:fletway_mobile/core/auth/auth_controller.dart';
import 'package:fletway_mobile/core/auth/auth_repository.dart';
import 'package:fletway_mobile/core/auth/perfil_repository.dart';
import 'package:fletway_mobile/features/carrier/inicio/data/disponibilidad_repository.dart';
import 'package:fletway_mobile/features/carrier/inicio/presentation/inicio_transportista_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/fakes.dart';

class MockDisponibilidadRepository extends Mock
    implements DisponibilidadRepository {}

void main() {
  testWidgets('el interruptor cambia la disponibilidad en la sesión', (
    tester,
  ) async {
    final authRepo = MockAuthRepository();
    final perfilRepo = MockPerfilRepository();
    final repo = MockDisponibilidadRepository();
    configurarAuth(authRepo, sesionInicial: sesion('t1'));
    final habilitado = perfil(
      id: 't1',
      rol: 'transportista',
      estadoHabilitacion: 'habilitado',
    ).copyWith(disponible: true);
    when(() => perfilRepo.me()).thenAnswer((_) async => habilitado);
    when(
      () => repo.cambiar(disponible: false),
    ).thenAnswer((_) async => habilitado.copyWith(disponible: false));

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepo),
        perfilRepositoryProvider.overrideWithValue(perfilRepo),
        disponibilidadRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    container.read(authControllerProvider);
    await tester.runAsync(pumpEventQueue);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: FletwayTheme.light,
          home: const InicioTransportistaScreen(),
        ),
      ),
    );
    expect(
      find.text('Te avisamos de las solicitudes nuevas de tus zonas.'),
      findsOneWidget,
    );

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    verify(() => repo.cambiar(disponible: false)).called(1);
    expect(container.read(authControllerProvider).user!.disponible, isFalse);
    expect(find.text('No te llegan solicitudes nuevas.'), findsOneWidget);
  });
}
