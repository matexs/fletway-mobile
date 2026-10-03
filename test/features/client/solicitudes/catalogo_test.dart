import 'package:fletway_mobile/app/theme.dart';
import 'package:fletway_mobile/features/client/solicitudes/application/catalogo_provider.dart';
import 'package:fletway_mobile/features/client/solicitudes/data/catalogo_repository.dart';
import 'package:fletway_mobile/features/client/solicitudes/data/objeto_dto.dart';
import 'package:fletway_mobile/features/client/solicitudes/presentation/selector_objeto_sheet.dart';
import 'package:fletway_mobile/features/client/solicitudes/presentation/widgets/icono_objeto.dart';
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

  group('iconoDeObjeto', () {
    for (final (nombre, icono) in [
      ('Mesa de luz', Icons.nightlight),
      ('Mesa de comedor', Icons.table_restaurant),
      ('Cama 1 plaza (colchón + base)', Icons.single_bed),
      ('Cama matrimonial (colchón + base)', Icons.king_bed),
      ('Sofá 3 cuerpos', Icons.weekend),
      ('Sillón individual', Icons.chair),
      ('Cómoda / cajonera', Icons.door_sliding),
      ('TV (hasta 55", embalada)', Icons.tv),
      ('Piano de cola', Icons.category_outlined),
    ]) {
      test(nombre, () => expect(iconoDeObjeto(nombre), icono));
    }
  });

  test('los 28 objetos del catálogo semilla tienen ícono propio', () {
    // Nombres de la migración 0009 del backend.
    const nombres = [
      'Aire acondicionado split (embalado)',
      'Biblioteca / estantería',
      'Bicicleta',
      'Bulto de ropa / valija',
      'Caja mudanza chica',
      'Caja mudanza estándar',
      'Caja mudanza grande',
      'Cama 1 plaza (colchón + base)',
      'Cama 2 plazas (colchón + base)',
      'Cama matrimonial (colchón + base)',
      'Cómoda / cajonera',
      'Escritorio',
      'Espejo / cuadro grande',
      'Estufa / calefactor portátil',
      'Heladera',
      'Horno eléctrico / anafe',
      'Lavarropas',
      'Lavavajillas',
      'Mesa de comedor',
      'Mesa de luz',
      'Mesa ratona',
      'Microondas',
      'Ropero / placard 2 cuerpos',
      'Silla (comedor)',
      'Sillón individual',
      'Sofá 2 cuerpos',
      'Sofá 3 cuerpos',
      'TV (hasta 55", embalada)'
    ];
    for (final n in nombres) {
      expect(iconoDeObjeto(n), isNot(Icons.category_outlined), reason: n);
    }
  });
}
