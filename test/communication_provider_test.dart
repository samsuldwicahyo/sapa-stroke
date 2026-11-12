import 'package:flutter_test/flutter_test.dart';
import 'package:sapa_stroke/models/communication_item.dart';
import 'package:sapa_stroke/providers/communication_provider.dart';
import 'package:sapa_stroke/providers/settings_provider.dart';
import 'package:sapa_stroke/services/scanning_service.dart';

import 'fakes.dart';

void main() {
  late FakeStorageService storage;
  late FakeTtsService tts;
  late FakeAudioService audio;
  late FakeVibrationService vibration;
  late ScanningService scanning;
  late SettingsProvider settings;
  late CommunicationProvider communication;

  Future<void> bootstrap() async {
    storage = FakeStorageService();
    tts = FakeTtsService();
    audio = FakeAudioService();
    vibration = FakeVibrationService();
    scanning = ScanningService();
    settings = SettingsProvider(
      storageService: storage,
      wakelockToggle: (_) async {},
    );
    await settings.load();
    communication = CommunicationProvider(
      ttsService: tts,
      audioService: audio,
      storageService: storage,
      vibrationService: vibration,
      scanningService: scanning,
    );
    await communication.initialize();
    communication.bindSettings(settings);
    await Future<void>.delayed(Duration.zero);
  }

  setUp(() async {
    await bootstrap();
  });

  test('tombol panggil pendamping membacakan kalimat yang benar', () async {
    final CommunicationItem item =
        communication.findItemById('need_call_caregiver')!;

    await communication.triggerItem(item);

    expect(
      tts.spokenTexts.last,
      'Tolong datang ke sini. Saya membutuhkan bantuan.',
    );
    expect(communication.history.first.title, 'PANGGIL PENDAMPING');
  });

  test('tombol Keluarga 1 dan Keluarga 2 menyebut nama yang benar', () async {
    final CommunicationItem bagas =
        communication.findItemById('family_call_primary')!;
    final CommunicationItem arum =
        communication.findItemById('family_call_secondary')!;

    await communication.triggerItem(bagas);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    await communication.triggerItem(arum);

    expect(tts.spokenTexts[0], 'Keluarga 1, tolong datang ke sini.');
    expect(tts.spokenTexts[1], 'Keluarga 2, tolong datang ke sini.');
  });

  test('tombol ketawa memutar audio lokal', () async {
    await communication.playLaugh();

    expect(audio.playLaughCount, 1);
    expect(audio.lastLaughVolume, settings.laughVolume);
    expect(tts.stopCount, 1);
  });

  test('tombol ya dan tidak membacakan respons benar', () async {
    final CommunicationItem yes = communication.findItemById('response_yes')!;
    final CommunicationItem no = communication.findItemById('response_no')!;

    await communication.triggerItem(yes);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    await communication.triggerItem(no);

    expect(tts.spokenTexts[0], 'Ya.');
    expect(tts.spokenTexts[1], 'Tidak.');
  });

  test('alarm darurat aktif setelah dua kali tekan', () async {
    final bool firstTap = await communication.triggerEmergencyArm();
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final bool secondTap = await communication.triggerEmergencyArm();

    expect(firstTap, isFalse);
    expect(secondTap, isTrue);
    expect(audio.emergencyStartCount, 1);
    expect(vibration.emergencyCount, 1);
    expect(communication.history.first.title, 'DARURAT — PANGGIL SEKARANG');
  });

  test('riwayat tersimpan setelah tombol ditekan', () async {
    final CommunicationItem item = communication.findItemById('need_phlegm')!;

    await communication.triggerItem(item);

    expect(storage.historyStore, isNotEmpty);
    expect(storage.historyStore.first.buttonId, 'need_phlegm');
  });

  test('suara sebelumnya dihentikan saat tombol lain ditekan', () async {
    final CommunicationItem first = communication.findItemById('need_pain')!;
    final CommunicationItem second = communication.findItemById('need_cold')!;

    await communication.triggerItem(first);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    await communication.triggerItem(second);

    expect(tts.stopCount, 2);
    expect(tts.spokenTexts.last, second.spokenText);
  });
}
