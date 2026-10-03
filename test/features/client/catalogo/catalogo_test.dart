import 'package:fletway_mobile/app/theme.dart';
import 'package:fletway_mobile/features/client/catalogo/application/catalogo_provider.dart';
import 'package:fletway_mobile/features/client/catalogo/data/catalogo_repository.dart';
import 'package:fletway_mobile/features/client/catalogo/data/objeto_dto.dart';
import 'package:fletway_mobile/features/client/catalogo/presentation/selector_objeto_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCatalogoRepository extends Mock implements CatalogoRepository {}

ObjetoCatalogo objeto(
  String nombre, {
  bool rotacionVertical = true,
  bool apilable = true,
}) =>
    ObjetoCatalogo(
      id: nombre,
      nombre: nombre,
      pesoEstimadoKg: 70,
      largoM: 0.7,
      anchoM: 0.7,
      altoM: 1.8,
      rotacionHorizontal: true,
      rotacionVertical: rotacionVertical,
      apilable: apilable,
    );

void main() {
  final catalogo = [
    objeto('Heladera', rotacionVertical: false, apilable: false),
    objeto('Sofá 2 cuerpos'),
    objeto('Caja mudanza estándar'),
  ];

  group('filtrarObjetos', () {
    for (final (texto, esperados) in [
      ('', ['Heladera', 'Sofá 2 cuerpos', 'Caja mudanza estándar']),
      ('sofa', ['Sofá 2 cuerpos']),
      ('ESTANDAR', ['Caja mudanza estándar']),
      ('  hel ', ['Heladera']),
      ('piano', <String>[]),
    ]) {
      test('"$texto"', () {
        expect(
          filtrarObjetos(catalogo, texto).map((o) => o.nombre),
          esperados,
        );
      });
    }
  });

  testWidgets('busca, muestra restricciones y devuelve el elegido', (
    tester,
  ) async {
    final repo = MockCatalogoRepository();
    when(() => repo.objetos()).thenAnswer((_) async => catalogo);
    ObjetoCatalogo? elegido;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [catalogoRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: FletwayTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async =>
                    elegido = await elegirObjetoDelCatalogo(context),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(find.textContaining('no se acuesta · sin carga encima'),
        findsOneWidget);
    expect(find.textContaining('0,7 × 0,7 × 1,8 m · 70 kg'), findsNWidgets(3));

    await tester.enterText(find.byType(TextFormField), 'piano');
    await tester.pump();
    expect(
      find.textContaining('Podés cargarlo a mano'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextFormField), 'sofa');
    await tester.pump();
    await tester.tap(find.text('Sofá 2 cuerpos'));
    await tester.pumpAndSettle();
    expect(elegido?.nombre, 'Sofá 2 cuerpos');
  });
}
