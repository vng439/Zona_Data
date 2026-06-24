import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/reports.dart';
import '../../services/ubicacion_service.dart';
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
            const SizedBox(height: 6),
            _buildDireccion(context),
            const SizedBox(height: 12),
            _buildDescripcion(context),
            if (reporte.imagenUrl != null) ...[
              const SizedBox(height: 16),
              _buildImagenCompleta(context),
            ],
            if (reporte.latitud != null && reporte.longitud != null) ...[
              const SizedBox(height: 16),
              _buildMapaMiniatura(context),
            ],
            const SizedBox(height: 16),
            _buildDivider(context),
            const SizedBox(height: 16),
            _buildMetadata(context),
            _buildApoyos(context),
            _buildInfoBox(context),
            const SizedBox(height: 32),
            _buildBotonCierre(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDireccion(BuildContext context) {
    if (reporte.latitud == null || reporte.longitud == null) {
      return const SizedBox.shrink();
    }

    final cs = Theme.of(context).colorScheme;

    return FutureBuilder<String?>(
      future: UbicacionService().obtenerDireccion(
        reporte.latitud!,
        reporte.longitud!,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Buscando dirección...',
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
              ),
            ],
          );
        }

        final direccion = snapshot.data;
        if (direccion == null) return const SizedBox.shrink();

        return Row(
          children: [
            Icon(Icons.location_on_outlined,
                size: 16, color: cs.onSurfaceVariant),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                direccion,
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMapaMiniatura(BuildContext context) {
    final punto = LatLng(reporte.latitud!, reporte.longitud!);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 150,
        child: IgnorePointer(
          child: FlutterMap(
            options: MapOptions(
              initialCenter: punto,
              initialZoom: 16,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ldsw.zona_data',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: punto,
                    width: 36,
                    height: 36,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorCategoria(reporte.categoria),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorTextoCategoria(reporte.categoria),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        iconoCategoria(reporte.categoria),
                        size: 18,
                        color: colorTextoCategoria(reporte.categoria),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagenCompleta(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: reporte.imagenUrl!,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 200,
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: cs.primary,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: 120,
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(Icons.broken_image_outlined,
                color: cs.onSurfaceVariant, size: 32),
          ),
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
        Icon(Icons.access_time, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          formatearFecha(reporte.fecha),
          style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildApoyos(BuildContext context) {
    if (reporte.apoyos == 0) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.people_outline, size: 18, color: cs.onPrimaryContainer),
          const SizedBox(width: 8),
          Text(
            '${reporte.apoyos} ${reporte.apoyos == 1 ? 'persona se sumó' : 'personas se sumaron'} a este reporte',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: cs.onPrimaryContainer,
            ),
          ),
        ],
      ),
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

    if (reporte.estado == EstadoReporte.activo &&
      reporte.cierreSugeridoUsuarios.isNotEmpty) {
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
              'Cierre sugerido por la comunidad',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: cs.onTertiaryContainer,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${reporte.cierreSugeridoUsuarios.length} vecino(s) indicaron que este '
              'problema fue resuelto.',
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
            style: TextButton.styleFrom(foregroundColor: cs.primary),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}