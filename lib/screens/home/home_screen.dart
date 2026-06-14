// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/reporte_service.dart';
import '../../models/reports.dart';
import '../../widgets/reporte_card.dart';
import '../detalle/detalle_screen.dart';
import '../nuevoReporte/nuevo_reporte_screen.dart';
import '../auth/login_screen.dart';
import '../../utils/reporte_helpers.dart';

enum FiltroFecha {
  todas,
  hoy,
  ayer,
  ultimaSemana,
  ultimoMes,
  ultimos3Meses,
}

extension FiltroFechaLabel on FiltroFecha {
  String get label {
    switch (this) {
      case FiltroFecha.todas:
        return 'Todas';
      case FiltroFecha.hoy:
        return 'Hoy';
      case FiltroFecha.ayer:
        return 'Ayer';
      case FiltroFecha.ultimaSemana:
        return 'Última semana';
      case FiltroFecha.ultimoMes:
        return 'Último mes';
      case FiltroFecha.ultimos3Meses:
        return 'Últimos 3 meses';
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CategoriaReporte? _categoriaFiltro;
  EstadoReporte? _estadoFiltro;
  FiltroFecha _fechaFiltro = FiltroFecha.todas;

  List<Reporte> _aplicarFiltros(List<Reporte> reportes) {
    return reportes.where((r) {
      if (_categoriaFiltro != null && r.categoria != _categoriaFiltro) {
        return false;
      }
      if (_estadoFiltro != null && r.estado != _estadoFiltro) {
        return false;
      }
      if (_fechaFiltro != FiltroFecha.todas) {
        final ahora = DateTime.now();
        final hoy = DateTime(ahora.year, ahora.month, ahora.day);
        final ayer = hoy.subtract(const Duration(days: 1));

        switch (_fechaFiltro) {
          case FiltroFecha.hoy:
            if (r.fecha.isBefore(hoy)) return false;
          case FiltroFecha.ayer:
            if (r.fecha.isBefore(ayer) || r.fecha.isAfter(hoy)) return false;
          case FiltroFecha.ultimaSemana:
            if (r.fecha.isBefore(hoy.subtract(const Duration(days: 7)))) {
              return false;
            }
          case FiltroFecha.ultimoMes:
            if (r.fecha.isBefore(hoy.subtract(const Duration(days: 30)))) {
              return false;
            }
          case FiltroFecha.ultimos3Meses:
            if (r.fecha.isBefore(hoy.subtract(const Duration(days: 90)))) {
              return false;
            }
          case FiltroFecha.todas:
            break;
        }
      }
      return true;
    }).toList();
  }

  int get _cantidadFiltrosActivos {
    int count = 0;
    if (_categoriaFiltro != null) count++;
    if (_estadoFiltro != null) count++;
    if (_fechaFiltro != FiltroFecha.todas) count++;
    return count;
  }

  bool get _hayFiltrosActivos => _cantidadFiltrosActivos > 0;

  void _limpiarFiltros() {
    setState(() {
      _categoriaFiltro = null;
      _estadoFiltro = null;
      _fechaFiltro = FiltroFecha.todas;
    });
  }

  void _mostrarFiltros() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _FiltrosSheet(
        categoriaFiltro: _categoriaFiltro,
        estadoFiltro: _estadoFiltro,
        fechaFiltro: _fechaFiltro,
        onCategoriaChanged: (cat) => setState(() => _categoriaFiltro = cat),
        onEstadoChanged: (est) => setState(() => _estadoFiltro = est),
        onFechaChanged: (fec) => setState(() => _fechaFiltro = fec),
        onLimpiar: _limpiarFiltros,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ZonaData',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: Column(
        children: [
          _buildBarraFiltros(cs),
          Expanded(
            child: StreamBuilder<List<Reporte>>(
              stream: ReporteService().obtenerReportes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: cs.primary),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child:
                        Text('Error al cargar reportes: ${snapshot.error}'),
                  );
                }

                final todos = snapshot.data ?? [];
                final reportes = _aplicarFiltros(todos);

                if (todos.isEmpty) {
                  return _buildEstadoVacio(
                    icono: Icons.inbox_outlined,
                    titulo: 'No hay reportes todavía',
                    subtitulo: 'Sé el primero en reportar un problema',
                  );
                }

                if (reportes.isEmpty) {
                  return _buildEstadoVacio(
                    icono: Icons.filter_list_off,
                    titulo: 'Sin resultados',
                    subtitulo:
                        'No hay reportes que coincidan con los filtros aplicados',
                    accion: TextButton(
                      onPressed: _limpiarFiltros,
                      child: const Text('Limpiar filtros'),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: reportes.length,
                  itemBuilder: (context, index) {
                    final reporte = reportes[index];
                    return ReporteCard(
                      reporte: reporte,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetalleScreen(reporte: reporte),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final usuario = FirebaseAuth.instance.currentUser;
          if (usuario == null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NuevoReporteScreen(),
            ),
          );
        },
        tooltip: 'Nuevo reporte',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBarraFiltros(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: cs.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Botón principal de filtros
          GestureDetector(
            onTap: _mostrarFiltros,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _hayFiltrosActivos
                    ? cs.primaryContainer
                    : cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _hayFiltrosActivos
                      ? cs.primary.withValues(alpha: 0.4)
                      : cs.outlineVariant,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune,
                    size: 16,
                    color: _hayFiltrosActivos
                        ? cs.onPrimaryContainer
                        : cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Filtrar',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: _hayFiltrosActivos
                          ? FontWeight.w500
                          : FontWeight.normal,
                      color: _hayFiltrosActivos
                          ? cs.onPrimaryContainer
                          : cs.onSurfaceVariant,
                    ),
                  ),
                  if (_hayFiltrosActivos) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$_cantidadFiltrosActivos',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cs.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Botón limpiar, solo visible cuando hay filtros activos
          if (_hayFiltrosActivos) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _limpiarFiltros,
              child: Text(
                'Limpiar',
                style: TextStyle(
                  fontSize: 13,
                  color: cs.onSurfaceVariant,
                  decoration: TextDecoration.underline,
                  decorationColor: cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEstadoVacio({
    required IconData icono,
    required String titulo,
    required String subtitulo,
    Widget? accion,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            titulo,
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Text(
            subtitulo,
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
          if (accion != null) ...[
            const SizedBox(height: 12),
            accion,
          ],
        ],
      ),
    );
  }
}

// =========================================================================
// BOTTOM SHEET DE FILTROS — widget separado para mantener el estado local
// =========================================================================
class _FiltrosSheet extends StatefulWidget {
  final CategoriaReporte? categoriaFiltro;
  final EstadoReporte? estadoFiltro;
  final FiltroFecha fechaFiltro;
  final ValueChanged<CategoriaReporte?> onCategoriaChanged;
  final ValueChanged<EstadoReporte?> onEstadoChanged;
  final ValueChanged<FiltroFecha> onFechaChanged;
  final VoidCallback onLimpiar;

  const _FiltrosSheet({
    required this.categoriaFiltro,
    required this.estadoFiltro,
    required this.fechaFiltro,
    required this.onCategoriaChanged,
    required this.onEstadoChanged,
    required this.onFechaChanged,
    required this.onLimpiar,
  });

  @override
  State<_FiltrosSheet> createState() => _FiltrosSheetState();
}

class _FiltrosSheetState extends State<_FiltrosSheet> {
  late CategoriaReporte? _categoria;
  late EstadoReporte? _estado;
  late FiltroFecha _fecha;

  @override
  void initState() {
    super.initState();
    _categoria = widget.categoriaFiltro;
    _estado = widget.estadoFiltro;
    _fecha = widget.fechaFiltro;
  }

  void _aplicar() {
    widget.onCategoriaChanged(_categoria);
    widget.onEstadoChanged(_estado);
    widget.onFechaChanged(_fecha);
    Navigator.pop(context);
  }

  void _limpiar() {
    setState(() {
      _categoria = null;
      _estado = null;
      _fecha = FiltroFecha.todas;
    });
    widget.onLimpiar();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtrar reportes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: _limpiar,
                  child: Text(
                    'Limpiar todo',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Sección Categoría
            _buildSeccionLabel(cs, 'Categoría'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip(
                  cs: cs,
                  label: 'Todas',
                  seleccionado: _categoria == null,
                  onTap: () => setState(() => _categoria = null),
                ),
                ...CategoriaReporte.values.map((cat) {
                  final seleccionado = _categoria == cat;
                  return _buildChip(
                    cs: cs,
                    label: labelCategoria(cat),
                    seleccionado: seleccionado,
                    colorFondo: seleccionado ? colorCategoria(cat) : null,
                    colorTexto:
                        seleccionado ? colorTextoCategoria(cat) : null,
                    onTap: () => setState(
                      () => _categoria = seleccionado ? null : cat,
                    ),
                  );
                }),
              ],
            ),

            const SizedBox(height: 20),

            // Sección Estado
            _buildSeccionLabel(cs, 'Estado'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip(
                  cs: cs,
                  label: 'Todos',
                  seleccionado: _estado == null,
                  onTap: () => setState(() => _estado = null),
                ),
                ...EstadoReporte.values.map((est) {
                  final seleccionado = _estado == est;
                  return _buildChip(
                    cs: cs,
                    label: labelEstado(est),
                    seleccionado: seleccionado,
                    colorFondo: seleccionado ? colorEstado(est) : null,
                    colorTexto: seleccionado ? colorTextoEstado(est) : null,
                    onTap: () => setState(
                      () => _estado = seleccionado ? null : est,
                    ),
                  );
                }),
              ],
            ),

            const SizedBox(height: 20),

            // Sección Fecha
            _buildSeccionLabel(cs, 'Fecha'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: FiltroFecha.values.map((fec) {
                final seleccionado = _fecha == fec;
                return _buildChip(
                  cs: cs,
                  label: fec.label,
                  seleccionado: seleccionado,
                  onTap: () => setState(() => _fecha = fec),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Botón aplicar
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _aplicar,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Aplicar filtros',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionLabel(ColorScheme cs, String texto) {
    return Text(
      texto,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: cs.onSurfaceVariant,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildChip({
    required ColorScheme cs,
    required String label,
    required bool seleccionado,
    required VoidCallback onTap,
    Color? colorFondo,
    Color? colorTexto,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: seleccionado
              ? (colorFondo ?? cs.primaryContainer)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: seleccionado
                ? (colorTexto ?? cs.primary).withValues(alpha: 0.4)
                : cs.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: seleccionado ? FontWeight.w500 : FontWeight.normal,
            color: seleccionado
                ? (colorTexto ?? cs.onPrimaryContainer)
                : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

