import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appointment_firebase/presentation/pages/profile_page.dart';
import 'package:appointment_firebase/presentation/pages/info_page.dart';
import 'package:appointment_firebase/presentation/pages/login_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<Map<String, dynamic>?> _getUserData() async {
    // Obtiene el documento del usuario desde Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();

    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserData(), // Carga los datos del usuario
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Muestra un indicador mientras se cargan los datos
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data;
          final nombre = userData?['nombre'] ?? 'Usuario';

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              if (user != null)
                UserAccountsDrawerHeader(
                  // Ahora muestra el nombre desde Firestore
                  accountName: Text(nombre),
                  accountEmail: Text(user.email ?? ''),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.teal),
                  ),
                  decoration: const BoxDecoration(color: Colors.teal),
                ),

              // Perfil
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Perfil'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                },
              ),

              // Privacidad
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Privacidad'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InfoPage(title: 'Privacidad'),
                    ),
                  );
                },
              ),

              // Sobre nosotros
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Sobre nosotros'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InfoPage(title: 'Sobre nosotros'),
                    ),
                  );
                },
              ),

              const Divider(),

              // Cerrar sesión
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Cerrar sesión',
                    style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
