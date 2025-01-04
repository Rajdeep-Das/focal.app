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
        'reminderTime': reminderTime != null
            ? '${reminderTime!.hour}:${reminderTime!.minute}'
            : null,
      };

  factory Settings.fromJson(Map<String, dynamic> json) {
    String? timeString = json['reminderTime'];
    TimeOfDay? parsedTime;

    if (timeString != null) {
      final parts = timeString.split(':');
      parsedTime =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return Settings(
      focusDuration: json['focusDuration'] ?? 25,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      theme: json['theme'] ?? 'system',
      keepScreenOn: json['keepScreenOn'] ?? true,
      dailyReminder: json['dailyReminder'] ?? false,
      reminderTime: parsedTime,
    );
  }
}
