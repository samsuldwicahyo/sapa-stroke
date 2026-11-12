import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class ScanningHighlight extends StatelessWidget {
  const ScanningHighlight({
    super.key,
    required this.isHighlighted,
    required this.child,
  });

  final bool isHighlighted;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isHighlighted ? AppColors.highlightYellow : Colors.transparent,
          width: isHighlighted ? 6 : 0,
        ),
        boxShadow: isHighlighted
            ? const <BoxShadow>[
                BoxShadow(
                  color: Color(0x55F4D03F),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ]
            : const <BoxShadow>[],
      ),
      child: child,
    );
  }
}
