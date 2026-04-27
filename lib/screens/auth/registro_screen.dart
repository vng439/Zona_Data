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
    final cs = Theme.of(context).colorScheme;

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
                Text(
                  'Crear cuenta',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tu nombre aparecerá en los reportes que publiques',
                  style: TextStyle(
                    fontSize: 15,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                _buildCampoNombre(context),
                const SizedBox(height: 16),
                _buildCampoEmail(context),
                const SizedBox(height: 16),
                _buildCampoPassword(context),
                const SizedBox(height: 32),
                _buildBotonRegistro(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCampoNombre(BuildContext context) {
    return TextFormField(
      controller: _nombreController,
      textCapitalization: TextCapitalization.words,
      decoration: _inputDecoration(context, 'Nombre o apodo', Icons.person_outline),
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

  Widget _buildCampoEmail(BuildContext context) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: _inputDecoration(context, 'Email', Icons.email_outlined),
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

  Widget _buildCampoPassword(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TextFormField(
      controller: _passwordController,
      obscureText: !_verPassword,
      decoration: _inputDecoration(
        context,
        'Contraseña',
        Icons.lock_outlined,
      ).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _verPassword ? Icons.visibility_off : Icons.visibility,
            color: cs.onSurfaceVariant,
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

  Widget _buildBotonRegistro(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _cargando ? null : _registrar,
        style: FilledButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _cargando
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: cs.onPrimary,
                ),
              )
            : const Text(
                'Crear cuenta',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label, IconData icono) {
    final cs = Theme.of(context).colorScheme;

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icono, size: 20, color: cs.onSurfaceVariant),
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

      await credencial.user?.updateDisplayName(
        _nombreController.text.trim(),
      );

      if (!mounted) return;
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
