// lib/screens/detalle/detalle_screen.dart

import 'package:flutter/material.dart';
import '../../models/reports.dart';
import '../../utils/reporte_helpers.dart';

class DetalleScreen extends StatelessWidget {
  final Reporte reporte;

  const DetalleScreen({super.key, required this.reporte});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle del reporte',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBadges(),
            const SizedBox(height: 16),
            _buildTitulo(context),
            const SizedBox(height: 8),
            _buildDescripcion(context),
            const SizedBox(height: 16),
            _buildDivider(context),
            const SizedBox(height: 16),
            _buildMetadata(context),
            _buildInfoBox(context),
            const SizedBox(height: 32),
            _buildBotonCierre(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBadges() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: colorCategoria(reporte.categoria),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            labelCategoria(reporte.categoria),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorTextoCategoria(reporte.categoria),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: colorEstado(reporte.estado),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            labelEstado(reporte.estado),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorTextoEstado(reporte.estado),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitulo(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Text(
      reporte.titulo,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: cs.onSurface,
      ),
    );
  }

  Widget _buildDescripcion(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Text(
      reporte.descripcion,
      style: TextStyle(
        fontSize: 15,
        color: cs.onSurfaceVariant,
        height: 1.6,
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Divider(color: cs.outlineVariant);
  }

  Widget _buildMetadata(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(Icons.person_outline, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          reporte.autorNombre,
          style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
        ),
        const SizedBox(width: 16),
        Icon(Icons.access_time, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          formatearFecha(reporte.fecha),
          style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildInfoBox(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (reporte.estado == EstadoReporte.resuelto &&
        reporte.respuestaAdmin != null) {
      return Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          border: Border(
            left: BorderSide(color: cs.primary, width: 3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Respuesta del administrador',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: cs.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              reporte.respuestaAdmin!,
              style: TextStyle(
                fontSize: 14,
                color: cs.onPrimaryContainer,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    if (reporte.estado == EstadoReporte.pendienteDeCierre) {
      return Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.tertiaryContainer,
          border: Border(
            left: BorderSide(color: cs.tertiary, width: 3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Solicitud de cierre enviada',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: cs.onTertiaryContainer,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Un vecino indicó que este problema fue resuelto. '
              'Esperando confirmación del administrador.',
              style: TextStyle(
                fontSize: 14,
                color: cs.onTertiaryContainer,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildBotonCierre(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (reporte.estado != EstadoReporte.activo) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _mostrarDialogoCierre(context),
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Este problema ya fue resuelto'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: cs.primary),
          foregroundColor: cs.primary,
        ),
      ),
    );
  }

  void _mostrarDialogoCierre(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Solicitar cierre'),
        content: const Text(
          '¿Confirmás que este problema fue resuelto? '
          'Tu solicitud será revisada por el administrador.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Solicitud enviada. Gracias por informar.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: cs.primary,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}