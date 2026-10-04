import 'package:fletway_mobile/app/theme.dart';
import 'package:fletway_mobile/features/client/solicitudes/data/direcciones_repository.dart';
import 'package:fletway_mobile/features/client/solicitudes/presentation/widgets/campo_direccion.dart';
import 'package:fletway_mobile/shared/models/zona.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDirecciones extends Mock implements DireccionesRepository {}

const _zona = Zona(id: 'z1', nombre: 'San Isidro', provincia: 'Buenos Aires');

void main() {
  late MockDirecciones repo;
  late TextEditingController controller;

  setUp(() {
    repo = MockDirecciones();
    controller = TextEditingController();
  });
  tearDown(() => controller.dispose());

  Future<void> montar(WidgetTester tester, {Zona? zona = _zona}) =>
      tester.pumpWidget(
        ProviderScope(
          overrides: [direccionesRepositoryProvider.overrideWithValue(repo)],
          child: MaterialApp(
            theme: FletwayTheme.light,
            home: Scaffold(
              body: CampoDireccion(controller: controller, zona: zona),
            ),
          ),
        ),
      );

  testWidgets('sugiere al dejar de escribir y completa al elegir',
      (tester) async {
    when(() => repo.sugerencias('z1', 'Av Centenario 12')).thenAnswer(
      (_) async => const [
        SugerenciaDireccion(
            direccion: 'Avenida Centenario 1200', detalle: '1642 San Isidro'),
        SugerenciaDireccion(direccion: 'Avenida Centenario', detalle: 'Beccar'),
      ],
    );
    await montar(tester);
    await tester.enterText(find.byType(TextFormField), 'Av Centenario 12');
    await tester.pump(const Duration(milliseconds: 100));
    verifyNever(() => repo.sugerencias(any(), any()));

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(find.text('Avenida Centenario 1200'), findsOneWidget);
    expect(find.text('1642 San Isidro'), findsOneWidget);

    await tester.tap(find.text('Avenida Centenario 1200'));
    await tester.pump();
    expect(controller.text, 'Avenida Centenario 1200');
    expect(find.text('Beccar'), findsNothing, reason: 'se cierran');
  });

  testWidgets('con menos de 3 letras no busca', (tester) async {
    await montar(tester);
    await tester.enterText(find.byType(TextFormField), 'Av');
    await tester.pump(const Duration(seconds: 1));
    verifyNever(() => repo.sugerencias(any(), any()));
  });

  testWidgets('sin zona pide elegirla y no busca', (tester) async {
    await montar(tester, zona: null);
    expect(find.textContaining('Elegí la zona primero'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Av Centenario');
    await tester.pump(const Duration(seconds: 1));
    verifyNever(() => repo.sugerencias(any(), any()));
  });

  testWidgets('si falla, se sigue escribiendo a mano', (tester) async {
    when(() => repo.sugerencias(any(), any())).thenThrow(Exception('sin red'));
    await montar(tester);
    await tester.enterText(find.byType(TextFormField), 'Calle Falsa 123');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    expect(controller.text, 'Calle Falsa 123');
    expect(find.byType(ListTile), findsNothing);
  });
}
