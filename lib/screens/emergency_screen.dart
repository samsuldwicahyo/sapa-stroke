import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/communication_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/large_communication_button.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CommunicationProvider communication =
        context.watch<CommunicationProvider>();
    final SettingsProvider settings = context.watch<SettingsProvider>();

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context),
          child: Scaffold(
            backgroundColor: Color.lerp(
              AppColors.emergencyRed,
              const Color(0xFFCC3B30),
              _controller.value,
            ),
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 24),
                  Text(
                    'DARURAT',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.white,
                              size: 82,
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Tolong datang sekarang.\nSaya membutuhkan bantuan segera.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    height: 1.2,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: LargeCommunicationButton(
                      title: 'HENTIKAN ALARM',
                      icon: Icons.stop_circle_rounded,
                      color: Colors.white,
                      semanticLabel: 'Tombol hentikan alarm darurat.',
                      textScale: settings.textScale,
                      onPressed: () async {
                        await communication.stopEmergency();
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.of(context).popUntil(
                          (Route<dynamic> route) =>
                              route.settings.name == AppConstants.routeHome ||
                              route.isFirst,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
