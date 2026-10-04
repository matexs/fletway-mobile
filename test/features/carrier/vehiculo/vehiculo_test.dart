import 'package:fletway_mobile/app/theme.dart';
import 'package:fletway_mobile/features/carrier/vehiculo/application/validadores_vehiculo.dart';
import 'package:fletway_mobile/features/carrier/vehiculo/data/vehiculo_dto.dart';
import 'package:fletway_mobile/features/carrier/vehiculo/data/vehiculo_repository.dart';
import 'package:fletway_mobile/features/carrier/vehiculo/presentation/alta_vehiculo_screen.dart';
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
    when(() => repo.propios()).thenAnswer((_) async => []);
    await montar(tester, '/v');
    await tester.tap(find.text('Agregar vehículo'));
    await tester.pumpAndSettle();

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
    await tester.tap(find.text('Guardar vehículo'));
    await tester.pumpAndSettle();

    final enviado =
        verify(() => repo.crear(captureAny())).captured.single as NuevoVehiculo;
    expect(enviado.patente, 'AB123CD');
    expect(enviado.largoUtilM, 2.4);
    expect(enviado.anchoUtilM, 1.5);
    expect(enviado.pesoMaximoKg, 700);
    expect(find.byType(VehiculosScreen), findsOneWidget,
        reason: 'vuelve al listado: no hay segundo paso de costos (D-34)');
    expect(find.text('Vehículo AB123CD agregado.'), findsOneWidget);
  });

  testWidgets('listado muestra el vehículo y lo desactiva', (tester) async {
    when(() => repo.propios()).thenAnswer((_) async => [_vehiculo]);
    when(
      () => repo.cambiarActivo('v1', activo: false),
    ).thenAnswer((_) async => _vehiculo.copyWith(activo: false));
    await montar(tester, '/v');

    expect(find.text('Furgón chico · AB123CD'), findsOneWidget);
    expect(find.textContaining('costos'), findsNothing,
        reason: 'los costos son de referencia por tipo (D-34)');
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    verify(() => repo.cambiarActivo('v1', activo: false)).called(1);
    expect(find.text('Inactivo: no se usa para ofertar.'), findsOneWidget);
  });
}
