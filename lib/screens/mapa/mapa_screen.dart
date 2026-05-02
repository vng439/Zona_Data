// lib/screens/mapa/mapa_screen.dart


import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- IMPORTANTE PARA VALIDAR SESIÓN
import '../../services/reporte_service.dart';
import '../../services/zona_critica_service.dart';
import '../../models/reports.dart'; 
import '../../models/zona_critica.dart';
import '../../utils/reporte_helpers.dart';
import '../detalle/detalle_screen.dart';


class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});


  @override
  State<MapaScreen> createState() => _MapaScreenState();
}


class _MapaScreenState extends State<MapaScreen> {
  // Centro inicial del mapa (Caleta Olivia)
  static const LatLng _centroInicial = LatLng(-46.4333, -67.5167);
  
  // Variable para guardar el punto tocado manualmente
  LatLng? _ubicacionManualSeleccionada;


  // Función que levanta el formulario inferior
  void _mostrarFormularioCreacion() {
    if (_ubicacionManualSeleccionada == null) return;


    // VERIFICACIÓN DE SEGURIDAD: ¿Está logueado?
    final usuarioActual = FirebaseAuth.instance.currentUser;
    if (usuarioActual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para poder crear un reporte.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }


    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Evita que el teclado tape todo
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _FormularioReporteSheet(
          ubicacion: _ubicacionManualSeleccionada!,
          onReporteCreado: () {
            // Cuando se crea, limpiamos el pin y cerramos el modal
            setState(() {
              _ubicacionManualSeleccionada = null;
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('¡Reporte creado con éxito!')),
            );
          },
        );
      },
    );
  }


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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // BOTÓN FLOTANTE QUE APARECE AL TOCAR EL MAPA
      floatingActionButton: _ubicacionManualSeleccionada != null
          ? FloatingActionButton(
              onPressed: _mostrarFormularioCreacion,
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: const CircleBorder(),
              child: const Icon(Icons.add_location_alt_outlined, size: 32),
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


          // Detectar zonas críticas (Mapa de calor)
          final zonasCriticas =
              ZonaCriticaService().detectarZonasCriticas(reportesGeo);


          return FlutterMap(
            options: MapOptions(
              initialCenter: _centroInicial,
              initialZoom: 13,
              // Capturamos el toque en el mapa
              onTap: (tapPosition, point) {
                setState(() {
                  _ubicacionManualSeleccionada = point;
                });
              },
            ),
            children: [
              // Capa base OpenStreetMap
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ldsw.zona_data',
              ),
              
              // Capa de zonas críticas — debajo de los pins
              CircleLayer(
                circles: zonasCriticas
                    .map((zona) => _buildCirculoZona(zona))
                    .toList(),
              ),
              
              // Capa de marcadores individuales — encima de las zonas
              MarkerLayer(
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
                          _iconoCategoria(reporte.categoria),
                          size: 20,
                          color: colorTextoCategoria(reporte.categoria),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              // Capa del Pin Manual de Prueba (Naranja)
              if (_ubicacionManualSeleccionada != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _ubicacionManualSeleccionada!,
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
  CategoriaReporte _categoriaSeleccionada = CategoriaReporte.vial;
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
      autorId: usuarioActual.uid, // ID Real
      autorNombre: usuarioActual.displayName ?? usuarioActual.email ?? 'Usuario', 
      latitud: widget.ubicacion.latitude,
      longitud: widget.ubicacion.longitude,
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
                child: Text(cat.name.toUpperCase()),
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








