import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/app_user.dart';
import '../core/auth/auth_controller.dart';

/// Rutas de la app. Cliente y Transportista tienen árboles separados
/// (`/cliente/...` y `/transportista/...`); un `redirect` central hace de guard
/// de auth y de rol (ver docs/ARQUITECTURA.md §4).
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, __) => notifier.value++);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final loggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation.startsWith('/registro');

      if (!auth.isAuthenticated) {
        return loggingIn ? null : '/login';
      }

      // Autenticado: mandar a la raíz del rol y no dejar entrar al árbol ajeno.
      final home = auth.user!.role == UserRole.transportista ? '/transportista' : '/cliente';
      if (loggingIn) return home;

      final enClienteArea = state.matchedLocation.startsWith('/cliente');
      final enCarrierArea = state.matchedLocation.startsWith('/transportista');
      if (auth.user!.esCliente && enCarrierArea) return home;
      if (auth.user!.esTransportista && enClienteArea) return home;
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const _Placeholder('Login')),
      GoRoute(
        path: '/registro/cliente',
        builder: (_, __) => const _Placeholder('Registro Cliente (RF-05)'),
      ),
      GoRoute(
        path: '/registro/transportista',
        builder: (_, __) => const _Placeholder('Registro Transportista (RF-16)'),
      ),

      // --- Árbol Cliente (RF-05..RF-15) ---
      GoRoute(
        path: '/cliente',
        builder: (_, __) => const _Placeholder('Home Cliente'),
        routes: [
          GoRoute(
            path: 'solicitudes/nueva',
            builder: (_, __) => const _Placeholder('Publicar solicitud (RF-06)'),
          ),
          GoRoute(
            path: 'solicitudes/:id/ofertas',
            builder: (_, __) => const _Placeholder('Top 3 ofertas (RF-07 / RN-05)'),
          ),
          GoRoute(
            path: 'viajes/:id',
            builder: (_, __) => const _Placeholder('Viaje Cliente (RF-15 tracking, chat RI-05)'),
          ),
        ],
      ),

      // --- Árbol Transportista (RF-16..RF-24) ---
      GoRoute(
        path: '/transportista',
        builder: (_, __) => const _Placeholder('Home Transportista'),
        routes: [
          GoRoute(
            path: 'habilitacion',
            builder: (_, __) => const _Placeholder('Estado de habilitación (RF-01)'),
          ),
          GoRoute(
            path: 'solicitudes',
            builder: (_, __) => const _Placeholder('Solicitudes compatibles (RF-17 / RN-04)'),
          ),
          GoRoute(
            path: 'viajes/:id',
            builder: (_, __) => const _Placeholder('Viaje Transportista (PIN RF-22 / RN-06)'),
          ),
        ],
      ),
    ],
  );
});

/// Placeholder mientras no existan las pantallas reales. Reemplazar con la skill
/// `new-screen`.
class _Placeholder extends StatelessWidget {
  const _Placeholder(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(label)),
        body: Center(child: Text('TODO: $label')),
      );
}
