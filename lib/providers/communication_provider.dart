import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/communication_history.dart';
import '../models/communication_item.dart';
import '../models/family_member.dart';
import '../services/audio_service.dart';
import '../services/scanning_service.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';
import '../services/vibration_service.dart';
import '../utils/app_constants.dart';
import 'settings_provider.dart';

class CommunicationProvider extends ChangeNotifier {
  CommunicationProvider({
    required TtsService ttsService,
    required AudioService audioService,
    required StorageService storageService,
    required VibrationService vibrationService,
    required ScanningService scanningService,
  })  : _ttsService = ttsService,
        _audioService = audioService,
        _storageService = storageService,
        _vibrationService = vibrationService,
        _scanningService = scanningService {
    _scanningService.addListener(_handleScanningChanged);
  }

  final TtsService _ttsService;
  final AudioService _audioService;
  final StorageService _storageService;
  final VibrationService _vibrationService;
  final ScanningService _scanningService;

  SettingsProvider? _settings;
  List<CommunicationHistory> _history = const <CommunicationHistory>[];
  bool _historyReady = false;
  bool _servicesReady = false;
  bool _isConfiguring = false;
  DateTime _lastActionAt = DateTime.fromMillisecondsSinceEpoch(0);
  String? _pressedItemId;
  Timer? _pressedTimer;
  DateTime? _emergencyArmedUntil;
  Timer? _emergencyTimer;
  bool _emergencyActive = false;

  bool get isReady =>
      _historyReady && (_settings?.isReady ?? false) && _servicesReady;
  List<CommunicationHistory> get history => _history;
  String? get pressedItemId => _pressedItemId;
  bool get emergencyActive => _emergencyActive;
  bool get emergencyArmed =>
      _emergencyArmedUntil?.isAfter(DateTime.now()) ?? false;
  String? get currentScanId => _scanningService.currentItemId;
  bool get autoScanEnabled => _settings?.autoScanEnabled ?? false;

  Future<void> initialize() async {
    await _vibrationService.initialize();
    _history = await _storageService.loadHistory();
    _historyReady = true;
    notifyListeners();
  }

  void bindSettings(SettingsProvider settings) {
    _settings = settings;
    if (!_settings!.isReady) {
      notifyListeners();
      return;
    }

    unawaited(_configureServices());
    notifyListeners();
  }

  List<CommunicationItem> get needItems => AppConstants.buildNeedItems(
        textOverrides: _settings?.buttonTextOverrides ?? <String, String>{},
      );

  List<CommunicationItem> get responseItems => AppConstants.buildResponseItems(
        textOverrides: _settings?.buttonTextOverrides ?? <String, String>{},
      );

  List<CommunicationItem> get emotionItems => AppConstants.buildEmotionItems(
        textOverrides: _settings?.buttonTextOverrides ?? <String, String>{},
      );

  List<CommunicationItem> get familyItems => AppConstants.buildFamilyItems(
        primaryName: _settings?.primaryFamilyName ??
            AppConstants.defaultPrimaryFamilyName,
        secondaryName: _settings?.secondaryFamilyName ??
            AppConstants.defaultSecondaryFamilyName,
        extraMembers: _settings?.additionalFamilyMembers ?? const <FamilyMember>[],
        textOverrides: _settings?.buttonTextOverrides ?? <String, String>{},
      );

  List<CommunicationItem> get otherItems => AppConstants.buildOtherItems(
        customItems: _settings?.customItems ?? const <CommunicationItem>[],
      );

  List<CommunicationItem> get editableItems => <CommunicationItem>[
        ...needItems,
        ...responseItems,
        ...familyItems,
        ...emotionItems,
        ...(_settings?.customItems ?? const <CommunicationItem>[]),
      ];

  List<CommunicationItem> get favoriteItems {
    final Map<String, CommunicationItem> itemMap = <String, CommunicationItem>{
      for (final CommunicationItem item in allItems) item.id: item,
    };
    return (_settings?.favoriteOrder ?? AppConstants.defaultFavoriteIds)
        .map((String id) => itemMap[id])
        .whereType<CommunicationItem>()
        .toList(growable: false);
  }

  List<CommunicationItem> get allItems => <CommunicationItem>[
        ...needItems,
        ...responseItems,
        ...familyItems,
        ...emotionItems,
        ...otherItems,
      ];

  CommunicationItem? findItemById(String id) {
    try {
      return allItems.firstWhere((CommunicationItem item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<String?> triggerItem(CommunicationItem item) async {
    if (!_canTrigger()) {
      return null;
    }

    _markPressed(item.id);

    if (item.id == AppConstants.laughItemId) {
      return _playLaugh(item);
    }

    return _speakAndRecord(item);
  }

  Future<String?> playLaugh() async {
    final CommunicationItem? laughItem = findItemById(AppConstants.laughItemId);
    if (laughItem == null) {
      return null;
    }

    return triggerItem(laughItem);
  }

  Future<String?> speakOpeningGreeting() {
    if (!(_settings?.openingGreetingEnabled ?? true)) {
      return Future<String?>.value(null);
    }

    return _speakText(
      'Halo. Selamat datang di SAPA Stroke. '
      'Tekan tombol untuk menyampaikan kebutuhan.',
      saveHistory: false,
      vibrate: false,
    );
  }

  Future<String?> testVoice() {
    return _ttsService.testVoice(
      'Ini adalah uji suara SAPA Stroke dalam bahasa Indonesia.',
    );
  }

  Future<bool> triggerEmergencyArm() async {
    if (!_canTrigger()) {
      return false;
    }

    _markPressed(AppConstants.emergencyActionId);

    if (emergencyArmed) {
      await _activateEmergency();
      return true;
    }

    _emergencyArmedUntil = DateTime.now().add(AppConstants.emergencyWindow);
    _emergencyTimer?.cancel();
    _emergencyTimer = Timer(AppConstants.emergencyWindow, () {
      _emergencyArmedUntil = null;
      notifyListeners();
    });
    notifyListeners();
    return false;
  }

  Future<void> stopEmergency() async {
    _emergencyActive = false;
    _emergencyArmedUntil = null;
    _emergencyTimer?.cancel();
    await _audioService.stopEmergencyAlarm();
    await _vibrationService.stop();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history = const <CommunicationHistory>[];
    notifyListeners();
    await _storageService.saveHistory(_history);
  }

  void registerScanningTargets(List<ScanTarget> targets) {
    _scanningService.registerTargets(
      targets: targets,
      enabled: _settings?.autoScanEnabled ?? false,
      interval: Duration(seconds: _settings?.scanIntervalSeconds ?? 3),
      onHighlightMoved: (_settings?.vibrationEnabled ?? true)
          ? _vibrationService.selectionPulse
          : null,
    );
  }

  void clearScanningTargets() {
    _scanningService.clearTargets();
  }

  Future<String?> activateCurrentScanTarget() {
    if (!(_settings?.autoScanEnabled ?? false)) {
      return Future<String?>.value(null);
    }

    return _scanningService.activateCurrent();
  }

  Future<void> _configureServices() async {
    if (_isConfiguring || _settings == null) {
      return;
    }

    _isConfiguring = true;
    try {
      await _ttsService.initialize(
        speechRate: _settings!.speechRate,
        volume: _settings!.voiceVolume,
        pitch: _settings!.pitch,
      );
      await _audioService.preload();
      _servicesReady = true;
    } finally {
      _isConfiguring = false;
      notifyListeners();
    }
  }

  Future<String?> _speakAndRecord(CommunicationItem item) async {
    final String? message = await _speakText(item.spokenText);
    if (message != null) {
      return message;
    }

    await _recordHistory(item);
    return null;
  }

  Future<String?> _playLaugh(CommunicationItem item) async {
    await _ttsService.stop();
    if (_settings?.vibrationEnabled ?? true) {
      await _vibrationService.pulse();
    }
    await _audioService.playLaugh(volume: _settings?.laughVolume ?? 1.0);
    await _recordHistory(item);
    return null;
  }

  Future<String?> _speakText(
    String text, {
    bool saveHistory = false,
    bool vibrate = true,
  }) async {
    await _audioService.stopLaugh();
    await _ttsService.stop();
    if (vibrate && (_settings?.vibrationEnabled ?? true)) {
      await _vibrationService.pulse();
    }

    final String? message = await _ttsService.speak(text);
    if (message != null) {
      return message;
    }

    if (saveHistory) {
      await recordHistory(
        buttonId: 'custom_voice_test',
        title: 'UJI SUARA',
        spokenText: text,
      );
    }

    return null;
  }

  Future<void> _activateEmergency() async {
    _emergencyArmedUntil = null;
    _emergencyActive = true;
    _emergencyTimer?.cancel();
    notifyListeners();

    await _audioService.startEmergencyAlarm(volume: 1.0);
    if (_settings?.vibrationEnabled ?? true) {
      await _vibrationService.startEmergencyPattern();
    }
    await _ttsService.stop();
    await _ttsService.speak(
      'Tolong datang sekarang. Saya membutuhkan bantuan segera.',
    );
    await recordHistory(
      buttonId: AppConstants.emergencyActionId,
      title: 'DARURAT — PANGGIL SEKARANG',
      spokenText: 'Tolong datang sekarang. Saya membutuhkan bantuan segera.',
    );
  }

  Future<void> _recordHistory(CommunicationItem item) {
    return recordHistory(
      buttonId: item.id,
      title: item.title,
      spokenText: item.spokenText,
    );
  }

  Future<void> recordHistory({
    required String buttonId,
    required String title,
    required String spokenText,
  }) async {
    final CommunicationHistory entry = CommunicationHistory(
      buttonId: buttonId,
      title: title,
      spokenText: spokenText,
      timestamp: DateTime.now(),
    );
    _history = <CommunicationHistory>[entry, ..._history].take(200).toList();
    notifyListeners();
    await _storageService.saveHistory(_history);
  }

  bool _canTrigger() {
    final DateTime now = DateTime.now();
    final bool allowed =
        now.difference(_lastActionAt) >= AppConstants.buttonDebounce;
    if (allowed) {
      _lastActionAt = now;
    }
    return allowed;
  }

  void _markPressed(String id) {
    _pressedItemId = id;
    _pressedTimer?.cancel();
    notifyListeners();
    _pressedTimer = Timer(AppConstants.buttonPressedFeedback, () {
      _pressedItemId = null;
      notifyListeners();
    });
  }

  void _handleScanningChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _pressedTimer?.cancel();
    _emergencyTimer?.cancel();
    _scanningService.removeListener(_handleScanningChanged);
    unawaited(_audioService.dispose());
    super.dispose();
  }
}
