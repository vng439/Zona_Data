// lib/screens/mapa/mapa_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/reporte_service.dart';
import '../../models/reports.dart';
import '../../utils/reporte_helpers.dart';
import '../detalle/detalle_screen.dart';

class MapaScreen extends StatelessWidget {
  const MapaScreen({super.key});

  // Centro inicial del mapa — Caleta Olivia, Santa Cruz
  static const LatLng _centroInicial = LatLng(-46.4333, -67.5167);

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
      body: StreamBuilder<List<Reporte>>(
        stream: ReporteService().obtenerReportes(),
        builder: (context, snapshot) {
          final reportes = snapshot.data ?? [];

          // Filtramos solo los reportes que tienen coordenadas
          final reportesConUbicacion = reportes
              .where((r) => r.latitud != null && r.longitud != null)
              .toList();

          return FlutterMap(
            options: const MapOptions(
              initialCenter: _centroInicial,
              initialZoom: 13,
            ),
            children: [
              // Capa del mapa base de OpenStreetMap
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ldsw.zona_data',
              ),
              // Capa de marcadores — un pin por reporte
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
            ],
          );
        },
      ),
    );
  }

  // Icono según la categoría del reporte
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