import 'package:fletway_mobile/core/auth/app_user.dart';
import 'package:fletway_mobile/core/auth/auth_controller.dart';
import 'package:fletway_mobile/core/auth/auth_repository.dart';
import 'package:fletway_mobile/core/auth/perfil_repository.dart';
import 'package:fletway_mobile/core/network/api_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../support/fakes.dart';

void main() {
  late MockAuthRepository authRepo;
  late MockPerfilRepository perfilRepo;

  setUpAll(() => registerFallbackValue(UserRole.cliente));

  setUp(() {
    authRepo = MockAuthRepository();
    perfilRepo = MockPerfilRepository();
  });

  ProviderContainer contenedor() {
    final c = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepo),
        perfilRepositoryProvider.overrideWithValue(perfilRepo),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  /// Lee el controller y espera a que termine la carga del perfil.
  Future<AuthSessionState> estadoFinal(ProviderContainer c) async {
    c.read(authControllerProvider);
    await pumpEventQueue();
    return c.read(authControllerProvider);
  }

  test('sin sesión queda no autenticado y no pide el perfil', () async {
    configurarAuth(authRepo);
    final estado = await estadoFinal(contenedor());
    expect(estado.estado, AuthEstado.noAutenticado);
    verifyNever(() => perfilRepo.me());
  });

  test('con sesión toma el rol de GET /me, no de la metadata', () async {
    configurarAuth(authRepo, sesionInicial: sesion('u1'));
    when(
      () => perfilRepo.me(),
    ).thenAnswer((_) async =>
        perfil(rol: 'transportista', estadoHabilitacion: 'pendiente'));

    final estado = await estadoFinal(contenedor());

    expect(estado.estado, AuthEstado.autenticado);
    expect(estado.user!.role, UserRole.transportista);
    expect(estado.user!.estadoHabilitacion, EstadoHabilitacion.pendiente);
    expect(estado.user!.puedeOfertar, isFalse);
    verifyNever(() => perfilRepo.completarRegistro(any()));
  });

  test('si falta la fila del rol, completa el registro', () async {
    configurarAuth(authRepo, sesionInicial: sesion('u1'));
    when(
      () => perfilRepo.me(),
    ).thenAnswer((_) async => perfil(rol: 'cliente', registroCompleto: false));
    when(
      () => perfilRepo.completarRegistro(UserRole.cliente),
    ).thenAnswer((_) async => perfil(rol: 'cliente'));

    final estado = await estadoFinal(contenedor());

    expect(estado.estado, AuthEstado.autenticado);
    expect(estado.user!.esCliente, isTrue);
    verify(() => perfilRepo.completarRegistro(UserRole.cliente)).called(1);
  });

  test('una cuenta de Administrador no entra a la app', () async {
    configurarAuth(authRepo, sesionInicial: sesion('u1'));
    when(() => perfilRepo.me())
        .thenAnswer((_) async => perfil(rol: 'administrador'));

    final estado = await estadoFinal(contenedor());

    expect(estado.estado, AuthEstado.error);
    expect(estado.falla!.code, 'rol_sin_app');
  });

  test('un error del backend deja el estado en error con su mensaje', () async {
    configurarAuth(authRepo, sesionInicial: sesion('u1'));
    when(() => perfilRepo.me()).thenThrow(
      ApiException(code: 'sin_conexion', message: 'x'),
    );

    final estado = await estadoFinal(contenedor());

    expect(estado.estado, AuthEstado.error);
    expect(estado.falla!.message, 'Sin conexión. Revisá tu internet.');
  });

  test('si el backend rechaza el JWT, cierra la sesión', () async {
    configurarAuth(authRepo, sesionInicial: sesion('u1'));
    when(() => perfilRepo.me()).thenThrow(
      ApiException(code: 'token_invalido', message: 'x', statusCode: 401),
    );

    await estadoFinal(contenedor());

    verify(() => authRepo.signOut()).called(1);
  });

  test('login y logout por eventos de Supabase', () async {
    final eventos = configurarAuth(authRepo);
    when(() => perfilRepo.me()).thenAnswer((_) async => perfil());
    final c = contenedor();
    await estadoFinal(c);

    eventos.add(sb.AuthState(sb.AuthChangeEvent.signedIn, sesion('u1')));
    await pumpEventQueue();
    expect(c.read(authControllerProvider).estado, AuthEstado.autenticado);

    eventos.add(const sb.AuthState(sb.AuthChangeEvent.signedOut, null));
    await pumpEventQueue();
    expect(c.read(authControllerProvider).estado, AuthEstado.noAutenticado);
  });
}
