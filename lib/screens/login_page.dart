import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hackathon/screens/home_page.dart';
import 'package:hackathon/screens/listarTurmas.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _loading = false;

  void _login() async {
    // if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    // --- LOGIN COMENTADO ---
    /*
    final url = Uri.parse('http://192.168.0.112:8080/api/login');
    final body = jsonEncode({
      'login': _userController.text,
      'password': _passController.text,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    setState(() => _loading = false);

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erro'),
          content: const Text('Usuário ou senha inválidos.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    */
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _loading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen(cameras: [],)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo_unialfa.png',
                      height: 120,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'UniALFA Gabarito',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 50),
                    TextFormField(
                      controller: _userController,
                      decoration: const InputDecoration(
                        labelText: 'Usuário',
                        prefixIcon: Icon(Icons.person, color: Colors.lightBlueAccent),
                      ),
                      // validator: (v) => (v == null || v.isEmpty) ? 'Informe o usuário' : null,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _passController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: Icon(Icons.lock, color: Colors.lightBlueAccent),
                      ),
                      // validator: (v) => (v == null || v.isEmpty) ? 'Informe a senha' : null,
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        child: _loading
                            ? const SizedBox(
                          height: 26,
                          width: 26,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                            : const Text('Entrar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
