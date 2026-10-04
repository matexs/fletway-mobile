import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../design_system/design_system.dart';
import '../extensions/numeros.dart';
import 'ruta.dart';

/// Mapas de OpenStreetMap: gratis y sin API key; piden identificar la app y
/// mostrar la atribución (D-35 del backend).
const _urlMapa = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const _paqueteApp = 'com.fletway.fletway_mobile';

/// Mapa con el recorrido de una solicitud: origen, destino y el trayecto por
/// calles, con la distancia y el tiempo de manejo. Lo usan el Cliente y el
/// Transportista. Si la ruta no carga, muestra el motivo sin romper la pantalla.
class MapaRutaSolicitud extends ConsumerWidget {
  /// Crea el mapa de la solicitud [solicitudId].
  const MapaRutaSolicitud({required this.solicitudId, super.key});

  /// Solicitud cuyo recorrido se dibuja.
  final String solicitudId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ruta = ref.watch(rutaSolicitudProvider(solicitudId));
    final tema = Theme.of(context);
    return ruta.when(
      loading: () => const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Row(
        children: [
          Icon(Icons.map_outlined, color: tema.colorScheme.onSurfaceVariant),
          const SizedBox(width: FletwaySpacing.sm),
          const Expanded(
              child: Text('No pudimos cargar el mapa del recorrido.')),
          TextButton(
            onPressed: () => ref.invalidate(rutaSolicitudProvider(solicitudId)),
            child: const Text('Reintentar'),
          ),
        ],
      ),
      data: (r) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(FletwaySpacing.md),
            child: SizedBox(height: 220, child: MapaRuta(ruta: r)),
          ),
          const SizedBox(height: FletwaySpacing.xs),
          Row(
            children: [
              Icon(Icons.route_outlined,
                  size: FletwaySpacing.lg, color: tema.colorScheme.primary),
              const SizedBox(width: FletwaySpacing.xs),
              Text(
                '${r.distanciaKm.legible} km · '
                '${(r.duracionMin / 60).duracion} de manejo',
                style: tema.textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// El mapa en sí: encuadra el recorrido y marca origen y destino. [extra] se
/// dibuja encima (por ejemplo, la posición del Transportista en el módulo 10).
class MapaRuta extends StatelessWidget {
  /// Crea el mapa de [ruta].
  const MapaRuta({required this.ruta, this.extra = const [], super.key});

  /// Recorrido a dibujar.
  final RutaSolicitud ruta;

  /// Marcadores adicionales.
  final List<Marker> extra;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final puntos =
        ruta.trazado.length >= 2 ? ruta.trazado : [ruta.origen, ruta.destino];
    return FlutterMap(
      options: MapOptions(
        initialCameraFit: CameraFit.bounds(
          bounds:
              LatLngBounds.fromPoints([...puntos, ruta.origen, ruta.destino]),
          padding: const EdgeInsets.all(36),
        ),
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(urlTemplate: _urlMapa, userAgentPackageName: _paqueteApp),
        PolylineLayer(
          polylines: [
            Polyline(points: puntos, strokeWidth: 5, color: colores.primary),
          ],
        ),
        MarkerLayer(
          markers: [
            _marcador(ruta.origen, Icons.trip_origin, colores.primary),
            _marcador(ruta.destino, Icons.place, colores.error),
            ...extra,
          ],
        ),
        const SimpleAttributionWidget(source: Text('OpenStreetMap')),
      ],
    );
  }

  static Marker _marcador(LatLng punto, IconData icono, Color color) => Marker(
        point: punto,
        width: 36,
        height: 36,
        child: Icon(icono, color: color, size: 32),
      );
}
