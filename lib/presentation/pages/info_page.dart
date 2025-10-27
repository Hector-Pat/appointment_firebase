import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  final String title;

  const InfoPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Esta es la sección de $title. Aquí puedes mostrar información relevante o texto descriptivo.',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
