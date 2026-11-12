import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../utils/app_constants.dart';

class SapaPageScaffold extends StatelessWidget {
  const SapaPageScaffold({
    super.key,
    required this.title,
    required this.child,
    this.footer,
  });

  final String title;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const _CaregiverAccessButton(),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: child,
              ),
            ),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                child: footer,
              ),
          ],
        ),
      ),
    );
  }
}

class _CaregiverAccessButton extends StatefulWidget {
  const _CaregiverAccessButton();

  @override
  State<_CaregiverAccessButton> createState() => _CaregiverAccessButtonState();
}

class _CaregiverAccessButtonState extends State<_CaregiverAccessButton> {
  Timer? _holdTimer;
  bool _holding = false;

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Tombol buka menu pendamping dengan tekan lama.',
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _holding = true);
          _holdTimer?.cancel();
          _holdTimer = Timer(const Duration(seconds: 3), () async {
            setState(() => _holding = false);
            await _openCaregiverSettings(context);
          });
        },
        onTapUp: (_) => _cancelHold(),
        onTapCancel: _cancelHold,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: _holding
                ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.settings_rounded, size: 28),
              SizedBox(width: 10),
              Text(
                'Pendamping\nTahan 3 dtk',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _cancelHold() {
    _holdTimer?.cancel();
    if (_holding) {
      setState(() => _holding = false);
    }
  }

  Future<void> _openCaregiverSettings(BuildContext context) async {
    final String? currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == AppConstants.routeSettings) {
      return;
    }

    final SettingsProvider settings = context.read<SettingsProvider>();
    final TextEditingController controller = TextEditingController();

    final bool? allowed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Masukkan PIN Pendamping'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'PIN',
              hintText: '1234',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(
                controller.text.trim() == settings.pin,
              ),
              child: const Text('Buka'),
            ),
          ],
        );
      },
    );

    if (!context.mounted) {
      return;
    }

    if (allowed == true) {
      Navigator.of(context).pushNamed(AppConstants.routeSettings);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PIN salah atau akses dibatalkan.'),
      ),
    );
  }
}
