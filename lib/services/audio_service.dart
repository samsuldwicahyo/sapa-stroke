import 'dart:math';

import 'package:audioplayers/audioplayers.dart';

abstract class AudioService {
  Future<void> preload();

  Future<void> playLaugh({required double volume});

  Future<void> stopLaugh();

  Future<void> startEmergencyAlarm({required double volume});

  Future<void> stopEmergencyAlarm();

  Future<void> dispose();
}

class AppAudioService implements AudioService {
  AppAudioService()
      : _laughPlayer = AudioPlayer(),
        _alarmPlayer = AudioPlayer();

  static const List<String> _laughAssets = <String>[
    'audio/laugh_short.mp3',
    'audio/laugh_soft.mp3',
    'audio/laugh_happy.mp3',
  ];

  final AudioPlayer _laughPlayer;
  final AudioPlayer _alarmPlayer;
  final Random _random = Random();
  bool _isReady = false;

  @override
  Future<void> preload() async {
    if (_isReady) {
      return;
    }

    await _laughPlayer.setReleaseMode(ReleaseMode.stop);
    await _alarmPlayer.setReleaseMode(ReleaseMode.loop);
    _isReady = true;
  }

  @override
  Future<void> playLaugh({required double volume}) async {
    await preload();
    await _laughPlayer.stop();
    await _laughPlayer.setVolume(volume);
    final String asset = _laughAssets[_random.nextInt(_laughAssets.length)];
    await _laughPlayer.play(AssetSource(asset));
  }

  @override
  Future<void> stopLaugh() {
    return _laughPlayer.stop();
  }

  @override
  Future<void> startEmergencyAlarm({required double volume}) async {
    await preload();
    await _alarmPlayer.stop();
    await _alarmPlayer.setReleaseMode(ReleaseMode.loop);
    await _alarmPlayer.setVolume(volume);
    await _alarmPlayer.play(AssetSource('audio/emergency_alarm.mp3'));
  }

  @override
  Future<void> stopEmergencyAlarm() {
    return _alarmPlayer.stop();
  }

  @override
  Future<void> dispose() async {
    await _laughPlayer.dispose();
    await _alarmPlayer.dispose();
  }
}
