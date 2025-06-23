import 'package:flutter/material.dart';
import 'package:hackathon/screens/listarTurmas.dart';
import 'package:hackathon/screens/login_page.dart';
import 'package:hackathon/screens/results_screen.dart';
import 'package:hackathon/screens/camera_screen.dart';
import 'package:hackathon/core/theme/app_theme.dart';

void main() {
  runApp(const UniAlfaApp());
}

class UniAlfaApp extends StatelessWidget {
  const UniAlfaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniALFA Gabarito',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/camera': (context) => const CameraScreen(),
        '/results': (context) => const ResultScreen(),
        '/listarTurmas': (context) => const ListarTurmas(),
      },
    );
  }
}
