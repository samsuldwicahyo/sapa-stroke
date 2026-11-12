import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/communication_item.dart';
import '../models/family_member.dart';
import '../services/storage_service.dart';
import '../utils/app_constants.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({
    required StorageService storageService,
    Future<void> Function(bool enable)? wakelockToggle,
  })  : _storageService = storageService,
        _wakelockToggle =
            wakelockToggle ?? ((bool enable) => WakelockPlus.toggle(enable: enable));

  final StorageService _storageService;
  final Future<void> Function(bool enable) _wakelockToggle;

  bool _isReady = false;
  String _patientName = AppConstants.defaultPatientName;
  String _primaryFamilyName = AppConstants.defaultPrimaryFamilyName;
  String _secondaryFamilyName = AppConstants.defaultSecondaryFamilyName;
  List<FamilyMember> _additionalFamilyMembers = const <FamilyMember>[];
  Map<String, String> _buttonTextOverrides = <String, String>{};
  List<CommunicationItem> _customItems = const <CommunicationItem>[];
  double _speechRate = AppConstants.defaultSpeechRate;
  double _voiceVolume = AppConstants.defaultSpeechVolume;
  double _pitch = AppConstants.defaultPitch;
  double _laughVolume = AppConstants.defaultLaughVolume;
  bool _vibrationEnabled = true;
  bool _openingGreetingEnabled = true;
  HandPreference _handPreference = HandPreference.left;
  bool _autoScanEnabled = false;
  int _scanIntervalSeconds = AppConstants.defaultScanIntervalSeconds;
  double _textScale = AppConstants.defaultTextScale;
  int _buttonsPerPage = AppConstants.defaultButtonsPerPage;
  List<String> _favoriteOrder = List<String>.from(AppConstants.defaultFavoriteIds);
  String _pin = AppConstants.defaultPin;
  bool _alwaysOn = true;
  bool _darkMode = false;

  bool get isReady => _isReady;
  String get patientName => _patientName;
  String get primaryFamilyName => _primaryFamilyName;
  String get secondaryFamilyName => _secondaryFamilyName;
  List<FamilyMember> get additionalFamilyMembers => _additionalFamilyMembers;
  Map<String, String> get buttonTextOverrides => _buttonTextOverrides;
  List<CommunicationItem> get customItems => _customItems;
  double get speechRate => _speechRate;
  double get voiceVolume => _voiceVolume;
  double get pitch => _pitch;
  double get laughVolume => _laughVolume;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get openingGreetingEnabled => _openingGreetingEnabled;
  HandPreference get handPreference => _handPreference;
  bool get autoScanEnabled => _autoScanEnabled;
  int get scanIntervalSeconds => _scanIntervalSeconds;
  double get textScale => _textScale;
  int get buttonsPerPage => _buttonsPerPage;
  List<String> get favoriteOrder => _favoriteOrder;
  String get pin => _pin;
  bool get alwaysOn => _alwaysOn;
  bool get darkMode => _darkMode;

  Future<void> load() async {
    final Map<String, dynamic> settings = await _storageService.loadSettings();

    _patientName = settings['patientName'] as String? ?? _patientName;
    _primaryFamilyName =
        settings['primaryFamilyName'] as String? ?? _primaryFamilyName;
    _secondaryFamilyName =
        settings['secondaryFamilyName'] as String? ?? _secondaryFamilyName;
    _additionalFamilyMembers = ((settings['additionalFamilyMembers'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .map(FamilyMember.fromMap)
                .toList(growable: false)) ??
            const <FamilyMember>[];
    _buttonTextOverrides = ((settings['buttonTextOverrides'] as Map?)
                ?.map<String, String>(
                  (dynamic key, dynamic value) =>
                      MapEntry(key as String, value as String),
                )) ??
            <String, String>{};
    _customItems = ((settings['customItems'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .map(CommunicationItem.fromMap)
                .toList(growable: false)) ??
            const <CommunicationItem>[];
    _speechRate = (settings['speechRate'] as num?)?.toDouble() ?? _speechRate;
    _voiceVolume =
        (settings['voiceVolume'] as num?)?.toDouble() ?? _voiceVolume;
    _pitch = (settings['pitch'] as num?)?.toDouble() ?? _pitch;
    _laughVolume =
        (settings['laughVolume'] as num?)?.toDouble() ?? _laughVolume;
    _vibrationEnabled =
        settings['vibrationEnabled'] as bool? ?? _vibrationEnabled;
    _openingGreetingEnabled =
        settings['openingGreetingEnabled'] as bool? ?? _openingGreetingEnabled;
    _handPreference = AppConstants.parseHandPreference(
      settings['handPreference'] as String?,
    );
    _autoScanEnabled = settings['autoScanEnabled'] as bool? ?? _autoScanEnabled;
    _scanIntervalSeconds =
        settings['scanIntervalSeconds'] as int? ?? _scanIntervalSeconds;
    _textScale = (settings['textScale'] as num?)?.toDouble() ?? _textScale;
    _buttonsPerPage = settings['buttonsPerPage'] as int? ?? _buttonsPerPage;
    _favoriteOrder = ((settings['favoriteOrder'] as List?)
                ?.whereType<String>()
                .toList(growable: false)) ??
            List<String>.from(AppConstants.defaultFavoriteIds);
    _pin = settings['pin'] as String? ?? _pin;
    _alwaysOn = settings['alwaysOn'] as bool? ?? _alwaysOn;
    _darkMode = settings['darkMode'] as bool? ?? _darkMode;

    await _wakelockToggle(_alwaysOn);
    _isReady = true;
    notifyListeners();
  }

  bool isFavorite(String itemId) => _favoriteOrder.contains(itemId);

  Future<void> updatePatientName(String value) async {
    _patientName = value.trim();
    notifyListeners();
    await _persist();
  }

  Future<void> updatePrimaryFamilyName(String value) async {
    _primaryFamilyName = value.trim();
    notifyListeners();
    await _persist();
  }

  Future<void> updateSecondaryFamilyName(String value) async {
    _secondaryFamilyName = value.trim();
    notifyListeners();
    await _persist();
  }

  Future<void> addFamilyMember(String name) async {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }

    _additionalFamilyMembers = <FamilyMember>[
      ..._additionalFamilyMembers,
      FamilyMember(
        id: 'extra_${DateTime.now().millisecondsSinceEpoch}',
        name: trimmed,
      ),
    ];
    notifyListeners();
    await _persist();
  }

  Future<void> updateFamilyMember(String id, String name) async {
    _additionalFamilyMembers = _additionalFamilyMembers
        .map(
          (FamilyMember member) => member.id == id
              ? member.copyWith(name: name.trim())
              : member,
        )
        .toList(growable: false);
    notifyListeners();
    await _persist();
  }

  Future<void> removeFamilyMember(String id) async {
    _additionalFamilyMembers = _additionalFamilyMembers
        .where((FamilyMember member) => member.id != id)
        .toList(growable: false);
    notifyListeners();
    await _persist();
  }

  Future<void> setButtonTextOverride(String itemId, String value) async {
    _buttonTextOverrides = <String, String>{
      ..._buttonTextOverrides,
      itemId: value.trim(),
    };
    notifyListeners();
    await _persist();
  }

  Future<void> removeButtonTextOverride(String itemId) async {
    _buttonTextOverrides = <String, String>{..._buttonTextOverrides}
      ..remove(itemId);
    notifyListeners();
    await _persist();
  }

  Future<void> addCustomItem({
    required String title,
    required String spokenText,
  }) async {
    final CommunicationItem item = AppConstants.createCustomItem(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      spokenText: spokenText,
      position: _customItems.length,
    );
    _customItems = <CommunicationItem>[..._customItems, item];
    notifyListeners();
    await _persist();
  }

  Future<void> updateCustomItem({
    required String id,
    required String title,
    required String spokenText,
  }) async {
    _customItems = _customItems
        .map(
          (CommunicationItem item) => item.id == id
              ? item.copyWith(
                  title: title.toUpperCase(),
                  spokenText: spokenText,
                )
              : item,
        )
        .toList(growable: false);
    notifyListeners();
    await _persist();
  }

  Future<void> removeCustomItem(String id) async {
    _customItems = _customItems
        .where((CommunicationItem item) => item.id != id)
        .toList(growable: false);
    _favoriteOrder = _favoriteOrder.where((String favorite) => favorite != id).toList();
    notifyListeners();
    await _persist();
  }

  Future<void> setSpeechRate(double value) async {
    _speechRate = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setVoiceVolume(double value) async {
    _voiceVolume = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setPitch(double value) async {
    _pitch = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setLaughVolume(double value) async {
    _laughVolume = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setVibrationEnabled(bool value) async {
    _vibrationEnabled = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setOpeningGreetingEnabled(bool value) async {
    _openingGreetingEnabled = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setModeTanganKiri(bool enabled) async {
    _handPreference = enabled ? HandPreference.left : HandPreference.center;
    notifyListeners();
    await _persist();
  }

  Future<void> setAutoScanEnabled(bool value) async {
    _autoScanEnabled = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setScanIntervalSeconds(int value) async {
    _scanIntervalSeconds = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setTextScale(double value) async {
    _textScale = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setButtonsPerPage(int value) async {
    _buttonsPerPage = value;
    notifyListeners();
    await _persist();
  }

  Future<void> setFavoriteEnabled(String itemId, bool enabled) async {
    final List<String> updated = List<String>.from(_favoriteOrder);
    if (enabled) {
      if (!updated.contains(itemId)) {
        updated.add(itemId);
      }
    } else {
      updated.remove(itemId);
    }
    _favoriteOrder = updated;
    notifyListeners();
    await _persist();
  }

  Future<void> reorderFavorites(List<String> itemIds) async {
    _favoriteOrder = List<String>.from(itemIds);
    notifyListeners();
    await _persist();
  }

  Future<void> setPin(String value) async {
    _pin = value.trim();
    notifyListeners();
    await _persist();
  }

  Future<void> setAlwaysOn(bool value) async {
    _alwaysOn = value;
    await _wakelockToggle(value);
    notifyListeners();
    await _persist();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() {
    return _storageService.saveSettings(<String, dynamic>{
      'patientName': _patientName,
      'primaryFamilyName': _primaryFamilyName,
      'secondaryFamilyName': _secondaryFamilyName,
      'additionalFamilyMembers':
          _additionalFamilyMembers.map((FamilyMember member) => member.toMap()).toList(),
      'buttonTextOverrides': _buttonTextOverrides,
      'customItems':
          _customItems.map((CommunicationItem item) => item.toMap()).toList(),
      'speechRate': _speechRate,
      'voiceVolume': _voiceVolume,
      'pitch': _pitch,
      'laughVolume': _laughVolume,
      'vibrationEnabled': _vibrationEnabled,
      'openingGreetingEnabled': _openingGreetingEnabled,
      'handPreference': AppConstants.handPreferenceToStorage(_handPreference),
      'autoScanEnabled': _autoScanEnabled,
      'scanIntervalSeconds': _scanIntervalSeconds,
      'textScale': _textScale,
      'buttonsPerPage': _buttonsPerPage,
      'favoriteOrder': _favoriteOrder,
      'pin': _pin,
      'alwaysOn': _alwaysOn,
      'darkMode': _darkMode,
    });
  }
}
