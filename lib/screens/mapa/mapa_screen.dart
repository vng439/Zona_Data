import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/reporte_service.dart';
import '../../services/zona_critica_service.dart';
import '../../models/reports.dart';
import '../../models/zona_critica.dart';
import '../../utils/reporte_helpers.dart';
import '../detalle/detalle_screen.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import '../nuevoReporte/nuevo_reporte_screen.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  static const LatLng _centroInicial = LatLng(-46.4333, -67.5167);
  LatLng? _ubicacionManualSeleccionada;

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mapa',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _ubicacionManualSeleccionada != null
    ? Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FilledButton.tonalIcon(
            onPressed: () {
              setState(() {
                _ubicacionManualSeleccionada = null;
              });
            },
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Quitar pin'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
            ),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            onPressed: () async {
              final usuarioActual = FirebaseAuth.instance.currentUser;
              if (usuarioActual == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Debes iniciar sesión para poder crear un reporte.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              await Navigator.push(
                context,
                PageRouteBuilder(
                  opaque: true,
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      NuevoReporteScreen(
                    ubicacionInicial: _ubicacionManualSeleccionada,
                  ),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );

              if (mounted) {
                setState(() {
                  _ubicacionManualSeleccionada = null;
                });
              }
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            elevation: 4,
            shape: const CircleBorder(),
            child: const Icon(Icons.add_location_alt_outlined, size: 32),
          ),
        ],
      )
    : null,

      body: StreamBuilder<List<Reporte>>(
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
                  _ubicacionManualSeleccionada = point;
                });
              },
            ),
            children: [
              
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ldsw.zona_data',
              ),

              // Capa de zonas críticas — debajo de los pins
              CircleLayer(
                circles: zonasCriticas
                    .map((zona) => _buildCirculoZona(zona))
                    .toList(),
              ),


              // Capa de marcadores con Clustering
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 60,
                  size: const Size(44, 44),
                  markers: reportesConUbicacion.map((reporte) {
                    return Marker(
                      point: LatLng(reporte.latitud!, reporte.longitud!),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetalleScreen(reporte: reporte),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorCategoria(reporte.categoria),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorTextoCategoria(reporte.categoria),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            iconoCategoria(reporte.categoria),
                            size: 20,
                            color: colorTextoCategoria(reporte.categoria),
                          ),
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

              // Pin de ubicación manual
              if (_ubicacionManualSeleccionada != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _ubicacionManualSeleccionada!,
                      width: 50,
                      height: 50,
                      child: Icon(
                        Icons.location_on,
                        color: Theme.of(context).colorScheme.primary,
                        size: 45,
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
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

// =========================================================================
// WIDGET DEL FORMULARIO INFERIOR (BottomSheet)
// =========================================================================
class _FormularioReporteSheet extends StatefulWidget {
  final LatLng ubicacion;
  final VoidCallback onReporteCreado;

  const _FormularioReporteSheet({
    required this.ubicacion,
    required this.onReporteCreado,
  });

  @override
  State<_FormularioReporteSheet> createState() =>
      _FormularioReporteSheetState();
}

class _FormularioReporteSheetState extends State<_FormularioReporteSheet> {
  final _tituloController = TextEditingController();
  final _descController = TextEditingController();
  CategoriaReporte _categoriaSeleccionada = CategoriaReporte.bachesYCalles;
  bool _estaGuardando = false;

  Future<void> _guardarReporte() async {
    if (_tituloController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completá todos los campos')),
      );
      return;
    }

    final usuarioActual = FirebaseAuth.instance.currentUser;
    if (usuarioActual == null) return;

    setState(() => _estaGuardando = true);

    final nuevoReporte = Reporte(
      id: '',
      titulo: _tituloController.text.trim(),
      descripcion: _descController.text.trim(),
      categoria: _categoriaSeleccionada,
      fecha: DateTime.now(),
      autorId: usuarioActual.uid,
      autorNombre:
          usuarioActual.displayName ?? usuarioActual.email ?? 'Usuario',
      latitud: widget.ubicacion.latitude,
      longitud: widget.ubicacion.longitude,
      ultimaActividad: DateTime.now(),
    );

    await ReporteService().crearReporte(nuevoReporte);

    widget.onReporteCreado();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Nuevo Reporte',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tituloController,
            decoration: const InputDecoration(
              labelText: 'Título corto (ej. Pozo profundo)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Descripción detallada',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<CategoriaReporte>(
            initialValue: _categoriaSeleccionada,
            decoration: const InputDecoration(
              labelText: 'Categoría',
              border: OutlineInputBorder(),
            ),
            items: CategoriaReporte.values.map((cat) {
              return DropdownMenuItem(
                value: cat,
                child: Text(labelCategoria(cat)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _categoriaSeleccionada = val);
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _estaGuardando ? null : _guardarReporte,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _estaGuardando
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Enviar Reporte'),
          ),
        ],
      ),
    );
  }
}






