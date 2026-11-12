import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/communication_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/emergency_screen.dart';
import 'screens/emotion_screen.dart';
import 'screens/family_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/other_needs_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'services/audio_service.dart';
import 'services/scanning_service.dart';
import 'services/storage_service.dart';
import 'services/tts_service.dart';
import 'services/vibration_service.dart';
import 'utils/app_constants.dart';
import 'utils/app_theme.dart';

class SapaStrokeRoot extends StatefulWidget {
  const SapaStrokeRoot({
    super.key,
    required this.sharedPreferences,
  });

  final SharedPreferences sharedPreferences;

  @override
  State<SapaStrokeRoot> createState() => _SapaStrokeRootState();
}

class _SapaStrokeRootState extends State<SapaStrokeRoot> {
  late final StorageService _storageService;
  late final TtsService _ttsService;
  late final AudioService _audioService;
  late final VibrationService _vibrationService;
  late final ScanningService _scanningService;

  @override
  void initState() {
    super.initState();
    _storageService = SharedPreferencesStorageService(
      widget.sharedPreferences,
    );
    _ttsService = FlutterTtsService();
    _audioService = AppAudioService();
    _vibrationService = DeviceVibrationService();
    _scanningService = ScanningService();
  }

  @override
  void dispose() {
    _scanningService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(
            storageService: _storageService,
          )..load(),
        ),
        ChangeNotifierProxyProvider<SettingsProvider, CommunicationProvider>(
          create: (_) => CommunicationProvider(
            ttsService: _ttsService,
            audioService: _audioService,
            storageService: _storageService,
            vibrationService: _vibrationService,
            scanningService: _scanningService,
          )..initialize(),
          update: (_, SettingsProvider settings, CommunicationProvider? value) {
            value!.bindSettings(settings);
            return value;
          },
        ),
      ],
      child: Consumer2<SettingsProvider, CommunicationProvider>(
        builder: (
          BuildContext context,
          SettingsProvider settings,
          CommunicationProvider communication,
          _,
        ) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
            locale: const Locale('id', 'ID'),
            routes: <String, WidgetBuilder>{
              AppConstants.routeHome: (_) => const HomeScreen(),
              AppConstants.routeFamily: (_) => const FamilyScreen(),
              AppConstants.routeEmotion: (_) => const EmotionScreen(),
              AppConstants.routeOtherNeeds: (_) => const OtherNeedsScreen(),
              AppConstants.routeEmergency: (_) => const EmergencyScreen(),
              AppConstants.routeSettings: (_) => const SettingsScreen(),
              AppConstants.routeHistory: (_) => const HistoryScreen(),
            },
            home: settings.isReady && communication.isReady
                ? const SplashScreen()
                : const _BootstrapScreen(),
          );
        },
      ),
    );
  }
}

class _BootstrapScreen extends StatelessWidget {
  const _BootstrapScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
