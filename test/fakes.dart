import 'package:sapa_stroke/models/communication_history.dart';
import 'package:sapa_stroke/services/audio_service.dart';
import 'package:sapa_stroke/services/storage_service.dart';
import 'package:sapa_stroke/services/tts_service.dart';
import 'package:sapa_stroke/services/vibration_service.dart';
import 'package:sapa_stroke/utils/app_constants.dart';

class FakeStorageService implements StorageService {
  Map<String, dynamic> settingsStore = <String, dynamic>{};
  List<CommunicationHistory> historyStore = <CommunicationHistory>[];

  @override
  Future<List<CommunicationHistory>> loadHistory() async {
    return List<CommunicationHistory>.from(historyStore);
  }

  @override
  Future<Map<String, dynamic>> loadSettings() async {
    return Map<String, dynamic>.from(settingsStore);
  }

  @override
  Future<void> saveHistory(List<CommunicationHistory> history) async {
    historyStore = List<CommunicationHistory>.from(history);
  }

  @override
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    settingsStore = Map<String, dynamic>.from(settings);
  }
}

class FakeTtsService implements TtsService {
  bool available = true;
  int initializeCount = 0;
  int stopCount = 0;
  List<String> spokenTexts = <String>[];

  @override
  bool get isLanguageAvailable => available;

  @override
  Future<void> initialize({
    required double speechRate,
    required double volume,
    required double pitch,
  }) async {
    initializeCount += 1;
  }

  @override
  Future<String?> speak(String text) async {
    if (!available) {
      return AppConstants.ttsUnavailableMessage;
    }

    spokenTexts.add(text);
    return null;
  }

  @override
  Future<void> stop() async {
    stopCount += 1;
  }

  @override
  Future<String?> testVoice(String text) => speak(text);

  @override
  Future<void> updateSettings({
    required double speechRate,
    required double volume,
    required double pitch,
  }) async {}
}

class FakeAudioService implements AudioService {
  int preloadCount = 0;
  int playLaughCount = 0;
  int stopLaughCount = 0;
  int emergencyStartCount = 0;
  int emergencyStopCount = 0;
  double? lastLaughVolume;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> playLaugh({required double volume}) async {
    playLaughCount += 1;
    lastLaughVolume = volume;
  }

  @override
  Future<void> preload() async {
    preloadCount += 1;
  }

  @override
  Future<void> startEmergencyAlarm({required double volume}) async {
    emergencyStartCount += 1;
  }

  @override
  Future<void> stopEmergencyAlarm() async {
    emergencyStopCount += 1;
  }

  @override
  Future<void> stopLaugh() async {
    stopLaughCount += 1;
  }
}

class FakeVibrationService implements VibrationService {
  int initializeCount = 0;
  int pulseCount = 0;
  int selectionPulseCount = 0;
  int emergencyCount = 0;
  int stopCount = 0;

  @override
  bool get isSupported => true;

  @override
  Future<void> initialize() async {
    initializeCount += 1;
  }

  @override
  Future<void> pulse() async {
    pulseCount += 1;
  }

  @override
  Future<void> selectionPulse() async {
    selectionPulseCount += 1;
  }

  @override
  Future<void> startEmergencyPattern() async {
    emergencyCount += 1;
  }

  @override
  Future<void> stop() async {
    stopCount += 1;
  }
}
