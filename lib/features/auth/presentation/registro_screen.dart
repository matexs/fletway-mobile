import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/app_user.dart';
import '../../../core/error/failure.dart';
import '../../../shared/design_system/design_system.dart';
import '../../../shared/widgets/widgets.dart';
import '../application/registro_controller.dart';
import '../application/validadores.dart';
import 'widgets/mensaje_error_auth.dart';

/// Pantalla de alta de cuenta para [rol]: Cliente (RF-05) o Transportista
/// (RF-16, datos personales; la documentación se carga después, en el módulo
/// 3). Crea la cuenta en Supabase Auth; al quedar la sesión iniciada, el
/// `AuthController` completa el registro en el backend y el router navega.
class RegistroScreen extends ConsumerStatefulWidget {
  /// Crea la pantalla de registro para [rol] (cliente o transportista).
  const RegistroScreen({required this.rol, super.key})
      : assert(
            rol != UserRole.administrador, 'el Administrador no se registra');

  /// Rol de la cuenta nueva. Un rol por cuenta (D-17).
  final UserRole rol;

  @override
  ConsumerState<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends ConsumerState<RegistroScreen> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _telefono = TextEditingController();
  final _email = TextEditingController();
  final _contrasena = TextEditingController();
  final _confirmacion = TextEditingController();

  bool get _esTransportista => widget.rol == UserRole.transportista;

  @override
  void dispose() {
    for (final c in [_nombre, _telefono, _email, _contrasena, _confirmacion]) {
      c.dispose();
    }
    super.dispose();
  }

  void _registrar() {
    if (!_form.currentState!.validate()) return;
    ref.read(registroControllerProvider.notifier).registrar(
          rol: widget.rol,
          nombreCompleto: _nombre.text,
          telefono: _telefono.text,
          email: _email.text,
          contrasena: _contrasena.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final envio = ref.watch(registroControllerProvider);
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _esTransportista
              ? 'Registro de Transportista'
              : 'Crear cuenta de Cliente',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(FletwaySpacing.xl),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _esTransportista
                      ? 'Completá tus datos. Después vas a cargar tu '
                          'documentación para que la revisemos antes de '
                          'que puedas ofertar.'
                      : 'Completá tus datos para publicar tus fletes y '
                          'mudanzas.',
                  style: textos.bodyLarge,
                ),
                const SizedBox(height: FletwaySpacing.xl),
                FletwayTextField(
                  etiqueta: 'Nombre y apellido',
                  controller: _nombre,
                  teclado: TextInputType.name,
                  accionTeclado: TextInputAction.next,
                  validator: ValidadoresAuth.nombreCompleto,
                ),
                const SizedBox(height: FletwaySpacing.lg),
                FletwayTextField(
                  etiqueta: 'Teléfono',
                  ayuda: 'Con código de área, sin 0 ni 15',
                  controller: _telefono,
                  teclado: TextInputType.phone,
                  accionTeclado: TextInputAction.next,
                  validator: ValidadoresAuth.telefono,
                ),
                const SizedBox(height: FletwaySpacing.lg),
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
                  ayuda: 'Al menos ${ValidadoresAuth.largoMinimoContrasena} '
                      'caracteres',
                  controller: _contrasena,
                  oculto: true,
                  accionTeclado: TextInputAction.next,
                  validator: ValidadoresAuth.contrasenaNueva,
                ),
                const SizedBox(height: FletwaySpacing.lg),
                FletwayTextField(
                  etiqueta: 'Repetí la contraseña',
                  controller: _confirmacion,
                  oculto: true,
                  accionTeclado: TextInputAction.done,
                  validator: (v) =>
                      ValidadoresAuth.confirmacion(v, _contrasena.text),
                ),
                MensajeErrorAuth(
                  mensaje: switch (envio) {
                    AsyncError(:final error) => Failure.from(error).message,
                    AsyncData(value: ResultadoRegistro.confirmarEmail) =>
                      'Te enviamos un email para confirmar la cuenta. '
                          'Confirmala y después iniciá sesión.',
                    _ => null,
                  },
                ),
                const SizedBox(height: FletwaySpacing.xl),
                FletwayButton(
                  texto: 'Crear cuenta',
                  onPressed: _registrar,
                  cargando: envio.isLoading,
                  anchoCompleto: true,
                ),
                const SizedBox(height: FletwaySpacing.sm),
                FletwayButton(
                  texto: 'Ya tengo cuenta',
                  variante: FletwayButtonVariante.texto,
                  onPressed: () => context.go('/login'),
                  anchoCompleto: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
