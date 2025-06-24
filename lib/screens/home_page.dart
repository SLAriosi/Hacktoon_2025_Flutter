import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/screens/login_page.dart';
import 'package:hackathon/screens/turma_detail_page.dart';
import 'package:hackathon/shared/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../screens/results_screen.dart';
import '../screens/camera_screen.dart';

class Turma {
  final int id;
  final String nome;

  Turma({required this.id, required this.nome});

  factory Turma.fromJson(Map<String, dynamic> json) {
    return Turma(
      id: json['id'] ?? '',
      nome: json['nome'] ?? '',
    );
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
      final response = await ApiClient.get('/Turma');

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 4,
        title: Image.asset(
          'assets/images/logo_unialfa.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        // O botão de menu será adicionado automaticamente quando houver um Drawer
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: colorScheme.primary,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo_unialfa.png',
                    height: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'UniALFA Gabarito',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Resultados'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultScreen()));
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear(); // limpa tudo
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Minhas Turmas',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            carregando
                ? const Center(child: CircularProgressIndicator())
                : turmas.isEmpty
                ? Text(
              'Nenhuma turma encontrada.',
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onBackground),
            )
                : Expanded(
              child: ListView.separated(
                itemCount: turmas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final turma = turmas[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primary.withOpacity(0.1),
                        child: Icon(Icons.class_, color: colorScheme.primary),
                      ),
                      title: Text(
                        turma.nome,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TurmaDetailPage(
                              nomeTurma: turma.nome,
                              turmaId: turma.id,
                            ),
                          ),
                        );
                      },
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

  Widget _botaoPrincipal(
      BuildContext context, {
        required String label,
        required IconData icon,
        required VoidCallback onPressed,
        required Color color,
      }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2 - 28,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, textAlign: TextAlign.center),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
