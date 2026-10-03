import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/app_user.dart';
import '../core/auth/auth_controller.dart';
import '../features/auth/presentation/inicio_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/registro_screen.dart';
import '../features/carrier/habilitacion/presentation/habilitacion_screen.dart';

/// Rutas de la app. Cliente y Transportista tienen árboles separados
/// (`/cliente/...` y `/transportista/...`); el `redirect` central
/// ([resolverRedireccion]) hace de guard de sesión y de rol con el perfil de
/// `GET /me` (D-18). Depende de [authControllerProvider].
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, __) => notifier.value++);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) => resolverRedireccion(
      ref.read(authControllerProvider),
      state.matchedLocation,
    ),
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/inicio', builder: (_, __) => const InicioScreen()),
      GoRoute(
        path: '/registro/cliente',
        builder: (_, __) => const RegistroScreen(rol: UserRole.cliente),
      ),
      GoRoute(
        path: '/registro/transportista',
        builder: (_, __) => const RegistroScreen(rol: UserRole.transportista),
      ),

      // --- Árbol Cliente (RF-05..RF-15) ---
      GoRoute(
        path: '/cliente',
        builder: (_, __) =>
            const _Placeholder('Home Cliente', conCerrarSesion: true),
        routes: [
          GoRoute(
            path: 'solicitudes/nueva',
            builder: (_, __) =>
                const _Placeholder('Publicar solicitud (RF-06)'),
          ),
          GoRoute(
            path: 'solicitudes/:id/ofertas',
            builder: (_, __) =>
                const _Placeholder('Top 3 ofertas (RF-07 / RN-05)'),
          ),
          GoRoute(
            path: 'viajes/:id',
            builder: (_, __) => const _Placeholder(
                'Viaje Cliente (RF-15 tracking, chat RI-05)'),
          ),
        ],
      ),

      // --- Árbol Transportista (RF-16..RF-24) ---
      // De primer nivel a propósito: para el no habilitado es su inicio y no
      // tiene que quedar el inicio del Transportista debajo (go_router no
      // vuelve a pasar por el redirect al hacer pop). El habilitado la abre
      // con push desde su inicio.
      GoRoute(
        path: '/transportista/habilitacion',
        builder: (_, __) => const HabilitacionScreen(),
      ),
      GoRoute(
        path: '/transportista',
        builder: (_, __) => const _Placeholder(
          'Home Transportista',
          conCerrarSesion: true,
          rutaDocumentacion: '/transportista/habilitacion',
        ),
        routes: [
          GoRoute(
            path: 'solicitudes',
            builder: (_, __) =>
                const _Placeholder('Solicitudes compatibles (RF-17 / RN-04)'),
          ),
          GoRoute(
            path: 'viajes/:id',
            builder: (_, __) =>
                const _Placeholder('Viaje Transportista (PIN RF-22 / RN-06)'),
          ),
        ],
      ),
    ],
  );
});

/// Decide a dónde redirigir según la sesión y la ruta pedida [ubicacion];
/// null si puede quedarse.
///
/// - Sin sesión: sólo login y registro.
/// - Con sesión y perfil cargándose o con error: la pantalla de inicio.
/// - Autenticado: fuera de login, registro e inicio, y nunca en el árbol del
///   otro rol (un rol por cuenta, D-17).
/// - Transportista no habilitado: su inicio es la documentación (RF-01).
String? resolverRedireccion(AuthSessionState auth, String ubicacion) {
  final publica = ubicacion == '/login' || ubicacion.startsWith('/registro');
  switch (auth.estado) {
    case AuthEstado.noAutenticado:
      return publica ? null : '/login';
    case AuthEstado.cargando:
    case AuthEstado.error:
      return ubicacion == '/inicio' ? null : '/inicio';
    case AuthEstado.autenticado:
      final user = auth.user!;
      final home = user.esTransportista ? '/transportista' : '/cliente';
      if (publica || ubicacion == '/inicio') return home;
      final enCliente = ubicacion.startsWith('/cliente');
      final enTransportista = ubicacion.startsWith('/transportista');
      if (user.esCliente && enTransportista) return home;
      if (user.esTransportista && enCliente) return home;
      // Mientras no está habilitado, su inicio es la documentación (RF-01).
      if (ubicacion == '/transportista' &&
          user.estadoHabilitacion != EstadoHabilitacion.habilitado) {
        return '/transportista/habilitacion';
      }
      return null;
  }
}

/// Placeholder mientras no existan las pantallas reales. Reemplazar con la skill
/// `new-screen`.
class _Placeholder extends ConsumerWidget {
  const _Placeholder(
    this.label, {
    this.conCerrarSesion = false,
    this.rutaDocumentacion,
  });
  final String label;
  final bool conCerrarSesion;
  // Acceso a la documentación desde el inicio del Transportista habilitado
  // (renovaciones, D-33).
  final String? rutaDocumentacion;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(
          title: Text(label),
          actions: [
            if (rutaDocumentacion != null)
              IconButton(
                tooltip: 'Mi documentación',
                icon: const Icon(Icons.badge_outlined),
                onPressed: () => context.push(rutaDocumentacion!),
              ),
            if (conCerrarSesion)
              IconButton(
                tooltip: 'Cerrar sesión',
                icon: const Icon(Icons.logout),
                onPressed: ref.read(authControllerProvider.notifier).signOut,
              ),
          ],
        ),
        body: Center(child: Text('TODO: $label')),
      );
}
