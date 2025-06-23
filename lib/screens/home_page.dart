import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final btnStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('UniALFA - Início')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: btnStyle,
              onPressed: () => Navigator.pushNamed(context, '/select-student'),
              child: const Text('Selecionar Aluno'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: btnStyle,
              onPressed: () => Navigator.pushNamed(context, '/results'),
              child: const Text('Ver Resultados'),
            ),
          ],
        ),
      ),
    );
  }
}
