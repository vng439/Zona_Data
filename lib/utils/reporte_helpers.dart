import 'package:flutter/material.dart';
import '../models/reports.dart';

// Devuelve el texto legible para cada categoría
String labelCategoria(CategoriaReporte categoria) {
  switch (categoria) {
    case CategoriaReporte.bachesYCalles:
      return 'Baches y calles';
    case CategoriaReporte.luminariaYElectrico:
      return 'Luminaria y eléctrico';
    case CategoriaReporte.aguaYDesagues:
      return 'Agua y desagües';
    case CategoriaReporte.espaciosVerdesYPoda:
      return 'Espacios verdes y poda';
    case CategoriaReporte.basuraYLimpieza:
      return 'Basura y limpieza';
    case CategoriaReporte.transitoYSenalizacion:
      return 'Tránsito y señalización';
    case CategoriaReporte.edificiosYEspaciosPublicos:
      return 'Edificios y espacios públicos';
    case CategoriaReporte.animalesSueltos:
      return 'Animales sueltos';
    case CategoriaReporte.otros:
      return 'Otros';
  }
}

// Devuelve el color de fondo del badge de categoría
Color colorCategoria(CategoriaReporte categoria) {
  switch (categoria) {
    case CategoriaReporte.bachesYCalles:
      return const Color(0xFFFAEEDA);
    case CategoriaReporte.luminariaYElectrico:
      return const Color(0xFFFFFBE6);
    case CategoriaReporte.aguaYDesagues:
      return const Color(0xFFE6F1FB);
    case CategoriaReporte.espaciosVerdesYPoda:
      return const Color(0xFFE1F5EE);
    case CategoriaReporte.basuraYLimpieza:
      return const Color(0xFFEAF3DE);
    case CategoriaReporte.transitoYSenalizacion:
      return const Color(0xFFFAECE7);
    case CategoriaReporte.edificiosYEspaciosPublicos:
      return const Color(0xFFEEEDFE);
    case CategoriaReporte.animalesSueltos:
      return const Color(0xFFF3EBE8);
    case CategoriaReporte.otros:
      return const Color(0xFFF0F0F0);
  }
}

// Devuelve el color del texto del badge de categoría
Color colorTextoCategoria(CategoriaReporte categoria) {
  switch (categoria) {
    case CategoriaReporte.bachesYCalles:
      return const Color(0xFF633806);
    case CategoriaReporte.luminariaYElectrico:
      return const Color(0xFF6B5A00);
    case CategoriaReporte.aguaYDesagues:
      return const Color(0xFF0C447C);
    case CategoriaReporte.espaciosVerdesYPoda:
      return const Color(0xFF085041);
    case CategoriaReporte.basuraYLimpieza:
      return const Color(0xFF27500A);
    case CategoriaReporte.transitoYSenalizacion:
      return const Color(0xFF712B13);
    case CategoriaReporte.edificiosYEspaciosPublicos:
      return const Color(0xFF3C3489);
    case CategoriaReporte.animalesSueltos:
      return const Color(0xFF5C2E1A);
    case CategoriaReporte.otros:
      return const Color(0xFF4A4A4A);
  }
}

// Devuelve el ícono para cada categoría (centralizado para todo el proyecto)
IconData iconoCategoria(CategoriaReporte categoria) {
  switch (categoria) {
    case CategoriaReporte.bachesYCalles:
      return Icons.route;
    case CategoriaReporte.luminariaYElectrico:
      return Icons.lightbulb_outline;
    case CategoriaReporte.aguaYDesagues:
      return Icons.water_drop;
    case CategoriaReporte.espaciosVerdesYPoda:
      return Icons.park;
    case CategoriaReporte.basuraYLimpieza:
      return Icons.delete_outline;
    case CategoriaReporte.transitoYSenalizacion:
      return Icons.traffic;
    case CategoriaReporte.edificiosYEspaciosPublicos:
      return Icons.business;
    case CategoriaReporte.animalesSueltos:
      return Icons.pets;
    case CategoriaReporte.otros:
      return Icons.help_outline;
  }
}

// Devuelve el texto del badge de estado
String labelEstado(EstadoReporte estado) {
  switch (estado) {
    case EstadoReporte.activo:
      return 'Activo';
    case EstadoReporte.resuelto:
      return 'Resuelto';
    case EstadoReporte.historico:
      return 'Histórico';
  }
}

// Devuelve el color de fondo del badge de estado
Color colorEstado(EstadoReporte estado) {
  switch (estado) {
    case EstadoReporte.activo:
      return const Color(0xFFFCEBEB);
    case EstadoReporte.resuelto:
      return const Color(0xFFE1F5EE);
    case EstadoReporte.historico:
      return const Color(0xFFEDEDED);
  }
}

// Devuelve el color del texto del badge de estado
Color colorTextoEstado(EstadoReporte estado) {
  switch (estado) {
    case EstadoReporte.activo:
      return const Color(0xFFA32D2D);
    case EstadoReporte.resuelto:
      return const Color(0xFF0F6E56);
    case EstadoReporte.historico:
      return const Color(0xFF6B6B6B);
  }
}

// Formatea la fecha de forma legible
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
