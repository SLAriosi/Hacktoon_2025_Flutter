import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hackathon/screens/select_student_page.dart';
import 'package:hackathon/shared/services/api_service.dart';

class Aluno {
  final int id;
  final String nome;

  Aluno({required this.id, required this.nome});

  factory Aluno.fromJson(Map<String, dynamic> json) {
    return Aluno(
      id: json['id'],
      nome: json['nome'] ?? '',
    );
  }
}

class TurmaDetailPage extends StatefulWidget {
  final String nomeTurma;
  final int turmaId;

  const TurmaDetailPage({
    super.key,
    required this.nomeTurma,
    required this.turmaId,
  });

  @override
  State<TurmaDetailPage> createState() => _TurmaDetailPageState();
}

class _TurmaDetailPageState extends State<TurmaDetailPage> {
  List<Aluno> alunos = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    fetchAlunos();
  }

  Future<void> fetchAlunos() async {
    try {
      final response = await ApiClient.get('/Aluno/turma/${widget.turmaId}');

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          alunos = data.map((e) => Aluno.fromJson(e)).toList();
          carregando = false;
        });
      } else {
        throw Exception('Erro ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar alunos: $e');
      setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final azul = Colors.blue[800]!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: azul,
        title: Text(widget.nomeTurma),
        centerTitle: true,
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : alunos.isEmpty
          ? const Center(
        child: Text(
          'Nenhum aluno encontrado.',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.separated(
        itemCount: alunos.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final aluno = alunos[index];
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectStudentPage(
                    alunoId: aluno.id,
                    alunoNome: aluno.nome,
                  ),
                ),
              );
            },
            leading: CircleAvatar(
              backgroundColor: azul,
              child: Text(aluno.nome[0]),
            ),
            title: Text(aluno.nome),
          );
        },
      ),
    );
  }
}
