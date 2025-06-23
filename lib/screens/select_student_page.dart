import 'package:flutter/material.dart';
import '../widgets/student_card.dart';

class SelectStudentScreen extends StatelessWidget {
  SelectStudentScreen({super.key});

  final students = [
    {'id': '1001', 'name': 'Ana Maria'},
    {'id': '1002', 'name': 'Bruno Silva'},
    {'id': '1003', 'name': 'Carlos Eduardo'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selecionar Aluno')),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 10),
        itemCount: students.length,
        itemBuilder: (context, i) {
          final student = students[i];
          return StudentCard(
            name: student['name']!,
            id: student['id']!,
            onTap: () => Navigator.pushNamed(context, '/manual-answers', arguments: student),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/camera');
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
