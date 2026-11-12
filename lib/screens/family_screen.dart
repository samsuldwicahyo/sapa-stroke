import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/communication_item.dart';
import '../providers/communication_provider.dart';
import '../providers/settings_provider.dart';
import '../services/scanning_service.dart';
import '../utils/app_constants.dart';
import '../widgets/large_communication_button.dart';
import '../widgets/sapa_page_scaffold.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  int _page = 0;

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
    final List<CommunicationItem> allItems = communication.familyItems;
    final List<CommunicationItem> visibleItems =
        _visibleItems(allItems, _page, settings.buttonsPerPage);
    final int pageCount = _pageCount(allItems, settings.buttonsPerPage);
    final List<ScanTarget> scanTargets = <ScanTarget>[
      ...visibleItems.map(
        (CommunicationItem item) => ScanTarget(
          id: item.id,
          onActivate: () => communication.triggerItem(item),
        ),
      ),
      if (_page > 0)
        ScanTarget(
          id: 'family_prev',
          onActivate: () async {
            setState(() => _page -= 1);
            return null;
          },
        ),
      if (_page < pageCount - 1)
        ScanTarget(
          id: 'family_next',
          onActivate: () async {
            setState(() => _page += 1);
            return null;
          },
        ),
      ScanTarget(
        id: 'back_home_family',
        onActivate: () async {
          if (mounted) {
            Navigator.of(context).popUntil(
              (Route<dynamic> route) => route.settings.name == AppConstants.routeHome || route.isFirst,
            );
          }
          return null;
        },
      ),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      communication.registerScanningTargets(scanTargets);
    });

    return SapaPageScaffold(
      title: 'KELUARGA DAN SAPAAN',
      footer: _buildHomeButton(
        context,
        settings.textScale,
        communication.currentScanId == 'back_home_family',
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: FractionallySizedBox(
          widthFactor: settings.handPreference == HandPreference.left ? 0.76 : 0.92,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: settings.autoScanEnabled
                ? () async {
                    final String? message =
                        await communication.activateCurrentScanTarget();
                    _showMessage(message);
                  }
                : null,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 2.6,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: visibleItems
                        .map(
                          (CommunicationItem item) => LargeCommunicationButton(
                            title: item.title,
                            icon: item.icon,
                            color: item.color,
                            textScale: settings.textScale,
                            semanticLabel:
                                item.semanticLabel ?? 'Tombol ${item.title}.',
                            isHighlighted: communication.currentScanId == item.id,
                            isPressed: communication.pressedItemId == item.id,
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
                    const SizedBox(height: 18),
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
                                communication.currentScanId == 'family_prev',
                            onPressed: _page > 0
                                ? () => setState(() => _page -= 1)
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
                                communication.currentScanId == 'family_next',
                            onPressed: _page < pageCount - 1
                                ? () => setState(() => _page += 1)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeButton(
    BuildContext context,
    double textScale,
    bool highlighted,
  ) {
    return SizedBox(
      width: 360,
      child: LargeCommunicationButton(
        title: 'KEMBALI KE BERANDA',
        icon: Icons.home_rounded,
        color: const Color(0xFF415A77),
        semanticLabel: 'Tombol kembali ke beranda.',
        isHighlighted: highlighted,
        textScale: textScale,
        onPressed: () {
          Navigator.of(context).popUntil(
            (Route<dynamic> route) =>
                route.settings.name == AppConstants.routeHome || route.isFirst,
          );
        },
      ),
    );
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
