import 'dart:io';
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    final String? imagePath = args['imagePath'];
    final Map<int, bool>? answers = args['answers'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados do Gabarito'),
        backgroundColor: Colors.greenAccent.shade700,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF121212),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(imagePath),
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            Expanded(
              child: answers == null
                  ? const Center(
                child: Text('Nenhuma resposta disponível',
                    style: TextStyle(color: Colors.white70)),
              )
                  : ListView.builder(
                itemCount: answers.length,
                itemBuilder: (context, index) {
                  final question = answers.keys.elementAt(index);
                  final correct = answers[question]!;

                  return Card(
                    color: correct ? Colors.green.shade900 : Colors.red.shade900,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Icon(
                        correct ? Icons.check_circle : Icons.cancel,
                        color: correct ? Colors.greenAccent : Colors.redAccent,
                        size: 32,
                      ),
                      title: Text(
                        'Questão $question',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      subtitle: Text(
                        correct ? 'Resposta correta' : 'Resposta incorreta',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
