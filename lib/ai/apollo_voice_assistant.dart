import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ai_state.dart';
import 'apollo_intent_processor.dart';
import 'apollo_navigator.dart';
import 'apollo_recordings.dart';
import 'speech_to_text_service.dart';

class ApolloVoiceAssistant {
  final SpeechToTextService _speech = SpeechToTextService();
  final AudioPlayer _player = AudioPlayer();

  bool _running = false;
  bool _speaking = false;
  bool _wakeActive = false;

  Timer? _cooldownTimer;

  Future<void> start() async {
    if (_running) return;

    final mic = await Permission.microphone.request();
    if (!mic.isGranted) return;

    _running = true;

    while (_running) {
      if (_speaking) {
        await Future.delayed(const Duration(milliseconds: 100));
        continue;
      }

      if (!_wakeActive) {
        assistantState.value = AIState.idle;

        final wakeText = await _speech.listenForWakeWord();
        final lowerWake = wakeText.toLowerCase();

        final hasWakeWord =
            lowerWake.contains("hey apollo") ||
                lowerWake.contains("ok apollo") ||
                lowerWake.contains("okay apollo");

        if (hasWakeWord) {
          _wakeActive = true;

          assistantState.value = AIState.thinking;
          await Future.delayed(const Duration(milliseconds: 550));

          final bytes = await ApolloRecordings.getWakeResponse();
          await playLocalResponse(bytes);

          assistantState.value = AIState.listening;
          _startCooldown();
        }
      } else {
        await _captureCommand();
      }
    }
  }

  void stop() {
    _running = false;
    _wakeActive = false;
    _speaking = false;

    _cooldownTimer?.cancel();

    try {
      _player.stop();
      _speech.stop();
    } catch (_) {}

    assistantState.value = AIState.idle;
  }

  void sleep() {
    _wakeActive = false;
    _speaking = false;

    _cooldownTimer?.cancel();

    try {
      _speech.stop();
    } catch (_) {}

    assistantState.value = AIState.idle;
  }

  Future<void> _captureCommand() async {
    assistantState.value = AIState.listening;

    final raw = await _speech.listenOnce();
    final cleaned = ApolloIntentProcessor.cleanWakeWord(raw);

    liveTranscript.value = cleaned;

    if (cleaned.isEmpty) {
      assistantState.value = AIState.listening;
      return;
    }

    assistantState.value = AIState.thinking;

    final isShutdown = ApolloIntentProcessor.isShutdownCommand(cleaned);

    if (isShutdown) {
      assistantState.value = AIState.thinking;
      await Future.delayed(const Duration(milliseconds: 450));

      final bytes = await ApolloRecordings.getShutdownResponse();
      await playLocalResponse(bytes);

      sleep();
      return;
    }

    final isOpenPlanetCommand =
    ApolloIntentProcessor.isOpenPlanetCommand(cleaned);

    final isClosePlanetCommand =
    ApolloIntentProcessor.isClosePlanetCommand(cleaned);

    if (isClosePlanetCommand) {
      assistantState.value = AIState.thinking;
      await Future.delayed(const Duration(milliseconds: 450));

      final closed = ApolloNavigator.closeCurrentPlanetPopup();

      if (closed) {
        final bytes = await ApolloRecordings.getClosePlanetResponse();
        await playLocalResponse(bytes);
      }

      assistantState.value = AIState.listening;
      _startCooldown();
      return;
    }

    if (isOpenPlanetCommand) {
      assistantState.value = AIState.thinking;
      await Future.delayed(const Duration(milliseconds: 450));

      final opened = ApolloNavigator.openCurrentPlanetPopup();

      if (opened) {
        final bytes = await ApolloRecordings.getOpenPlanetResponse();
        await playLocalResponse(bytes);
      }

      assistantState.value = AIState.listening;
      _startCooldown();
      return;
    }

    final isMorePlanetInfoCommand =
    ApolloIntentProcessor.isMorePlanetInfoCommand(cleaned);

    if (isMorePlanetInfoCommand) {
      final planet = ApolloNavigator.focusedPlanet;

      if (planet != null) {
        final enrichedPrompt = '''
The user is asking for more details about the planet they are currently viewing.

Planet card data:
Name: ${planet.name}
Subtitle: ${planet.subtitle}
Description: ${planet.description}
Diameter: ${planet.diameter}
Mass: ${planet.mass}
Day length: ${planet.dayLength}

User request:
$cleaned

Respond naturally as Apollo, in a short but interesting way. Add extra useful facts beyond the card data, like fun facts, but keep it easy to understand.
''';

        await _speakFromBackend(enrichedPrompt);
        _finishInteraction();
        return;
      }
    }

    final isScrollCommand = ApolloIntentProcessor.isPlanetScrollCommand(cleaned);

    if (isScrollCommand) {
      final planet = ApolloNavigator.extractPlanetName(cleaned);

      assistantState.value = AIState.thinking;
      await Future.delayed(const Duration(milliseconds: 450));

      if (planet != null) {
        final bytes = await ApolloRecordings.getPlanetResponse(planet);

        if (bytes != null) {
          playLocalResponse(bytes);
          await ApolloNavigator.scrollToPlanet(cleaned);
        }

        assistantState.value = AIState.listening;
      }

      _startCooldown();
      return;
    }

    await _speakFromBackend(cleaned);
    _finishInteraction();
  }

  Future<void> playLocalResponse(Uint8List bytes) async {
    _speaking = true;
    assistantState.value = AIState.speaking;

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/apollo_local_response.mp3');
    await file.writeAsBytes(bytes);

    final completer = Completer<void>();

    late StreamSubscription sub;
    sub = _player.onPlayerComplete.listen((_) {
      if (!completer.isCompleted) completer.complete();
    });

    try {
      await _player.play(DeviceFileSource(file.path));
      await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {},
      );
    } catch (e) {
      debugPrint("Apollo local playback failed: $e");
    }

    await sub.cancel();
    _speaking = false;
  }

  Future<void> _speakFromBackend(String message) async {
    _speaking = true;
    assistantState.value = AIState.thinking;

    final bytes = await _sendQuestionToBackend(message);

    if (bytes.isEmpty) {
      _speaking = false;
      assistantState.value = AIState.idle;
      return;
    }

    assistantState.value = AIState.speaking;

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/apollo_response.mp3');
    await file.writeAsBytes(bytes);

    final completer = Completer<void>();

    late StreamSubscription sub;
    sub = _player.onPlayerComplete.listen((_) {
      if (!completer.isCompleted) completer.complete();
    });

    try {
      await _player.play(DeviceFileSource(file.path));
      await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {},
      );
    } catch (e) {
      debugPrint("Apollo backend playback failed: $e");
    }

    await sub.cancel();
    _speaking = false;
  }

  Future<List<int>> _sendQuestionToBackend(String message) async {
    final response = await http.post(
      Uri.parse("https://optima-livekit-token-server.onrender.com/apollo-chat"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "message": message,
      }),
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    }

    debugPrint("Apollo backend failed: ${response.statusCode} ${response.body}");
    return [];
  }

  void _finishInteraction() {
    _speaking = false;
    _wakeActive = true;
    assistantState.value = AIState.listening;
    _startCooldown();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();

    _cooldownTimer = Timer(const Duration(seconds: 50), () {
      if (_speaking) return;

      _wakeActive = false;
      assistantState.value = AIState.idle;
    });
  }
}

final apolloVoice = ApolloVoiceAssistant();