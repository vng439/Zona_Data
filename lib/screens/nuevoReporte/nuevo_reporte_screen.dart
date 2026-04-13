// lib/screens/nuevo_reporte/nuevo_reporte_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/reporte_service.dart';
import 'package:flutter/material.dart';
import '../../models/reports.dart';
import '../../utils/reporte_helpers.dart';
import '../../services/ubicacion_service.dart';

class NuevoReporteScreen extends StatefulWidget {
  const NuevoReporteScreen({super.key});

  @override
  State<NuevoReporteScreen> createState() => _NuevoReporteScreenState();
}

class _NuevoReporteScreenState extends State<NuevoReporteScreen> {
  // _formKey identifica al formulario y permite validarlo
  final _formKey = GlobalKey<FormState>();

  // Controllers capturan el texto que escribe el usuario
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();

  // Categoría seleccionada — empieza en null (sin seleccionar)
  CategoriaReporte? _categoriaSeleccionada;

  // Indica si el formulario se está "enviando" para mostrar un loader
  bool _enviando = false;

  double? _latitud;
  double? _longitud;
  bool _obteniendoUbicacion = false;

  @override
  void dispose() {
    // Liberar los controllers cuando se cierra la pantalla
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
              _buildLabel('Categoría'),
              const SizedBox(height: 8),
              _buildSelectorCategoria(),
              const SizedBox(height: 24),
              _buildLabel('Título'),
              const SizedBox(height: 8),
              _buildCampoTitulo(),
              const SizedBox(height: 24),
              _buildLabel('Descripción'),
              const SizedBox(height: 8),
              _buildCampoDescripcion(),
              const SizedBox(height: 24),
              _buildLabel('Ubicación'),
              const SizedBox(height: 8),
              _buildSelectorUbicacion(),
              const SizedBox(height: 32),
              _buildBotonEnviar(),
            ],
          ),
        ),
      ),
    );
  }

  // Etiqueta de sección reutilizable
  Widget _buildLabel(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // Grilla de chips para seleccionar categoría
  Widget _buildSelectorCategoria() {
    return Wrap(
      // Wrap acomoda los chips en múltiples filas si no entran en una sola
      spacing: 8,
      runSpacing: 8,
      children: CategoriaReporte.values.map((categoria) {
        final seleccionada = _categoriaSeleccionada == categoria;
        return GestureDetector(
          onTap: () {
            setState(() {
              _categoriaSeleccionada = categoria;
            });
          },
          child: AnimatedContainer(
            // AnimatedContainer hace la transición de colores suavemente
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
                    : Colors.grey.withValues(alpha: 0.3),
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
                    : Colors.grey[600],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCampoTitulo() {
    return TextFormField(
      controller: _tituloController,
      decoration: InputDecoration(
        hintText: 'Ej: Bache en Av. San Martín',
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1D9E75)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      maxLength: 80, // límite de caracteres para el título
      validator: (valor) {
        // validator se ejecuta cuando se intenta enviar el formulario
        if (valor == null || valor.trim().isEmpty) {
          return 'El título no puede estar vacío';
        }
        if (valor.trim().length < 10) {
          return 'El título debe tener al menos 10 caracteres';
        }
        return null; // null significa que es válido
      },
    );
  }

  Widget _buildCampoDescripcion() {
    return TextFormField(
      controller: _descripcionController,
      decoration: InputDecoration(
        hintText: 'Describí el problema con el mayor detalle posible...',
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1D9E75)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      maxLines: 5,    // campo de texto alto para descripción
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

  Widget _buildBotonEnviar() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _enviando ? null : _enviarFormulario,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF1D9E75),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _enviando
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Publicar reporte',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
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
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No se pudo obtener la ubicación'),
      ),
    );
  }

  setState(() => _obteniendoUbicacion = false);
}

  Widget _buildSelectorUbicacion() {
  return GestureDetector(
    onTap: _obteniendoUbicacion ? null : _obtenerUbicacion,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color: _latitud != null
              ? const Color(0xFF1D9E75)
              : Colors.grey.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            _latitud != null
                ? Icons.location_on
                : Icons.location_on_outlined,
            color: _latitud != null
                ? const Color(0xFF1D9E75)
                : Colors.grey[500],
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _obteniendoUbicacion
                ? const Text('Obteniendo ubicación...')
                : Text(
                    _latitud != null
                        ? 'Ubicación obtenida correctamente'
                        : 'Tocar para obtener ubicación actual',
                    style: TextStyle(
                      color: _latitud != null
                          ? const Color(0xFF1D9E75)
                          : Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
          ),
          if (_obteniendoUbicacion)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF1D9E75),
              ),
            ),
        ],
      ),
    ),
  );
}

  Future<void> _enviarFormulario() async {
  if (_categoriaSeleccionada == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Seleccioná una categoría')),
    );
    return;
  }

  if (!_formKey.currentState!.validate()) return;

  // Verificamos que haya un usuario autenticado
  final usuario = FirebaseAuth.instance.currentUser;
  if (usuario == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Necesitás iniciar sesión para publicar')),
    );
    return;
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

    await ReporteService().crearReporte(reporte);

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
      const SnackBar(content: Text('Error al publicar. Intentá de nuevo')),
    );
  } finally {
    if (mounted) setState(() => _enviando = false);
  }
}
}



