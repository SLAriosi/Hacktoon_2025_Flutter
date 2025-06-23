import 'package:flutter/material.dart';

class SelectStudentPage extends StatelessWidget {
  const SelectStudentPage({Key? key}) : super(key: key);

  final List<Map<String, String>> alunos = const [
    {'nome': 'Ana Silva', 'matricula': '2021001'},
    {'nome': 'Carlos Pereira', 'matricula': '2021002'},
    {'nome': 'Mariana Souza', 'matricula': '2021003'},
    {'nome': 'João Oliveira', 'matricula': '2021004'},
  ];

  @override
  Widget build(BuildContext context) {
    final Color azul = Colors.blue[800]!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: azul,
        title: const Text('Selecionar Aluno'),
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: alunos.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final aluno = alunos[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: azul,
                child: Text(
                  aluno['nome']![0],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                aluno['nome']!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('Matrícula: ${aluno['matricula']}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Implementar ação ao selecionar aluno
              },
            );
          },
        ),
      ),
    );
  }
}
