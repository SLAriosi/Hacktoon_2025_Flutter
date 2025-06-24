import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hackathon/screens/manual_answers_screen.dart';
import 'package:hackathon/shared/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectStudentPage extends StatefulWidget {
  final int alunoId;
  final String alunoNome;

  const SelectStudentPage({
    super.key,
    required this.alunoId,
    required this.alunoNome,
  });

  @override
  State<SelectStudentPage> createState() => _SelectStudentPageState();
}

class _SelectStudentPageState extends State<SelectStudentPage> {
  List<dynamic> provas = [];
  List<dynamic> provasCorrigidas = [];
  bool carregando = true;
  Set<String> enviosFeitos = {};

  @override
  void initState() {
    super.initState();
    fetchProvas();
    carregarEnvios();
    fetchGabaritos();
  }

  Future<void> fetchProvas() async {
    try {
      final response = await ApiClient.get('/Aluno/${widget.alunoId}/provas');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          provas = data;
          carregando = false;
        });
      } else {
        throw Exception('Erro ao buscar provas: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar provas: $e');
      setState(() => carregando = false);
    }
  }

  Future<void> fetchGabaritos() async {
    try {
      final response = await ApiClient.get('/gabarito/${widget.alunoId}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          provasCorrigidas = data;
        });
      }
    } catch (e) {
      print('Erro ao buscar gabaritos: $e');
    }
  }

  Future<void> carregarEnvios() async {
    final prefs = await SharedPreferences.getInstance();
    final enviados = prefs.getStringList('envios_realizados') ?? [];
    setState(() {
      enviosFeitos = enviados.toSet();
    });
  }

  void _abrirSelecaoDeProva(BuildContext context) async {
    final provasCorrigidasIds = provasCorrigidas
        .map((g) => (g['prova_id'] ?? g['id']).toString())
        .toSet();

    final provasDisponiveis = provas.where((p) {
      final provaId = p['id'].toString();
      final key = '${widget.alunoId}-$provaId';
      return !enviosFeitos.contains(key) &&
          !provasCorrigidasIds.contains(provaId);
    }).toList();

    if (provasDisponiveis.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma prova disponível para correção.')),
      );
      return;
    }

    final provaSelecionada = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          children: provasDisponiveis.map<Widget>((prova) {
            return ListTile(
              title: Text(prova['nome']),
              onTap: () {
                Navigator.pop(context, prova);
              },
            );
          }).toList(),
        );
      },
    );

    if (provaSelecionada != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ManualAnswersScreen(),
          settings: RouteSettings(arguments: {
            'id': widget.alunoId,
            'name': widget.alunoNome,
            'provaId': provaSelecionada['id'],
            'itens': provaSelecionada['itens'],
          }),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final azul = Colors.blue[800]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alunoNome),
        centerTitle: true,
        backgroundColor: azul,
      ),
      body: Column(
        children: [
          Expanded(
            child: carregando
                ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                : provas.isEmpty
                ? const Center(child: Text('Nenhuma prova encontrada.'))
                : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gabarito',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: provas.length,
                      itemBuilder: (context, index) {
                        final prova = provas[index];
                        final itens = prova['itens'] as List<dynamic>;
                        final corrigidaIds = provasCorrigidas
                            .map((g) => (g['prova_id'] ?? g['id']).toString())
                            .toSet();

                        if (corrigidaIds.contains(prova['id'].toString())) {
                          return const SizedBox.shrink();
                        }

                        return ExpansionTile(
                          title: Text(prova['nome']),
                          children: itens.map((item) {
                            return ListTile(
                              title: Text(item['enunciado']),
                              subtitle: Text('Resposta: ${item['resposta']}'),
                              trailing: Text('Valor: ${item['valor']}'),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Provas Corrigidas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...provasCorrigidas.map((g) {
                    final id = g['prova_id'] ?? g['id'];
                    final acertos = g['acertos'] ?? 0;
                    final total = g['total'] ?? 0;
                    return ListTile(
                      leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                      title: Text('Prova $id'),
                      subtitle: Text('Acertos: $acertos de $total'),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _abrirSelecaoDeProva(context),
                    icon: const Icon(Icons.edit),
                    label: const Text('Corrigir prova manualmente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: azul,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Cadastrar a prova por escaneamento'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
