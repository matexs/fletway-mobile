import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/failure.dart';
import '../../../shared/design_system/design_system.dart';
import '../../../shared/widgets/widgets.dart';
import '../application/login_controller.dart';
import '../application/validadores.dart';
import 'widgets/mensaje_error_auth.dart';

/// Pantalla de login con email y contraseña (Supabase Auth). Desde acá se llega
/// al registro de Cliente (RF-05) o de Transportista (RF-16). Al iniciar sesión
/// el router lleva al inicio del rol que devuelve `GET /me`.
class LoginScreen extends ConsumerStatefulWidget {
  /// Crea la pantalla de login.
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _contrasena = TextEditingController();

  // Después del primer envío, cada campo se revalida al editarlo para que el
  // error desaparezca apenas se corrige.
  var _enviado = false;

  @override
  void dispose() {
    _email.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  void _ingresar() {
    setState(() => _enviado = true);
    if (!_form.currentState!.validate()) return;
    ref
        .read(loginControllerProvider.notifier)
        .ingresar(email: _email.text, contrasena: _contrasena.text);
  }

  @override
  Widget build(BuildContext context) {
    final envio = ref.watch(loginControllerProvider);
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(FletwaySpacing.xl),
            child: Form(
              key: _form,
              autovalidateMode: _enviado
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Fletway',
                    style: textos.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: FletwaySpacing.sm),
                  Text(
                    'Fletes y mudanzas',
                    style: textos.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: FletwaySpacing.xxl),
                  FletwayTextField(
                    etiqueta: 'Email',
                    controller: _email,
                    teclado: TextInputType.emailAddress,
                    accionTeclado: TextInputAction.next,
                    validator: ValidadoresAuth.email,
                  ),
                  const SizedBox(height: FletwaySpacing.lg),
                  FletwayTextField(
                    etiqueta: 'Contraseña',
                    controller: _contrasena,
                    oculto: true,
                    accionTeclado: TextInputAction.done,
                    validator: ValidadoresAuth.contrasenaIngresada,
                  ),
                  MensajeErrorAuth(
                    mensaje: envio.hasError
                        ? Failure.from(envio.error!).message
                        : null,
                  ),
                  const SizedBox(height: FletwaySpacing.xl),
                  FletwayButton(
                    texto: 'Ingresar',
                    onPressed: _ingresar,
                    cargando: envio.isLoading,
                    anchoCompleto: true,
                  ),
                  const SizedBox(height: FletwaySpacing.xl),
                  FletwayButton(
                    texto: 'Crear cuenta de Cliente',
                    variante: FletwayButtonVariante.secundario,
                    onPressed: () => context.push('/registro/cliente'),
                    anchoCompleto: true,
                  ),
                  const SizedBox(height: FletwaySpacing.sm),
                  FletwayButton(
                    texto: 'Quiero trabajar como Transportista',
                    variante: FletwayButtonVariante.texto,
                    onPressed: () => context.push('/registro/transportista'),
                    anchoCompleto: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
