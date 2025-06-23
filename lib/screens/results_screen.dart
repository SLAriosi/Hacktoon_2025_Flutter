import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AlunoResultado {
  final String nome;
  final double nota;

  AlunoResultado({required this.nome, required this.nota});

  factory AlunoResultado.fromJson(Map<String, dynamic> json) {
    return AlunoResultado(
      nome: json['nome'],
      nota: (json['nota'] as num).toDouble(),
    );
  }
}

class ResultScreen extends StatefulWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<AlunoResultado> resultados = [];
  bool carregando = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    fetchResultados();
  }

  Future<void> fetchResultados() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8080/api/alunos'));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          resultados = data.map((e) => AlunoResultado.fromJson(e)).toList();
          carregando = false;
        });
      } else {
        setState(() {
          erro = 'Erro ao carregar resultados: ${response.statusCode}';
          carregando = false;
        });
      }
    } catch (e) {
      setState(() {
        erro = 'Erro ao carregar resultados: $e';
        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color azul = Colors.blue[800]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados dos Alunos'),
        backgroundColor: azul,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: carregando
            ? const Center(child: CircularProgressIndicator())
            : erro != null
            ? Center(
          child: Text(
            erro!,
            style: const TextStyle(color: Colors.red),
          ),
        )
            : resultados.isEmpty
            ? const Center(child: Text('Nenhum resultado encontrado.'))
            : ListView.separated(
          itemCount: resultados.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final resultado = resultados[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: azul.withOpacity(0.2),
                child: Text(
                  resultado.nome[0],
                  style: TextStyle(
                    color: azul,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                resultado.nome,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: azul,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  resultado.nota.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
