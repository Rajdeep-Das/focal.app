// lib/providers/timer_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../services/audio_service.dart';

class TimerProvider with ChangeNotifier {
  int _timeLeft;
  bool _isRunning = false;
  Timer? _timer;
  final List<Session> _sessions = [];
  final SettingsProvider _settings;
  final NotificationService _notificationService;
  final AudioService _audioService;

  TimerProvider(this._settings, this._notificationService, this._audioService)
      : _timeLeft = _settings.settings.focusDuration * 60;

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
    _timeLeft = _settings.settings.focusDuration * 60;
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
          Duration(minutes: _settings.settings.focusDuration),
        ),
        duration: _settings.settings.focusDuration * 60,
        completed: true,
      ),
    );

    // Play sound if enabled
    if (_settings.settings.soundEnabled) {
      _audioService.playTimerCompleteSound();
    }

    // Show notification
    _notificationService.showTimerCompleteNotification();

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
