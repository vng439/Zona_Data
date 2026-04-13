// lib/services/reporte_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reports.dart';

class ReporteService {
  // Referencia a la colección de reportes en Firestore
  final CollectionReference _coleccion =
      FirebaseFirestore.instance.collection('reportes');

  // Escucha los reportes en tiempo real, ordenados por fecha descendente
  // Stream significa que se actualiza automáticamente cuando hay cambios
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

  // Guarda un nuevo reporte en Firestore
  Future<void> crearReporte(Reporte reporte) async {
    await _coleccion.add(reporte.toMap());
  }

  // Cambia el estado a pendienteDeCierre
  Future<void> solicitarCierre(String reporteId) async {
    await _coleccion.doc(reporteId).update({
      'estado': EstadoReporte.pendienteDeCierre.name,
    });
  }
}
