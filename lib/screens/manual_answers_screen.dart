import 'package:flutter/material.dart';
import 'package:hackathon/screens/select_student_page.dart';
import 'package:hackathon/shared/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_button.dart';

class ManualAnswersScreen extends StatefulWidget {
  const ManualAnswersScreen({super.key});

  @override
  State<ManualAnswersScreen> createState() => _ManualAnswersScreenState();
}

class _ManualAnswersScreenState extends State<ManualAnswersScreen> {
  final Map<int, String> answers = {};
  bool _submitting = false;

  void _submit() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final int? alunoId = args?['id'];
    final int? provaId = args?['provaId'];
    final String? alunoNome = args?['name'];
    final List<dynamic> questoes = args?['itens'] ?? [];

    if (alunoId == null || provaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro interno: alunoId ou provaId inválido.'),
        ),
      );
      return;
    }

    if (answers.length < questoes.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Responda todas as questões')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final response = await ApiClient.post(
        '/gabarito/corrigir/$provaId/aluno/$alunoId',
        body: {
          'respostas': List.generate(questoes.length, (i) => answers[i + 1]),
        },
      );

      if (response.statusCode == 200) {
        await _salvarEnvio(alunoId, provaId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Respostas enviadas com sucesso!')),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) =>
                SelectStudentPage(alunoId: alunoId, alunoNome: alunoNome ?? ''),
          ),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro de conexão: $e')));
    } finally {
      setState(() => _submitting = false);
    }
  }

  Future<void> _salvarEnvio(int alunoId, int provaId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'envios_realizados';
    final existing = prefs.getStringList(key) ?? [];
    final newKey = '$alunoId-$provaId';

    if (!existing.contains(newKey)) {
      existing.add(newKey);
      await prefs.setStringList(key, existing);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final studentName = args?['name'] ?? '';
    final provaId = args?['provaId'];
    final List<dynamic> questoes = args?['itens'] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text('Respostas: $studentName - Prova $provaId')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: questoes.length,
          itemBuilder: (context, i) {
            final item = questoes[i];
            final questionNumber = i + 1;
            final enunciado = item['enunciado'] ?? 'Questão $questionNumber';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Questão $questionNumber: $enunciado',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomButton(
          label: 'Enviar Respostas',
          onPressed: _submitting ? null : _submit,
          isLoading: _submitting,
        ),
      ),
    );
  }
}
