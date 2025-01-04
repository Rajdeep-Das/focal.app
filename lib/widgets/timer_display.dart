import 'package:flutter/material.dart';

class TimerDisplay extends StatelessWidget {
  final int timeLeft;
  final bool isRunning;

  const TimerDisplay({
    Key? key,
    required this.timeLeft,
    required this.isRunning,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final minutes = (timeLeft / 60).floor();
    final seconds = timeLeft % 60;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: const TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.w300,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            isRunning ? 'Focus Time' : 'Ready to Focus?',
            key: ValueKey(isRunning),
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[400],
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}
