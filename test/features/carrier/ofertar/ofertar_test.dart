import 'package:fletway_mobile/app/app.dart' show localeApp;
import 'package:fletway_mobile/app/theme.dart';
import 'package:fletway_mobile/core/error/failure.dart';
import 'package:fletway_mobile/core/network/api_exception.dart';
import 'package:fletway_mobile/features/carrier/ofertar/data/oferta_dto.dart';
import 'package:fletway_mobile/features/carrier/ofertar/data/ofertas_repository.dart';
import 'package:fletway_mobile/features/carrier/ofertar/presentation/armar_oferta_screen.dart';
import 'package:fletway_mobile/features/carrier/ofertar/presentation/mis_ofertas_screen.dart';
import 'package:fletway_mobile/features/carrier/solicitudes/data/solicitudes_compatibles_repository.dart';
import 'package:fletway_mobile/features/carrier/vehiculo/data/vehiculo_dto.dart';
import 'package:fletway_mobile/features/carrier/vehiculo/data/vehiculo_repository.dart';
import 'package:fletway_mobile/shared/extensions/numeros.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

class MockOfertas extends Mock implements OfertasRepository {}

class MockVehiculos extends Mock implements VehiculoRepository {}

class MockSolicitudes extends Mock
    implements SolicitudesCompatiblesRepository {}

Vehiculo _vehiculo(String id, {bool activo = true, bool costos = true}) =>
    Vehiculo(
      id: id,
      tipoVehiculoId: 't',
      tipoVehiculoNombre: 'Furgón chico',
      patente: 'AB${id}CD',
      largoUtilM: 2.4,
      anchoUtilM: 1.45,
      altoUtilM: 1.15,
      pesoMaximoKg: 650,
      activo: activo,
      tieneCostos: costos,
    );

const _desglose = DesgloseOferta(
  distanciaKm: 18.4,
  duracionRutaH: 0.61,
  duracionOperacionH: 0.52,
  costoLaboral: 42210.33,
  costoVehiculo: 9120.5,
  costosAdicionales: 0,
  costoOperativo: 51330.83,
  margenPct: 0,
  precioNeto: 60389.21,
  porcentajeComision: 15,
  ivaPct: 21,
);

Cotizacion _cotizacion(int ayudantes, double precio) => Cotizacion(
      cantidadViajes: 2,
      cantidadAyudantes: ayudantes,
      precioCalculado: precio,
      desglose: _desglose,
    );

Oferta _oferta(String estado) => Oferta(
      id: 'o1',
      estado: estado,
      solicitudId: 's1',
      solicitudEstado: 'publicada',
      fechaServicioDeseada: '2026-10-12',
      origenZonaNombre: 'San Isidro',
      destinoZonaNombre: 'CABA',
      vehiculoId: '1',
      vehiculoPatente: 'AB1CD',
      vehiculoTipo: 'Furgón chico',
      cantidadViajes: 1,
      cantidadAyudantes: 1,
      precioCalculado: 73070.94,
      desglose: _desglose,
    );

void main() {
  late MockOfertas ofertas;
  late MockVehiculos vehiculos;
  late MockSolicitudes solicitudes;

  setUpAll(() => initializeDateFormatting('es_AR'));
  setUp(() {
    ofertas = MockOfertas();
    vehiculos = MockVehiculos();
    solicitudes = MockSolicitudes();
    when(() => solicitudes.detalle(any()))
        .thenAnswer((_) async => throw Exception('sin detalle'));
  });

  Future<void> montar(WidgetTester tester, String inicial) async {
    tester.view.physicalSize = const Size(1080, 3200);
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: inicial,
      routes: [
        GoRoute(
          path: '/ofertar',
          builder: (_, __) => const ArmarOfertaScreen(solicitudId: 's1'),
        ),
        GoRoute(
          path: '/transportista/ofertas',
          builder: (_, __) => const MisOfertasScreen(),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ofertasRepositoryProvider.overrideWithValue(ofertas),
          vehiculoRepositoryProvider.overrideWithValue(vehiculos),
          solicitudesCompatiblesRepositoryProvider
              .overrideWithValue(solicitudes),
        ],
        child: MaterialApp.router(
          theme: FletwayTheme.light,
          locale: localeApp,
          supportedLocales: const [localeApp],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('armar oferta', () {
    testWidgets('cotiza al elegir vehículo y ayudantes, y envía',
        (tester) async {
      when(() => vehiculos.propios()).thenAnswer((_) async => [
            _vehiculo('1'),
            _vehiculo('2', costos: false),
          ]);
      when(() => ofertas.cotizar('s1', vehiculoId: '1', ayudantes: 0))
          .thenAnswer((_) async => _cotizacion(0, 80000));
      when(() => ofertas.cotizar('s1', vehiculoId: '1', ayudantes: 2))
          .thenAnswer((_) async => _cotizacion(2, 98456.12));
      when(() => ofertas.ofertar('s1', vehiculoId: '1', ayudantes: 2))
          .thenAnswer((_) async => _oferta('pendiente'));
      when(() => ofertas.propias()).thenAnswer((_) async => []);

      await montar(tester, '/ofertar');
      expect(
          find.text('Elegí un vehículo para ver el precio.'), findsOneWidget);
      expect(find.text('Cargá sus costos para ofertar con él'), findsOneWidget,
          reason: 'el vehículo sin costos se explica, no se oculta');

      await tester.tap(find.text('Furgón chico · AB1CD'));
      await tester.pumpAndSettle();
      expect(find.text(80000.pesos), findsOneWidget);

      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();
      expect(find.text(98456.12.pesos), findsOneWidget);
      expect(find.textContaining('2 viajes · 2 ayudantes'), findsOneWidget);

      await tester.tap(find.text('Enviar oferta'));
      await tester.pumpAndSettle();
      expect(find.textContaining('El Cliente va a ver ${98456.12.pesos}'),
          findsOneWidget);
      await tester.tap(find.text('Enviar'));
      await tester.pumpAndSettle();

      verify(() => ofertas.ofertar('s1', vehiculoId: '1', ayudantes: 2))
          .called(1);
      expect(find.text('Mis ofertas'), findsOneWidget);
    });

    testWidgets('muestra por qué la carga no entra y no deja enviar',
        (tester) async {
      when(() => vehiculos.propios()).thenAnswer((_) async => [_vehiculo('1')]);
      when(() => ofertas.cotizar('s1', vehiculoId: '1', ayudantes: 0))
          .thenThrow(ApiException(
        code: 'carga_no_factible',
        message: 'la carga no se puede llevar con este vehículo',
        details: {
          'motivos': [
            'Heladera: no entra en la posición en que tiene que viajar'
          ],
        },
      ));

      await montar(tester, '/ofertar');
      await tester.tap(find.text('Furgón chico · AB1CD'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining(
            '- Heladera: no entra en la posición en que tiene que viajar'),
        findsOneWidget,
      );
      final boton = tester.widget<FilledButton>(find.ancestor(
        of: find.text('Enviar oferta'),
        matching: find.byWidgetPredicate((w) => w is FilledButton),
      ));
      expect(boton.onPressed, isNull);
    });

    testWidgets('sin vehículos invita a cargar uno', (tester) async {
      when(() => vehiculos.propios()).thenAnswer((_) async => []);
      await montar(tester, '/ofertar');
      expect(find.text('Agregar vehículo'), findsOneWidget);
    });
  });

  group('mis ofertas', () {
    testWidgets('vacía invita a ver solicitudes', (tester) async {
      when(() => ofertas.propias()).thenAnswer((_) async => []);
      await montar(tester, '/transportista/ofertas');
      expect(find.text('Ver solicitudes'), findsOneWidget);
    });

    testWidgets('retira una oferta pendiente', (tester) async {
      when(() => ofertas.propias())
          .thenAnswer((_) async => [_oferta('pendiente')]);
      when(() => ofertas.retirar('o1'))
          .thenAnswer((_) async => _oferta('retirada'));

      await montar(tester, '/transportista/ofertas');
      expect(find.text('San Isidro → CABA'), findsOneWidget);
      expect(find.text('Esperando al Cliente'), findsOneWidget);
      expect(find.text(73070.94.pesos), findsOneWidget);

      await tester.tap(find.text('Retirar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retirar').last);
      await tester.pumpAndSettle();

      verify(() => ofertas.retirar('o1')).called(1);
      expect(find.text('Retirada'), findsOneWidget);
      expect(find.text('Retirar'), findsNothing);
    });
  });

  group('formatos y errores', () {
    test('pesos y duración', () {
      expect(98456.1.pesos, '\$ 98.456,10');
      expect(0.75.duracion, '45 min');
      expect(1.0833.duracion, '1 h 5 min');
      expect(2.0.duracion, '2 h');
    });

    test('un código sin detalles usa el texto fijo', () {
      final f =
          Failure.from(ApiException(code: 'oferta_duplicada', message: 'x'));
      expect(f.message, contains('Ya tenés una oferta vigente'));
    });
  });
}
