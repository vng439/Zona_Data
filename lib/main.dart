// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/root_screen.dart';
// import 'screens/auth/login_screen.dart';

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
  useMaterial3: true,
  colorScheme: ColorScheme(
    brightness: Brightness.light,


    // Azul profundo — Santa Cruz
    primary: Color(0xFF2D2A77),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE8E7F5),
    onPrimaryContainer: Color(0xFF1A1850),


    // Azul cielo — Caleta Olivia
    secondary: Color(0xFF75C5F0),
    onSecondary: Color(0xFF1A1A1A),
    secondaryContainer: Color(0xFFE3F4FD),
    onSecondaryContainer: Color(0xFF0D4F6B),


    // Amarillo — exclusivo para FAB
    tertiary: Color(0xFFFFD700),
    onTertiary: Color(0xFF1A1A1A),
    tertiaryContainer: Color(0xFFFFF8CC),
    onTertiaryContainer: Color(0xFF5A4800),


    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1A1A1A),
    surfaceContainerHighest: Color(0xFFF3F3F3),
    onSurfaceVariant: Color(0xFF555555),


    outline: Color(0xFFCCCCCC),
    outlineVariant: Color(0xFFE5E5E5),


    error: Color(0xFFB00020),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),


    scrim: Color(0xFF000000),
    shadow: Color(0xFF000000),


    inversePrimary: Color(0xFFBBB8FF),
    inverseSurface: Color(0xFF2C2C2C),
    onInverseSurface: Color(0xFFF5F5F5),
  ),


  // AppBar usa primary
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF2D2A77),
    foregroundColor: Color(0xFFFFFFFF),
    elevation: 0,
    scrolledUnderElevation: 0.5,
    titleTextStyle: TextStyle(
      fontFamily: 'Arial',
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Color(0xFFFFFFFF),
    ),
  ),


  // Botones principales usan primary
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: Color(0xFF2D2A77),
      foregroundColor: Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    ),
  ),


  // FAB exclusivo en amarillo
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFFFD700),
    foregroundColor: Color(0xFF1A1A1A),
    elevation: 2,
    shape: CircleBorder(),
  ),
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

