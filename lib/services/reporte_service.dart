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
  static const int _minimoVotosCierre = 5;
  static const Duration _plazoConfirmacionAutor = Duration(hours: 48);
  static const Duration _plazoInactividadHistorico = Duration(days: 90);

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
      ultimaActividad: reporte.fecha,
    );

    await _coleccion.add(reporteFinal.toMap());
  }

  /// Busca reportes de la misma categoría a menos de 50 metros
  /// con estado activo.
  Future<List<Reporte>> buscarReportesCercanos({
    required CategoriaReporte categoria,
    required double latitud,
    required double longitud,
  }) async {
    final snapshot = await _coleccion
        .where('categoria', isEqualTo: categoria.name)
        .where('estado', isEqualTo: EstadoReporte.activo.name)
        .get();

    final reportes = snapshot.docs
        .map((doc) =>
            Reporte.fromMap(doc.id, doc.data() as Map<String, dynamic>))
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

  /// Suma el uid del usuario a apoyosUsuarios, incrementa el contador
  /// y actualiza la fecha de última actividad (resetea el contador
  /// de inactividad para el paso a histórico).
  Future<void> sumarseAReporte({
    required String reporteId,
    required String usuarioId,
  }) async {
    await _coleccion.doc(reporteId).update({
      'apoyos': FieldValue.increment(1),
      'apoyosUsuarios': FieldValue.arrayUnion([usuarioId]),
      'ultimaActividad': DateTime.now(),
    });
  }

  /// El autor cierra el reporte directamente, sin espera.
  Future<void> cerrarDirectamentePorAutor(String reporteId) async {
    await _coleccion.doc(reporteId).update({
      'estado': EstadoReporte.resuelto.name,
      'origenResolucion': OrigenResolucion.comunidad.name,
    });
  }

  /// Un vecino (no autor) sugiere que el reporte está resuelto.
  /// Al llegar al mínimo de votos, se activa el plazo de 48hs
  /// para que el autor confirme o rechace.
  Future<void> sugerirCierre({
    required String reporteId,
    required String usuarioId,
  }) async {
    final doc = await _coleccion.doc(reporteId).get();
    if (!doc.exists) return;

    final reporte =
        Reporte.fromMap(doc.id, doc.data() as Map<String, dynamic>);

    if (reporte.cierreSugeridoUsuarios.contains(usuarioId)) return;

    final nuevosVotos = [...reporte.cierreSugeridoUsuarios, usuarioId];

    final actualizacion = <String, dynamic>{
      'cierreSugeridoUsuarios': nuevosVotos,
    };

    // Si justo alcanzamos el mínimo y todavía no había fecha seteada,
    // activamos el plazo de 48hs
    if (nuevosVotos.length >= _minimoVotosCierre &&
        reporte.cierreSugeridoFecha == null) {
      actualizacion['cierreSugeridoFecha'] = DateTime.now();
    }

    await _coleccion.doc(reporteId).update(actualizacion);
  }

  /// El autor confirma que el cierre sugerido por la comunidad es correcto.
  Future<void> confirmarCierrePorAutor(String reporteId) async {
    await _coleccion.doc(reporteId).update({
      'estado': EstadoReporte.resuelto.name,
      'origenResolucion': OrigenResolucion.comunidad.name,
    });
  }

  /// El autor rechaza el cierre sugerido: el reporte vuelve a activo
  /// y se reinicia el proceso de sugerencia.
  Future<void> rechazarCierrePorAutor(String reporteId) async {
    await _coleccion.doc(reporteId).update({
      'estado': EstadoReporte.activo.name,
      'cierreSugeridoUsuarios': <String>[],
      'cierreSugeridoFecha': null,
    });
  }

  /// Recorre una lista de reportes ya cargados y aplica en Firestore
  /// los cambios de estado correspondientes a vencimientos de plazo:
  /// - Cierre sugerido con más de 48hs sin respuesta del autor → resuelto
  /// - Reporte activo sin actividad en 90 días → histórico
  /// Se ejecuta del lado del cliente, disparado al abrir el feed o el mapa.
  Future<void> verificarYActualizarEstados(List<Reporte> reportes) async {
    final ahora = DateTime.now();

    for (final reporte in reportes) {
      // Caso 1: cierre sugerido vencido sin respuesta del autor
      if (reporte.estado == EstadoReporte.activo &&
          reporte.cierreSugeridoFecha != null) {
        final vencio = ahora.difference(reporte.cierreSugeridoFecha!) >=
            _plazoConfirmacionAutor;
        if (vencio) {
          await _coleccion.doc(reporte.id).update({
            'estado': EstadoReporte.resuelto.name,
            'origenResolucion': OrigenResolucion.comunidad.name,
          });
          continue;
        }
      }

      // Caso 2: inactividad prolongada → histórico
      if (reporte.estado == EstadoReporte.activo) {
        final inactivo = ahora.difference(reporte.ultimaActividad) >=
            _plazoInactividadHistorico;
        if (inactivo) {
          await _coleccion.doc(reporte.id).update({
            'estado': EstadoReporte.historico.name,
          });
        }
      }
    }
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