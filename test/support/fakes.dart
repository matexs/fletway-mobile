import 'dart:async';

import 'package:fletway_mobile/core/auth/auth_repository.dart';
import 'package:fletway_mobile/core/auth/perfil_repository.dart';
import 'package:fletway_mobile/shared/models/me.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// Doble de [AuthRepository] con un stream de eventos controlable.
class MockAuthRepository extends Mock implements AuthRepository {}

/// Doble de [PerfilRepository].
class MockPerfilRepository extends Mock implements PerfilRepository {}

/// Sesión de Supabase mínima para el usuario [id].
sb.Session sesion(String id) => sb.Session(
      accessToken: 'token',
      tokenType: 'bearer',
      user: sb.User(
        id: id,
        appMetadata: const {},
        userMetadata: const {},
        aud: 'authenticated',
        createdAt: '2026-10-02T00:00:00Z',
      ),
    );

/// Perfil de prueba como lo devuelve `GET /me`.
Me perfil({
  String id = 'u1',
  String rol = 'cliente',
  bool registroCompleto = true,
  String? estadoHabilitacion,
}) =>
    Me(
      usuarioId: id,
      email: 'usuario@ejemplo.com',
      nombreCompleto: 'Usuario Prueba',
      telefono: '1144440000',
      rol: rol,
      activo: true,
      registroCompleto: registroCompleto,
      estadoHabilitacion: estadoHabilitacion,
    );

/// Configura [repo] con [sesionInicial] y devuelve el controlador del stream de
/// eventos de auth.
StreamController<sb.AuthState> configurarAuth(
  MockAuthRepository repo, {
  sb.Session? sesionInicial,
}) {
  final eventos = StreamController<sb.AuthState>.broadcast();
  when(() => repo.onAuthStateChange).thenAnswer((_) => eventos.stream);
  when(() => repo.currentSession).thenReturn(sesionInicial);
  when(() => repo.signOut()).thenAnswer((_) async {});
  return eventos;
}
