import 'dart:io';
import 'package:flutter/material.dart';

class ListarTurmas extends StatelessWidget {
  const ListarTurmas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Turmas")),
      body: const Center(
        child: Text(
          'Login feito com sucesso!',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
      backgroundColor: const Color(0xFF121212),
    );
  }
}
