// lib/widgets/reporte_card.dart

import 'package:flutter/material.dart';
import '../models/reports.dart';
import '../utils/reporte_helpers.dart';

class ReporteCard extends StatelessWidget {
  // El widget recibe un Reporte y una función opcional para cuando se toca
  final Reporte reporte;
  final VoidCallback? onTap;

  const ReporteCard({
    super.key,
    required this.reporte,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // Card de Flutter ya maneja el fondo blanco y el borde redondeado
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0, // sin sombra, estilo flat
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: InkWell(
        // InkWell agrega el efecto de toque (ripple) al card
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildTitulo(),
              const SizedBox(height: 4),
              _buildDescripcion(),
              _buildRespuestaAdmin(),
              const SizedBox(height: 12),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // Fila superior: badge de categoría + badge de estado
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _Badge(
          texto: labelCategoria(reporte.categoria),
          colorFondo: colorCategoria(reporte.categoria),
          colorTexto: colorTextoCategoria(reporte.categoria),
        ),
        _Badge(
          texto: labelEstado(reporte.estado),
          colorFondo: colorEstado(reporte.estado),
          colorTexto: colorTextoEstado(reporte.estado),
        ),
      ],
    );
  }

  Widget _buildTitulo() {
    return Text(
      reporte.titulo,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDescripcion() {
    return Text(
      reporte.descripcion,
      style: TextStyle(
        fontSize: 13,
        color: Colors.grey[600],
        height: 1.5, // interlineado
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis, // corta con "..." si es muy largo
    );
  }

  // Solo se muestra si hay respuesta del admin o está pendiente de cierre
  Widget _buildRespuestaAdmin() {
    if (reporte.estado == EstadoReporte.resuelto && reporte.respuestaAdmin != null) {
      return _InfoBox(
        label: 'Respuesta del administrador',
        texto: reporte.respuestaAdmin!,
        colorBorde: const Color(0xFF1D9E75),
        colorLabel: const Color(0xFF0F6E56),
      );
    }

    if (reporte.estado == EstadoReporte.pendienteDeCierre) {
      return _InfoBox(
        label: 'Un vecino indicó que esto fue resuelto',
        texto: 'Esperando confirmación del administrador.',
        colorBorde: const Color(0xFFBA7517),
        colorLabel: const Color(0xFF854F0B),
      );
    }

    // Si no hay nada que mostrar, devolvemos un widget vacío
    return const SizedBox.shrink();
  }

  // Fila inferior: autor + fecha
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          reporte.autorNombre,
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        Text(
          formatearFecha(reporte.fecha),
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
      ],
    );
  }
}

// Widget privado para los badges de categoría y estado
// El guión bajo en el nombre indica que es privado a este archivo
class _Badge extends StatelessWidget {
  final String texto;
  final Color colorFondo;
  final Color colorTexto;

  const _Badge({
    required this.texto,
    required this.colorFondo,
    required this.colorTexto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: colorTexto,
        ),
      ),
    );
  }
}

// Widget privado para el bloque de respuesta admin o aviso de cierre pendiente
class _InfoBox extends StatelessWidget {
  final String label;
  final String texto;
  final Color colorBorde;
  final Color colorLabel;

  const _InfoBox({
    required this.label,
    required this.texto,
    required this.colorBorde,
    required this.colorLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          left: BorderSide(color: colorBorde, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: colorLabel,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            texto,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
