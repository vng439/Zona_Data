// lib/utils/reporte_helpers.dart

import 'package:flutter/material.dart';
import '../models/reports.dart';

// Devuelve el texto legible para cada categoría
String labelCategoria(CategoriaReporte categoria) {
  switch (categoria) {
    case CategoriaReporte.vial:             return 'Vial';
    case CategoriaReporte.electrico:        return 'Eléctrico';
    case CategoriaReporte.agua:             return 'Agua';
    case CategoriaReporte.cloacal:          return 'Cloacal';
    case CategoriaReporte.espaciosVerdes:   return 'Espacios verdes';
    case CategoriaReporte.residuos:         return 'Residuos';
    case CategoriaReporte.seguridadVial:    return 'Seguridad vial';
    case CategoriaReporte.edificiosPublicos:return 'Edificios públicos';
  }
}

// Devuelve el color de fondo del badge de categoría
Color colorCategoria(CategoriaReporte categoria) {
  switch (categoria) {
    case CategoriaReporte.vial:             return const Color(0xFFFAEEDA);
    case CategoriaReporte.electrico:        return const Color(0xFFFAEEDA);
    case CategoriaReporte.agua:             return const Color(0xFFE6F1FB);
    case CategoriaReporte.cloacal:          return const Color(0xFFF1EFE8);
    case CategoriaReporte.espaciosVerdes:   return const Color(0xFFE1F5EE);
    case CategoriaReporte.residuos:         return const Color(0xFFEAF3DE);
    case CategoriaReporte.seguridadVial:    return const Color(0xFFFAECE7);
    case CategoriaReporte.edificiosPublicos:return const Color(0xFFEEEDFE);
  }
}

// Devuelve el color del texto del badge de categoría
Color colorTextoCategoria(CategoriaReporte categoria) {
  switch (categoria) {
    case CategoriaReporte.vial:             return const Color(0xFF633806);
    case CategoriaReporte.electrico:        return const Color(0xFF633806);
    case CategoriaReporte.agua:             return const Color(0xFF0C447C);
    case CategoriaReporte.cloacal:          return const Color(0xFF444441);
    case CategoriaReporte.espaciosVerdes:   return const Color(0xFF085041);
    case CategoriaReporte.residuos:         return const Color(0xFF27500A);
    case CategoriaReporte.seguridadVial:    return const Color(0xFF712B13);
    case CategoriaReporte.edificiosPublicos:return const Color(0xFF3C3489);
  }
}

// Devuelve el texto del badge de estado
String labelEstado(EstadoReporte estado) {
  switch (estado) {
    case EstadoReporte.activo:             return 'Activo';
    case EstadoReporte.pendienteDeCierre:  return 'Pendiente de cierre';
    case EstadoReporte.resuelto:           return 'Resuelto';
  }
}

// Devuelve el color de fondo del badge de estado
Color colorEstado(EstadoReporte estado) {
  switch (estado) {
    case EstadoReporte.activo:            return const Color(0xFFFCEBEB);
    case EstadoReporte.pendienteDeCierre: return const Color(0xFFFAEEDA);
    case EstadoReporte.resuelto:          return const Color(0xFFE1F5EE);
  }
}

// Devuelve el color del texto del badge de estado
Color colorTextoEstado(EstadoReporte estado) {
  switch (estado) {
    case EstadoReporte.activo:            return const Color(0xFFA32D2D);
    case EstadoReporte.pendienteDeCierre: return const Color(0xFF854F0B);
    case EstadoReporte.resuelto:          return const Color(0xFF0F6E56);
  }
}

// Formatea la fecha de forma legible: "hace 2 horas", "hace 1 día", etc.
String formatearFecha(DateTime fecha) {
  final diferencia = DateTime.now().difference(fecha);

  if (diferencia.inMinutes < 60) {
    return 'hace ${diferencia.inMinutes} min';
  } else if (diferencia.inHours < 24) {
    final h = diferencia.inHours;
    return 'hace $h ${h == 1 ? 'hora' : 'horas'}';
  } else {
    final d = diferencia.inDays;
    return 'hace $d ${d == 1 ? 'día' : 'días'}';
  }
}
