// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MaterialApp(
    home: CameraScreen(cameras: cameras),
  ));
}

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final bool isCadastro;

  const CameraScreen({
    super.key,
    required this.cameras,
    this.isCadastro = false,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  String _resultText = '';
  File? _capturedImage;

  // Configurações de detecção (simplificadas para este exemplo)
  final int circleRadius = 15;
  final double detectionThreshold = 0.4;
  final double luminanceThreshold = 110;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameraController = CameraController(
      widget.cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _resultText = 'Erro ao inicializar câmera: $e');
      }
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _captureProcess() async {
    if (_isProcessing || !_cameraController.value.isInitialized) return;

    setState(() {
      _isProcessing = true;
      _resultText = 'Processando...';
    });

    try {
      final picture = await _cameraController.takePicture();
      final file = File(picture.path);
      final bytes = await file.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) throw Exception('Erro ao decodificar imagem');

      // Processamento fictício só para exemplo
      // No seu caso, aplique seu processamento real aqui

      setState(() {
        _capturedImage = file;
        _resultText = 'Foto capturada e processada com sucesso.';
      });
    } catch (e) {
      setState(() => _resultText = 'Erro: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final azul = Colors.blue[800]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCadastro ? 'Cadastrar Gabarito' : 'Corrigir Prova'),
        backgroundColor: azul,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          if (_isCameraInitialized)
            CameraPreview(_cameraController)
          else
            const Center(child: CircularProgressIndicator()),

          if (_capturedImage != null)
            Positioned.fill(
              child: Opacity(
                opacity: 0.7,
                child: Image.file(
                  _capturedImage!,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          if (_resultText.isNotEmpty)
            Positioned(
              top: 20,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _resultText,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          if (_isProcessing)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isProcessing
                    ? null
                    : () {
                  setState(() {
                    _capturedImage = null;
                    _resultText = '';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _captureProcess,
                style: ElevatedButton.styleFrom(
                  backgroundColor: azul,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                child: const Text('Tirar Foto'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
