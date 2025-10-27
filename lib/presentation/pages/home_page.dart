import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appointment_firebase/presentation/pages/messages_page.dart';
import 'package:appointment_firebase/presentation/pages/settings_page.dart';
import 'package:appointment_firebase/presentation/pages/appointments_page.dart';
import 'package:appointment_firebase/presentation/pages/doctor_profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Lista de páginas para la barra inferior
  final List<Widget> _pages = const [
    _HomeContent(),
    MessagesPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Mensajes'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configuración'),
        ],
      ),
    );
  }
}

/// Contenido de la pestaña "Inicio".
/// Obtiene el nombre real del usuario desde Firestore (colección 'usuarios') y lo muestra en el saludo.
class _HomeContent extends StatelessWidget {
  const _HomeContent();

  // Consulta Firestore para obtener el nombre del usuario actual.
  Future<String> _getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Usuario';

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
      if (!snapshot.exists) return user.displayName ?? 'Usuario';
      final data = snapshot.data();
      return (data != null && data['nombre'] != null && data['nombre'].toString().isNotEmpty)
          ? data['nombre'].toString()
          : (user.displayName ?? 'Usuario');
    } catch (_) {
      // En caso de error, usar displayName o parte del email como fallback
      return FirebaseAuth.instance.currentUser?.displayName ??
          FirebaseAuth.instance.currentUser?.email?.split('@').first ??
          'Usuario';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Firebase'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<String>(
          future: _getUserName(),
          builder: (context, snapshot) {
            final nombre = snapshot.data ?? 'Usuario';

            return ListView(
              children: [
                Text(
                  '¡Hola, $nombre! ¿En qué podemos ayudarte?',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // --- Opciones principales ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _HomeOption(
                      icon: Icons.calendar_today,
                      label: 'Agendar Cita',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AppointmentsPage()),
                        );
                      },
                    ),
                    _HomeOption(
                      icon: Icons.healing,
                      label: 'Consejos Médicos',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sección de consejos médicos (pendiente)'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                const Text(
                  'Especialistas disponibles:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                const _SpecialistList(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HomeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HomeOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.teal.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.teal.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.teal, size: 36),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _SpecialistList extends StatelessWidget {
  const _SpecialistList();

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('doctores').where('activo', isEqualTo: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No hay doctores disponibles.'));
        }

        final docs = snapshot.data!.docs;

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final nombre = data['nombre'] ?? 'Sin nombre';
            final especialidad = data['especialidad'] ?? 'General';
            final telefono = data['telefono'] ?? 'No disponible';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.medical_information, color: Colors.teal),
                title: Text(nombre),
                subtitle: Text(especialidad),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorProfilePage(doctorId: doc.id),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}


