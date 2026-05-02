// lib/services/zona_critica_service.dart

import 'dart:math';
import '../models/zona_critica.dart';

class ZonaCriticaService {
  // Radio máximo en metros para considerar dos reportes como parte del mismo grupo
  static const double _radioAgrupacionMetros = 100.0;

  // Umbral mínimo de reportes para declarar zona crítica
  static const int _umbralMinimo = 3;

  /// Detecta zonas críticas a partir de una lista de reportes geolocalizados.
  ///
  /// Algoritmo: Union-Find (Disjoint Set Union) adaptado a coordenadas.
  /// Complejidad: O(n²) en el peor caso, aceptable para datasets de MVP (<1000 reportes).
  /// Ventaja sobre naive: una sola pasada de agrupación sin recalcular grupos ya unidos.
  List<ZonaCritica> detectarZonasCriticas(List<ReporteGeo> reportes) {
    final int n = reportes.length;
    if (n < _umbralMinimo) return [];

    // parent[i] = índice del representante del grupo al que pertenece i
    final List<int> parent = List.generate(n, (i) => i);

    int find(int i) {
      // Path compression: aplana el árbol para futuras búsquedas
      if (parent[i] != i) parent[i] = find(parent[i]);
      return parent[i];
    }

    void union(int a, int b) {
      final ra = find(a);
      final rb = find(b);
      if (ra != rb) parent[ra] = rb;
    }

    // Conectar reportes dentro del radio de agrupación
    for (int i = 0; i < n; i++) {
      for (int j = i + 1; j < n; j++) {
        final distancia = _haversineMetros(
          reportes[i].latitud,
          reportes[i].longitud,
          reportes[j].latitud,
          reportes[j].longitud,
        );
        if (distancia <= _radioAgrupacionMetros) {
          union(i, j);
        }
      }
    }

    // Agrupar índices por representante
    final Map<int, List<int>> grupos = {};
    for (int i = 0; i < n; i++) {
      final raiz = find(i);
      grupos.putIfAbsent(raiz, () => []).add(i);
    }

    // Convertir grupos que superan el umbral en ZonaCritica
    final List<ZonaCritica> zonas = [];

    for (final indices in grupos.values) {
      if (indices.length < _umbralMinimo) continue;

      final miembros = indices.map((i) => reportes[i]).toList();

      // Centro geométrico del grupo (centroide simple)
      final double latCentro =
          miembros.map((r) => r.latitud).reduce((a, b) => a + b) /
              miembros.length;
      final double lonCentro =
          miembros.map((r) => r.longitud).reduce((a, b) => a + b) /
              miembros.length;

      // Radio real = distancia máxima desde el centroide a cualquier miembro
      final double radioReal = miembros
          .map((r) => _haversineMetros(latCentro, lonCentro, r.latitud, r.longitud))
          .reduce(max);

      zonas.add(ZonaCritica(
        latitudCentro: latCentro,
        longitudCentro: lonCentro,
        radioMetros: radioReal.clamp(_radioAgrupacionMetros, double.infinity),
        cantidadReportes: miembros.length,
        reporteIds: miembros.map((r) => r.id).toList(),
      ));
    }

    // Ordenar de mayor a menor concentración
    zonas.sort((a, b) => b.cantidadReportes.compareTo(a.cantidadReportes));

    return zonas;
  }

  /// Fórmula de Haversine — devuelve distancia en metros entre dos coordenadas.
  double _haversineMetros(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double radioTierraMetros = 6371000.0;

    final double dLat = _gradArad(lat2 - lat1);
    final double dLon = _gradArad(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_gradArad(lat1)) *
            cos(_gradArad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return radioTierraMetros * c;
  }

  double _gradArad(double grados) => grados * pi / 180.0;
}
