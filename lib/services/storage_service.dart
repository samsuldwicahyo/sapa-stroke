import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/communication_history.dart';

abstract class StorageService {
  Future<Map<String, dynamic>> loadSettings();

  Future<void> saveSettings(Map<String, dynamic> settings);

  Future<List<CommunicationHistory>> loadHistory();

  Future<void> saveHistory(List<CommunicationHistory> history);
}

class SharedPreferencesStorageService implements StorageService {
  SharedPreferencesStorageService(this._sharedPreferences);

  static const String _settingsKey = 'sapa_stroke_settings';
  static const String _historyKey = 'sapa_stroke_history';

  final SharedPreferences _sharedPreferences;

  @override
  Future<Map<String, dynamic>> loadSettings() async {
    final String? rawSettings = _sharedPreferences.getString(_settingsKey);
    if (rawSettings == null || rawSettings.isEmpty) {
      return <String, dynamic>{};
    }

    final Object? decoded = jsonDecode(rawSettings);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{};
  }

  @override
  Future<void> saveSettings(Map<String, dynamic> settings) {
    return _sharedPreferences.setString(_settingsKey, jsonEncode(settings));
  }

  @override
  Future<List<CommunicationHistory>> loadHistory() async {
    final String? rawHistory = _sharedPreferences.getString(_historyKey);
    if (rawHistory == null || rawHistory.isEmpty) {
      return <CommunicationHistory>[];
    }

    final Object? decoded = jsonDecode(rawHistory);
    if (decoded is! List<dynamic>) {
      return <CommunicationHistory>[];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(CommunicationHistory.fromMap)
        .toList(growable: false);
  }

  @override
  Future<void> saveHistory(List<CommunicationHistory> history) {
    return _sharedPreferences.setString(
      _historyKey,
      jsonEncode(history.map((CommunicationHistory item) => item.toMap()).toList()),
    );
  }
}
