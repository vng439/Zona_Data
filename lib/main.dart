// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/root_screen.dart';
//import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ZonaDataApp());
}

class ZonaDataApp extends StatelessWidget {
  const ZonaDataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZonaData',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1D9E75),
        ),
        useMaterial3: true,
      ),
      // StreamBuilder escucha cambios en el estado de autenticación
      // y redirige automáticamente según corresponda
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Mientras Firebase verifica el estado mostramos un loader
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF1D9E75),
                ),
              ),
            );
          }
          // Si hay usuario autenticado vamos al feed
          // Si no, mostramos el login
          // Como definimos Opción A, RootScreen maneja
          // la lectura pública sin necesidad de cuenta
          return const RootScreen();
        },
      ),
    );
  }
}

