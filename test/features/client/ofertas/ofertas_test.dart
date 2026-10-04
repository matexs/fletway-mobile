import 'package:fletway_mobile/app/app.dart' show localeApp;
import 'package:fletway_mobile/app/theme.dart';
import 'package:fletway_mobile/core/network/api_exception.dart';
import 'package:fletway_mobile/features/client/ofertas/data/oferta_cliente_dto.dart';
import 'package:fletway_mobile/features/client/ofertas/data/ofertas_cliente_repository.dart';
import 'package:fletway_mobile/features/client/perfil/data/perfil_dto.dart';
import 'package:fletway_mobile/features/client/perfil/data/perfil_repository.dart';
import 'package:fletway_mobile/features/client/perfil/presentation/perfil_transportista_screen.dart';
import 'package:fletway_mobile/features/client/solicitudes/data/solicitudes_repository.dart';
import 'package:fletway_mobile/features/client/solicitudes/presentation/detalle_solicitud_screen.dart';
import 'package:fletway_mobile/features/client/viaje/presentation/viaje_confirmado_screen.dart';
import 'package:fletway_mobile/shared/extensions/numeros.dart';
import 'package:fletway_mobile/shared/models/solicitud.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

class MockOfertas extends Mock implements OfertasClienteRepository {}

class MockSolicitudes extends Mock implements SolicitudesRepository {}

class MockPerfil extends Mock implements PerfilTransportistaRepository {}

const _punto = PuntoSolicitud(
  zonaId: 'z1',
  zonaNombre: 'San Isidro',
  direccion: 'Av. Centenario 1200',
  pisos: 0,
  ascensorUtilizable: false,
  distanciaVehiculoM: 0,
);

Solicitud _solicitud(String estado) => Solicitud(
      id: 's1',
      estado: estado,
      fechaServicioDeseada: '2026-10-12',
      origen: _punto,
      destino: _punto,
      cantidadAyudantesSolicitados: 1,
      objetos: const [],
    );

OfertaParaCliente _oferta(String id, String nombre, double precio,
        {double? calificacion, int ayudantes = 1}) =>
    OfertaParaCliente(
      id: id,
      transportistaId: 't-$id',
      transportistaNombre: nombre,
      calificacionPromedio: calificacion,
      cantidadResenas: calificacion == null ? 0 : 8,
      tasaCumplimiento: 100,
      vehiculoTipo: 'Furgón grande',
      cantidadViajes: 1,
      cantidadAyudantes: ayudantes,
      precioCalculado: precio,
    );

const _viaje = ViajeConfirmado(
  id: 'v1',
  solicitudId: 's1',
  transportistaId: 't-o1',
  transportistaNombre: 'Tomás Pérez',
  vehiculoPatente: 'AC456EF',
  vehiculoMarcaModelo: 'Iveco Daily',
  montoTotal: 106900.15,
  cantidadViajes: 1,
  cantidadAyudantes: 1,
  fechaServicioDeseada: '2026-10-12',
  origenDireccion: 'Av. Centenario 1200',
  destinoDireccion: 'Corrientes 3500',
);

void main() {
  late MockOfertas ofertas;
  late MockSolicitudes solicitudes;
  late MockPerfil perfiles;

  setUpAll(() => initializeDateFormatting('es_AR'));
  setUp(() {
    ofertas = MockOfertas();
    solicitudes = MockSolicitudes();
    perfiles = MockPerfil();
    when(() => solicitudes.detalle('s1'))
        .thenAnswer((_) async => _solicitud('publicada'));
  });

  Future<void> montar(WidgetTester tester, String inicial) async {
    tester.view.physicalSize = const Size(1080, 6000);
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: inicial,
      routes: [
        GoRoute(
          path: '/cliente/solicitudes/:id',
          builder: (_, s) =>
              DetalleSolicitudScreen(solicitudId: s.pathParameters['id']!),
        ),
        GoRoute(
          path: '/cliente/transportistas/:id',
          builder: (_, s) => PerfilTransportistaScreen(
              transportistaId: s.pathParameters['id']!),
        ),
        GoRoute(
          path: '/cliente/viajes/:id/confirmado',
          builder: (_, s) =>
              ViajeConfirmadoScreen(viaje: s.extra as ViajeConfirmado?),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ofertasClienteRepositoryProvider.overrideWithValue(ofertas),
          solicitudesRepositoryProvider.overrideWithValue(solicitudes),
          perfilTransportistaRepositoryProvider.overrideWithValue(perfiles),
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

  testWidgets('muestra el top 3, la recomendada y ver más', (tester) async {
    when(() => ofertas.ofertas('s1')).thenAnswer(
      (_) async => OfertasDeSolicitud(
        cantidadAyudantesSolicitados: 1,
        total: 4,
        siguienteCursor: 3,
        ofertas: [
          _oferta('o1', 'Tomás Pérez', 106900.15, calificacion: 4.5),
          _oferta('o2', 'Ana Ruiz', 110000, ayudantes: 2),
          _oferta('o3', 'Luis Gómez', 120000, calificacion: 3),
        ],
      ),
    );
    when(() => ofertas.ofertas('s1', cursor: 3)).thenAnswer(
      (_) async => OfertasDeSolicitud(
        cantidadAyudantesSolicitados: 1,
        total: 4,
        ofertas: [_oferta('o4', 'Marta Díaz', 150000)],
      ),
    );
    await montar(tester, '/cliente/solicitudes/s1');

    expect(find.text('Ofertas (4)'), findsOneWidget);
    expect(find.text('Recomendada'), findsOneWidget);
    expect(find.text(106900.15.pesos), findsOneWidget);
    expect(find.text('4,5 (8 reseñas)'), findsOneWidget);
    expect(find.text('Nuevo en Fletway'), findsOneWidget,
        reason: 'sin reseñas no muestra una calificación');
    expect(find.textContaining('2 ayudantes (pediste 1)'), findsOneWidget);
    expect(find.text('Marta Díaz'), findsNothing);

    await tester.tap(find.text('Ver más ofertas (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Marta Díaz'), findsOneWidget);
    expect(find.textContaining('Ver más ofertas'), findsNothing);
  });

  testWidgets('elegir confirma, acepta y muestra la patente', (tester) async {
    when(() => ofertas.ofertas('s1')).thenAnswer(
      (_) async => OfertasDeSolicitud(
        cantidadAyudantesSolicitados: 1,
        total: 1,
        ofertas: [_oferta('o1', 'Tomás Pérez', 106900.15)],
      ),
    );
    when(() => ofertas.aceptar('o1')).thenAnswer((_) async => _viaje);
    await montar(tester, '/cliente/solicitudes/s1');

    await tester.tap(find.text('Elegir'));
    await tester.pumpAndSettle();
    expect(find.text('¿Elegir a Tomás Pérez?'), findsOneWidget);
    await tester.tap(find.text('Confirmar viaje'));
    await tester.pumpAndSettle();

    verify(() => ofertas.aceptar('o1')).called(1);
    expect(find.text('¡Listo! Tu viaje está confirmado.'), findsOneWidget);
    expect(find.text('AC456EF'), findsOneWidget);
    expect(find.text('Iveco Daily'), findsOneWidget);
  });

  testWidgets('si la oferta ya no está, avisa y recarga', (tester) async {
    when(() => ofertas.ofertas('s1')).thenAnswer(
      (_) async => OfertasDeSolicitud(
        cantidadAyudantesSolicitados: 1,
        total: 1,
        ofertas: [_oferta('o1', 'Tomás Pérez', 106900.15)],
      ),
    );
    when(() => ofertas.aceptar('o1'))
        .thenThrow(ApiException(code: 'oferta_no_disponible', message: 'x'));
    await montar(tester, '/cliente/solicitudes/s1');

    await tester.tap(find.text('Elegir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar viaje'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Esa oferta ya no está disponible'),
        findsOneWidget);
    verify(() => ofertas.ofertas('s1')).called(2);
  });

  testWidgets('sin ofertas explica y deja actualizar', (tester) async {
    when(() => ofertas.ofertas('s1')).thenAnswer(
      (_) async => const OfertasDeSolicitud(
          cantidadAyudantesSolicitados: 0, total: 0, ofertas: []),
    );
    await montar(tester, '/cliente/solicitudes/s1');
    expect(find.textContaining('Todavía no recibiste ofertas'), findsOneWidget);
    await tester.tap(find.text('Actualizar'));
    await tester.pumpAndSettle();
    verify(() => ofertas.ofertas('s1')).called(2);
  });

  testWidgets('una solicitud asignada no muestra ofertas', (tester) async {
    when(() => solicitudes.detalle('s1'))
        .thenAnswer((_) async => _solicitud('asignada'));
    await montar(tester, '/cliente/solicitudes/s1');
    expect(find.textContaining('el viaje está confirmado'), findsOneWidget);
    verifyNever(() => ofertas.ofertas(any()));
  });

  testWidgets('el perfil muestra reputación, zonas y vehículos',
      (tester) async {
    when(() => perfiles.perfil('t1')).thenAnswer(
      (_) async => PerfilTransportista(
        id: 't1',
        nombre: 'Tomás Pérez',
        formaTrabajo: 'Mudanzas chicas, con cuidado.',
        calificacionPromedio: 4.5,
        cantidadResenas: 1,
        tasaCumplimiento: 95,
        zonas: const ['San Isidro', 'Tigre'],
        tiposVehiculo: const ['Furgón grande'],
        resenas: [
          Resena(
            calificacion: 5,
            mensaje: 'Impecable.',
            clienteNombre: 'Clara',
            creadoEn: DateTime(2026, 9, 30),
          ),
        ],
        enFletwayDesde: DateTime(2026, 9, 1),
      ),
    );
    await montar(tester, '/cliente/transportistas/t1');
    expect(find.text('Tomás Pérez'), findsOneWidget);
    expect(find.text('4,5 (1 reseña)'), findsOneWidget);
    expect(find.text('95 % cumplidos'), findsOneWidget);
    expect(find.text('Mudanzas chicas, con cuidado.'), findsOneWidget);
    expect(find.text('Tigre'), findsOneWidget);
    expect(find.text('Furgón grande'), findsOneWidget);
    expect(find.text('Impecable.'), findsOneWidget);
    expect(find.textContaining('septiembre de 2026'), findsOneWidget);
  });
}
