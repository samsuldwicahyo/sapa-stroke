import 'package:flutter_tts/flutter_tts.dart';

import '../utils/app_constants.dart';

abstract class TtsService {
  Future<void> initialize({
    required double speechRate,
    required double volume,
    required double pitch,
  });

  Future<void> updateSettings({
    required double speechRate,
    required double volume,
    required double pitch,
  });

  Future<String?> speak(String text);

  Future<String?> testVoice(String text);

  Future<void> stop();

  bool get isLanguageAvailable;
}

class FlutterTtsService implements TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _initialized = false;
  bool _languageAvailable = true;

  @override
  bool get isLanguageAvailable => _languageAvailable;

  @override
  Future<void> initialize({
    required double speechRate,
    required double volume,
    required double pitch,
  }) async {
    if (!_initialized) {
      await _flutterTts.awaitSpeakCompletion(true);
      final dynamic available =
          await _flutterTts.isLanguageAvailable(AppConstants.ttsLocale);
      _languageAvailable = available == true || available == 1;
      if (_languageAvailable) {
        await _flutterTts.setLanguage(AppConstants.ttsLocale);
      }
      _initialized = true;
    }

    await updateSettings(
      speechRate: speechRate,
      volume: volume,
      pitch: pitch,
    );
  }

  @override
  Future<void> updateSettings({
    required double speechRate,
    required double volume,
    required double pitch,
  }) async {
    if (!_initialized) {
      await initialize(
        speechRate: speechRate,
        volume: volume,
        pitch: pitch,
      );
      return;
    }

    if (!_languageAvailable) {
      return;
    }

    await _flutterTts.setSpeechRate(speechRate);
    await _flutterTts.setVolume(volume);
    await _flutterTts.setPitch(pitch);
  }

  @override
  Future<String?> speak(String text) async {
    if (!_languageAvailable) {
      return AppConstants.ttsUnavailableMessage;
    }

    await _flutterTts.stop();
    await _flutterTts.speak(text);
    return null;
  }

  @override
  Future<String?> testVoice(String text) {
    return speak(text);
  }

  @override
  Future<void> stop() {
    return _flutterTts.stop();
  }
}
