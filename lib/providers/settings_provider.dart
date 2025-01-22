import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';
import '../services/notification_service.dart';
import '../services/reminder_service.dart';

class SettingsProvider with ChangeNotifier {
  late SharedPreferences _prefs;
  Settings _settings = Settings();
  final NotificationService _notificationService;
  final ReminderService _reminderService;

  SettingsProvider(this._notificationService, this._reminderService);

  Settings get settings => _settings;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();

    // Reactivate reminder if it was enabled
    if (_settings.dailyReminder && _settings.reminderTime != null) {
      await _reminderService.scheduleDailyReminder(_settings.reminderTime!);
    }
  }

  Future<void> _loadSettings() async {
    final settingsJson = _prefs.getString('settings');
    if (settingsJson != null) {
      _settings = Settings.fromJson(
        Map<String, dynamic>.from(
          jsonDecode(settingsJson),
        ),
      );
      notifyListeners();
    }
  }

  Future<void> updateSettings(Settings newSettings) async {
    _settings = newSettings;
    await _prefs.setString('settings', jsonEncode(newSettings.toJson()));
    notifyListeners();
  }

  Future<void> updateDailyReminder({
    required bool enabled,
    TimeOfDay? time,
  }) async {
    if (enabled && (time != null || _settings.reminderTime != null)) {
      final reminderTime = time ?? _settings.reminderTime!;
      final hasPermission = await _notificationService.requestPermissions();

      if (!hasPermission) {
        return;
      }

      await _reminderService.scheduleDailyReminder(reminderTime);
      await updateSettings(
        _settings.copyWith(
          dailyReminder: true,
          reminderTime: reminderTime,
        ),
      );
    } else {
      await _reminderService.cancelDailyReminder();
      await updateSettings(
        _settings.copyWith(
          dailyReminder: false,
          reminderTime: time,
        ),
      );
    }
  }
}
