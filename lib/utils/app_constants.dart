import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/communication_item.dart';
import '../models/family_member.dart';
import 'app_colors.dart';

enum HandPreference {
  left,
  center,
  right,
}

class AppConstants {
  static const String appName = 'SAPA Stroke';
  static const String appSubtitle = 'Sarana Komunikasi Pasien Stroke';

  static const String routeHome = '/home';
  static const String routeFamily = '/family';
  static const String routeEmotion = '/emotion';
  static const String routeOtherNeeds = '/other-needs';
  static const String routeEmergency = '/emergency';
  static const String routeSettings = '/settings';
  static const String routeHistory = '/history';

  static const Duration splashDelay = Duration(seconds: 2);
  static const Duration buttonDebounce = Duration(milliseconds: 700);
  static const Duration buttonPressedFeedback = Duration(milliseconds: 220);
  static const Duration emergencyWindow = Duration(seconds: 5);

  static const String ttsLocale = 'id-ID';
  static const String ttsUnavailableMessage =
      'Suara bahasa Indonesia belum tersedia. Silakan aktifkan atau unduh '
      'suara bahasa Indonesia pada pengaturan perangkat.';

  static const String defaultPatientName = 'Pasien';
  static const String defaultPrimaryFamilyName = 'Keluarga 1';
  static const String defaultSecondaryFamilyName = 'Keluarga 2';
  static const String defaultPin =
      String.fromEnvironment('SAPA_DEMO_PIN', defaultValue: '0000');
  static const double defaultSpeechRate = 0.48;
  static const double defaultSpeechVolume = 1.0;
  static const double defaultPitch = 1.0;
  static const double defaultLaughVolume = 1.0;
  static const double defaultTextScale = 1.0;
  static const int defaultButtonsPerPage = 6;
  static const int defaultScanIntervalSeconds = 3;

  static const List<int> scanIntervalOptions = <int>[2, 3, 4, 5];
  static const List<int> buttonsPerPageOptions = <int>[4, 6, 8];
  static const List<double> textScaleOptions = <double>[0.95, 1.0, 1.15, 1.3];

  static const String categoryNeeds = 'needs';
  static const String categoryResponse = 'response';
  static const String categoryFamily = 'family';
  static const String categoryEmotion = 'emotion';
  static const String categoryOther = 'other';
  static const String categoryCustom = 'custom';

  static const String laughAudioShort = 'assets/audio/laugh_short.mp3';
  static const String laughAudioSoft = 'assets/audio/laugh_soft.mp3';
  static const String laughAudioHappy = 'assets/audio/laugh_happy.mp3';
  static const String emergencyAlarmAudio = 'assets/audio/emergency_alarm.mp3';

  static const String laughItemId = 'other_laugh';
  static const String emergencyActionId = 'emergency_call_now';

  static const List<String> defaultFavoriteIds = <String>[
    'need_call_caregiver',
    'response_yes',
    'response_no',
    'need_phlegm',
    'need_change_position',
    'family_call_primary',
    'family_call_secondary',
    laughItemId,
  ];

  static List<CommunicationItem> buildNeedItems({
    required Map<String, String> textOverrides,
  }) {
    return <CommunicationItem>[
      _item(
        id: 'need_call_caregiver',
        title: 'PANGGIL PENDAMPING',
        spokenText: _override(
          textOverrides,
          'need_call_caregiver',
          'Tolong datang ke sini. Saya membutuhkan bantuan.',
        ),
        icon: Icons.notifications_active_rounded,
        category: categoryNeeds,
        color: AppColors.needBlue,
        position: 0,
        semanticLabel: 'Tombol panggil pendamping.',
      ),
      _item(
        id: 'need_pain',
        title: 'SAYA KESAKITAN',
        spokenText: _override(
          textOverrides,
          'need_pain',
          'Saya merasa sakit. Tolong periksa saya.',
        ),
        icon: Icons.personal_injury_rounded,
        category: categoryNeeds,
        color: AppColors.needBlue,
        position: 1,
        semanticLabel: 'Tombol saya kesakitan.',
      ),
      _item(
        id: 'need_breathless',
        title: 'SAYA SESAK',
        spokenText: _override(
          textOverrides,
          'need_breathless',
          'Saya merasa sulit bernapas. Tolong bantu saya.',
        ),
        icon: Icons.air_rounded,
        category: categoryNeeds,
        color: AppColors.needBlue,
        position: 2,
        semanticLabel: 'Tombol saya sesak.',
      ),
      _item(
        id: 'need_phlegm',
        title: 'DAHAK MENGGANGGU',
        spokenText: _override(
          textOverrides,
          'need_phlegm',
          'Dahak saya mengganggu. Tolong bantu bersihkan.',
        ),
        icon: Icons.record_voice_over_rounded,
        category: categoryNeeds,
        color: AppColors.needBlue,
        position: 3,
        semanticLabel: 'Tombol dahak mengganggu.',
      ),
      _item(
        id: 'need_change_position',
        title: 'UBAH POSISI',
        spokenText: _override(
          textOverrides,
          'need_change_position',
          'Posisi tubuh saya tidak nyaman. Tolong ubah posisi saya.',
        ),
        icon: Icons.bed_rounded,
        category: categoryNeeds,
        color: AppColors.needBlue,
        position: 4,
        semanticLabel: 'Tombol ubah posisi.',
      ),
      _item(
        id: 'need_toilet',
        title: 'INGIN BUANG AIR',
        spokenText: _override(
          textOverrides,
          'need_toilet',
          'Saya ingin buang air. Tolong bantu saya.',
        ),
        icon: Icons.wc_rounded,
        category: categoryNeeds,
        color: AppColors.needBlue,
        position: 5,
        semanticLabel: 'Tombol ingin buang air.',
      ),
      _item(
        id: 'need_dry_mouth',
        title: 'MULUT KERING',
        spokenText: _override(
          textOverrides,
          'need_dry_mouth',
          'Mulut saya terasa kering. Tolong periksa saya.',
        ),
        icon: Icons.water_drop_rounded,
        category: categoryNeeds,
        color: AppColors.needBlue,
        position: 6,
        semanticLabel: 'Tombol mulut kering.',
      ),
      _item(
        id: 'need_hot',
        title: 'SAYA KEPANASAN',
        spokenText: _override(
          textOverrides,
          'need_hot',
          'Saya merasa kepanasan. Tolong bantu saya.',
        ),
        icon: Icons.thermostat_rounded,
        category: categoryNeeds,
        color: AppColors.needBlue,
        position: 7,
        semanticLabel: 'Tombol saya kepanasan.',
      ),
      _item(
        id: 'need_cold',
        title: 'SAYA KEDINGINAN',
        spokenText: _override(
          textOverrides,
          'need_cold',
          'Saya merasa kedinginan. Tolong bantu saya.',
        ),
        icon: Icons.ac_unit_rounded,
        category: categoryNeeds,
        color: AppColors.needBlue,
        position: 8,
        semanticLabel: 'Tombol saya kedinginan.',
      ),
      _item(
        id: 'need_uncomfortable',
        title: 'TIDAK NYAMAN',
        spokenText: _override(
          textOverrides,
          'need_uncomfortable',
          'Saya merasa tidak nyaman. Tolong periksa posisi tubuh saya.',
        ),
        icon: Icons.accessibility_new_rounded,
        category: categoryNeeds,
        color: AppColors.needBlue,
        position: 9,
        semanticLabel: 'Tombol tidak nyaman.',
      ),
    ];
  }

  static List<CommunicationItem> buildResponseItems({
    required Map<String, String> textOverrides,
  }) {
    return <CommunicationItem>[
      _item(
        id: 'response_yes',
        title: 'YA',
        spokenText: _override(textOverrides, 'response_yes', 'Ya.'),
        icon: Icons.check_circle_rounded,
        category: categoryResponse,
        color: AppColors.yesGreen,
        position: 0,
        semanticLabel: 'Tombol ya.',
      ),
      _item(
        id: 'response_no',
        title: 'TIDAK',
        spokenText: _override(textOverrides, 'response_no', 'Tidak.'),
        icon: Icons.cancel_rounded,
        category: categoryResponse,
        color: AppColors.noRed,
        position: 1,
        semanticLabel: 'Tombol tidak.',
      ),
      _item(
        id: 'response_unknown',
        title: 'TIDAK TAHU',
        spokenText: _override(
          textOverrides,
          'response_unknown',
          'Saya tidak tahu.',
        ),
        icon: Icons.help_rounded,
        category: categoryResponse,
        color: AppColors.unknownAmber,
        position: 2,
        semanticLabel: 'Tombol tidak tahu.',
      ),
      _item(
        id: 'response_repeat',
        title: 'ULANGI PERTANYAAN',
        spokenText: _override(
          textOverrides,
          'response_repeat',
          'Tolong ulangi pertanyaannya.',
        ),
        icon: Icons.replay_circle_filled_rounded,
        category: categoryResponse,
        color: AppColors.repeatBlueGrey,
        position: 3,
        semanticLabel: 'Tombol ulangi pertanyaan.',
      ),
    ];
  }

  static List<CommunicationItem> buildEmotionItems({
    required Map<String, String> textOverrides,
  }) {
    return <CommunicationItem>[
      _item(
        id: 'emotion_happy',
        title: 'SAYA SENANG',
        spokenText: _override(
          textOverrides,
          'emotion_happy',
          'Saya merasa senang.',
        ),
        icon: Icons.sentiment_very_satisfied_rounded,
        category: categoryEmotion,
        color: AppColors.emotionOrange,
        position: 0,
      ),
      _item(
        id: 'emotion_sad',
        title: 'SAYA SEDIH',
        spokenText: _override(
          textOverrides,
          'emotion_sad',
          'Saya merasa sedih. Tolong temani saya.',
        ),
        icon: Icons.sentiment_dissatisfied_rounded,
        category: categoryEmotion,
        color: AppColors.emotionOrange,
        position: 1,
      ),
      _item(
        id: 'emotion_afraid',
        title: 'SAYA TAKUT',
        spokenText: _override(
          textOverrides,
          'emotion_afraid',
          'Saya merasa takut. Tolong tetap di dekat saya.',
        ),
        icon: Icons.shield_moon_rounded,
        category: categoryEmotion,
        color: AppColors.emotionOrange,
        position: 2,
      ),
      _item(
        id: 'emotion_anxious',
        title: 'SAYA CEMAS',
        spokenText: _override(
          textOverrides,
          'emotion_anxious',
          'Saya merasa cemas. Tolong tenangkan saya.',
        ),
        icon: Icons.psychology_alt_rounded,
        category: categoryEmotion,
        color: AppColors.emotionOrange,
        position: 3,
      ),
      _item(
        id: 'emotion_sleepy',
        title: 'SAYA MENGANTUK',
        spokenText: _override(
          textOverrides,
          'emotion_sleepy',
          'Saya mengantuk dan ingin beristirahat.',
        ),
        icon: Icons.bedtime_rounded,
        category: categoryEmotion,
        color: AppColors.emotionOrange,
        position: 4,
      ),
      _item(
        id: 'emotion_alone',
        title: 'SAYA INGIN SENDIRI',
        spokenText: _override(
          textOverrides,
          'emotion_alone',
          'Saya ingin beristirahat sebentar.',
        ),
        icon: Icons.self_improvement_rounded,
        category: categoryEmotion,
        color: AppColors.emotionOrange,
        position: 5,
      ),
      _item(
        id: 'emotion_companionship',
        title: 'SAYA INGIN DITEMANI',
        spokenText: _override(
          textOverrides,
          'emotion_companionship',
          'Saya ingin ditemani.',
        ),
        icon: Icons.groups_rounded,
        category: categoryEmotion,
        color: AppColors.emotionOrange,
        position: 6,
      ),
      _item(
        id: 'emotion_watch',
        title: 'SAYA INGIN MENONTON',
        spokenText: _override(
          textOverrides,
          'emotion_watch',
          'Saya ingin menonton televisi atau video.',
        ),
        icon: Icons.tv_rounded,
        category: categoryEmotion,
        color: AppColors.emotionOrange,
        position: 7,
      ),
      _item(
        id: 'emotion_music',
        title: 'SAYA INGIN MENDENGARKAN MUSIK',
        spokenText: _override(
          textOverrides,
          'emotion_music',
          'Saya ingin mendengarkan musik.',
        ),
        icon: Icons.music_note_rounded,
        category: categoryEmotion,
        color: AppColors.emotionOrange,
        position: 8,
      ),
    ];
  }

  static List<CommunicationItem> buildFamilyItems({
    required String primaryName,
    required String secondaryName,
    required List<FamilyMember> extraMembers,
    required Map<String, String> textOverrides,
  }) {
    final String primaryUpper = primaryName.toUpperCase();
    final String secondaryUpper = secondaryName.toUpperCase();

    final List<CommunicationItem> items = <CommunicationItem>[
      _item(
        id: 'family_call_primary',
        title: 'PANGGIL $primaryUpper',
        spokenText: _override(
          textOverrides,
          'family_call_primary',
          '$primaryName, tolong datang ke sini.',
        ),
        icon: Icons.person_pin_circle_rounded,
        category: categoryFamily,
        color: AppColors.familyPurple,
        position: 0,
        semanticLabel: 'Tombol panggil $primaryName.',
      ),
      _item(
        id: 'family_hello_primary',
        title: 'HALO $primaryUpper',
        spokenText: _override(
          textOverrides,
          'family_hello_primary',
          'Halo $primaryName. Senang melihatmu.',
        ),
        icon: Icons.waving_hand_rounded,
        category: categoryFamily,
        color: AppColors.familyPurple,
        position: 1,
      ),
      _item(
        id: 'family_thanks_primary',
        title: 'TERIMA KASIH $primaryUpper',
        spokenText: _override(
          textOverrides,
          'family_thanks_primary',
          'Terima kasih, $primaryName, sudah menemani dan membantu saya.',
        ),
        icon: Icons.favorite_rounded,
        category: categoryFamily,
        color: AppColors.familyPurple,
        position: 2,
      ),
      _item(
        id: 'family_call_secondary',
        title: 'PANGGIL $secondaryUpper',
        spokenText: _override(
          textOverrides,
          'family_call_secondary',
          '$secondaryName, tolong datang ke sini.',
        ),
        icon: Icons.person_pin_circle_rounded,
        category: categoryFamily,
        color: AppColors.familyPurple,
        position: 3,
        semanticLabel: 'Tombol panggil $secondaryName.',
      ),
      _item(
        id: 'family_hello_secondary',
        title: 'HALO $secondaryUpper',
        spokenText: _override(
          textOverrides,
          'family_hello_secondary',
          'Halo $secondaryName. Senang melihatmu.',
        ),
        icon: Icons.waving_hand_rounded,
        category: categoryFamily,
        color: AppColors.familyPurple,
        position: 4,
      ),
      _item(
        id: 'family_thanks_secondary',
        title: 'TERIMA KASIH $secondaryUpper',
        spokenText: _override(
          textOverrides,
          'family_thanks_secondary',
          'Terima kasih, $secondaryName, sudah menemani dan membantu saya.',
        ),
        icon: Icons.favorite_rounded,
        category: categoryFamily,
        color: AppColors.familyPurple,
        position: 5,
      ),
      _item(
        id: 'family_hello_together',
        title: 'HALO $primaryUpper DAN $secondaryUpper',
        spokenText: _override(
          textOverrides,
          'family_hello_together',
          'Halo $primaryName dan $secondaryName. Saya senang kalian ada di sini.',
        ),
        icon: Icons.diversity_3_rounded,
        category: categoryFamily,
        color: AppColors.familyPurple,
        position: 6,
      ),
      _item(
        id: 'family_love',
        title: 'SAYA SAYANG KALIAN',
        spokenText: _override(
          textOverrides,
          'family_love',
          'Saya sayang $primaryName dan $secondaryName. '
              'Terima kasih sudah menemani saya.',
        ),
        icon: Icons.favorite_border_rounded,
        category: categoryFamily,
        color: AppColors.familyPurple,
        position: 7,
      ),
      _item(
        id: 'family_good_morning',
        title: 'SELAMAT PAGI',
        spokenText: _override(
          textOverrides,
          'family_good_morning',
          'Selamat pagi, $primaryName dan $secondaryName. '
              'Semoga hari ini menyenangkan.',
        ),
        icon: Icons.wb_sunny_rounded,
        category: categoryFamily,
        color: AppColors.familyPurple,
        position: 8,
      ),
      _item(
        id: 'family_good_afternoon',
        title: 'SELAMAT SIANG',
        spokenText: _override(
          textOverrides,
          'family_good_afternoon',
          'Selamat siang, $primaryName dan $secondaryName.',
        ),
        icon: Icons.wb_sunny_outlined,
        category: categoryFamily,
        color: AppColors.familyPurple,
        position: 9,
      ),
      _item(
        id: 'family_good_night',
        title: 'SELAMAT MALAM',
        spokenText: _override(
          textOverrides,
          'family_good_night',
          'Selamat malam, $primaryName dan $secondaryName. '
              'Semoga kalian beristirahat dengan tenang.',
        ),
        icon: Icons.nightlight_round,
        category: categoryFamily,
        color: AppColors.familyPurple,
        position: 10,
      ),
      _item(
        id: 'family_how_are_you',
        title: 'APA KABAR',
        spokenText: _override(
          textOverrides,
          'family_how_are_you',
          '$primaryName dan $secondaryName, apa kabar hari ini?',
        ),
        icon: Icons.question_answer_rounded,
        category: categoryFamily,
        color: AppColors.familyPurple,
        position: 11,
      ),
      _item(
        id: 'family_happy_today',
        title: 'SAYA SENANG HARI INI',
        spokenText: _override(
          textOverrides,
          'family_happy_today',
          'Saya merasa senang hari ini.',
        ),
        icon: Icons.sentiment_satisfied_alt_rounded,
        category: categoryFamily,
        color: AppColors.familyPurple,
        position: 12,
      ),
      _item(
        id: 'family_miss_you',
        title: 'SAYA RINDU',
        spokenText: _override(
          textOverrides,
          'family_miss_you',
          'Saya rindu $primaryName dan $secondaryName.',
        ),
        icon: Icons.mark_chat_unread_rounded,
        category: categoryFamily,
        color: AppColors.familyPurple,
        position: 13,
      ),
    ];

    for (int index = 0; index < extraMembers.length; index++) {
      final FamilyMember member = extraMembers[index];
      final String upper = member.name.toUpperCase();
      items.addAll(<CommunicationItem>[
        _item(
          id: 'family_call_${member.id}',
          title: 'PANGGIL $upper',
          spokenText: _override(
            textOverrides,
            'family_call_${member.id}',
            '${member.name}, tolong datang ke sini.',
          ),
          icon: Icons.person_pin_circle_rounded,
          category: categoryFamily,
          color: AppColors.familyPurple,
          position: 20 + (index * 3),
        ),
        _item(
          id: 'family_hello_${member.id}',
          title: 'HALO $upper',
          spokenText: _override(
            textOverrides,
            'family_hello_${member.id}',
            'Halo ${member.name}. Senang melihatmu.',
          ),
          icon: Icons.waving_hand_rounded,
          category: categoryFamily,
          color: AppColors.familyPurple,
          position: 21 + (index * 3),
        ),
        _item(
          id: 'family_thanks_${member.id}',
          title: 'TERIMA KASIH $upper',
          spokenText: _override(
            textOverrides,
            'family_thanks_${member.id}',
            'Terima kasih, ${member.name}, sudah menemani dan membantu saya.',
          ),
          icon: Icons.favorite_rounded,
          category: categoryFamily,
          color: AppColors.familyPurple,
          position: 22 + (index * 3),
        ),
      ]);
    }

    return items;
  }

  static List<CommunicationItem> buildOtherItems({
    required List<CommunicationItem> customItems,
  }) {
    return <CommunicationItem>[
      _item(
        id: laughItemId,
        title: 'KETAWA',
        spokenText: 'Memutar suara ketawa.',
        icon: Icons.mood_rounded,
        category: categoryOther,
        color: AppColors.otherNeedTeal,
        position: 0,
        audioAsset: laughAudioShort,
        semanticLabel: 'Tombol suara ketawa.',
      ),
      ...customItems.map(
        (CommunicationItem item) => item.copyWith(
          color: item.color,
          category: categoryCustom,
        ),
      ),
    ];
  }

  static CommunicationItem createCustomItem({
    required String id,
    required String title,
    required String spokenText,
    required int position,
    bool isFavorite = false,
  }) {
    return CommunicationItem(
      id: id,
      title: title.toUpperCase(),
      spokenText: spokenText,
      icon: Icons.chat_bubble_rounded,
      category: categoryCustom,
      color: AppColors.otherNeedTeal,
      isFavorite: isFavorite,
      position: position,
      requiresConfirmation: false,
      semanticLabel: 'Tombol $title.',
    );
  }

  static String formatHistoryTimestamp(DateTime timestamp) {
    final DateFormat dateFormat = DateFormat('d MMMM y', 'id_ID');
    final DateFormat timeFormat = DateFormat('HH.mm', 'id_ID');
    return '${dateFormat.format(timestamp)} — ${timeFormat.format(timestamp)}';
  }

  static HandPreference parseHandPreference(String? value) {
    switch (value) {
      case 'center':
        return HandPreference.center;
      case 'right':
        return HandPreference.right;
      case 'left':
      default:
        return HandPreference.left;
    }
  }

  static String handPreferenceToStorage(HandPreference preference) {
    return preference.name;
  }

  static String _override(
    Map<String, String> overrides,
    String id,
    String fallback,
  ) {
    return overrides[id] ?? fallback;
  }

  static CommunicationItem _item({
    required String id,
    required String title,
    required String spokenText,
    required IconData icon,
    required String category,
    required Color color,
    required int position,
    bool isFavorite = false,
    bool requiresConfirmation = false,
    String? audioAsset,
    String? semanticLabel,
  }) {
    return CommunicationItem(
      id: id,
      title: title,
      spokenText: spokenText,
      icon: icon,
      category: category,
      color: color,
      isFavorite: isFavorite,
      position: position,
      requiresConfirmation: requiresConfirmation,
      audioAsset: audioAsset,
      semanticLabel: semanticLabel,
    );
  }
}
