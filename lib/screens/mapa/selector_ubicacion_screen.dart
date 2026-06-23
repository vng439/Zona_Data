import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/reporte_service.dart';
import '../../services/zona_critica_service.dart';
import '../../models/reports.dart';
import '../../models/zona_critica.dart';
import '../../utils/reporte_helpers.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

class SelectorUbicacionScreen extends StatefulWidget {
  const SelectorUbicacionScreen({super.key});

  @override
  State<SelectorUbicacionScreen> createState() =>
      _SelectorUbicacionScreenState();
}

class _SelectorUbicacionScreenState extends State<SelectorUbicacionScreen> {
  static const LatLng _centroInicial = LatLng(-46.4333, -67.5167);
  LatLng? _ubicacionSeleccionada;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Elegir ubicación',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _ubicacionSeleccionada != null
        ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.pop(context, _ubicacionSeleccionada);
              },
              icon: const Icon(Icons.check),
              label: const Text(
                'Confirmar ubicación',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        )
      : null,
      body: Stack(
        children: [
          StreamBuilder<List<Reporte>>(
            stream: ReporteService().obtenerReportes(),
            builder: (context, snapshot) {
              final reportes = snapshot.data ?? [];

              final reportesConUbicacion = reportes
                  .where((r) => r.latitud != null && r.longitud != null)
                  .toList();

              final reportesGeo = reportesConUbicacion
                  .map((r) => ReporteGeo(
                        id: r.id,
                        latitud: r.latitud!,
                        longitud: r.longitud!,
                      ))
                  .toList();

              final zonasCriticas =
                  ZonaCriticaService().detectarZonasCriticas(reportesGeo);

              return FlutterMap(
                options: MapOptions(
                  initialCenter: _centroInicial,
                  initialZoom: 13,
                  onTap: (tapPosition, point) {
                    setState(() {
                      _ubicacionSeleccionada = point;
                    });
                  },
                ),
                children: [
                  // Capa base OpenStreetMap
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.ldsw.zona_data',
                  ),

                  // Capa de zonas críticas
                  CircleLayer(
                    circles: zonasCriticas
                        .map((zona) => _buildCirculoZona(zona))
                        .toList(),
                  ),

                  // Capa de marcadores individuales
                  // Capa de marcadores con clustering
MarkerClusterLayerWidget(
  options: MarkerClusterLayerOptions(
    maxClusterRadius: 60,
    size: const Size(44, 44),
    markers: reportesConUbicacion.map((reporte) {
      return Marker(
        point: LatLng(reporte.latitud!, reporte.longitud!),
        width: 36,
        height: 36,
        child: Container(
          decoration: BoxDecoration(
            color: colorCategoria(reporte.categoria)
                .withValues(alpha: 0.85),
            shape: BoxShape.circle,
            border: Border.all(
              color: colorTextoCategoria(reporte.categoria),
              width: 1.5,
            ),
          ),
          child: Icon(
            iconoCategoria(reporte.categoria),
            size: 18,
            color: colorTextoCategoria(reporte.categoria),
          ),
        ),
      );
    }).toList(),
    builder: (context, markers) {
      final color = _colorCluster(markers.length);
      return Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            '${markers.length}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      );
    },
  ),
),



                  // Pin de ubicación seleccionada
                  if (_ubicacionSeleccionada != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _ubicacionSeleccionada!,
                          width: 50,
                          height: 50,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.deepOrange,
                            size: 45,
                          ),
                        ),
                      ],
                    ),
                ],
              );
            },
          ),

          // Banner superior de instrucción
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.93),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(Icons.touch_app_outlined,
                      size: 18, color: cs.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    'Tocá el mapa para ubicar el problema',
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  CircleMarker _buildCirculoZona(ZonaCritica zona) {
    final color = _colorPorNivel(zona.nivelCriticidad);
    return CircleMarker(
      point: LatLng(zona.latitudCentro, zona.longitudCentro),
      radius: zona.radioMetros,
      useRadiusInMeter: true,
      color: color.withValues(alpha: 0.12),
      borderColor: color,
      borderStrokeWidth: 3,
    );
  }

  Color _colorPorNivel(NivelCriticidad nivel) {
    switch (nivel) {
      case NivelCriticidad.moderada:
        return const Color(0xFFE6A817);
      case NivelCriticidad.alta:
        return const Color(0xFFE06B1A);
      case NivelCriticidad.critica:
        return const Color(0xFFCC2A2A);
    }
  }

  Color _colorCluster(int cantidad) {
    if (cantidad >= 10) return const Color(0xFFCC2A2A);
    if (cantidad >= 5) return const Color(0xFFE06B1A);
    return const Color(0xFFE6A817);
}
}