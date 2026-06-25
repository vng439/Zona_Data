import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/reports.dart';
import '../../services/reporte_service.dart';
import '../../utils/reporte_helpers.dart';
import '../detalle/detalle_screen.dart';
import 'editar_reportes_screen.dart';

class MisReportesScreen extends StatelessWidget {
  const MisReportesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis reportes',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: usuario == null
          ? const Center(child: Text('Necesitás iniciar sesión'))
          : StreamBuilder<List<Reporte>>(
              stream:
                  ReporteService().obtenerReportesDeUsuario(usuario.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: cs.primary),
                  );
                }

                final reportes = snapshot.data ?? [];

                if (reportes.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'Todavía no creaste ningún reporte',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: reportes.length,
                  itemBuilder: (context, index) {
                    return _MiReporteCard(reporte: reportes[index]);
                  },
                );
              },
            ),
    );
  }
}

class _MiReporteCard extends StatefulWidget {
  final Reporte reporte;

  const _MiReporteCard({required this.reporte});

  @override
  State<_MiReporteCard> createState() => _MiReporteCardState();
}

class _MiReporteCardState extends State<_MiReporteCard> {
  bool _eliminando = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final reporte = widget.reporte;
    final puedeEditar = ReporteService().puedeEditarse(reporte);
    final puedeEliminar = ReporteService().puedeEliminarse(reporte);

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
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: true,
              pageBuilder: (context, animation, secondaryAnimation) =>
                  DetalleScreen(reporte: reporte),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorCategoria(reporte.categoria),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      labelCategoria(reporte.categoria),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: colorTextoCategoria(reporte.categoria),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorEstado(reporte.estado),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      labelEstado(reporte.estado),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: colorTextoEstado(reporte.estado),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                reporte.titulo,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                reporte.descripcion,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (reporte.apoyos > 0) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.people_outline,
                        size: 13, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '${reporte.apoyos} ${reporte.apoyos == 1 ? 'apoyo' : 'apoyos'}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              if (!puedeEditar)
                Text(
                  'Este reporte tiene apoyos de otros vecinos y no puede modificarse.',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                Row(
                  children: [
                    if (puedeEliminar)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _eliminando ? null : _confirmarEliminar,
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text('Eliminar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: cs.error,
                            side: BorderSide(color: cs.error.withValues(alpha: 0.4)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            textStyle: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    if (puedeEliminar) const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditarReporteScreen(reporte: reporte),
                          ),
                        );
                      },
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Editar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.primary,
                          side: BorderSide(color: cs.primary.withValues(alpha: 0.4)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              if (puedeEditar && !puedeEliminar)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Ya pasaron 48hs desde su creación, no se puede eliminar.',
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmarEliminar() async {
    final cs = Theme.of(context).colorScheme;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar reporte'),
        content: const Text(
          'Esta acción no se puede deshacer. ¿Querés eliminar este reporte definitivamente?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: cs.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    setState(() => _eliminando = true);
    await ReporteService().eliminarReporte(widget.reporte);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reporte eliminado')),
    );
  }
}