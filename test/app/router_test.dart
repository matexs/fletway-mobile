import 'package:fletway_mobile/app/router.dart';
import 'package:fletway_mobile/core/auth/app_user.dart';
import 'package:fletway_mobile/core/auth/auth_controller.dart';
import 'package:fletway_mobile/core/error/failure.dart';
import 'package:flutter_test/flutter_test.dart';

AuthSessionState autenticado(UserRole rol) => AuthSessionState(
      estado: AuthEstado.autenticado,
      user: AppUser(
        id: 'u1',
        email: 'a@b.com',
        nombreCompleto: 'A B',
        telefono: '1144440000',
        role: rol,
      ),
    );

void main() {
  const sinSesion = AuthSessionState();
  const cargando = AuthSessionState(estado: AuthEstado.cargando);
  const conError = AuthSessionState(
    estado: AuthEstado.error,
    falla: Failure('x'),
  );
  final cliente = autenticado(UserRole.cliente);
  final transportista = autenticado(UserRole.transportista);

  final casos = <(String, AuthSessionState, String, String?)>[
    ('sin sesión puede ver login', sinSesion, '/login', null),
    (
      'sin sesión puede registrarse',
      sinSesion,
      '/registro/transportista',
      null
    ),
    ('sin sesión no entra al área de cliente', sinSesion, '/cliente', '/login'),
    ('sin sesión no entra a inicio', sinSesion, '/inicio', '/login'),
    ('cargando va a inicio', cargando, '/login', '/inicio'),
    ('cargando no entra a un área', cargando, '/cliente', '/inicio'),
    ('cargando se queda en inicio', cargando, '/inicio', null),
    ('con error va a inicio', conError, '/transportista', '/inicio'),
    ('cliente sale del login', cliente, '/login', '/cliente'),
    ('cliente sale de inicio', cliente, '/inicio', '/cliente'),
    ('cliente sale del registro', cliente, '/registro/cliente', '/cliente'),
    ('cliente no entra al área ajena', cliente, '/transportista', '/cliente'),
    ('cliente navega su área', cliente, '/cliente/solicitudes/nueva', null),
    ('transportista sale del login', transportista, '/login', '/transportista'),
    (
      'transportista no entra al área ajena',
      transportista,
      '/cliente',
      '/transportista'
    ),
    (
      'transportista navega su área',
      transportista,
      '/transportista/habilitacion',
      null
    ),
  ];

  for (final (nombre, estado, ubicacion, esperado) in casos) {
    test(nombre, () {
      expect(resolverRedireccion(estado, ubicacion), esperado);
    });
  }
}
