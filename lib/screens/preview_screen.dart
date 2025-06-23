import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late String imagePath;
  String recognizedText = '';
  bool _isProcessing = true;
  bool _sending = false;

  final textRecognizer = TextRecognizer();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      imagePath = args;
      _performOCR();
    }
  }

  Future<void> _performOCR() async {
    setState(() {
      _isProcessing = true;
      recognizedText = '';
    });

    final inputImage = InputImage.fromFilePath(imagePath);
    try {
      final RecognizedText result = await textRecognizer.processImage(inputImage);
      String text = result.text;
      setState(() {
        recognizedText = text.isNotEmpty ? text : '[Nenhum texto reconhecido]';
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        recognizedText = 'Erro ao reconhecer texto: $e';
        _isProcessing = false;
      });
    }
  }

  void _sendData() async {
    setState(() => _sending = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _sending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados enviados com sucesso!')),
    );

    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  void _retake() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blueAccent = Colors.blueAccent.shade400;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pré-visualizar e Enviar'),
      ),
      backgroundColor: const Color(0xFF0D1B2A),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(imagePath),
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade900.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    recognizedText,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _sending ? null : _retake,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Refazer Foto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _sending ? null : _sendData,
                    icon: const Icon(Icons.send),
                    label: _sending
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text('Enviar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
