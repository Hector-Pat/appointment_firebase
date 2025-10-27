import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Test',
      debugShowCheckedModeBanner: false,
      home: const FirebaseCheckPage(),
    );
  }
}

class FirebaseCheckPage extends StatelessWidget {
  const FirebaseCheckPage({super.key});

  Future<void> _checkFirebaseConnection(BuildContext context) async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(' Firebase inicializado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al inicializar Firebase: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prueba de Firebase')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _checkFirebaseConnection(context),
          child: const Text('Probar conexión Firebase'),
        ),
      ),
    );
  }
}
