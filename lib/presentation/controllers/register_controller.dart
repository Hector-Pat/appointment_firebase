import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para registrar usuario y guardar en Firestore
  Future<String?> registerUser({
    required String email,
    required String password,
    required String nombre,
  }) async {
    try {
      // Crear el usuario en Firebase Auth
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Guardar los datos en Firestore
      await _firestore.collection('usuarios').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'nombre': nombre,
        'email': email,
        'creadoEn': FieldValue.serverTimestamp(),
      });

      return null; // Éxito
    } on FirebaseAuthException catch (e) {
      // Manejo de errores comunes
      if (e.code == 'email-already-in-use') {
        return 'Este correo ya está registrado.';
      } else if (e.code == 'weak-password') {
        return 'La contraseña es demasiado débil.';
      } else {
        return 'Error: ${e.message}';
      }
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }
}
