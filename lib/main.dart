import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:hackathon/screens/home_page.dart';
import 'package:hackathon/screens/login_page.dart';
import 'package:hackathon/screens/results_screen.dart';
import 'package:hackathon/screens/camera_screen.dart';
import 'package:hackathon/core/theme/app_theme.dart';

late final List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
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
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/results':
            return MaterialPageRoute(builder: (_) => const ResultScreen());
          case '/listarTurmas':
            final bool isCadastro = settings.arguments as bool? ?? false;
            return MaterialPageRoute(
              builder: (_) => CameraScreen(cameras: cameras, isCadastro: isCadastro),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(child: Text('Rota não encontrada: ${settings.name}')),
              ),
            );
        }
      },
    );
  }
}
