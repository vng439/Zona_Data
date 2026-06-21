import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reports.dart';
import 'almacenamiento_service.dart';

class ReporteService {
  final CollectionReference _coleccion =
      FirebaseFirestore.instance.collection('reportes');

  final StorageService _storageService = StorageService();

  static const double _radioduplicadosMetros = 50.0;

  Stream<List<Reporte>> obtenerReportes() {
    return _coleccion
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Reporte.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> crearReporte(Reporte reporte, {File? imagenFile}) async {
    String? imagenUrl;
    String? thumbnailUrl;

    if (imagenFile != null) {
      final urls = await _storageService.subirImagenReporte(
        imagen: imagenFile,
        autorId: reporte.autorId,
      );
      imagenUrl = urls.imagenUrl;
      thumbnailUrl = urls.thumbnailUrl;
    }

    final reporteFinal = Reporte(
      id: reporte.id,
      titulo: reporte.titulo,
      descripcion: reporte.descripcion,
      categoria: reporte.categoria,
      fecha: reporte.fecha,
      autorId: reporte.autorId,
      autorNombre: reporte.autorNombre,
      estado: reporte.estado,
      respuestaAdmin: reporte.respuestaAdmin,
      latitud: reporte.latitud,
      longitud: reporte.longitud,
      imagenUrl: imagenUrl,
      thumbnailUrl: thumbnailUrl,
    );

    await _coleccion.add(reporteFinal.toMap());
  }

  /// Busca reportes de la misma categoría a menos de 50 metros
  /// con estado activo o pendiente de cierre.
  Future<List<Reporte>> buscarReportesCercanos({
    required CategoriaReporte categoria,
    required double latitud,
    required double longitud,
  }) async {
    final snapshot = await _coleccion
        .where('categoria', isEqualTo: categoria.name)
        .where('estado', whereIn: [
          EstadoReporte.activo.name,
          EstadoReporte.pendienteDeCierre.name,
        ])
        .get();

    final reportes = snapshot.docs
        .map((doc) => Reporte.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .where((r) => r.latitud != null && r.longitud != null)
        .where((r) => _haversineMetros(
              latitud,
              longitud,
              r.latitud!,
              r.longitud!,
            ) <= _radioduplicadosMetros)
        .toList();

    return reportes;
  }

  /// Suma el uid del usuario a apoyosUsuarios e incrementa el contador.
  Future<void> sumarseAReporte({
    required String reporteId,
    required String usuarioId,
  }) async {
    await _coleccion.doc(reporteId).update({
      'apoyos': FieldValue.increment(1),
      'apoyosUsuarios': FieldValue.arrayUnion([usuarioId]),
    });
  }

  Future<void> solicitarCierre(String reporteId) async {
    await _coleccion.doc(reporteId).update({
      'estado': EstadoReporte.pendienteDeCierre.name,
    });
  }

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

