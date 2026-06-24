enum CategoriaReporte {
  bachesYCalles,
  luminariaYElectrico,
  aguaYDesagues,
  espaciosVerdesYPoda,
  basuraYLimpieza,
  transitoYSenalizacion,
  edificiosYEspaciosPublicos,
  animalesSueltos,
  otros,
}

enum EstadoReporte {
  activo,
  resuelto,
  historico,
}

enum OrigenResolucion {
  comunidad,
  autoridad,
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
  final String? imagenUrl;
  final String? thumbnailUrl;
  final int apoyos;
  final List<String> apoyosUsuarios;
  final OrigenResolucion? origenResolucion;
  final List<String> cierreSugeridoUsuarios;
  final DateTime? cierreSugeridoFecha;
  final DateTime ultimaActividad;

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
    this.imagenUrl,
    this.thumbnailUrl,
    this.apoyos = 0,
    this.apoyosUsuarios = const [],
    this.origenResolucion,
    this.cierreSugeridoUsuarios = const [],
    this.cierreSugeridoFecha,
    required this.ultimaActividad,
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
      'imagenUrl': imagenUrl,
      'thumbnailUrl': thumbnailUrl,
      'apoyos': apoyos,
      'apoyosUsuarios': apoyosUsuarios,
      'origenResolucion': origenResolucion?.name,
      'cierreSugeridoUsuarios': cierreSugeridoUsuarios,
      'cierreSugeridoFecha': cierreSugeridoFecha,
      'ultimaActividad': ultimaActividad,
    };
  }

  factory Reporte.fromMap(String id, Map<String, dynamic> map) {
    return Reporte(
      id: id,
      titulo: map['titulo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      categoria: CategoriaReporte.values.firstWhere(
        (c) => c.name == map['categoria'],
        orElse: () => CategoriaReporte.bachesYCalles,
      ),
      fecha: (map['fecha'] as dynamic).toDate(),
      autorId: map['autorId'] ?? '',
      autorNombre: map['autorNombre'] ?? 'Usuario',
      estado: EstadoReporte.values.firstWhere(
        (e) => e.name == map['estado'],
        orElse: () => EstadoReporte.activo,
      ),
      respuestaAdmin: map['respuestaAdmin'],
      latitud: map['latitud'] != null
          ? (map['latitud'] as num).toDouble()
          : null,
      longitud: map['longitud'] != null
          ? (map['longitud'] as num).toDouble()
          : null,
      imagenUrl: map['imagenUrl'],
      thumbnailUrl: map['thumbnailUrl'],
      apoyos: map['apoyos'] ?? 0,
      apoyosUsuarios: List<String>.from(map['apoyosUsuarios'] ?? []),
      origenResolucion: map['origenResolucion'] != null
          ? OrigenResolucion.values.firstWhere(
              (o) => o.name == map['origenResolucion'],
              orElse: () => OrigenResolucion.comunidad,
            )
          : null,
      cierreSugeridoUsuarios:
          List<String>.from(map['cierreSugeridoUsuarios'] ?? []),
      cierreSugeridoFecha: map['cierreSugeridoFecha'] != null
          ? (map['cierreSugeridoFecha'] as dynamic).toDate()
          : null,
      ultimaActividad: map['ultimaActividad'] != null
          ? (map['ultimaActividad'] as dynamic).toDate()
          : (map['fecha'] as dynamic).toDate(),
    );
  }
}