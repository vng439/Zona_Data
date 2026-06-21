// Niveles de criticidad según cantidad de reportes

enum NivelCriticidad {
  moderada,  // 5-9 reportes
  alta,      // 10-19 reportes
  critica,   // 20+ reportes
}

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

  // Getter calculado — no requiere cambios en el constructor
  NivelCriticidad get nivelCriticidad {
    if (cantidadReportes >= 20) return NivelCriticidad.critica;
    if (cantidadReportes >= 10) return NivelCriticidad.alta;
    return NivelCriticidad.moderada;
  }
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

