import 'package:fletway_mobile/app/theme.dart';
import 'package:fletway_mobile/shared/mapa/mapa_ruta.dart';
import 'package:fletway_mobile/shared/mapa/ruta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

class MockRutas extends Mock implements RutaRepository {}

void main() {
  late MockRutas rutas;
  setUpAll(() => initializeDateFormatting('es_AR'));
  setUp(() => rutas = MockRutas());

  Future<void> montar(WidgetTester tester) => tester.pumpWidget(
        ProviderScope(
          // Sin los reintentos automáticos de Riverpod: el error se ve enseguida.
          retry: (_, __) => null,
          overrides: [rutaRepositoryProvider.overrideWithValue(rutas)],
          child: MaterialApp(
            theme: FletwayTheme.light,
            home: const Scaffold(body: MapaRutaSolicitud(solicitudId: 's1')),
          ),
        ),
      );

  test('lee la ruta de la API', () {
    final r = RutaSolicitud.fromJson({
      'origen': {'lat': -34.46, 'lng': -58.52},
      'destino': {'lat': -34.60, 'lng': -58.41},
      'distancia_km': 25.1,
      'duracion_min': 26,
      'trazado': [
        {'lat': -34.46, 'lng': -58.52},
        {'lat': -34.60, 'lng': -58.41},
      ],
    });
    expect(r.origen.latitude, -34.46);
    expect(r.destino.longitude, -58.41);
    expect(r.trazado, hasLength(2));
    expect(r.duracionMin, 26);
  });

  testWidgets('dibuja el recorrido con distancia y tiempo', (tester) async {
    when(() => rutas.deSolicitud('s1')).thenAnswer(
      (_) async => RutaSolicitud.fromJson({
        'origen': {'lat': -34.46, 'lng': -58.52},
        'destino': {'lat': -34.60, 'lng': -58.41},
        'distancia_km': 25.1,
        'duracion_min': 26,
        'trazado': [
          {'lat': -34.46, 'lng': -58.52},
          {'lat': -34.55, 'lng': -58.47},
          {'lat': -34.60, 'lng': -58.41},
        ],
      }),
    );
    await montar(tester);
    await tester.pump();
    await tester.pump();
    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.text('25,1 km · 26 min de manejo'), findsOneWidget);
    expect(find.text('OpenStreetMap'), findsOneWidget, reason: 'atribución');
  });

  testWidgets('si la ruta falla, avisa y deja reintentar', (tester) async {
    when(() => rutas.deSolicitud('s1'))
        .thenAnswer((_) async => throw Exception('sin red'));
    await montar(tester);
    await tester.pump();
    expect(
        find.text('No pudimos cargar el mapa del recorrido.'), findsOneWidget);
    await tester.tap(find.text('Reintentar'));
    await tester.pump();
    verify(() => rutas.deSolicitud('s1')).called(2);
  });
}
