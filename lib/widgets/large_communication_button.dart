import 'package:flutter/material.dart';

import 'scanning_highlight.dart';

class LargeCommunicationButton extends StatelessWidget {
  const LargeCommunicationButton({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.semanticLabel,
    this.isHighlighted = false,
    this.isPressed = false,
    this.textScale = 1.0,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final bool isHighlighted;
  final bool isPressed;
  final double textScale;

  @override
  Widget build(BuildContext context) {
    final Color foreground = ThemeData.estimateBrightnessForColor(color) ==
            Brightness.dark
        ? Colors.white
        : Colors.black;

    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: ScanningHighlight(
        isHighlighted: isHighlighted,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 140),
          scale: isPressed ? 0.97 : 1,
          child: Material(
            color: color,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: onPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 128,
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        icon,
                        size: 38,
                        color: foreground,
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Text(
                          title,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: foreground,
                            fontSize: 30 * textScale,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
