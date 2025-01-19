// lib/providers/timer_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../services/audio_service.dart';
import '../repositories/session_repository.dart';
import '../services/analytics_service.dart';
import '../models/analytics_model.dart';
import 'package:flutter/services.dart' show HapticFeedback;

class TimerProvider with ChangeNotifier {
  int _timeLeft;
  bool _isRunning = false;
  Timer? _timer;
  final List<Session> _sessions = [];
  final SettingsProvider _settings;
  final NotificationService _notificationService;
  final AudioService _audioService;
  final SessionRepository _repository;
  final AnalyticsService _analytics;

  DailyStatistics? _todayStats;
  WeeklyAnalytics? _weeklyStats;

  TimerProvider(this._settings, this._notificationService, this._audioService,
      this._repository, this._analytics)
      : _timeLeft = _settings.settings.focusDuration * 60 {
    // Load statistics when provider is initialized
    refreshStatistics();
  }

  int get timeLeft => _timeLeft;
  bool get isRunning => _isRunning;
  List<Session> get sessions => List.unmodifiable(_sessions);

  DailyStatistics? get todayStats => _todayStats;
  WeeklyAnalytics? get weeklyStats => _weeklyStats;

  Future<void> refreshStatistics() async {
    _todayStats = await _analytics.getDailyStatistics(DateTime.now());
    _weeklyStats = await _analytics.getWeeklyAnalytics(
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)));
    notifyListeners();
  }

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
    final session = Session(
      startTime: DateTime.now().subtract(
        Duration(minutes: _settings.settings.focusDuration),
      ),
      endTime: DateTime.now(),
      status: SessionStatus.completed,
    );

    _sessions.add(session);
    _repository.saveSession(session);

    // Play sound if enabled
    if (_settings.settings.soundEnabled) {
      _audioService.playTimerCompleteSound();
    }

    if (_settings.settings.vibrationEnabled) {
      HapticFeedback.vibrate();
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
