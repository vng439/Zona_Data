// lib/screens/nuevo_reporte/nuevo_reporte_screen.dart
import 'dart:io';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/reports.dart';
import '../../services/reporte_service.dart';
import '../../services/ubicacion_service.dart';
import '../../utils/reporte_helpers.dart';
import '../mapa/selector_ubicacion_screen.dart';

class NuevoReporteScreen extends StatefulWidget {
  const NuevoReporteScreen({super.key});

  @override
  State<NuevoReporteScreen> createState() => _NuevoReporteScreenState();
}

class _NuevoReporteScreenState extends State<NuevoReporteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  CategoriaReporte? _categoriaSeleccionada;
  bool _enviando = false;
  double? _latitud;
  double? _longitud;
  bool _obteniendoUbicacion = false;
  File? _imagenSeleccionada;
  bool _ubicacionEsDelMapa = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nuevo reporte',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel(context, 'Categoría'),
              const SizedBox(height: 8),
              _buildSelectorCategoria(context),
              const SizedBox(height: 24),
              _buildLabel(context, 'Título'),
              const SizedBox(height: 8),
              _buildCampoTitulo(context),
              const SizedBox(height: 24),
              _buildLabel(context, 'Descripción'),
              const SizedBox(height: 8),
              _buildCampoDescripcion(context),
              const SizedBox(height: 24),
              _buildLabel(context, 'Ubicación'),
              const SizedBox(height: 8),
              _buildSelectorUbicacion(context),
              const SizedBox(height: 24),
              _buildLabel(context, 'Foto'),
              const SizedBox(height: 8),
              _buildSelectorImagen(context),
              const SizedBox(height: 32),
              _buildBotonEnviar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String texto) {
    final cs = Theme.of(context).colorScheme;

    return Text(
      texto,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: cs.onSurface,
      ),
    );
  }

  Widget _buildSelectorCategoria(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: CategoriaReporte.values.map((categoria) {
        final seleccionada = _categoriaSeleccionada == categoria;
        return GestureDetector(
          onTap: () => setState(() => _categoriaSeleccionada = categoria),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: seleccionada
                  ? colorCategoria(categoria)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: seleccionada
                    ? colorTextoCategoria(categoria).withValues(alpha: 0.4)
                    : cs.outlineVariant,
              ),
            ),
            child: Text(
              labelCategoria(categoria),
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    seleccionada ? FontWeight.w500 : FontWeight.normal,
                color: seleccionada
                    ? colorTextoCategoria(categoria)
                    : cs.onSurfaceVariant,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCampoTitulo(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TextFormField(
      controller: _tituloController,
      decoration: InputDecoration(
        hintText: 'Ej: Bache en Av. San Martín',
        hintStyle:
            TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      maxLength: 80,
      validator: (valor) {
        if (valor == null || valor.trim().isEmpty) {
          return 'El título no puede estar vacío';
        }
        if (valor.trim().length < 10) {
          return 'El título debe tener al menos 10 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildCampoDescripcion(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TextFormField(
      controller: _descripcionController,
      decoration: InputDecoration(
        hintText: 'Describí el problema con el mayor detalle posible...',
        hintStyle:
            TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      maxLines: 5,
      maxLength: 500,
      validator: (valor) {
        if (valor == null || valor.trim().isEmpty) {
          return 'La descripción no puede estar vacía';
        }
        if (valor.trim().length < 20) {
          return 'La descripción debe tener al menos 20 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildSelectorUbicacion(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  final tieneUbicacion = _latitud != null;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Botón GPS
      GestureDetector(
        onTap: _obteniendoUbicacion ? null : _obtenerUbicacion,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(
              color: (tieneUbicacion && !_ubicacionEsDelMapa)
                  ? cs.primary
                  : cs.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                (tieneUbicacion && !_ubicacionEsDelMapa)
                    ? Icons.my_location
                    : Icons.my_location_outlined,
                color: (tieneUbicacion && !_ubicacionEsDelMapa)
                    ? cs.primary
                    : cs.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _obteniendoUbicacion
                    ? Text(
                        'Obteniendo ubicación...',
                        style: TextStyle(
                            color: cs.onSurfaceVariant, fontSize: 14),
                      )
                    : Text(
                        (tieneUbicacion && !_ubicacionEsDelMapa)
                            ? 'Ubicación GPS obtenida'
                            : 'Usar mi ubicación actual (GPS)',
                        style: TextStyle(
                          color: (tieneUbicacion && !_ubicacionEsDelMapa)
                              ? cs.primary
                              : cs.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
              ),
              if (_obteniendoUbicacion)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.primary,
                  ),
                ),
            ],
          ),
        ),
      ),

      const SizedBox(height: 10),

      // Botón elegir en el mapa
      GestureDetector(
        onTap: _abrirSelectorMapa,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(
              color: (tieneUbicacion && _ubicacionEsDelMapa)
                  ? cs.primary
                  : cs.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                (tieneUbicacion && _ubicacionEsDelMapa)
                    ? Icons.map
                    : Icons.map_outlined,
                color: (tieneUbicacion && _ubicacionEsDelMapa)
                    ? cs.primary
                    : cs.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  (tieneUbicacion && _ubicacionEsDelMapa)
                      ? 'Ubicación elegida en el mapa'
                      : 'Elegir ubicación en el mapa',
                  style: TextStyle(
                    color: (tieneUbicacion && _ubicacionEsDelMapa)
                        ? cs.primary
                        : cs.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: cs.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}


  Widget _buildSelectorImagen(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: _mostrarOpcionesImagen,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: _imagenSeleccionada != null ? 200 : 100,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: _imagenSeleccionada != null
                ? cs.primary
                : cs.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(10),
          color: cs.surfaceContainerLowest,
        ),
        child: _imagenSeleccionada != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.file(
                      _imagenSeleccionada!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _imagenSeleccionada = null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: cs.surface.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close,
                            size: 18, color: cs.onSurface),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined,
                      color: cs.onSurfaceVariant, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    'Adjuntar foto (opcional)',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBotonEnviar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _enviando ? null : _enviarFormulario,
        style: FilledButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _enviando
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: cs.onPrimary,
                ),
              )
            : const Text(
                'Publicar reporte',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
      ),
    );
  }
  

  Future<void> _seleccionarImagen(ImageSource fuente) async {
    final XFile? archivo = await _picker.pickImage(
      source: fuente,
      imageQuality: 90,
      maxWidth: 1920,
    );

    if (archivo == null) return;

    setState(() {
      _imagenSeleccionada = File(archivo.path);
    });
  }

  void _mostrarOpcionesImagen() {
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading:
                  Icon(Icons.photo_library_outlined, color: cs.primary),
              title: const Text('Elegir de la galería'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagen(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: cs.primary),
              title: const Text('Tomar una foto'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagen(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _obtenerUbicacion() async {
  setState(() => _obteniendoUbicacion = true);

  final posicion = await UbicacionService().obtenerUbicacion();

  if (!mounted) return;

  if (posicion != null) {
    setState(() {
      _latitud = posicion.latitude;
      _longitud = posicion.longitude;
      _ubicacionEsDelMapa = false;
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No se pudo obtener la ubicación')),
    );
  }

  setState(() => _obteniendoUbicacion = false);
}

  Future<void> _abrirSelectorMapa() async {
  final LatLng? resultado = await Navigator.push<LatLng>(
    context,
    MaterialPageRoute(
      builder: (context) => const SelectorUbicacionScreen(),
    ),
  );

  if (resultado == null) return;

  setState(() {
    _latitud = resultado.latitude;
    _longitud = resultado.longitude;
    _ubicacionEsDelMapa = true;
  });
}

  Future<void> _enviarFormulario() async {
  if (_categoriaSeleccionada == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Seleccioná una categoría')),
    );
    return;
  }

  if (!_formKey.currentState!.validate()) return;

  final usuario = FirebaseAuth.instance.currentUser;
  if (usuario == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Necesitás iniciar sesión para publicar')),
    );
    return;
  }

  // Solo verificar duplicados si hay ubicación
  if (_latitud != null && _longitud != null) {
    setState(() => _enviando = true);

    final cercanos = await ReporteService().buscarReportesCercanos(
      categoria: _categoriaSeleccionada!,
      latitud: _latitud!,
      longitud: _longitud!,
    );

    if (!mounted) return;
    setState(() => _enviando = false);

    if (cercanos.isNotEmpty) {
      final continuar = await _mostrarDialogoDuplicados(cercanos, usuario.uid);
      if (!mounted) return;
      if (!continuar) return;
    }
  }

  setState(() => _enviando = true);

  try {
    final reporte = Reporte(
      id: '',
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      categoria: _categoriaSeleccionada!,
      fecha: DateTime.now(),
      autorId: usuario.uid,
      autorNombre: usuario.displayName ?? 'Usuario',
      latitud: _latitud,
      longitud: _longitud,
    );

    await ReporteService().crearReporte(
      reporte,
      imagenFile: _imagenSeleccionada,
    );

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reporte publicado correctamente'),
        duration: Duration(seconds: 2),
      ),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Error al publicar. Intentá de nuevo')),
    );
  } finally {
    if (mounted) setState(() => _enviando = false);
  }
}

/// Muestra el diálogo de duplicados y devuelve true si el usuario
/// decide crear el reporte de todas formas.
Future<bool> _mostrarDialogoDuplicados(
  List<Reporte> cercanos,
  String usuarioId,
) async {
  final cs = Theme.of(context).colorScheme;

  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reportes cercanos encontrados'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hay reportes de la misma categoría a menos de 50 metros. '
                  '¿Querés sumarte a alguno o tu caso es diferente?',
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                ...cercanos.map((reporte) {
                  final yaApoyo =
                      reporte.apoyosUsuarios.contains(usuarioId);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reporte.titulo,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          reporte.autorNombre,
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        if (reporte.apoyos > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${reporte.apoyos} ${reporte.apoyos == 1 ? 'persona se sumó' : 'personas se sumaron'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: yaApoyo
                                ? null
                                : () async {
                                    await ReporteService().sumarseAReporte(
                                      reporteId: reporte.id,
                                      usuarioId: usuarioId,
                                    );
                                    if (context.mounted) {
                                      Navigator.pop(context, false);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Te sumaste al reporte correctamente'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              yaApoyo ? 'Ya te sumaste' : 'Sumarme a este reporte',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancelar',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: cs.primary),
              child: const Text('Mi caso es diferente'),
            ),
          ],
        ),
      ) ??
      false;
}

}
