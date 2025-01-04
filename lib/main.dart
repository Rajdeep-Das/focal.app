import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/timer_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FocalApp());
}

class FocalApp extends StatelessWidget {
  const FocalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerProvider()),
      ],
      child: MaterialApp(
        title: 'Focal',
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
