import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  String _resultText = '';
  File? _capturedImage;

  // Defina as posições dos círculos no gabarito (ajuste conforme sua imagem)
  final Map<int, Map<String, Point>> circlePositions = {
    1: {
      'A': Point(100, 500),
      'B': Point(150, 500),
      'C': Point(200, 500),
      'D': Point(250, 500),
      'E': Point(300, 500),
    },
    2: {
      'A': Point(100, 550),
      'B': Point(150, 550),
      'C': Point(200, 550),
      'D': Point(250, 550),
      'E': Point(300, 550),
    },
    // Adicione mais questões aqui...
  };

  final int circleRadius = 15;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _cameraController.initialize();
    if (!mounted) return;
    setState(() => _isCameraInitialized = true);
  }

  bool isCircleMarked(img.Image image, int centerX, int centerY, int radius) {
    int darkPixels = 0;
    int totalPixels = 0;

    for (int y = centerY - radius; y <= centerY + radius; y++) {
      for (int x = centerX - radius; x <= centerX + radius; x++) {
        if (x < 0 || y < 0 || x >= image.width || y >= image.height) continue;

        int dx = x - centerX;
        int dy = y - centerY;
        if (dx * dx + dy * dy <= radius * radius) {
          totalPixels++;
          final pixel = image.getPixelSafe(x, y);
          final r = pixel.r;
          final g = pixel.g;
          final b = pixel.b;

          double luminance = 0.299 * r + 0.587 * g + 0.114 * b;
          if (luminance < 60) darkPixels++;
        }
      }
    }

    if (totalPixels == 0) return false;
    double ratio = darkPixels / totalPixels;
    return ratio > 0.5;
  }

  Future<void> _captureProcess() async {
    if (_isProcessing || !_cameraController.value.isInitialized) return;

    setState(() {
      _isProcessing = true;
      _resultText = '';
      _capturedImage = null;
    });

    try {
      final picture = await _cameraController.takePicture();
      final file = File(picture.path);
      setState(() => _capturedImage = file);

      // OCR - reconhecer texto
      final inputImage = InputImage.fromFile(file);
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final visionText = await recognizer.processImage(inputImage);
      recognizer.close();

      // Extrair números das questões via regex
      final questionNumbers = <int>{};
      final regExp = RegExp(r'\b\d+\b');
      for (final block in visionText.blocks) {
        for (final line in block.lines) {
          final matches = regExp.allMatches(line.text);
          for (final m in matches) {
            final n = int.tryParse(m.group(0)!);
            if (n != null) questionNumbers.add(n);
          }
        }
      }

      // Decodificar imagem para análise dos círculos
      final bytes = await file.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      if (image == null) throw Exception('Falha ao decodificar imagem');
      image = img.grayscale(image);

      final Map<int, String> respostasDetectadas = {};

      for (var q in questionNumbers) {
        if (!circlePositions.containsKey(q)) continue;
        final alternativas = circlePositions[q]!;

        for (var alt in alternativas.entries) {
          final marcado = isCircleMarked(image, alt.value.x, alt.value.y, circleRadius);
          if (marcado) {
            respostasDetectadas[q] = alt.key;
            break; // pega só a primeira marcada
          }
        }
      }

      final buffer = StringBuffer();
      buffer.writeln('Questões detectadas pelo OCR: ${questionNumbers.join(', ')}');
      buffer.writeln('Respostas detectadas:');
      if (respostasDetectadas.isEmpty) {
        buffer.writeln('Nenhuma bolinha marcada detectada.');
      } else {
        respostasDetectadas.forEach((q, a) {
          buffer.writeln('Questão $q: alternativa $a');
        });
      }

      setState(() => _resultText = buffer.toString());
    } catch (e) {
      setState(() => _resultText = 'Erro: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    if (_isCameraInitialized) _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gabarito Scanner')),
      body: _isCameraInitialized
          ? Stack(
        children: [
          CameraPreview(_cameraController),
          if (_isProcessing)
            const Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _captureProcess,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capturar e Processar'),
              ),
            ),
          ),
          if (_resultText.isNotEmpty)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    _resultText,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class Point {
  final int x;
  final int y;
  const Point(this.x, this.y);
}
