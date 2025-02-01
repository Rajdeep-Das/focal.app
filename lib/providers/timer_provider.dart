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
import 'package:flutter/services.dart'
    show HapticFeedback, SystemChrome, SystemUiMode, SystemUiOverlay;

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
      DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)),
    );
    _sessions.clear();
    _sessions.addAll(await _repository.getSessionsByDate(DateTime.now()));
    notifyListeners();
  }

  void startTimer() {
    if (!_isRunning) {
      _isRunning = true;
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        _timerCallback,
      );

      // Keep screen on when timer starts
      if (_settings.settings.keepScreenOn) {
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
        );
      }

      notifyListeners();
    }
  }

  void pauseTimer() {
    if (_isRunning) {
      _timer?.cancel();
      _isRunning = false;

      // Allow screen to turn off when timer is paused
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );

      notifyListeners();
    }
  }

  void resetTimer() {
    _timer?.cancel();
    _timeLeft = _settings.settings.focusDuration * 60;
    _isRunning = false;

    // Allow screen to turn off when timer is reset
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

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

  void _handleTimerComplete() async {
    _timer?.cancel();
    _isRunning = false;

    // Create and save the completed session
    final session = Session(
      startTime: DateTime.now()
          .subtract(Duration(minutes: _settings.settings.focusDuration)),
      endTime: DateTime.now(),
      status: SessionStatus.completed,
    );

    await _repository.saveSession(session);
    _sessions.insert(0, session);

    // Refresh statistics immediately after session completion
    await refreshStatistics();

    // Handle notifications and feedback
    if (_settings.settings.soundEnabled) {
      await _audioService.playTimerCompleteSound();
    }
    if (_settings.settings.vibrationEnabled) {
      HapticFeedback.mediumImpact();
    }
    await _notificationService.showTimerCompleteNotification();

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    // Ensure screen can turn off when disposing
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }
}
