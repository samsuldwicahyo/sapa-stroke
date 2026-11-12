import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/communication_item.dart';
import '../models/family_member.dart';
import '../providers/communication_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_constants.dart';
import '../widgets/large_communication_button.dart';
import '../widgets/sapa_page_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final SettingsProvider settings = context.watch<SettingsProvider>();
    final CommunicationProvider communication =
        context.watch<CommunicationProvider>();
    final List<CommunicationItem> favoriteItems = settings.favoriteOrder
        .map(communication.findItemById)
        .whereType<CommunicationItem>()
        .toList(growable: false);

    return SapaPageScaffold(
      title: 'PENGATURAN PENDAMPING',
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
          child: ListView(
            children: <Widget>[
              _sectionCard(
                context: context,
                title: 'Identitas dan Keluarga',
                children: <Widget>[
                  _editableTile(
                    context: context,
                    title: 'Nama pasien',
                    value: settings.patientName,
                    onEdit: () => _editSimpleValue(
                      title: 'Nama pasien',
                      initialValue: settings.patientName,
                      onSave: settings.updatePatientName,
                    ),
                  ),
                  _editableTile(
                    context: context,
                    title: 'Nama keluarga 1',
                    value: settings.primaryFamilyName,
                    onEdit: () => _editSimpleValue(
                      title: 'Nama keluarga 1',
                      initialValue: settings.primaryFamilyName,
                      onSave: settings.updatePrimaryFamilyName,
                    ),
                  ),
                  _editableTile(
                    context: context,
                    title: 'Nama keluarga 2',
                    value: settings.secondaryFamilyName,
                    onEdit: () => _editSimpleValue(
                      title: 'Nama keluarga 2',
                      initialValue: settings.secondaryFamilyName,
                      onSave: settings.updateSecondaryFamilyName,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _addFamilyMember,
                    icon: const Icon(Icons.person_add_alt_rounded),
                    label: const Text('Tambah keluarga lain'),
                  ),
                  const SizedBox(height: 12),
                  if (settings.additionalFamilyMembers.isEmpty)
                    const Text('Belum ada keluarga tambahan.')
                  else
                    ...settings.additionalFamilyMembers.map(
                      (FamilyMember member) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(member.name),
                        subtitle: const Text('Otomatis dibuat: Panggil, Halo, Terima kasih'),
                        trailing: Wrap(
                          spacing: 8,
                          children: <Widget>[
                            IconButton(
                              onPressed: () => _editFamilyMember(member),
                              icon: const Icon(Icons.edit_rounded),
                            ),
                            IconButton(
                              onPressed: () => settings.removeFamilyMember(member.id),
                              icon: const Icon(Icons.delete_outline_rounded),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              _sectionCard(
                context: context,
                title: 'Kalimat Tombol',
                children: <Widget>[
                  Text(
                    'Ubah kalimat yang dibacakan tanpa mengubah struktur tombol.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  ...communication.editableItems.map(
                    (CommunicationItem item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.title),
                      subtitle: Text(item.spokenText),
                      trailing: Wrap(
                        spacing: 8,
                        children: <Widget>[
                          IconButton(
                            onPressed: () => _editButtonText(item),
                            icon: const Icon(Icons.edit_rounded),
                          ),
                          if (settings.buttonTextOverrides.containsKey(item.id))
                            IconButton(
                              onPressed: () => settings.removeButtonTextOverride(item.id),
                              icon: const Icon(Icons.restore_rounded),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              _sectionCard(
                context: context,
                title: 'Tombol Custom',
                children: <Widget>[
                  FilledButton.icon(
                    onPressed: _addCustomButton,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: const Text('Tambah tombol custom'),
                  ),
                  const SizedBox(height: 10),
                  if (settings.customItems.isEmpty)
                    const Text('Belum ada tombol custom.')
                  else
                    ...settings.customItems.map(
                      (CommunicationItem item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.title),
                        subtitle: Text(item.spokenText),
                        trailing: Wrap(
                          spacing: 8,
                          children: <Widget>[
                            IconButton(
                              onPressed: () => _editCustomButton(item),
                              icon: const Icon(Icons.edit_rounded),
                            ),
                            IconButton(
                              onPressed: () => settings.removeCustomItem(item.id),
                              icon: const Icon(Icons.delete_outline_rounded),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              _sectionCard(
                context: context,
                title: 'Suara dan Getaran',
                children: <Widget>[
                  _sliderTile(
                    context: context,
                    label: 'Kecepatan suara',
                    valueLabel: settings.speechRate.toStringAsFixed(2),
                    value: settings.speechRate,
                    min: 0.30,
                    max: 0.65,
                    onChanged: settings.setSpeechRate,
                  ),
                  _sliderTile(
                    context: context,
                    label: 'Volume suara',
                    valueLabel: '${(settings.voiceVolume * 100).round()}%',
                    value: settings.voiceVolume,
                    min: 0.2,
                    max: 1.0,
                    onChanged: settings.setVoiceVolume,
                  ),
                  _sliderTile(
                    context: context,
                    label: 'Nada suara',
                    valueLabel: settings.pitch.toStringAsFixed(2),
                    value: settings.pitch,
                    min: 0.7,
                    max: 1.3,
                    onChanged: settings.setPitch,
                  ),
                  _sliderTile(
                    context: context,
                    label: 'Volume ketawa',
                    valueLabel: '${(settings.laughVolume * 100).round()}%',
                    value: settings.laughVolume,
                    min: 0.2,
                    max: 1.0,
                    onChanged: settings.setLaughVolume,
                  ),
                  SwitchListTile(
                    value: settings.vibrationEnabled,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Aktifkan getaran'),
                    onChanged: settings.setVibrationEnabled,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final String? message = await communication.testVoice();
                        _showMessage(
                          message ?? 'Suara SAPA Stroke berhasil diuji.',
                        );
                      },
                      icon: const Icon(Icons.volume_up_rounded),
                      label: const Text('Uji suara'),
                    ),
                  ),
                ],
              ),
              _sectionCard(
                context: context,
                title: 'Tata Letak dan Akses',
                children: <Widget>[
                  SwitchListTile(
                    value: settings.openingGreetingEnabled,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Sapaan pembuka'),
                    onChanged: settings.setOpeningGreetingEnabled,
                  ),
                  SwitchListTile(
                    value: settings.handPreference == HandPreference.left,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Mode tangan kiri'),
                    onChanged: settings.setModeTanganKiri,
                  ),
                  SwitchListTile(
                    value: settings.autoScanEnabled,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Mode pilih otomatis'),
                    onChanged: settings.setAutoScanEnabled,
                  ),
                  if (settings.autoScanEnabled)
                    DropdownButtonFormField<int>(
                      value: settings.scanIntervalSeconds,
                      decoration: const InputDecoration(
                        labelText: 'Interval pemindaian',
                      ),
                      items: AppConstants.scanIntervalOptions
                          .map(
                            (int value) => DropdownMenuItem<int>(
                              value: value,
                              child: Text('$value detik'),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (int? value) {
                        if (value != null) {
                          settings.setScanIntervalSeconds(value);
                        }
                      },
                    ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: settings.buttonsPerPage,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah tombol per halaman',
                    ),
                    items: AppConstants.buttonsPerPageOptions
                        .map(
                          (int value) => DropdownMenuItem<int>(
                            value: value,
                            child: Text('$value tombol'),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (int? value) {
                      if (value != null) {
                        settings.setButtonsPerPage(value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<double>(
                    value: settings.textScale,
                    decoration: const InputDecoration(
                      labelText: 'Ukuran tulisan',
                    ),
                    items: AppConstants.textScaleOptions
                        .map(
                          (double value) => DropdownMenuItem<double>(
                            value: value,
                            child: Text('${(value * 100).round()}%'),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (double? value) {
                      if (value != null) {
                        settings.setTextScale(value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: settings.alwaysOn,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Layar selalu menyala'),
                    onChanged: settings.setAlwaysOn,
                  ),
                  SwitchListTile(
                    value: settings.darkMode,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Mode gelap'),
                    onChanged: settings.setDarkMode,
                  ),
                ],
              ),
              _sectionCard(
                context: context,
                title: 'Favorit',
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed: _manageFavorites,
                    icon: const Icon(Icons.star_rounded),
                    label: const Text('Kelola tombol favorit'),
                  ),
                  const SizedBox(height: 10),
                  if (favoriteItems.isEmpty)
                    const Text('Belum ada tombol favorit.')
                  else
                    ...favoriteItems.asMap().entries.map(
                      (MapEntry<int, CommunicationItem> entry) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(entry.value.title),
                        subtitle: Text(entry.value.spokenText),
                        trailing: Wrap(
                          spacing: 4,
                          children: <Widget>[
                            IconButton(
                              onPressed: entry.key > 0
                                  ? () => _moveFavorite(entry.key, -1, favoriteItems)
                                  : null,
                              icon: const Icon(Icons.arrow_upward_rounded),
                            ),
                            IconButton(
                              onPressed: entry.key < favoriteItems.length - 1
                                  ? () => _moveFavorite(entry.key, 1, favoriteItems)
                                  : null,
                              icon: const Icon(Icons.arrow_downward_rounded),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              _sectionCard(
                context: context,
                title: 'Riwayat dan Darurat',
                children: <Widget>[
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: <Widget>[
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppConstants.routeHistory);
                        },
                        icon: const Icon(Icons.history_rounded),
                        label: const Text('Lihat riwayat'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final bool confirmed = await _confirmAction(
                            title: 'Hapus riwayat',
                            message: 'Hapus seluruh riwayat penggunaan tombol?',
                          );
                          if (confirmed) {
                            await communication.clearHistory();
                            _showMessage('Riwayat berhasil dihapus.');
                          }
                        },
                        icon: const Icon(Icons.delete_sweep_rounded),
                        label: const Text('Hapus riwayat'),
                      ),
                      if (communication.emergencyActive)
                        FilledButton.icon(
                          onPressed: () async {
                            await communication.stopEmergency();
                            _showMessage('Alarm darurat dihentikan.');
                          },
                          icon: const Icon(Icons.stop_circle_rounded),
                          label: const Text('Hentikan alarm darurat'),
                        ),
                    ],
                  ),
                ],
              ),
              _sectionCard(
                context: context,
                title: 'Keamanan',
                children: <Widget>[
                  _editableTile(
                    context: context,
                    title: 'PIN pendamping',
                    value: '••••',
                    onEdit: _changePin,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _editableTile({
    required BuildContext context,
    required String title,
    required String value,
    required VoidCallback onEdit,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(value),
      trailing: IconButton(
        onPressed: onEdit,
        icon: const Icon(Icons.edit_rounded),
      ),
    );
  }

  Widget _sliderTile({
    required BuildContext context,
    required String label,
    required String valueLabel,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$label: $valueLabel',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Future<void> _editSimpleValue({
    required String title,
    required String initialValue,
    required Future<void> Function(String value) onSave,
  }) async {
    final TextEditingController controller =
        TextEditingController(text: initialValue);
    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: title),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (saved == true) {
      await onSave(controller.text);
    }
  }

  Future<void> _editButtonText(CommunicationItem item) async {
    final SettingsProvider settings = context.read<SettingsProvider>();
    final TextEditingController controller =
        TextEditingController(text: item.spokenText);

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(item.title),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Kalimat yang dibacakan',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (saved == true) {
      await settings.setButtonTextOverride(item.id, controller.text);
    }
  }

  Future<void> _addFamilyMember() async {
    final SettingsProvider settings = context.read<SettingsProvider>();
    final TextEditingController controller = TextEditingController();
    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Tambah keluarga lain'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nama keluarga',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );

    if (saved == true) {
      await settings.addFamilyMember(controller.text);
    }
  }

  Future<void> _editFamilyMember(FamilyMember member) async {
    final SettingsProvider settings = context.read<SettingsProvider>();
    await _editSimpleValue(
      title: 'Ubah nama keluarga',
      initialValue: member.name,
      onSave: (String value) => settings.updateFamilyMember(member.id, value),
    );
  }

  Future<void> _addCustomButton() async {
    final SettingsProvider settings = context.read<SettingsProvider>();
    final TextEditingController titleController = TextEditingController();
    final TextEditingController spokenController = TextEditingController();
    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Tambah tombol custom'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul tombol',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: spokenController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Kalimat yang dibacakan',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );

    if (saved == true) {
      await settings.addCustomItem(
        title: titleController.text,
        spokenText: spokenController.text,
      );
    }
  }

  Future<void> _editCustomButton(CommunicationItem item) async {
    final SettingsProvider settings = context.read<SettingsProvider>();
    final TextEditingController titleController =
        TextEditingController(text: item.title);
    final TextEditingController spokenController =
        TextEditingController(text: item.spokenText);
    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Ubah tombol custom'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul tombol',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: spokenController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Kalimat yang dibacakan',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (saved == true) {
      await settings.updateCustomItem(
        id: item.id,
        title: titleController.text,
        spokenText: spokenController.text,
      );
    }
  }

  Future<void> _manageFavorites() async {
    final SettingsProvider settings = context.read<SettingsProvider>();
    final CommunicationProvider communication = context.read<CommunicationProvider>();
    final List<String> selected = List<String>.from(settings.favoriteOrder);
    final List<CommunicationItem> candidates = communication.allItems;

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Kelola tombol favorit'),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: candidates
                        .map(
                          (CommunicationItem item) => CheckboxListTile(
                            value: selected.contains(item.id),
                            title: Text(item.title),
                            subtitle: Text(item.spokenText),
                            onChanged: (bool? checked) {
                              setState(() {
                                if (checked ?? false) {
                                  if (!selected.contains(item.id)) {
                                    selected.add(item.id);
                                  }
                                } else {
                                  selected.remove(item.id);
                                }
                              });
                            },
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved == true) {
      await settings.reorderFavorites(selected);
    }
  }

  Future<void> _moveFavorite(
    int index,
    int direction,
    List<CommunicationItem> items,
  ) async {
    final SettingsProvider settings = context.read<SettingsProvider>();
    final List<String> order = items.map((CommunicationItem item) => item.id).toList();
    final int target = index + direction;
    final String moved = order.removeAt(index);
    order.insert(target, moved);
    await settings.reorderFavorites(order);
  }

  Future<void> _changePin() async {
    final SettingsProvider settings = context.read<SettingsProvider>();
    final TextEditingController controller =
        TextEditingController(text: settings.pin);
    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Ubah PIN'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'PIN baru',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (saved == true && controller.text.trim().isNotEmpty) {
      await settings.setPin(controller.text);
      _showMessage('PIN pendamping berhasil diperbarui.');
    }
  }

  Future<bool> _confirmAction({
    required String title,
    required String message,
  }) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Lanjutkan'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
