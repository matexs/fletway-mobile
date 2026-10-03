import 'package:fletway_mobile/app/app.dart' show localeApp;
import 'package:fletway_mobile/app/theme.dart';
import 'package:fletway_mobile/features/carrier/solicitudes/data/solicitud_compatible_dto.dart';
import 'package:fletway_mobile/features/carrier/solicitudes/data/solicitudes_compatibles_repository.dart';
import 'package:fletway_mobile/features/carrier/solicitudes/presentation/detalle_compatible_screen.dart';
import 'package:fletway_mobile/features/carrier/solicitudes/presentation/solicitudes_compatibles_screen.dart';
import 'package:fletway_mobile/shared/models/solicitud.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

class MockRepo extends Mock implements SolicitudesCompatiblesRepository {}

const _punto = PuntoSolicitud(
  zonaId: 'z1',
  zonaNombre: 'San Isidro',
  direccion: 'Av. Centenario 1200',
  pisos: 0,
  ascensorUtilizable: false,
  distanciaVehiculoM: 20,
);

void main() {
  late MockRepo repo;

  setUpAll(() => initializeDateFormatting('es_AR'));
  setUp(() => repo = MockRepo());

  Future<void> montar(WidgetTester tester, String inicial) async {
    tester.view.physicalSize = const Size(1080, 3000);
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: inicial,
      routes: [
        GoRoute(
            path: '/',
            builder: (_, __) => const SolicitudesCompatiblesScreen()),
        GoRoute(
          path: '/transportista/solicitudes/:id',
          builder: (_, s) =>
              DetalleCompatibleScreen(solicitudId: s.pathParameters['id']!),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          solicitudesCompatiblesRepositoryProvider.overrideWithValue(repo)
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

  testWidgets('lista vacía explica por qué y deja actualizar', (tester) async {
    when(() => repo.compatibles()).thenAnswer((_) async => []);
    await montar(tester, '/');
    expect(find.textContaining('Revisá que estés disponible'), findsOneWidget);
    await tester.tap(find.text('Actualizar'));
    await tester.pumpAndSettle();
    verify(() => repo.compatibles()).called(2);
  });

  testWidgets('muestra la carga y abre el detalle', (tester) async {
    when(() => repo.compatibles()).thenAnswer(
      (_) async => const [
        SolicitudCompatible(
          id: 's1',
          fechaServicioDeseada: '2026-10-12',
          franjaHorariaInicio: '09:00',
          franjaHorariaFin: '13:00',
          origenZonaNombre: 'San Isidro',
          destinoZonaNombre: 'CABA',
          cantidadObjetos: 4,
          pesoTotalKg: 400,
          volumenTotalM3: 3.98,
          cantidadAyudantesSolicitados: 2,
        ),
      ],
    );
    when(() => repo.detalle('s1')).thenAnswer(
      (_) async => const Solicitud(
        id: 's1',
        estado: 'publicada',
        fechaServicioDeseada: '2026-10-12',
        origen: _punto,
        destino: _punto,
        cantidadAyudantesSolicitados: 2,
        objetos: [
          ObjetoSolicitud(
            id: 'so1',
            objetoId: 'o1',
            nombre: 'Heladera',
            cantidad: 1,
            pesoUnitarioKg: 70,
            largoM: 0.7,
            anchoM: 0.7,
            altoM: 1.8,
            rotacionHorizontal: true,
            rotacionVertical: false,
            apilable: false,
          ),
        ],
      ),
    );
    await montar(tester, '/');

    expect(find.text('San Isidro → CABA'), findsOneWidget);
    expect(find.text('lunes 12 de octubre, de 09:00 a 13:00'), findsOneWidget);
    expect(find.text('4 objetos · 400 kg · 3,98 m³ · pide 2 ayudantes'),
        findsOneWidget);
    expect(find.textContaining('\$'), findsNothing,
        reason: 'sin montos (RN-01)');

    await tester.tap(find.text('San Isidro → CABA'));
    await tester.pumpAndSettle();
    expect(find.text('1 × Heladera'), findsOneWidget);
    expect(find.textContaining('no se acuesta · sin carga encima'),
        findsOneWidget);
    expect(find.textContaining('20 m a pie'), findsNWidgets(2));
  });
}
