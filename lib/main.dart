import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:appointment_firebase/firebase_options.dart';
import 'package:appointment_firebase/routes/app_routes.dart';
import 'package:appointment_firebase/presentation/pages/login_page.dart';
import 'package:appointment_firebase/presentation/pages/home_page.dart';

// import 'package:appointment_firebase/utils/add_doctors.dart'; // solo se activa al agregar doctores

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await addInitialDoctors(); // esto ejecuta la función para agregar doctores iniciales

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Doctor Appointment',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),

      // Rutas
      routes: appRoutes,

      // Localizaciones necesarias para widgets Material (DatePicker, etc.)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'), // español
        Locale('en', 'US'), // inglés (opcional)
      ],

      home: const AuthWrapper(), // Controla si va al login o al home
    );
  }
}

/// Widget que redirige según el estado de sesión
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Si Firebase aún está verificando la sesión
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Si el usuario está autenticado
        if (snapshot.hasData) {
          return const HomePage();
        }

        // Si no hay sesión
        return const LoginPage();
      },
    );
  }
}
