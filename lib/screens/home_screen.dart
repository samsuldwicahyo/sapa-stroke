import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/communication_item.dart';
import '../providers/communication_provider.dart';
import '../providers/settings_provider.dart';
import '../services/scanning_service.dart';
import '../utils/app_constants.dart';
import '../widgets/emergency_button.dart';
import '../widgets/large_communication_button.dart';
import '../widgets/sapa_page_scaffold.dart';
import '../widgets/yes_no_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _favoritePage = 0;
  int _needsPage = 0;
  bool _didGreeting = false;

  @override
  void dispose() {
    context.read<CommunicationProvider>().clearScanningTargets();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SettingsProvider settings = context.watch<SettingsProvider>();
    final CommunicationProvider communication =
        context.watch<CommunicationProvider>();

    final List<CommunicationItem> favorites = communication.favoriteItems;
    final List<CommunicationItem> needs = communication.needItems;
    final List<CommunicationItem> responses = communication.responseItems;
    final int itemsPerPage = settings.buttonsPerPage;
    final double textScale = settings.textScale;
    final List<ScanTarget> scanTargets = <ScanTarget>[];

    _maybeSpeakGreeting(communication);

    final List<CommunicationItem> visibleFavorites =
        _visibleItems(favorites, _favoritePage, itemsPerPage);
    final List<CommunicationItem> visibleNeeds =
        _visibleItems(needs, _needsPage, itemsPerPage);

    final Widget content = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: settings.autoScanEnabled
          ? () => _activateCurrentScanTarget(communication)
          : null,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildSection(
              context: context,
              title: 'TOMBOL FAVORIT',
              items: visibleFavorites,
              pageIndex: _favoritePage,
              pageCount: _pageCount(favorites, itemsPerPage),
              onPageChanged: (int index) {
                setState(() => _favoritePage = index);
              },
              sectionId: 'favorite',
              communication: communication,
              textScale: textScale,
              scanTargets: scanTargets,
            ),
            const SizedBox(height: 18),
            _buildSection(
              context: context,
              title: 'KEBUTUHAN UTAMA',
              items: visibleNeeds,
              pageIndex: _needsPage,
              pageCount: _pageCount(needs, itemsPerPage),
              onPageChanged: (int index) {
                setState(() => _needsPage = index);
              },
              sectionId: 'needs',
              communication: communication,
              textScale: textScale,
              scanTargets: scanTargets,
            ),
            const SizedBox(height: 18),
            Text(
              'NAVIGASI UTAMA',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 2.6,
              mainAxisSpacing: 18,
              crossAxisSpacing: 18,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                LargeCommunicationButton(
                  title: 'KELUARGA DAN SAPAAN',
                  icon: Icons.family_restroom_rounded,
                  color: const Color(0xFF6B3FA0),
                  semanticLabel: 'Tombol keluarga dan sapaan.',
                  isHighlighted:
                      communication.currentScanId == 'nav_family_screen',
                  textScale: textScale,
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppConstants.routeFamily);
                  },
                ),
                LargeCommunicationButton(
                  title: 'PERASAAN',
                  icon: Icons.emoji_emotions_rounded,
                  color: const Color(0xFFBC6B00),
                  semanticLabel: 'Tombol perasaan.',
                  isHighlighted:
                      communication.currentScanId == 'nav_emotion_screen',
                  textScale: textScale,
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppConstants.routeEmotion);
                  },
                ),
                LargeCommunicationButton(
                  title: 'KEBUTUHAN LAINNYA',
                  icon: Icons.widgets_rounded,
                  color: const Color(0xFF146C6C),
                  semanticLabel: 'Tombol kebutuhan lainnya.',
                  isHighlighted:
                      communication.currentScanId == 'nav_other_needs_screen',
                  textScale: textScale,
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(AppConstants.routeOtherNeeds);
                  },
                ),
                LargeCommunicationButton(
                  title: 'KETAWA',
                  icon: Icons.mood_rounded,
                  color: const Color(0xFF146C6C),
                  semanticLabel: 'Tombol suara ketawa.',
                  isHighlighted: communication.currentScanId ==
                      AppConstants.laughItemId,
                  isPressed:
                      communication.pressedItemId == AppConstants.laughItemId,
                  textScale: textScale,
                  onPressed: () async {
                    final String? message = await communication.playLaugh();
                    _showMessage(message);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );

    _registerScanTargets(
      communication,
      settings,
      responses,
      scanTargets,
    );

    return SapaPageScaffold(
      title: 'BERANDA',
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          YesNoPanel(
            items: responses,
            currentScanId: communication.currentScanId,
            pressedItemId: communication.pressedItemId,
            textScale: textScale,
            onPressed: (CommunicationItem item) async {
              final String? message = await communication.triggerItem(item);
              _showMessage(message);
            },
          ),
          EmergencyButton(
            isArmed: communication.emergencyArmed,
            isHighlighted:
                communication.currentScanId == AppConstants.emergencyActionId,
            isPressed:
                communication.pressedItemId == AppConstants.emergencyActionId,
            textScale: textScale,
            onPressed: () => _handleEmergencyPress(communication),
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: FractionallySizedBox(
          widthFactor: settings.handPreference == HandPreference.left ? 0.76 : 0.92,
          child: content,
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<CommunicationItem> items,
    required int pageIndex,
    required int pageCount,
    required ValueChanged<int> onPageChanged,
    required String sectionId,
    required CommunicationProvider communication,
    required double textScale,
    required List<ScanTarget> scanTargets,
  }) {
    for (final CommunicationItem item in items) {
      scanTargets.add(
        ScanTarget(
          id: item.id,
          onActivate: () => communication.triggerItem(item),
        ),
      );
    }

    if (pageCount > 1 && pageIndex > 0) {
      scanTargets.add(
        ScanTarget(
          id: '${sectionId}_prev',
          onActivate: () async {
            setState(() => onPageChanged(pageIndex - 1));
            return null;
          },
        ),
      );
    }

    if (pageCount > 1 && pageIndex < pageCount - 1) {
      scanTargets.add(
        ScanTarget(
          id: '${sectionId}_next',
          onActivate: () async {
            setState(() => onPageChanged(pageIndex + 1));
            return null;
          },
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 2.6,
            mainAxisSpacing: 18,
            crossAxisSpacing: 18,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: items
                .map(
                  (CommunicationItem item) => LargeCommunicationButton(
                    title: item.title,
                    icon: item.icon,
                    color: item.color,
                    semanticLabel:
                        item.semanticLabel ?? 'Tombol ${item.title}.',
                    isHighlighted: communication.currentScanId == item.id,
                    isPressed: communication.pressedItemId == item.id,
                    textScale: textScale,
                    onPressed: () async {
                      final String? message =
                          await communication.triggerItem(item);
                      _showMessage(message);
                    },
                  ),
                )
                .toList(growable: false),
          ),
          if (pageCount > 1) ...<Widget>[
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: LargeCommunicationButton(
                    title: 'SEBELUMNYA',
                    icon: Icons.arrow_back_rounded,
                    color: const Color(0xFF415A77),
                    semanticLabel: 'Tombol halaman sebelumnya.',
                    textScale: 0.9,
                    isHighlighted:
                        communication.currentScanId == '${sectionId}_prev',
                    onPressed: pageIndex > 0
                        ? () => setState(() => onPageChanged(pageIndex - 1))
                        : null,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: LargeCommunicationButton(
                    title: 'BERIKUTNYA',
                    icon: Icons.arrow_forward_rounded,
                    color: const Color(0xFF415A77),
                    semanticLabel: 'Tombol halaman berikutnya.',
                    textScale: 0.9,
                    isHighlighted:
                        communication.currentScanId == '${sectionId}_next',
                    onPressed: pageIndex < pageCount - 1
                        ? () => setState(() => onPageChanged(pageIndex + 1))
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _registerScanTargets(
    CommunicationProvider communication,
    SettingsProvider settings,
    List<CommunicationItem> responses,
    List<ScanTarget> baseTargets,
  ) {
    final List<ScanTarget> targets = <ScanTarget>[
      ...baseTargets,
      ScanTarget(
        id: 'nav_family_screen',
        onActivate: () async {
          if (!mounted) {
            return null;
          }
          Navigator.of(context).pushNamed(AppConstants.routeFamily);
          return null;
        },
      ),
      ScanTarget(
        id: 'nav_emotion_screen',
        onActivate: () async {
          if (!mounted) {
            return null;
          }
          Navigator.of(context).pushNamed(AppConstants.routeEmotion);
          return null;
        },
      ),
      ScanTarget(
        id: 'nav_other_needs_screen',
        onActivate: () async {
          if (!mounted) {
            return null;
          }
          Navigator.of(context).pushNamed(AppConstants.routeOtherNeeds);
          return null;
        },
      ),
      ScanTarget(
        id: AppConstants.laughItemId,
        onActivate: communication.playLaugh,
      ),
      ...responses.map(
        (CommunicationItem item) => ScanTarget(
          id: item.id,
          onActivate: () => communication.triggerItem(item),
        ),
      ),
      ScanTarget(
        id: AppConstants.emergencyActionId,
        onActivate: () async {
          await _handleEmergencyPress(communication);
          return null;
        },
      ),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      communication.registerScanningTargets(targets);
    });
  }

  Future<void> _handleEmergencyPress(CommunicationProvider communication) async {
    final bool activated = await communication.triggerEmergencyArm();
    if (!mounted) {
      return;
    }

    if (activated) {
      Navigator.of(context).pushNamed(AppConstants.routeEmergency);
    }
  }

  Future<void> _activateCurrentScanTarget(
    CommunicationProvider communication,
  ) async {
    final String? message = await communication.activateCurrentScanTarget();
    _showMessage(message);
  }

  void _maybeSpeakGreeting(CommunicationProvider communication) {
    if (_didGreeting) {
      return;
    }

    _didGreeting = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      final String? message = await communication.speakOpeningGreeting();
      _showMessage(message);
    });
  }

  int _pageCount(List<CommunicationItem> items, int pageSize) {
    if (items.isEmpty) {
      return 1;
    }
    return (items.length / pageSize).ceil();
  }

  List<CommunicationItem> _visibleItems(
    List<CommunicationItem> items,
    int page,
    int pageSize,
  ) {
    if (items.isEmpty) {
      return const <CommunicationItem>[];
    }

    final int safePage = page.clamp(0, _pageCount(items, pageSize) - 1);
    final int start = safePage * pageSize;
    final int end = (start + pageSize).clamp(0, items.length);
    return items.sublist(start, end);
  }

  void _showMessage(String? message) {
    if (!mounted || message == null || message.isEmpty) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
