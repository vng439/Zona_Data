import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/reporte_service.dart';
import '../../services/zona_critica_service.dart';
import '../../models/reports.dart';
import '../../models/zona_critica.dart';
import '../../utils/reporte_helpers.dart';

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
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pop(context, _ubicacionSeleccionada);
              },
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              icon: const Icon(Icons.check),
              label: const Text(
                'Confirmar ubicación',
                style: TextStyle(fontWeight: FontWeight.w500),
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
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.ldsw.zona_data',
                  ),

                  // Zonas críticas
                  CircleLayer(
                    circles: zonasCriticas
                        .map((zona) => _buildCirculoZona(zona))
                        .toList(),
                  ),

                  // Marcadores de reportes existentes
                  MarkerLayer(
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
                            _iconoCategoria(reporte.categoria),
                            size: 18,
                            color: colorTextoCategoria(reporte.categoria),
                          ),
                        ),
                      );
                    }).toList(),
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
    return CircleMarker(
      point: LatLng(zona.latitudCentro, zona.longitudCentro),
      radius: zona.radioMetros,
      useRadiusInMeter: true,
      color: Colors.red.withValues(alpha: 0.3),
      borderColor: Colors.red,
      borderStrokeWidth: 2,
    );
  }

  IconData _iconoCategoria(CategoriaReporte categoria) {
    switch (categoria) {
      case CategoriaReporte.vial:
        return Icons.route;
      case CategoriaReporte.electrico:
        return Icons.bolt;
      case CategoriaReporte.agua:
        return Icons.water_drop;
      case CategoriaReporte.cloacal:
        return Icons.plumbing;
      case CategoriaReporte.espaciosVerdes:
        return Icons.park;
      case CategoriaReporte.residuos:
        return Icons.delete_outline;
      case CategoriaReporte.seguridadVial:
        return Icons.warning_amber;
      case CategoriaReporte.edificiosPublicos:
        return Icons.business;
    }
  }
}

