import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/session_model.dart';

class TimerProvider with ChangeNotifier {
  int _timeLeft = 25 * 60; // 25 minutes in seconds
  bool _isRunning = false;
  Timer? _timer;
  final List<Session> _sessions = [];

  int get timeLeft => _timeLeft;
  bool get isRunning => _isRunning;
  List<Session> get sessions => List.unmodifiable(_sessions);

  void startTimer() {
    if (!_isRunning) {
      _isRunning = true;
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        _timerCallback,
      );
      notifyListeners();
    }
  }

  void pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _timeLeft = 25 * 60;
    _isRunning = false;
    notifyListeners();
  }

  void _timerCallback(Timer timer) {
    if (_timeLeft > 0) {
      _timeLeft--;
      notifyListeners();
    } else {
      _handleTimerComplete();
    }
  }

  void _handleTimerComplete() {
    _timer?.cancel();
    _isRunning = false;
    _sessions.add(
      Session(
        id: DateTime.now().toString(),
        startTime: DateTime.now().subtract(
          Duration(seconds: 25 * 60),
        ),
        duration: 25 * 60,
        completed: true,
      ),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
