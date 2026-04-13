  // lib/screens/auth/registro_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _cargando = false;
  bool _verPassword = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Crear cuenta',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tu nombre aparecerá en los reportes que publiques',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                _buildCampoNombre(),
                const SizedBox(height: 16),
                _buildCampoEmail(),
                const SizedBox(height: 16),
                _buildCampoPassword(),
                const SizedBox(height: 32),
                _buildBotonRegistro(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCampoNombre() {
    return TextFormField(
      controller: _nombreController,
      textCapitalization: TextCapitalization.words,
      decoration: _inputDecoration('Nombre o apodo', Icons.person_outline),
      validator: (valor) {
        if (valor == null || valor.trim().isEmpty) {
          return 'Ingresá tu nombre o apodo';
        }
        if (valor.trim().length < 3) {
          return 'Debe tener al menos 3 caracteres';
        }
        return null;
      },
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
          return 'Ingresá una contraseña';
        }
        if (valor.length < 6) {
          return 'La contraseña debe tener al menos 6 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildBotonRegistro() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _cargando ? null : _registrar,
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
                'Crear cuenta',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
      ),
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

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      final credencial =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Guardamos el nombre en el perfil de Firebase Auth
      await credencial.user?.updateDisplayName(
        _nombreController.text.trim(),
      );

      if (!mounted) return;
      // Volvemos al login — el StreamBuilder detecta el login y redirige
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_mensajeError(e.code))),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  String _mensajeError(String codigo) {
    switch (codigo) {
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese email';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'invalid-email':
        return 'El email no es válido';
      default:
        return 'Ocurrió un error. Intentá de nuevo';
    }
  }
}


