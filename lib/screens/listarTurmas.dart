import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Turma {
  final String nome;
  final String turno;

  Turma({required this.nome, required this.turno});

  factory Turma.fromJson(Map<String, dynamic> json) {
    return Turma(
      nome: json['nome'],
      turno: json['turno'],
    );
  }
}

class ListarTurmas extends StatefulWidget {
  const ListarTurmas({super.key});

  @override
  State<ListarTurmas> createState() => _ListarTurmasState();
}

class _ListarTurmasState extends State<ListarTurmas> {
  List<Turma> turmas = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    fetchTurmas();
  }

  Future<void> fetchTurmas() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/turmas'),
      );

      if (response.statusCode == 200) {
        final List jsonData = json.decode(response.body);
        setState(() {
          turmas = jsonData.map((e) => Turma.fromJson(e)).toList();
          carregando = false;
        });
      } else {
        throw Exception('Erro: ${response.statusCode}');
      }
    } catch (e) {
      print("Erro ao buscar turmas: $e");
      setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Turmas"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 4,
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: turmas.length,
        itemBuilder: (context, index) {
          final turma = turmas[index];
          return Card(
            color: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                turma.nome,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Turno: ${turma.turno}',
                style: const TextStyle(color: Colors.white70),
              ),
              trailing:
              const Icon(Icons.arrow_forward_ios, color: Colors.white38),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
