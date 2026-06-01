// lib/services/reporte_service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reports.dart';
import 'almacenamiento_service.dart';

class ReporteService {
  final CollectionReference _coleccion =
      FirebaseFirestore.instance.collection('reportes');

  final StorageService _storageService = StorageService();

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

  /// Crea un reporte en Firestore. Si se pasa [imagenFile], primero
  /// sube ambas versiones a Storage y guarda las URLs en el documento.
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

  Future<void> solicitarCierre(String reporteId) async {
    await _coleccion.doc(reporteId).update({
      'estado': EstadoReporte.pendienteDeCierre.name,
    });
  }
}

