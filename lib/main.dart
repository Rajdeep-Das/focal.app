import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/timer_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'config/theme.dart';
import 'services/notification_service.dart';
import 'services/audio_service.dart';
import 'services/analytics_service.dart';
import 'repositories/session_repository.dart';
import 'models/session_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters only if they haven't been registered
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(SessionStatusAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(SessionAdapter());
  }

  final notificationService = NotificationService();
  await notificationService.initialize();

  final audioService = AudioService();
  final sessionRepository = SessionRepository();
  await sessionRepository.initialize();

  final analyticsService = AnalyticsService(sessionRepository);

  final settingsProvider = SettingsProvider();
  await settingsProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: settingsProvider,
        ),
        ChangeNotifierProvider(
          create: (_) => TimerProvider(
            settingsProvider,
            notificationService,
            audioService,
            sessionRepository,
            analyticsService,
          ),
        ),
      ],
      child: const FocalApp(),
    ),
  );
}

class FocalApp extends StatelessWidget {
  const FocalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final themeMode = switch (settings.settings.theme) {
          'dark' => ThemeMode.dark,
          'light' => ThemeMode.light,
          _ => ThemeMode.system,
        };

        return MaterialApp(
          title: 'Focal',
          themeMode: themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const HomeScreen(),
        );
      },
    );
  }
}
