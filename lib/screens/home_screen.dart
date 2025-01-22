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
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(_controller);
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          if (timer.isRunning) {
            timer.pauseTimer();
          } else {
            timer.startTimer();
          }
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: timer.isRunning
                    ? Colors.red.shade400
                    : Colors.green.shade400,
                boxShadow: [
                  BoxShadow(
                    color: (timer.isRunning ? Colors.red : Colors.green)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                timer.isRunning ? Icons.pause : Icons.play_arrow,
                size: 40,
                color: Colors.white,
              ),
            ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: iconColor ?? Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
