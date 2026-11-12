import 'package:flutter_test/flutter_test.dart';
import 'package:sapa_stroke/providers/settings_provider.dart';

import 'fakes.dart';

void main() {
  test('pengaturan tetap tersimpan setelah provider dimuat ulang', () async {
    final FakeStorageService storage = FakeStorageService();

    final SettingsProvider first = SettingsProvider(
      storageService: storage,
      wakelockToggle: (_) async {},
    );
    await first.load();
    await first.setSpeechRate(0.62);
    await first.setAutoScanEnabled(true);
    await first.setScanIntervalSeconds(5);
    await first.addFamilyMember('Budi');

    final SettingsProvider second = SettingsProvider(
      storageService: storage,
      wakelockToggle: (_) async {},
    );
    await second.load();

    expect(second.speechRate, 0.62);
    expect(second.autoScanEnabled, isTrue);
    expect(second.scanIntervalSeconds, 5);
    expect(second.additionalFamilyMembers.single.name, 'Budi');
  });
}
