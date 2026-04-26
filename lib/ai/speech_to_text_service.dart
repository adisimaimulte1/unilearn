import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextService {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;

  bool get isListening => _speech.isListening;

  Future<bool> init() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize();
    return _initialized;
  }

  Future<String> listenOnce() async {
    final ready = await init();
    if (!ready) return '';

    final completer = Completer<String>();
    String transcript = '';

    await _speech.listen(
      partialResults: true,
      listenMode: ListenMode.dictation,
      localeId: 'en_US',
      onResult: (result) {
        transcript = result.recognizedWords;

        if (result.finalResult && !completer.isCompleted) {
          completer.complete(transcript);
        }
      },
    );

    return completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () async {
        await stop();
        return transcript;
      },
    );
  }

  Future<String> listenForWakeWord() async {
    final ready = await init();
    if (!ready) return '';

    final completer = Completer<String>();

    await _speech.listen(
      partialResults: true,
      listenMode: ListenMode.dictation,
      localeId: 'en_US',
      onResult: (result) {
        final text = result.recognizedWords.toLowerCase();

        final hasWakeWord =
                text.contains("hey apollo") ||
                text.contains("ok apollo") ||
                text.contains("okay apollo");

        if (hasWakeWord && !completer.isCompleted) {
          completer.complete(text);
          stop();
        }
      },
    );

    return completer.future.timeout(
      const Duration(seconds: 6),
      onTimeout: () async {
        await stop();
        return '';
      },
    );
  }

  Future<void> stop() async {
    if (_initialized) {
      await _speech.stop();
    }
  }
}