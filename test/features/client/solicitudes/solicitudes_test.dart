import 'package:fletway_mobile/app/app.dart' show localeApp;
import 'package:fletway_mobile/app/theme.dart';
import 'package:fletway_mobile/features/client/solicitudes/application/borrador_solicitud.dart';
import 'package:fletway_mobile/features/client/solicitudes/application/validadores_solicitud.dart';
import 'package:fletway_mobile/features/client/solicitudes/data/catalogo_repository.dart';
import 'package:fletway_mobile/features/client/solicitudes/data/objeto_dto.dart';
import 'package:fletway_mobile/features/client/solicitudes/data/solicitud_dto.dart';
import 'package:fletway_mobile/features/client/solicitudes/data/solicitudes_repository.dart';
import 'package:fletway_mobile/features/client/solicitudes/presentation/detalle_solicitud_screen.dart';
import 'package:fletway_mobile/features/client/solicitudes/presentation/mis_solicitudes_screen.dart';
import 'package:fletway_mobile/features/client/solicitudes/presentation/publicar_solicitud_screen.dart';
import 'package:fletway_mobile/shared/extensions/fechas.dart';
import 'package:fletway_mobile/shared/models/zona.dart';
import 'package:fletway_mobile/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

class MockSolicitudesRepository extends Mock implements SolicitudesRepository {}

class MockCatalogoRepository extends Mock implements CatalogoRepository {}

const _heladera = ObjetoCatalogo(
  id: 'o1',
  nombre: 'Heladera',
  pesoEstimadoKg: 70,
  largoM: 0.7,
  anchoM: 0.7,
  altoM: 1.8,
  rotacionHorizontal: true,
  rotacionVertical: false,
  apilable: false,
);

const _zonas = [
  Zona(id: 'z1', nombre: 'San Isidro', provincia: 'Buenos Aires'),
  Zona(id: 'z2', nombre: 'Ciudad Autónoma de Buenos Aires', provincia: 'CABA'),
];

const _punto = PuntoSolicitud(
  zonaId: 'z1',
  zonaNombre: 'San Isidro',
  direccion: 'Av. Centenario 1200',
  pisos: 2,
  ascensorUtilizable: false,
  distanciaVehiculoM: 15.5,
);

Solicitud solicitud(String estado) => Solicitud(
      id: 's1',
      estado: estado,
      fechaServicioDeseada: '2026-10-12',
      origen: _punto,
      destino:
          _punto.copyWith(zonaNombre: 'CABA', direccion: 'Corrientes 3500'),
      cantidadAyudantesSolicitados: 2,
      objetos: const [
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
    );

void main() {
  late MockSolicitudesRepository repo;
  late MockCatalogoRepository catalogo;

  setUpAll(() async {
    await initializeDateFormatting('es_AR');
    registerFallbackValue(
      const NuevaSolicitud(
        origen: PuntoNuevo(
          zonaId: '',
          direccion: '',
          pisos: 0,
          ascensorUtilizable: false,
          distanciaVehiculoM: 0,
        ),
        destino: PuntoNuevo(
          zonaId: '',
          direccion: '',
          pisos: 0,
          ascensorUtilizable: false,
          distanciaVehiculoM: 0,
        ),
        fechaServicioDeseada: '',
        cantidadAyudantesSolicitados: 0,
        objetos: [],
      ),
    );
  });

  setUp(() {
    repo = MockSolicitudesRepository();
    catalogo = MockCatalogoRepository();
    when(() => repo.zonas()).thenAnswer((_) async => _zonas);
    when(() => catalogo.objetos()).thenAnswer((_) async => [_heladera]);
  });

  Future<void> montar(WidgetTester tester, String inicial) async {
    tester.view.physicalSize = const Size(1080, 7000);
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: inicial,
      routes: [
        GoRoute(path: '/', builder: (_, __) => const MisSolicitudesScreen()),
        GoRoute(
            path: '/nueva',
            builder: (_, __) => const PublicarSolicitudScreen()),
        GoRoute(
          path: '/cliente/solicitudes/:id',
          builder: (_, s) =>
              DetalleSolicitudScreen(solicitudId: s.pathParameters['id']!),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          solicitudesRepositoryProvider.overrideWithValue(repo),
          catalogoRepositoryProvider.overrideWithValue(catalogo),
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

  group('borrador', () {
    test('el mismo objeto del catálogo suma cantidad', () {
      var objetos =
          agregarObjeto([], const ObjetoBorrador.delCatalogo(_heladera));
      objetos =
          agregarObjeto(objetos, const ObjetoBorrador.delCatalogo(_heladera));
      expect(objetos, hasLength(1));
      expect(objetos.single.cantidad, 2);
      expect(pesoTotal(objetos), 140);
    });

    test('del catálogo sólo manda id y cantidad', () {
      final r =
          const ObjetoBorrador.delCatalogo(_heladera, cantidad: 3).aRequest();
      expect(r.objetoId, 'o1');
      expect(r.cantidad, 3);
      expect(r.pesoUnitarioKg, isNull);
      expect(r.largoM, isNull);
    });

    test('a mano manda nombre, medidas y restricciones', () {
      final r = const ObjetoBorrador.manual(
        nombre: 'Piano',
        pesoKg: 250,
        largoM: 1.5,
        anchoM: 0.6,
        altoM: 1.3,
        seAcuesta: false,
      ).aRequest();
      expect(r.objetoId, isNull);
      expect(r.nombrePersonalizado, 'Piano');
      expect(r.rotacionVertical, isFalse);
      expect(r.apilable, isTrue);
    });
  });

  group('validadores', () {
    test('dirección, pisos y distancia', () {
      expect(ValidadoresSolicitud.direccion('Av 1'), isNotNull);
      expect(ValidadoresSolicitud.direccion('Av. Centenario 1200'), isNull);
      expect(ValidadoresSolicitud.pisos('61'), isNotNull);
      expect(ValidadoresSolicitud.pisos('0'), isNull);
      expect(ValidadoresSolicitud.distancia('15,5'), isNull);
      expect(ValidadoresSolicitud.distancia(''), isNotNull);
    });
  });

  test('fechas en es-AR', () {
    final f = DateTime(2026, 10, 12);
    expect(f.paraApi, '2026-10-12');
    expect(f.larga, 'lunes 12 de octubre');
    expect(fechaDesdeApi('2026-10-12'), f);
  });

  testWidgets('publicar sin fecha ni objetos avisa y no envía', (tester) async {
    await montar(tester, '/nueva');
    await tester.tap(find.text('Publicar'));
    await tester.pumpAndSettle();
    expect(find.text('Elegí la fecha del traslado.'), findsOneWidget);
    expect(find.text('Elegí la zona.'), findsNWidgets(2));
    verifyNever(() => repo.publicar(any()));
  });

  testWidgets('publica con objeto del catálogo y sin monto', (tester) async {
    when(() => repo.publicar(any()))
        .thenAnswer((_) async => solicitud('publicada'));
    when(() => repo.detalle('s1'))
        .thenAnswer((_) async => solicitud('publicada'));
    await montar(tester, '/nueva');

    final selectores = find.byType(FletwaySelector<Zona>);
    for (final (i, zona) in [
      (0, 'San Isidro (Buenos Aires)'),
      (1, 'Ciudad Autónoma de Buenos Aires')
    ]) {
      await tester.tap(selectores.at(i));
      await tester.pumpAndSettle();
      await tester.tap(find.text(zona).last);
      await tester.pumpAndSettle();
    }
    final direcciones = find.widgetWithText(TextFormField, 'Dirección');
    await tester.enterText(direcciones.at(0), 'Av. Centenario 1200');
    await tester.enterText(direcciones.at(1), 'Av. Corrientes 3500');

    await tester.tap(find.text('Elegir fecha'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ACEPTAR'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Del catálogo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Heladera'));
    await tester.pumpAndSettle();
    expect(find.text('Peso estimado total: 70 kg'), findsOneWidget);

    await tester.tap(find.text('Publicar'));
    await tester.pumpAndSettle();

    final enviada = verify(() => repo.publicar(captureAny())).captured.single
        as NuevaSolicitud;
    expect(enviada.origen.zonaId, 'z1');
    expect(enviada.destino.direccion, 'Av. Corrientes 3500');
    expect(enviada.fechaServicioDeseada, DateTime.now().paraApi);
    expect(enviada.franjaHorariaInicio, isNull);
    expect(enviada.objetos.single.objetoId, 'o1');
    expect(enviada.objetos.single.pesoUnitarioKg, isNull);
    expect(enviada.toJson().toString(), isNot(contains('monto')));
    expect(find.byType(DetalleSolicitudScreen), findsOneWidget);
  });

  testWidgets('mis solicitudes vacía invita a publicar', (tester) async {
    when(() => repo.propias()).thenAnswer((_) async => []);
    await montar(tester, '/');
    expect(find.textContaining('Todavía no publicaste'), findsOneWidget);
    expect(find.text('Publicar solicitud'), findsOneWidget);
  });

  testWidgets('mis solicitudes muestra el estado', (tester) async {
    when(() => repo.propias()).thenAnswer(
      (_) async => const [
        SolicitudResumen(
          id: 's1',
          estado: 'vencida',
          fechaServicioDeseada: '2026-10-12',
          origenZonaNombre: 'San Isidro',
          destinoZonaNombre: 'CABA',
          cantidadObjetos: 3,
        ),
      ],
    );
    await montar(tester, '/');
    expect(find.text('San Isidro → CABA'), findsOneWidget);
    expect(find.text('lunes 12 de octubre, lo antes posible'), findsOneWidget);
    expect(find.text('Vencida'), findsOneWidget);
  });

  testWidgets('cancelar pide confirmación', (tester) async {
    when(() => repo.detalle('s1'))
        .thenAnswer((_) async => solicitud('publicada'));
    when(() => repo.cancelar('s1'))
        .thenAnswer((_) async => solicitud('cancelada'));
    await montar(tester, '/cliente/solicitudes/s1');

    await tester.tap(find.text('Cancelar solicitud'));
    await tester.pumpAndSettle();
    expect(find.text('¿Cancelar la solicitud?'), findsOneWidget);
    await tester.tap(find.text('Volver'));
    await tester.pumpAndSettle();
    verifyNever(() => repo.cancelar(any()));

    await tester.tap(find.text('Cancelar solicitud'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar solicitud').last);
    await tester.pumpAndSettle();
    verify(() => repo.cancelar('s1')).called(1);
    expect(find.text('Cancelada'), findsOneWidget);
  });

  testWidgets('una vencida ofrece republicar', (tester) async {
    when(() => repo.detalle('s1'))
        .thenAnswer((_) async => solicitud('vencida'));
    await montar(tester, '/cliente/solicitudes/s1');
    expect(find.text('Republicar con otra fecha'), findsOneWidget);
    expect(find.text('Cancelar solicitud'), findsNothing);
    expect(find.text('1 × Heladera'), findsOneWidget);
    expect(find.textContaining('2 pisos por escalera'), findsWidgets);
  });
}
