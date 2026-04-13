// lib/screens/detalle/detalle_screen.dart

import 'package:flutter/material.dart';
import '../../models/reports.dart';
import '../../utils/reporte_helpers.dart';


class DetalleScreen extends StatelessWidget {
  // Recibe el reporte completo desde la pantalla anterior
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
        // SingleChildScrollView permite que el contenido sea scrolleable
        // si no entra en pantalla
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBadges(),
            const SizedBox(height: 16),
            _buildTitulo(),
            const SizedBox(height: 8),
            _buildDescripcion(),
            const SizedBox(height: 16),
            _buildDivider(),
            const SizedBox(height: 16),
            _buildMetadata(context),
            _buildInfoBox(),
            const SizedBox(height: 32),
            _buildBotonCierre(context),
          ],
        ),
      ),
    );
  }

  // Fila de badges: categoría y estado
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

  Widget _buildTitulo() {
    return Text(
      reporte.titulo,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        height: 1.3,
      ),
    );
  }

  Widget _buildDescripcion() {
    return Text(
      reporte.descripcion,
      style: TextStyle(
        fontSize: 15,
        color: Colors.grey[600],
        height: 1.6,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey.withValues(alpha: 0.2));
  }

  // Autor y fecha
  Widget _buildMetadata(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.person_outline, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          reporte.autorNombre,
          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
        ),
        const SizedBox(width: 16),
        Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          formatearFecha(reporte.fecha),
          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
        ),
      ],
    );
  }

  // Bloque informativo: respuesta admin o aviso de cierre pendiente
  Widget _buildInfoBox() {
    if (reporte.estado == EstadoReporte.resuelto &&
        reporte.respuestaAdmin != null) {
      return Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          color: Color(0xFFE1F5EE),
          border: Border(
            left: BorderSide(color: Color(0xFF1D9E75), width: 3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Respuesta del administrador',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0F6E56),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              reporte.respuestaAdmin!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF085041),
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
        decoration: const BoxDecoration(
          color: Color(0xFFFAEEDA),
          border: Border(
            left: BorderSide(color: Color(0xFFBA7517), width: 3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Solicitud de cierre enviada',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF854F0B),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Un vecino indicó que este problema fue resuelto. '
              'Esperando confirmación del administrador.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF633806),
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // Botón de solicitar cierre — solo visible si el reporte está activo
  Widget _buildBotonCierre(BuildContext context) {
    if (reporte.estado != EstadoReporte.activo) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity, // ocupa todo el ancho disponible
      child: OutlinedButton.icon(
        onPressed: () {
          // Por ahora mostramos un diálogo de confirmación.
          // En la Etapa 3 esto va a escribir en Firestore.
          _mostrarDialogoCierre(context);
        },
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Este problema ya fue resuelto'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Color(0xFF1D9E75)),
          foregroundColor: const Color(0xFF1D9E75),
        ),
      ),
    );
  }

  void _mostrarDialogoCierre(BuildContext context) {
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
              foregroundColor: const Color(0xFF1D9E75),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
