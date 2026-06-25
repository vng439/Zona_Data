import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/reports.dart';
import '../../services/reporte_service.dart';
import '../../services/ubicacion_service.dart';
import '../../utils/reporte_helpers.dart';

class DetalleScreen extends StatefulWidget {
  final Reporte reporte;

  const DetalleScreen({super.key, required this.reporte});

  @override
  State<DetalleScreen> createState() => _DetalleScreenState();
}

class _DetalleScreenState extends State<DetalleScreen> {
  late Reporte _reporte;
  bool _procesando = false;

  static const Duration _plazoConfirmacion = Duration(hours: 48);

  @override
  void initState() {
    super.initState();
    _reporte = widget.reporte;
  }

  String? get _usuarioActualId => FirebaseAuth.instance.currentUser?.uid;
  bool get _esAutor => _usuarioActualId == _reporte.autorId;
  bool get _hayCierreSugerido => _reporte.cierreSugeridoFecha != null;
  bool get _yaVotoCierre =>
      _usuarioActualId != null &&
      _reporte.cierreSugeridoUsuarios.contains(_usuarioActualId);

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
            if (_reporte.imagenUrl != null) ...[
              const SizedBox(height: 16),
              _buildImagenCompleta(context),
            ],
            if (_reporte.latitud != null && _reporte.longitud != null) ...[
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
            _buildBotonesCierre(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDireccion(BuildContext context) {
    if (_reporte.latitud == null || _reporte.longitud == null) {
      return const SizedBox.shrink();
    }

    final cs = Theme.of(context).colorScheme;

    return FutureBuilder<String?>(
      future: UbicacionService().obtenerDireccion(
        _reporte.latitud!,
        _reporte.longitud!,
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
    final punto = LatLng(_reporte.latitud!, _reporte.longitud!);

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
                        color: colorCategoria(_reporte.categoria),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorTextoCategoria(_reporte.categoria),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        iconoCategoria(_reporte.categoria),
                        size: 18,
                        color: colorTextoCategoria(_reporte.categoria),
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
        imageUrl: _reporte.imagenUrl!,
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
            color: colorCategoria(_reporte.categoria),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            labelCategoria(_reporte.categoria),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorTextoCategoria(_reporte.categoria),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: colorEstado(_reporte.estado),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            labelEstado(_reporte.estado),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorTextoEstado(_reporte.estado),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitulo(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Text(
      _reporte.titulo,
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
      _reporte.descripcion,
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
          formatearFecha(_reporte.fecha),
          style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildApoyos(BuildContext context) {
    if (_reporte.apoyos == 0) return const SizedBox.shrink();

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
            '${_reporte.apoyos} ${_reporte.apoyos == 1 ? 'persona se sumó' : 'personas se sumaron'} a este reporte',
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

    if (_reporte.estado == EstadoReporte.resuelto &&
        _reporte.respuestaAdmin != null) {
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
              _reporte.respuestaAdmin!,
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

    if (_reporte.estado == EstadoReporte.activo && _hayCierreSugerido) {
      final tiempoRestante = _calcularTiempoRestante();

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
              _esAutor
                  ? '${_reporte.cierreSugeridoUsuarios.length} vecinos indicaron que esto '
                      'fue resuelto. Tenés $tiempoRestante para confirmar o rechazar, '
                      'sino se confirmará automáticamente.'
                  : '${_reporte.cierreSugeridoUsuarios.length} vecinos indicaron que esto '
                      'fue resuelto. Esperando confirmación del autor.',
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

    if (_reporte.estado == EstadoReporte.activo &&
        !_hayCierreSugerido &&
        _yaVotoCierre) {
      return Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Ya sugeriste el cierre de este reporte.',
          style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _calcularTiempoRestante() {
    if (_reporte.cierreSugeridoFecha == null) return '';
    final vencimiento =
        _reporte.cierreSugeridoFecha!.add(_plazoConfirmacion);
    final restante = vencimiento.difference(DateTime.now());

    if (restante.isNegative) return 'muy poco tiempo';
    if (restante.inHours >= 1) return '${restante.inHours}h';
    return '${restante.inMinutes} min';
  }

  Widget _buildBotonesCierre(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_reporte.estado != EstadoReporte.activo) {
      return const SizedBox.shrink();
    }

    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) return const SizedBox.shrink();

    // Caso: hay cierre sugerido pendiente y el usuario es el autor
    if (_hayCierreSugerido && _esAutor) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _procesando ? null : _confirmarCierre,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Sí, ya se resolvió'),
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _procesando ? null : _rechazarCierre,
              icon: const Icon(Icons.close),
              label: const Text('No, sigue activo'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: cs.outlineVariant),
                foregroundColor: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      );
    }

    // Caso: hay cierre sugerido pendiente, pero el usuario no es el autor
    if (_hayCierreSugerido && !_esAutor) {
      return const SizedBox.shrink();
    }

    // Caso: el usuario es el autor, sin cierre sugerido todavía
    if (_esAutor) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _procesando ? null : _cerrarDirectamente,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Marcar como resuelto'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: BorderSide(color: cs.primary),
            foregroundColor: cs.primary,
          ),
        ),
      );
    }

    // Caso: usuario no es el autor, ya votó
    if (_yaVotoCierre) {
      return const SizedBox.shrink();
    }

    // Caso: usuario no es el autor, no votó todavía
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _procesando ? null : _sugerirCierre,
        icon: const Icon(Icons.thumb_up_outlined),
        label: const Text('Sugerir que esto se resolvió'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: cs.primary),
          foregroundColor: cs.primary,
        ),
      ),
    );
  }

  Future<void> _cerrarDirectamente() async {
    setState(() => _procesando = true);
    await ReporteService().cerrarDirectamentePorAutor(_reporte.id);
    if (!mounted) return;
    setState(() {
      _reporte = Reporte(
        id: _reporte.id,
        titulo: _reporte.titulo,
        descripcion: _reporte.descripcion,
        categoria: _reporte.categoria,
        fecha: _reporte.fecha,
        autorId: _reporte.autorId,
        autorNombre: _reporte.autorNombre,
        estado: EstadoReporte.resuelto,
        respuestaAdmin: _reporte.respuestaAdmin,
        latitud: _reporte.latitud,
        longitud: _reporte.longitud,
        imagenUrl: _reporte.imagenUrl,
        thumbnailUrl: _reporte.thumbnailUrl,
        apoyos: _reporte.apoyos,
        apoyosUsuarios: _reporte.apoyosUsuarios,
        origenResolucion: OrigenResolucion.comunidad,
        cierreSugeridoUsuarios: _reporte.cierreSugeridoUsuarios,
        cierreSugeridoFecha: _reporte.cierreSugeridoFecha,
        ultimaActividad: _reporte.ultimaActividad,
      );
      _procesando = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reporte marcado como resuelto')),
    );
  }

  Future<void> _sugerirCierre() async {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) return;

    setState(() => _procesando = true);
    await ReporteService().sugerirCierre(
      reporteId: _reporte.id,
      usuarioId: usuario.uid,
    );
    if (!mounted) return;

    final nuevosVotos = [..._reporte.cierreSugeridoUsuarios, usuario.uid];
    final activaPlazo = nuevosVotos.length >= 5 &&
        _reporte.cierreSugeridoFecha == null;

    setState(() {
      _reporte = _copiarReporteConCierre(
        cierreSugeridoUsuarios: nuevosVotos,
        cierreSugeridoFecha:
            activaPlazo ? DateTime.now() : _reporte.cierreSugeridoFecha,
      );
      _procesando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gracias por confirmar')),
    );
  }

  Future<void> _confirmarCierre() async {
    setState(() => _procesando = true);
    await ReporteService().confirmarCierrePorAutor(_reporte.id);
    if (!mounted) return;
    setState(() {
      _reporte = _copiarReporteConCierre(
        estado: EstadoReporte.resuelto,
        origenResolucion: OrigenResolucion.comunidad,
      );
      _procesando = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reporte marcado como resuelto')),
    );
  }

  Future<void> _rechazarCierre() async {
    setState(() => _procesando = true);
    await ReporteService().rechazarCierrePorAutor(_reporte.id);
    if (!mounted) return;
    setState(() {
      _reporte = _copiarReporteConCierre(
        estado: EstadoReporte.activo,
        cierreSugeridoUsuarios: [],
        cierreSugeridoFecha: null,
        limpiarCierreSugeridoFecha: true,
      );
      _procesando = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('El reporte sigue activo')),
    );
  }

  /// Helper para reconstruir el reporte local con cambios puntuales,
  /// ya que Reporte es inmutable (sin copyWith definido en el modelo).
  Reporte _copiarReporteConCierre({
    EstadoReporte? estado,
    OrigenResolucion? origenResolucion,
    List<String>? cierreSugeridoUsuarios,
    DateTime? cierreSugeridoFecha,
    bool limpiarCierreSugeridoFecha = false,
  }) {
    return Reporte(
      id: _reporte.id,
      titulo: _reporte.titulo,
      descripcion: _reporte.descripcion,
      categoria: _reporte.categoria,
      fecha: _reporte.fecha,
      autorId: _reporte.autorId,
      autorNombre: _reporte.autorNombre,
      estado: estado ?? _reporte.estado,
      respuestaAdmin: _reporte.respuestaAdmin,
      latitud: _reporte.latitud,
      longitud: _reporte.longitud,
      imagenUrl: _reporte.imagenUrl,
      thumbnailUrl: _reporte.thumbnailUrl,
      apoyos: _reporte.apoyos,
      apoyosUsuarios: _reporte.apoyosUsuarios,
      origenResolucion: origenResolucion ?? _reporte.origenResolucion,
      cierreSugeridoUsuarios:
          cierreSugeridoUsuarios ?? _reporte.cierreSugeridoUsuarios,
      cierreSugeridoFecha: limpiarCierreSugeridoFecha
          ? null
          : (cierreSugeridoFecha ?? _reporte.cierreSugeridoFecha),
      ultimaActividad: _reporte.ultimaActividad,
    );
  }
}