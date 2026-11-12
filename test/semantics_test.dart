import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sapa_stroke/widgets/large_communication_button.dart';

void main() {
  testWidgets('large communication button memiliki label semantics', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LargeCommunicationButton(
            title: 'PANGGIL PENDAMPING',
            icon: Icons.notifications_active_rounded,
            color: Colors.blue,
            semanticLabel: 'Tombol panggil pendamping.',
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.byType(LargeCommunicationButton)),
      matchesSemantics(
        label: 'Tombol panggil pendamping.',
        isButton: true,
      ),
    );

    handle.dispose();
  });
}
