import 'dart:typed_data';

import 'package:fletway_mobile/app/theme.dart';
import 'package:fletway_mobile/core/auth/app_user.dart';
import 'package:fletway_mobile/core/auth/auth_controller.dart';
import 'package:fletway_mobile/core/auth/auth_repository.dart';
import 'package:fletway_mobile/core/auth/perfil_repository.dart';
import 'package:fletway_mobile/core/error/failure.dart';
import 'package:fletway_mobile/core/network/api_client.dart';
import 'package:fletway_mobile/features/carrier/habilitacion/application/carga_documento_controller.dart';
import 'package:fletway_mobile/features/carrier/habilitacion/data/habilitacion_dto.dart';
import 'package:fletway_mobile/features/carrier/habilitacion/data/habilitacion_repository.dart';
import 'package:fletway_mobile/features/carrier/habilitacion/data/selector_archivo.dart';
import 'package:fletway_mobile/features/carrier/habilitacion/presentation/habilitacion_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show SupabaseStorageClient;

import '../../../support/fakes.dart';

class MockHabilitacionRepository extends Mock
    implements HabilitacionRepository {}

class MockSelectorArchivo extends Mock implements SelectorArchivo {}

class MockApiClient extends Mock implements ApiClient {}

class MockStorage extends Mock implements SupabaseStorageClient {}

TipoDocumento tipo(String codigo, String descripcion, [Documento? ultimo]) =>
    TipoDocumento(
      tipoDocumentoCodigo: codigo,
      descripcion: descripcion,
      ultimo: ultimo,
    );

Documento documento(String tipo, String estado, {String? motivo}) => Documento(
      id: 'd-$tipo',
      tipoDocumentoCodigo: tipo,
      estado: estado,
      motivoRechazo: motivo,
      cargadoEn: DateTime(2026, 10, 3),
    );

final _pdf = ArchivoElegido(
  nombre: 'dni.pdf',
  bytes: Uint8List.fromList([1, 2, 3]),
);

void main() {
  late MockAuthRepository authRepo;
  late MockPerfilRepository perfilRepo;
  late MockHabilitacionRepository repo;
  late MockSelectorArchivo selector;

  setUpAll(() {
    registerFallbackValue(OrigenArchivo.archivo);
    registerFallbackValue(_pdf);
  });

  setUp(() {
    authRepo = MockAuthRepository();
    perfilRepo = MockPerfilRepository();
    repo = MockHabilitacionRepository();
    selector = MockSelectorArchivo();
    configurarAuth(authRepo, sesionInicial: sesion('t1'));
    when(() => perfilRepo.me()).thenAnswer(
      (_) async => perfil(
        id: 't1',
        rol: 'transportista',
        estadoHabilitacion: 'pendiente',
      ),
    );
  });

  List<Override> overrides() => [
        authRepositoryProvider.overrideWithValue(authRepo),
        perfilRepositoryProvider.overrideWithValue(perfilRepo),
        habilitacionRepositoryProvider.overrideWithValue(repo),
        selectorArchivoProvider.overrideWithValue(selector),
      ];

  group('HabilitacionRepository valida antes de subir', () {
    final r = HabilitacionRepository(MockApiClient(), MockStorage());

    for (final (nombre, archivo, mensaje) in [
      (
        'formato no permitido',
        ArchivoElegido(nombre: 'dni.docx', bytes: Uint8List(3)),
        'El archivo tiene que ser PDF, JPG o PNG.',
      ),
      (
        'más de 10 MB',
        ArchivoElegido(
          nombre: 'dni.pdf',
          bytes: Uint8List(HabilitacionRepository.tamanoMaximo + 1),
        ),
        'El archivo no puede superar los 10 MB.',
      ),
    ]) {
      test(nombre, () {
        expect(
          () => r.cargar(usuarioId: 't1', tipo: 'dni', archivo: archivo),
          throwsA(
            isA<ArchivoInvalido>().having((e) => e.mensaje, 'mensaje', mensaje),
          ),
        );
      });
    }
  });

  group('CargaDocumentoController', () {
    Future<ProviderContainer> contenedor() async {
      final c = ProviderContainer(overrides: overrides());
      addTearDown(c.dispose);
      c.read(authControllerProvider);
      await pumpEventQueue();
      // Mantiene vivo el provider autoDispose durante el test.
      c.listen(cargaDocumentoControllerProvider, (_, __) {});
      return c;
    }

    test('si el usuario cancela no sube nada', () async {
      when(() => selector.elegir(any())).thenAnswer((_) async => null);
      final c = await contenedor();

      final cargo = await c
          .read(cargaDocumentoControllerProvider.notifier)
          .cargar('dni', OrigenArchivo.archivo);

      expect(cargo, isFalse);
      verifyNever(
        () => repo.cargar(
          usuarioId: any(named: 'usuarioId'),
          tipo: any(named: 'tipo'),
          archivo: any(named: 'archivo'),
        ),
      );
    });

    test('sube con el usuario logueado', () async {
      when(() => selector.elegir(any())).thenAnswer((_) async => _pdf);
      when(
        () => repo.cargar(
          usuarioId: any(named: 'usuarioId'),
          tipo: any(named: 'tipo'),
          archivo: any(named: 'archivo'),
        ),
      ).thenAnswer((_) async => documento('dni', 'pendiente'));
      when(() => repo.obtener()).thenAnswer(
        (_) async => const MiHabilitacion(
            estadoHabilitacion: 'pendiente', documentos: []),
      );
      final c = await contenedor();

      await c
          .read(cargaDocumentoControllerProvider.notifier)
          .cargar('dni', OrigenArchivo.camara);

      verify(
        () => repo.cargar(usuarioId: 't1', tipo: 'dni', archivo: _pdf),
      ).called(1);
      expect(c.read(cargaDocumentoControllerProvider).hasError, isFalse);
    });

    test('un archivo inválido queda como error con su mensaje', () async {
      when(() => selector.elegir(any())).thenAnswer((_) async => _pdf);
      when(
        () => repo.cargar(
          usuarioId: any(named: 'usuarioId'),
          tipo: any(named: 'tipo'),
          archivo: any(named: 'archivo'),
        ),
      ).thenThrow(
          const ArchivoInvalido('El archivo no puede superar los 10 MB.'));
      final c = await contenedor();

      await c
          .read(cargaDocumentoControllerProvider.notifier)
          .cargar('dni', OrigenArchivo.archivo);

      final estado = c.read(cargaDocumentoControllerProvider);
      expect(
        Failure.from(estado.error!).message,
        'El archivo no puede superar los 10 MB.',
      );
    });
  });

  group('HabilitacionScreen', () {
    Future<void> montar(WidgetTester tester, MiHabilitacion mi) async {
      tester.view.physicalSize = const Size(1080, 3200);
      addTearDown(tester.view.reset);
      when(() => repo.obtener()).thenAnswer((_) async => mi);
      // Como en la app: la pantalla aparece con la sesión ya autenticada.
      final container = ProviderContainer(overrides: overrides());
      addTearDown(container.dispose);
      container.read(authControllerProvider);
      await tester.runAsync(pumpEventQueue);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: FletwayTheme.light,
            home: const HabilitacionScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('rechazado muestra el motivo y permite volver a cargar', (
      tester,
    ) async {
      await montar(
        tester,
        MiHabilitacion(
          estadoHabilitacion: 'rechazado',
          documentos: [
            tipo('dni', 'Documento Nacional de Identidad',
                documento('dni', 'aprobado')),
            tipo('registro', 'Registro de conducir habilitante',
                documento('registro', 'pendiente')),
            tipo('seguro', 'Seguro del vehículo'),
            tipo(
              'vtv',
              'Verificación Técnica Vehicular',
              documento('vtv', 'rechazado', motivo: 'La VTV está vencida'),
            ),
          ],
        ),
      );

      expect(find.text('Documentación rechazada'), findsOneWidget);
      expect(find.text('Motivo: La VTV está vencida'), findsOneWidget);
      expect(find.text('Volver a cargar'), findsOneWidget);
      expect(find.text('Cargar'), findsOneWidget,
          reason: 'el seguro no se cargó');
      expect(find.text('Reemplazar'), findsOneWidget,
          reason: 'el DNI aprobado');
      expect(find.text('En revisión'), findsOneWidget);
    });

    testWidgets('habilitado actualiza el estado de la sesión', (tester) async {
      await montar(
        tester,
        MiHabilitacion(
          estadoHabilitacion: 'habilitado',
          documentos: [
            for (final t in ['dni', 'registro', 'seguro', 'vtv'])
              tipo(t, t, documento(t, 'aprobado')),
          ],
        ),
      );

      expect(find.text('Cuenta habilitada'), findsOneWidget);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(HabilitacionScreen)),
      );
      expect(
        container.read(authControllerProvider).user!.estadoHabilitacion,
        EstadoHabilitacion.habilitado,
      );
    });
  });
}
