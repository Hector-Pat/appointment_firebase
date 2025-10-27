import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appointment_firebase/presentation/pages/home_page.dart';

class LoginController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // --- Validación de email ---
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa tu correo.';
    }
    if (!value.contains('@')) {
      return 'Ingresa un correo válido.';
    }
    return null;
  }

  // --- Validación de contraseña ---
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa tu contraseña.';
    }
    if (value.length < 6) {
      return 'Debe tener al menos 6 caracteres.';
    }
    return null;
  }

  // --- Inicio de sesión con Firebase Auth ---
  Future<bool> login(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Si se autentica correctamente, redirige al Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error de FirebaseAuth: ${e.code}');
      return false;
    } catch (e) {
      debugPrint('Error inesperado: $e');
      return false;
    }
  }
}
