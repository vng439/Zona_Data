// lib/models/zona_critica.dart

//import 'dart:math';

// Representa una zona crítica detectada por concentración de reportes
class ZonaCritica {
  final double latitudCentro;
  final double longitudCentro;
  final double radioMetros;
  final int cantidadReportes;
  final List<String> reporteIds;

  const ZonaCritica({
    required this.latitudCentro,
    required this.longitudCentro,
    required this.radioMetros,
    required this.cantidadReportes,
    required this.reporteIds,
  });
}

// Modelo mínimo para el algoritmo — compatible con Reporte existente
class ReporteGeo {
  final String id;
  final double latitud;
  final double longitud;

  const ReporteGeo({
    required this.id,
    required this.latitud,
    required this.longitud,
  });
}

