// lib/models/reporte.dart

enum CategoriaReporte {
  vial,
  electrico,
  agua,
  cloacal,
  espaciosVerdes,
  residuos,
  seguridadVial,
  edificiosPublicos,
}

enum EstadoReporte {
  activo,
  pendienteDeCierre,
  resuelto,
}

class Reporte {
  final String id;
  final String titulo;
  final String descripcion;
  final CategoriaReporte categoria;
  final DateTime fecha;
  final String autorId;
  final String autorNombre;
  final EstadoReporte estado;
  final String? respuestaAdmin;
  final double? latitud;
  final double? longitud;

  const Reporte({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.fecha,
    required this.autorId,
    required this.autorNombre,
    this.estado = EstadoReporte.activo,
    this.respuestaAdmin,
    this.latitud,
    this.longitud,
  });

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria.name,   
      'fecha': fecha,
      'autorId': autorId,
      'autorNombre': autorNombre,
      'estado': estado.name,
      'respuestaAdmin': respuestaAdmin,
      'latitud': latitud,
      'longitud': longitud,
    };
  }

  factory Reporte.fromMap(String id, Map<String, dynamic> map) {
    return Reporte(
      id: id,
      titulo: map['titulo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      categoria: CategoriaReporte.values.firstWhere(
        (c) => c.name == map['categoria'],
        orElse: () => CategoriaReporte.vial,
      ),
      fecha: (map['fecha'] as dynamic).toDate(),
      autorId: map['autorId'] ?? '',
      autorNombre: map['autorNombre'] ?? 'Usuario',
      estado: EstadoReporte.values.firstWhere(
        (e) => e.name == map['estado'],
        orElse: () => EstadoReporte.activo,
      ),
      respuestaAdmin: map['respuestaAdmin'],
      latitud: map['latitud'] != null ? (map['latitud'] as num).toDouble() : null,
      longitud: map['longitud'] != null ? (map['longitud'] as num).toDouble() : null,
    );
  }
}
