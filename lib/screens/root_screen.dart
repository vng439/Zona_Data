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



/* import 'package:flutter/material.dart';
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.view_list, 'Feed'),
              _buildNavItem(1, Icons.explore, 'Mapa'),
              _buildNavItem(2, Icons.account_circle, 'Perfil'),
            ],
          ),
        ),
      ), );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
  final isSelected = _indiceActual == index;
  return GestureDetector(
    onTap: () => _cambiarPantalla(index),
    behavior: HitTestBehavior.opaque,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.grey,
            size: 26,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blue : Colors.grey,
          ),
        ),
      ],
    ),
  );
}
}


 */