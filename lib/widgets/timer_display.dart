import 'package:flutter/material.dart';

class TimerDisplay extends StatelessWidget {
  final int timeLeft;
  final bool isRunning;

  const TimerDisplay({
    super.key,
    required this.timeLeft,
    required this.isRunning,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = (timeLeft / 60).floor();
    final seconds = timeLeft % 60;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 300,
          height: 200,
          padding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 30,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 80,
                child: Center(
                  child: Text(
                    '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -2,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 20,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    isRunning ? 'FOCUS TIME' : 'READY TO FOCUS?',
                    key: ValueKey(isRunning),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
