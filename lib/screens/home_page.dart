import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../main.dart';
import '../screens/results_screen.dart';
import '../screens/select_student_page.dart';
import '../screens/camera_screen.dart';

class Turma {
  final String nome;
  final String turno;

  Turma({required this.nome, required this.turno});

  factory Turma.fromJson(Map<String, dynamic> json) {
    return Turma(nome: json['nome'], turno: json['turno']);
  }
}

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const HomeScreen({super.key, required this.cameras});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Turma> turmas = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    fetchTurmas();
  }

  Future<void> fetchTurmas() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8080/api/turmas'));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          turmas = data.map((e) => Turma.fromJson(e)).toList();
          carregando = false;
        });
      } else {
        throw Exception('Erro ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar turmas: $e');
      setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color azul = Colors.blue[800]!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: azul,
        centerTitle: true,
        elevation: 4,
        title: Image.asset(
          'assets/images/logo_unialfa.png',
          height: 40,
          fit: BoxFit.contain,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _botaoPrincipal(
                  context,
                  label: 'Selecionar Aluno',
                  icon: Icons.person_search,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SelectStudentPage()));
                  },
                ),
                _botaoPrincipal(
                  context,
                  label: 'Ver Resultados',
                  icon: Icons.bar_chart,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultScreen()));
                  },
                ),
                _botaoPrincipal(
                  context,
                  label: 'Escanear Prova',
                  icon: Icons.camera_alt,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CameraScreen(cameras: widget.cameras)),
                    );
                  },
                ),

                _botaoPrincipal(
                  context,
                  label: 'Cadastrar Prova',
                  icon: Icons.edit_note,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CameraScreen(
                          cameras: widget.cameras,
                          isCadastro: true,
                        ),
                      ),
                    );
                  },
                ),

              ],
            ),

            const SizedBox(height: 30),

            const Text(
              'Minhas Turmas',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),

            carregando
                ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                : turmas.isEmpty
                ? const Text('Nenhuma turma encontrada.', style: TextStyle(color: Colors.white70))
                : Expanded(
              child: ListView.separated(
                itemCount: turmas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final turma = turmas[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      leading: CircleAvatar(
                        backgroundColor: azul.withOpacity(0.1),
                        child: Icon(Icons.class_, color: azul),
                      ),
                      title: Text(
                        turma.nome,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        'Turno: ${turma.turno}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.white54,
                      ),
                      onTap: () {},
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

  Widget _botaoPrincipal(BuildContext context,
      {required String label, required IconData icon, required VoidCallback onPressed}) {
    final Color azul = Colors.blue[800]!;
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2 - 28,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, textAlign: TextAlign.center),
        style: ElevatedButton.styleFrom(
          backgroundColor: azul,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
