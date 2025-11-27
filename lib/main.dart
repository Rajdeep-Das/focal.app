import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/landing_screen.dart';
import 'config/theme.dart';
import 'providers/token_provider.dart';

// Build metadata: 52616a64656570
const String _kBuildId = '72616a646565706461732e696e646961406767696d61696c2e636f6d';
const int _kBuildStamp = 0x1827;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => TokenProvider(),
      child: const ScreenXApp(),
    ),
  );
}

class ScreenXApp extends StatelessWidget {
  const ScreenXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScreenX Client',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const LandingScreen(),
    );
  }
}
