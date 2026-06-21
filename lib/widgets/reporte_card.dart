// lib/widgets/reporte_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/reports.dart';
import '../utils/reporte_helpers.dart';

class ReporteCard extends StatelessWidget {
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner de thumbnail, solo visible si hay imagen
            if (reporte.thumbnailUrl != null)
              _buildThumbnailBanner(context),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 8),
                  _buildTitulo(),
                  const SizedBox(height: 4),
                  _buildDescripcion(),
                  _buildApoyos(),
                  _buildRespuestaAdmin(),
                  const SizedBox(height: 12),
                  _buildFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailBanner(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: CachedNetworkImage(
        imageUrl: reporte.thumbnailUrl!,
        height: 140,
        width: double.infinity,
        fit: BoxFit.cover,
        // Placeholder mientras carga: shimmer suave con el color del tema
        placeholder: (context, url) => Container(
          height: 140,
          color: Colors.grey.withValues(alpha: 0.15),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: 140,
          color: Colors.grey.withValues(alpha: 0.1),
          child: const Center(
            child: Icon(Icons.broken_image_outlined,
                color: Colors.grey, size: 28),
          ),
        ),
      ),
    );
  }

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
        height: 1.5,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildApoyos(){
    if (reporte.apoyos == 0) return const SizedBox.shrink(); {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child:Row(
          children: [
            Icon(Icons.people_outline, size: 14, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              '${reporte.apoyos} ${reporte.apoyos == 1 ? 'persona se sumó' : 'personas se sumaron'} a este reporte',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildRespuestaAdmin() {
    if (reporte.estado == EstadoReporte.resuelto &&
        reporte.respuestaAdmin != null) {
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

    return const SizedBox.shrink();
  }

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

