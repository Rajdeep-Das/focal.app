import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/timer_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'config/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsProvider = SettingsProvider();
  await settingsProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: settingsProvider,
        ),
        ChangeNotifierProvider(
          create: (_) => TimerProvider(settingsProvider),
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
      // theme: ThemeData.dark().copyWith(
      //   primaryColor: Colors.indigo,
      //   scaffoldBackgroundColor: Colors.black,
      // ),
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
