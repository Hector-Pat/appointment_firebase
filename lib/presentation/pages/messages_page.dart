import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Sección de mensajes (no funcional por ahora).',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
