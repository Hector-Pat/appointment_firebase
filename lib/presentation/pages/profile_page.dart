import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool _loading = false;

  // Carga inicial de datos del usuario desde Firestore
  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('usuarios').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      _nombreCtrl.text = data['nombre'] ?? '';
      _emailCtrl.text = data['email'] ?? user.email ?? '';
    }
  }

  // Actualiza los datos del perfil
  Future<void> _updateProfile() async {
    setState(() => _loading = true);
    final user = _auth.currentUser;

    try {
      await _firestore.collection('usuarios').doc(user!.uid).update({
        'nombre': _nombreCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente.')),
        );
      }
    } catch (e) { // Manejo de errores a través de la variable "e" en el catch
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil de usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Correo electrónico'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _loading ? null : _updateProfile,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
