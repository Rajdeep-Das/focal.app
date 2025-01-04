import 'package:flutter/material.dart';

class Settings {
  final int focusDuration;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String theme;
  final bool keepScreenOn;
  final bool dailyReminder;
  final TimeOfDay? reminderTime;

  Settings({
    this.focusDuration = 25,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.theme = 'system',
    this.keepScreenOn = true,
    this.dailyReminder = false,
    this.reminderTime,
  });

  Settings copyWith({
    int? focusDuration,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? theme,
    bool? keepScreenOn,
    bool? dailyReminder,
    TimeOfDay? reminderTime,
  }) {
    return Settings(
      focusDuration: focusDuration ?? this.focusDuration,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      theme: theme ?? this.theme,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      dailyReminder: dailyReminder ?? this.dailyReminder,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  Map<String, dynamic> toJson() => {
        'focusDuration': focusDuration,
        'soundEnabled': soundEnabled,
        'vibrationEnabled': vibrationEnabled,
        'theme': theme,
        'keepScreenOn': keepScreenOn,
        'dailyReminder': dailyReminder,
        'reminderTime': reminderTime?.toString(),
      };

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      focusDuration: json['focusDuration'] ?? 25,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      theme: json['theme'] ?? 'system',
      keepScreenOn: json['keepScreenOn'] ?? true,
      dailyReminder: json['dailyReminder'] ?? false,
      reminderTime: json['reminderTime'] != null
          ? TimeOfDay.fromDateTime(DateTime.parse(json['reminderTime']))
          : null,
    );
  }
}
