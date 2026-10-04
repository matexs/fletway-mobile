import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../data/oferta_dto.dart';
import '../data/ofertas_repository.dart';
import 'mis_ofertas_controller.dart';

/// Tope de ayudantes por oferta (D-23).
const maxAyudantes = 3;

/// Lo que el Transportista eligió para su oferta y el precio que resulta.
class ArmarOferta {
  /// Crea el estado.
  const ArmarOferta({
    this.vehiculoId,
    this.ayudantes = 0,
    this.cotizacion,
    this.enviando = false,
  });

  /// Vehículo elegido, o null si todavía no eligió.
  final String? vehiculoId;

  /// Ayudantes, de 0 a [maxAyudantes].
  final int ayudantes;

  /// Precio y viajes para la elección actual, o el motivo por el que no se
  /// puede (por ejemplo, la carga no entra). Null sin vehículo elegido.
  final AsyncValue<Cotizacion>? cotizacion;

  /// Si se está guardando la oferta.
  final bool enviando;

  /// Se puede ofertar cuando hay un precio calculado para la elección actual.
  bool get puedeOfertar =>
      !enviando && cotizacion != null && cotizacion!.hasValue;

  ArmarOferta _con({
    String? vehiculoId,
    int? ayudantes,
    AsyncValue<Cotizacion>? cotizacion,
    bool? enviando,
  }) =>
      ArmarOferta(
        vehiculoId: vehiculoId ?? this.vehiculoId,
        ayudantes: ayudantes ?? this.ayudantes,
        cotizacion: cotizacion ?? this.cotizacion,
        enviando: enviando ?? this.enviando,
      );
}

/// Armado de la oferta para una solicitud. Depende de
/// [ofertasRepositoryProvider].
final armarOfertaProvider = NotifierProvider.autoDispose
    .family<ArmarOfertaController, ArmarOferta, String>(
  ArmarOfertaController.new,
);

/// Cotiza cada vez que cambia el vehículo o los ayudantes, para que el
/// Transportista vea el precio antes de ofertar (RN-01, RN-02).
class ArmarOfertaController extends Notifier<ArmarOferta> {
  /// Crea el controller de la solicitud [solicitudId].
  ArmarOfertaController(this.solicitudId);

  /// Solicitud a la que se oferta.
  final String solicitudId;

  // Cuenta los pedidos de cotización: sólo vale la respuesta del último, por
  // si el usuario cambia la elección antes de que llegue la anterior.
  int _pedido = 0;

  @override
  ArmarOferta build() => const ArmarOferta();

  /// Elige el vehículo y cotiza. Efecto: red.
  Future<void> elegirVehiculo(String vehiculoId) {
    state = state._con(vehiculoId: vehiculoId);
    return _cotizar();
  }

  /// Cambia la cantidad de ayudantes y cotiza si ya hay vehículo. Efecto: red.
  Future<void> elegirAyudantes(int ayudantes) {
    state = state._con(ayudantes: ayudantes.clamp(0, maxAyudantes));
    return _cotizar();
  }

  Future<void> _cotizar() async {
    final vehiculoId = state.vehiculoId;
    if (vehiculoId == null) return;
    final pedido = ++_pedido;
    state = state._con(cotizacion: const AsyncLoading());
    final resultado = await AsyncValue.guard(
      () => ref.read(ofertasRepositoryProvider).cotizar(
            solicitudId,
            vehiculoId: vehiculoId,
            ayudantes: state.ayudantes,
          ),
    );
    if (pedido == _pedido && ref.mounted) {
      state = state._con(cotizacion: resultado);
    }
  }

  /// Guarda la oferta con la elección actual. Devuelve el error, o null si
  /// salió bien. Efectos: red y recarga de [misOfertasProvider].
  Future<Failure?> ofertar() async {
    final vehiculoId = state.vehiculoId;
    if (vehiculoId == null) return const Failure('Elegí un vehículo.');
    state = state._con(enviando: true);
    try {
      await ref.read(ofertasRepositoryProvider).ofertar(
            solicitudId,
            vehiculoId: vehiculoId,
            ayudantes: state.ayudantes,
          );
      ref.invalidate(misOfertasProvider);
      return null;
    } catch (e) {
      return Failure.from(e);
    } finally {
      if (ref.mounted) state = state._con(enviando: false);
    }
  }
}
