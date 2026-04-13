// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/reporte_service.dart';
import '../../models/reports.dart';
import '../../widgets/reporte_card.dart';
import '../detalle/detalle_screen.dart';
import '../nuevoReporte/nuevo_reporte_screen.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: StreamBuilder<List<Reporte>>(
        // StreamBuilder escucha cambios en Firestore en tiempo real
        stream: ReporteService().obtenerReportes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1D9E75),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar reportes: ${snapshot.error}'),
            );
          }

          final reportes = snapshot.data ?? [];

          if (reportes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay reportes todavía',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sé el primero en reportar un problema',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Si no hay sesión iniciada redirigimos al login
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
}




