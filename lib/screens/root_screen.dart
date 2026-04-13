// lib/screens/root_screen.dart

import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'mapa/mapa_screen.dart';
import 'perfil/perfil_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen>
    with SingleTickerProviderStateMixin {
  int _indiceActual = 0;
  int _indiceAnterior = 0;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _cambiarPantalla(int nuevoIndice) {
    if (nuevoIndice == _indiceActual) return;
    setState(() {
      _indiceAnterior = _indiceActual;
      _indiceActual = nuevoIndice;
    });
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    // Pasamos _cambiarPantalla a PerfilScreen para que pueda
    // cambiar la pestaña activa después del login
    final pantallas = [
      const HomeScreen(),
      const MapaScreen(),
      PerfilScreen(onLoginExitoso: () => _cambiarPantalla(0)),
    ];

    return Scaffold(
      body: Stack(
        children: [
          pantallas[_indiceAnterior],
          FadeTransition(
            opacity: _animation,
            child: pantallas[_indiceActual],
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceActual,
        onDestinationSelected: _cambiarPantalla,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_outlined),
            selectedIcon: Icon(Icons.list),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
