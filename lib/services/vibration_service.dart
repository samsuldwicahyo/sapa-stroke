import 'package:vibration/vibration.dart';

abstract class VibrationService {
  Future<void> initialize();

  Future<void> pulse();

  Future<void> selectionPulse();

  Future<void> startEmergencyPattern();

  Future<void> stop();

  bool get isSupported;
}

class DeviceVibrationService implements VibrationService {
  bool _isSupported = false;

  @override
  bool get isSupported => _isSupported;

  @override
  Future<void> initialize() async {
    _isSupported = await Vibration.hasVibrator();
  }

  @override
  Future<void> pulse() async {
    if (!_isSupported) {
      return;
    }

    await Vibration.vibrate(duration: 80);
  }

  @override
  Future<void> selectionPulse() async {
    if (!_isSupported) {
      return;
    }

    await Vibration.vibrate(duration: 40);
  }

  @override
  Future<void> startEmergencyPattern() async {
    if (!_isSupported) {
      return;
    }

    await Vibration.vibrate(
      pattern: const <int>[0, 450, 180, 450],
      repeat: 0,
    );
  }

  @override
  Future<void> stop() {
    return Vibration.cancel();
  }
}
