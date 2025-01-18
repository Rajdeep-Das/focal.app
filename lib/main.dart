import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/timer_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'config/theme.dart';
import 'services/notification_service.dart';
import 'services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();
  await notificationService.initialize();

  final audioService = AudioService();

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
    return MaterialApp(
      title: 'Focal',
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
