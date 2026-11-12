import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sapa_stroke/services/scanning_service.dart';

void main() {
  test('mode pemindaian berpindah sesuai interval dan reset ke tombol pertama', () {
    fakeAsync((FakeAsync async) {
      final ScanningService service = ScanningService();
      service.registerTargets(
        targets: <ScanTarget>[
          ScanTarget(id: 'a', onActivate: () async => null),
          ScanTarget(id: 'b', onActivate: () async => null),
        ],
        enabled: true,
        interval: const Duration(seconds: 2),
      );

      expect(service.currentItemId, 'a');

      async.elapse(const Duration(seconds: 2));
      expect(service.currentItemId, 'b');

      service.resetToFirst();
      expect(service.currentItemId, 'a');
    });
  });
}
