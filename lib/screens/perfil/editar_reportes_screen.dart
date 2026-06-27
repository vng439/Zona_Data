import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/reports.dart';
import '../../services/reporte_service.dart';
import '../../utils/validadores.dart';
import '../../utils/moderacion_texto.dart';

class EditarReporteScreen extends StatefulWidget {
  final Reporte reporte;

  const EditarReporteScreen({super.key, required this.reporte});

  @override
  State<EditarReporteScreen> createState() => _EditarReporteScreenState();
}

class _EditarReporteScreenState extends State<EditarReporteScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloController;
  late final TextEditingController _descripcionController;
  final ImagePicker _picker = ImagePicker();

  File? _nuevaImagen;
  bool _imagenEliminada = false;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.reporte.titulo);
    _descripcionController =
        TextEditingController(text: widget.reporte.descripcion);
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  bool get _tieneImagenActual =>
      widget.reporte.imagenUrl != null && !_imagenEliminada;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar reporte',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel(context, 'Título'),
              const SizedBox(height: 8),
              _buildCampoTitulo(context),
              const SizedBox(height: 24),
              _buildLabel(context, 'Descripción'),
              const SizedBox(height: 8),
              _buildCampoDescripcion(context),
              const SizedBox(height: 24),
              _buildLabel(context, 'Foto'),
              const SizedBox(height: 8),
              _buildSelectorImagen(context),
              const SizedBox(height: 32),
              _buildBotonGuardar(context),
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

  Widget _buildCampoTitulo(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TextFormField(
      controller: _tituloController,
      decoration: InputDecoration(
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      maxLength: 80,
      validator: (valor) {
        if (valor == null || valor.trim().isEmpty) {
          return 'El título no puede estar vacío';
        }
        if (valor.trim().length < 10) {
          return 'El título debe tener al menos 10 caracteres';
        }
        if (!tieneSentido(valor)) {
          return 'Escribí un título que describa el problema';
        }
        if (contieneLenguajeInapropiado(valor)) {
          return 'El título contiene lenguaje inapropiado';
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
        if (!tieneSentido(valor)) {
          return 'Describí el problema con palabras reales';
        }
        if (contieneLenguajeInapropiado(valor)) {
          return 'La descripción contiene lenguaje inapropiado';
        }
        return null;
      },
    );
  }

  Widget _buildSelectorImagen(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final mostrarNueva = _nuevaImagen != null;
    final mostrarActual = !mostrarNueva && _tieneImagenActual;

    return GestureDetector(
      onTap: _mostrarOpcionesImagen,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: (mostrarNueva || mostrarActual) ? 200 : 100,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: (mostrarNueva || mostrarActual)
                ? cs.primary
                : cs.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(10),
          color: cs.surfaceContainerLowest,
        ),
        child: mostrarNueva
            ? _buildPreviewConBoton(
                child: Image.file(_nuevaImagen!, fit: BoxFit.cover),
                onQuitar: () => setState(() => _nuevaImagen = null),
              )
            : mostrarActual
                ? _buildPreviewConBoton(
                    child: Image.network(
                      widget.reporte.imagenUrl!,
                      fit: BoxFit.cover,
                    ),
                    onQuitar: () =>
                        setState(() => _imagenEliminada = true),
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

  Widget _buildPreviewConBoton({
    required Widget child,
    required VoidCallback onQuitar,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: child,
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onQuitar,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.85),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 18, color: cs.onSurface),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBotonGuardar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _guardando ? null : _guardarCambios,
        style: FilledButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _guardando
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: cs.onPrimary,
                ),
              )
            : const Text(
                'Guardar cambios',
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
      _nuevaImagen = File(archivo.path);
      _imagenEliminada = false;
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
              leading: Icon(Icons.photo_library_outlined, color: cs.primary),
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

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      await ReporteService().actualizarReporte(
        reporte: widget.reporte,
        nuevoTitulo: _tituloController.text.trim(),
        nuevaDescripcion: _descripcionController.text.trim(),
        nuevaImagen: _nuevaImagen,
        eliminarImagenActual: _imagenEliminada && _nuevaImagen == null,
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reporte actualizado correctamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar. Intentá de nuevo')),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }
}