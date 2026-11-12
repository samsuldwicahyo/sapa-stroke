import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'large_communication_button.dart';

class EmergencyButton extends StatelessWidget {
  const EmergencyButton({
    super.key,
    required this.isArmed,
    required this.isHighlighted,
    required this.isPressed,
    required this.textScale,
    required this.onPressed,
  });

  final bool isArmed;
  final bool isHighlighted;
  final bool isPressed;
  final double textScale;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (isArmed)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'TEKAN SEKALI LAGI UNTUK MEMANGGIL.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.emergencyRed,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
        LargeCommunicationButton(
          title: 'DARURAT — PANGGIL SEKARANG',
          icon: Icons.warning_rounded,
          color: AppColors.emergencyRed,
          semanticLabel: 'Tombol darurat panggil sekarang.',
          isHighlighted: isHighlighted,
          isPressed: isPressed,
          textScale: textScale,
          onPressed: onPressed,
        ),
      ],
    );
  }
}
