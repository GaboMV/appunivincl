import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _escuchando = false;
  String _ultimoResultado = '';

  Future<bool> init() async {
    return await _speech.initialize(
      onError: (e) => print("Error en Speech: ${e.errorMsg}"),
    );
  }

  Future<void> startListening() async {
    if (!_escuchando) {
      _escuchando = true;
      _ultimoResultado = '';
      await _speech.listen(
        onResult: (result) {
          _ultimoResultado = result.recognizedWords;
        },
      );
    }
  }

  Future<String> stopListening() async {
    if (_escuchando) {
      await _speech.stop();
      _escuchando = false;
    }
    return _ultimoResultado.trim();
  }
}
