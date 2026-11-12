import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/communication_history.dart';
import '../providers/communication_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_constants.dart';
import '../widgets/large_communication_button.dart';
import '../widgets/sapa_page_scaffold.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CommunicationProvider communication =
        context.watch<CommunicationProvider>();
    final SettingsProvider settings = context.watch<SettingsProvider>();

    return SapaPageScaffold(
      title: 'RIWAYAT PENGGUNAAN',
      footer: SizedBox(
        width: 360,
        child: LargeCommunicationButton(
          title: 'KEMBALI KE BERANDA',
          icon: Icons.home_rounded,
          color: const Color(0xFF415A77),
          semanticLabel: 'Tombol kembali ke beranda.',
          textScale: settings.textScale,
          onPressed: () {
            Navigator.of(context).popUntil(
              (Route<dynamic> route) =>
                  route.settings.name == AppConstants.routeHome || route.isFirst,
            );
          },
        ),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: FractionallySizedBox(
          widthFactor: 0.88,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  FilledButton.icon(
                    onPressed: () async {
                      await communication.clearHistory();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Riwayat berhasil dihapus.'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.delete_sweep_rounded),
                    label: const Text('Hapus seluruh riwayat'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: communication.history.isEmpty
                    ? const Center(
                        child: Text('Belum ada riwayat penggunaan tombol.'),
                      )
                    : ListView.separated(
                        itemCount: communication.history.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (BuildContext context, int index) {
                          final CommunicationHistory item =
                              communication.history[index];
                          return Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  item.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 8),
                                Text(item.spokenText),
                                const SizedBox(height: 8),
                                Text(
                                  AppConstants.formatHistoryTimestamp(
                                    item.timestamp,
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
