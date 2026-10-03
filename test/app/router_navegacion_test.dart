import 'package:fletway_mobile/app/router.dart';
import 'package:fletway_mobile/app/theme.dart';
import 'package:fletway_mobile/core/auth/auth_repository.dart';
import 'package:fletway_mobile/core/auth/perfil_repository.dart';
import 'package:fletway_mobile/features/carrier/habilitacion/data/habilitacion_dto.dart';
import 'package:fletway_mobile/features/carrier/habilitacion/data/habilitacion_repository.dart';
import 'package:fletway_mobile/features/carrier/habilitacion/presentation/habilitacion_screen.dart';
import 'package:fletway_mobile/features/carrier/inicio/presentation/inicio_transportista_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../support/fakes.dart';

class MockHabilitacionRepository extends Mock
    implements HabilitacionRepository {}

/// Navegación real del router con la sesión de un Transportista. Cubre que
/// go_router no vuelve a pasar por el redirect al hacer pop.
void main() {
  late MockAuthRepository authRepo;
  late MockPerfilRepository perfilRepo;
  late MockHabilitacionRepository habilitacionRepo;

  Future<void> montar(WidgetTester tester, String estado) async {
    authRepo = MockAuthRepository();
    perfilRepo = MockPerfilRepository();
    habilitacionRepo = MockHabilitacionRepository();
    configurarAuth(authRepo, sesionInicial: sesion('t1'));
    when(() => perfilRepo.me()).thenAnswer(
      (_) async =>
          perfil(id: 't1', rol: 'transportista', estadoHabilitacion: estado),
    );
    when(() => habilitacionRepo.obtener()).thenAnswer(
      (_) async => MiHabilitacion(estadoHabilitacion: estado, documentos: []),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
          perfilRepositoryProvider.overrideWithValue(perfilRepo),
          habilitacionRepositoryProvider.overrideWithValue(habilitacionRepo),
        ],
        child: Consumer(
          builder: (context, ref, _) => MaterialApp.router(
            theme: FletwayTheme.light,
            routerConfig: ref.watch(routerProvider),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('el pendiente no puede volver al inicio del Transportista', (
    tester,
  ) async {
    await montar(tester, 'pendiente');

    expect(find.byType(HabilitacionScreen), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);

    // El atrás del sistema no lo saca de la documentación (sale de la app).
    final manejado = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(manejado, isFalse);
    expect(find.byType(InicioTransportistaScreen), findsNothing);
  });

  testWidgets('el habilitado abre la documentación y vuelve a su inicio', (
    tester,
  ) async {
    await montar(tester, 'habilitado');
    expect(find.byType(InicioTransportistaScreen), findsOneWidget);

    await tester.tap(find.text('Mi documentación'));
    await tester.pumpAndSettle();
    expect(find.byType(HabilitacionScreen), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(InicioTransportistaScreen), findsOneWidget);
  });
}
