import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/perfil_dto.dart';
import '../data/perfil_repository.dart';

/// Perfil público del Transportista de id dado. Depende de
/// [perfilTransportistaRepositoryProvider].
final perfilTransportistaProvider =
    FutureProvider.autoDispose.family<PerfilTransportista, String>(
  (ref, id) => ref.watch(perfilTransportistaRepositoryProvider).perfil(id),
);
