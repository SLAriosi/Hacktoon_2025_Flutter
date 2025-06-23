import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class ManualAnswersScreen extends StatefulWidget {
  const ManualAnswersScreen({super.key});

  @override
  State<ManualAnswersScreen> createState() => _ManualAnswersScreenState();
}

class _ManualAnswersScreenState extends State<ManualAnswersScreen> {
  final int totalQuestions = 10;
  final Map<int, String> answers = {}; // questão -> resposta selecionada
  bool _submitting = false;

  void _submit() {
    if (answers.length < totalQuestions) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Responda todas as questões')));
      return;
    }
    setState(() => _submitting = true);

    // Simula envio para API
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Respostas enviadas com sucesso!')));
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final student = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(title: Text('Respostas do Aluno: ${student?['name'] ?? ''}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: totalQuestions,
          itemBuilder: (context, i) {
            int questionNumber = i + 1;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Questão $questionNumber', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 16,
                      children: ['A', 'B', 'C', 'D', 'E'].map((option) {
                        return ChoiceChip(
                          label: Text(option),
                          selected: answers[questionNumber] == option,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                answers[questionNumber] = option;
                              } else {
                                answers.remove(questionNumber);
                              }
                            });
                          },
                        );
                      }).toList(),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomButton(label: 'Enviar Respostas', onPressed: _submitting ? null : _submit, isLoading: _submitting),
      ),
    );
  }
}
