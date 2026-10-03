import 'package:fletway_mobile/app/theme.dart';
import 'package:fletway_mobile/features/carrier/zonas/data/zonas_repository.dart';
import 'package:fletway_mobile/features/carrier/zonas/presentation/zonas_screen.dart';
import 'package:fletway_mobile/shared/models/zona.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockZonasRepository extends Mock implements ZonasRepository {}

void main() {
  testWidgets('agrupa por provincia y guarda la selección', (tester) async {
    tester.view.physicalSize = const Size(1080, 4000);
    addTearDown(tester.view.reset);
    final repo = MockZonasRepository();
    when(() => repo.catalogo()).thenAnswer(
      (_) async => const [
        Zona(id: 'z1', nombre: 'San Isidro', provincia: 'Buenos Aires'),
        Zona(id: 'z2', nombre: 'Tigre', provincia: 'Buenos Aires'),
        Zona(
            id: 'z3',
            nombre: 'Ciudad Autónoma de Buenos Aires',
            provincia: 'CABA'),
      ],
    );
    when(() => repo.mias()).thenAnswer((_) async => {'z1'});
    when(() => repo.guardar(any())).thenAnswer(
      (i) async => i.positionalArguments.first as Set<String>,
    );
    final router = GoRouter(
      initialLocation: '/z',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const Text('inicio')),
        GoRoute(path: '/z', builder: (_, __) => const ZonasScreen()),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [zonasRepositoryProvider.overrideWithValue(repo)],
        child:
            MaterialApp.router(theme: FletwayTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Buenos Aires'), findsOneWidget);
    expect(find.text('CABA'), findsOneWidget);
    expect(find.text('Guardar 1 zona'), findsOneWidget);

    await tester.tap(find.text('Tigre'));
    await tester.tap(find.text('San Isidro'));
    await tester.pump();
    await tester.tap(find.text('Guardar 1 zona'));
    await tester.pumpAndSettle();

    verify(() => repo.guardar({'z2'})).called(1);
  });
}
