import 'package:flutter/material.dart';

import '../models/communication_item.dart';
import 'large_communication_button.dart';

class YesNoPanel extends StatelessWidget {
  const YesNoPanel({
    super.key,
    required this.items,
    required this.currentScanId,
    required this.pressedItemId,
    required this.textScale,
    required this.onPressed,
  });

  final List<CommunicationItem> items;
  final String? currentScanId;
  final String? pressedItemId;
  final double textScale;
  final ValueChanged<CommunicationItem> onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 12, 0, 12),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 2.8,
        children: items
            .map(
              (CommunicationItem item) => LargeCommunicationButton(
                title: item.title,
                icon: item.icon,
                color: item.color,
                textScale: textScale,
                semanticLabel: item.semanticLabel ?? 'Tombol ${item.title}.',
                isHighlighted: currentScanId == item.id,
                isPressed: pressedItemId == item.id,
                onPressed: () => onPressed(item),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}
