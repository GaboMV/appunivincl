import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();

  Future<void> hablar(String texto) async {
    await _tts.stop();
    await _tts.setLanguage("es-ES");
    await _tts.setSpeechRate(0.9);
    await _tts.speak(texto);
  }

  Future<void> detener() async {
    await _tts.stop();
  }
}
