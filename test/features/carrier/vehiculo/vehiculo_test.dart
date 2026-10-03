import 'package:fletway_mobile/app/theme.dart';
import 'package:fletway_mobile/features/carrier/vehiculo/application/validadores_vehiculo.dart';
import 'package:fletway_mobile/features/carrier/vehiculo/data/vehiculo_dto.dart';
import 'package:fletway_mobile/features/carrier/vehiculo/data/vehiculo_repository.dart';
import 'package:fletway_mobile/features/carrier/vehiculo/presentation/alta_vehiculo_screen.dart';
import 'package:fletway_mobile/features/carrier/vehiculo/presentation/costos_vehiculo_screen.dart';
import 'package:fletway_mobile/features/carrier/vehiculo/presentation/vehiculos_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockVehiculoRepository extends Mock implements VehiculoRepository {}

const _furgon = TipoVehiculo(
  id: 't2',
  nombre: 'Furgón chico',
  largoEstandarM: 2.5,
  anchoEstandarM: 1.5,
  altoEstandarM: 1.2,
  pesoMaximoEstandarKg: 700,
);

const _vehiculo = Vehiculo(
  id: 'v1',
  tipoVehiculoId: 't2',
  tipoVehiculoNombre: 'Furgón chico',
  patente: 'AB123CD',
  largoUtilM: 2.4,
  anchoUtilM: 1.45,
  altoUtilM: 1.15,
  pesoMaximoKg: 650,
  activo: true,
  tieneCostos: false,
);

void main() {
  late MockVehiculoRepository repo;

  setUpAll(() {
    registerFallbackValue(
      const NuevoVehiculo(
        tipoVehiculoId: '',
        patente: '',
        largoUtilM: 0,
        anchoUtilM: 0,
        altoUtilM: 0,
        pesoMaximoKg: 0,
      ),
    );
    registerFallbackValue(
      const CostosVehiculo(
        combustiblePrecioL: 0,
        rendimientoKmL: 0,
        cantidadNeumaticos: 0,
        costoNeumatico: 0,
        vidaNeumaticoKm: 0,
        costoMantenimientoKm: 0,
        valorCompra: 0,
        valorResidual: 0,
        vidaUtilKm: 0,
        seguroMensual: 0,
        patenteMensual: 0,
      ),
    );
  });

  setUp(() => repo = MockVehiculoRepository());

  /// Monta [inicial] dentro de un router mínimo con las rutas de vehículos.
  Future<void> montar(WidgetTester tester, String inicial) async {
    tester.view.physicalSize = const Size(1080, 6000);
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: inicial,
      routes: [
        GoRoute(path: '/', builder: (_, __) => const Text('inicio')),
        GoRoute(path: '/v', builder: (_, __) => const VehiculosScreen()),
        GoRoute(
          path: '/transportista/vehiculos/nuevo',
          builder: (_, __) => const AltaVehiculoScreen(),
        ),
        GoRoute(
          path: '/transportista/vehiculos/:id/costos',
          builder: (_, s) =>
              CostosVehiculoScreen(vehiculoId: s.pathParameters['id']!),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [vehiculoRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp.router(
          theme: FletwayTheme.light,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder campo(String etiqueta) => find.widgetWithText(TextFormField, etiqueta);

  group('ValidadoresVehiculo', () {
    for (final (valor, valido) in [
      ('AB123CD', true),
      ('abc 123', true),
      ('ab-123-cd', true),
      ('1234', false),
      ('ABC12', false),
    ]) {
      test('patente "$valor"', () {
        expect(ValidadoresVehiculo.patente(valor) == null, valido);
      });
    }

    test('rango con mínimo exclusivo', () {
      final v = ValidadoresVehiculo.rango(min: 0, max: 3, minExclusivo: true);
      expect(v('0'), isNotNull);
      expect(v('3,5'), isNotNull);
      expect(v('1,45'), isNull);
    });
  });

  testWidgets('el tipo propone sus medidas y el alta manda las corregidas', (
    tester,
  ) async {
    when(() => repo.tipos()).thenAnswer((_) async => [_furgon]);
    when(() => repo.crear(any())).thenAnswer((_) async => _vehiculo);
    when(() => repo.costos(any())).thenAnswer((_) async => null);
    await montar(tester, '/transportista/vehiculos/nuevo');

    await tester.tap(find.text('Tipo de vehículo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Furgón chico').last);
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextFormField>(campo('Largo')).controller!.text,
      '2,5',
      reason: 'propone la medida estándar del tipo',
    );

    await tester.enterText(campo('Patente'), 'ab 123 cd');
    await tester.enterText(campo('Largo'), '2,4');
    await tester.tap(find.text('Guardar y cargar costos'));
    await tester.pumpAndSettle();

    final enviado =
        verify(() => repo.crear(captureAny())).captured.single as NuevoVehiculo;
    expect(enviado.patente, 'AB123CD');
    expect(enviado.largoUtilM, 2.4);
    expect(enviado.anchoUtilM, 1.5);
    expect(enviado.pesoMaximoKg, 700);
    expect(
      find.byType(CostosVehiculoScreen),
      findsOneWidget,
      reason: 'sigue el segundo paso: costos',
    );
  });

  testWidgets('costos: valida el residual y manda los números', (tester) async {
    when(() => repo.costos('v1')).thenAnswer((_) async => null);
    when(
      () => repo.guardarCostos(any(), any()),
    ).thenAnswer((i) async => i.positionalArguments[1] as CostosVehiculo);
    await montar(tester, '/transportista/vehiculos/v1/costos');

    final valores = {
      'Precio del combustible': '1350,50',
      'Rendimiento': '9,5',
      'Cantidad de neumáticos': '4',
      'Precio de un neumático': '185000',
      'Duración de un neumático': '50000',
      'Mantenimiento por kilómetro': '45,75',
      'Valor del vehículo': '28000000',
      'Valor al final de su vida útil': '30000000',
      'Vida útil': '400000',
      'Seguro': '95000',
      'Patente': '38000',
    };
    for (final e in valores.entries) {
      await tester.enterText(campo(e.key), e.value);
    }
    await tester.tap(find.text('Guardar costos'));
    await tester.pumpAndSettle();
    expect(
        find.text('No puede superar el valor del vehículo.'), findsOneWidget);
    verifyNever(() => repo.guardarCostos(any(), any()));

    await tester.enterText(campo('Valor al final de su vida útil'), '9000000');
    await tester.tap(find.text('Guardar costos'));
    await tester.pumpAndSettle();
    final c = verify(() => repo.guardarCostos('v1', captureAny()))
        .captured
        .single as CostosVehiculo;
    expect(c.combustiblePrecioL, 1350.5);
    expect(c.costoMantenimientoKm, 45.75);
    expect(c.cantidadNeumaticos, 4);
    expect(c.valorResidual, 9000000);
  });

  testWidgets('listado avisa los costos faltantes y desactiva', (tester) async {
    when(() => repo.propios()).thenAnswer((_) async => [_vehiculo]);
    when(
      () => repo.cambiarActivo('v1', activo: false),
    ).thenAnswer((_) async => _vehiculo.copyWith(activo: false));
    await montar(tester, '/v');

    expect(find.text('Furgón chico · AB123CD'), findsOneWidget);
    expect(
      find.text(
          'Faltan los costos: sin ellos no podés ofertar con este vehículo.'),
      findsOneWidget,
    );
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    verify(() => repo.cambiarActivo('v1', activo: false)).called(1);
    expect(find.text('Inactivo: no se usa para ofertar.'), findsOneWidget);
  });
}
