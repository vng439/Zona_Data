// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'registro_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginExitoso;

  const LoginScreen({super.key, this.onLoginExitoso});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _cargando = false;
  bool _verPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                _buildEncabezado(),
                const SizedBox(height: 40),
                _buildCampoEmail(),
                const SizedBox(height: 16),
                _buildCampoPassword(),
                const SizedBox(height: 32),
                _buildBotonLogin(),
                const SizedBox(height: 16),
                _buildLinkRegistro(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEncabezado() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF1D9E75),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.location_on,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'ZonaData',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Iniciá sesión para publicar reportes',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCampoEmail() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: _inputDecoration('Email', Icons.email_outlined),
      validator: (valor) {
        if (valor == null || valor.trim().isEmpty) {
          return 'Ingresá tu email';
        }
        if (!valor.contains('@')) {
          return 'Ingresá un email válido';
        }
        return null;
      },
    );
  }

  Widget _buildCampoPassword() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_verPassword,
      decoration: _inputDecoration(
        'Contraseña',
        Icons.lock_outlined,
      ).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _verPassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey[500],
            size: 20,
          ),
          onPressed: () => setState(() => _verPassword = !_verPassword),
        ),
      ),
      validator: (valor) {
        if (valor == null || valor.isEmpty) {
          return 'Ingresá tu contraseña';
        }
        return null;
      },
    );
  }

  Widget _buildBotonLogin() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _cargando ? null : _iniciarSesion,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF1D9E75),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _cargando
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Iniciar sesión',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
      ),
    );
  }

  Widget _buildLinkRegistro() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿No tenés cuenta? ',
          style: TextStyle(color: Colors.grey[600]),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RegistroScreen(),
              ),
            );
          },
          child: const Text(
            'Registrate',
            style: TextStyle(
              color: Color(0xFF1D9E75),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icono) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icono, size: 20, color: Colors.grey[500]),
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
    );
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // mounted verifica que el widget sigue activo
      if (!mounted) return;

      // Mostramos el dialog de éxito
      _mostrarDialogoExito();

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_mensajeError(e.code))),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _mostrarDialogoExito() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => _DialogExito(
      onTerminado: () {
        Navigator.of(context).pop();
        widget.onLoginExitoso?.call();
      },
    ),
  );
}


  String _mensajeError(String codigo) {
    switch (codigo) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email o contraseña incorrectos';
      case 'invalid-email':
        return 'El email no es válido';
      case 'too-many-requests':
        return 'Demasiados intentos. Intentá más tarde';
      default:
        return 'Ocurrió un error. Intentá de nuevo';
    }
  }

}

// Widget separado para el dialog — maneja su propio timer
// sin necesidad de acceder a context externo
class _DialogExito extends StatefulWidget {
  final VoidCallback onTerminado;

  const _DialogExito({required this.onTerminado});

  @override
  State<_DialogExito> createState() => _DialogExitoState();
}

class _DialogExitoState extends State<_DialogExito> {
  @override
  void initState() {
    super.initState();
    // El timer vive dentro del widget, usa su propio context
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pop(); // cierra el dialog
      widget.onTerminado();        // cierra el login y va al Feed
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFE1F5EE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Color(0xFF1D9E75),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Sesión iniciada!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bienvenido a ZonaData',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


