import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../widgets/timer_display.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';
import 'package:flutter/services.dart' show HapticFeedback;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timer, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Focal Timer'),
            actions: [
              IconButton(
                icon: const Icon(Icons.bar_chart),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StatisticsScreen(),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: TimerDisplay(
                      timeLeft: timer.timeLeft,
                      isRunning: timer.isRunning,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(
                        icon: Icons.refresh,
                        onPressed: timer.resetTimer,
                        iconColor: Colors.grey[400],
                      ),
                      _buildMainButton(timer),
                      _buildControlButton(
                        icon: Icons.settings,
                        onPressed: () async {
                          HapticFeedback.mediumImpact();
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                          Provider.of<TimerProvider>(context, listen: false)
                              .resetTimer();
                        },
                        iconColor: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainButton(TimerProvider timer) {
    return GestureDetector(
      onTap: () {
        if (timer.isRunning) {
          timer.pauseTimer();
        } else {
          timer.startTimer();
        }
        HapticFeedback.mediumImpact();
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: timer.isRunning
                  ? [Colors.red.shade400, Colors.red.shade600]
                  : [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: (timer.isRunning
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary)
                    .withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            timer.isRunning ? Icons.pause : Icons.play_arrow,
            size: 36,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? iconColor,
  }) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: iconColor ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
