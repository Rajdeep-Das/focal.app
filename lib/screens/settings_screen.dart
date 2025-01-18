import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings_model.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          final settings = settingsProvider.settings;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Timer Settings
              SettingsSection(
                title: 'Timer',
                children: [
                  ListTile(
                    title: const Text('Focus Duration'),
                    subtitle: Text('${settings.focusDuration} minutes'),
                    onTap: () => _showDurationPicker(
                      context,
                      settings,
                      settingsProvider,
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Keep Screen On'),
                    subtitle: const Text('Prevent screen from turning off'),
                    value: settings.keepScreenOn,
                    onChanged: (value) {
                      settingsProvider.updateSettings(
                        settings.copyWith(keepScreenOn: value),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Notification Settings
              SettingsSection(
                title: 'Notifications',
                children: [
                  SwitchListTile(
                    title: const Text('Sound'),
                    subtitle: const Text('Play sound when timer ends'),
                    value: settings.soundEnabled,
                    onChanged: (value) {
                      settingsProvider.updateSettings(
                        settings.copyWith(soundEnabled: value),
                      );
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Vibration'),
                    subtitle: const Text('Vibrate when timer ends'),
                    value: settings.vibrationEnabled,
                    onChanged: (value) {
                      settingsProvider.updateSettings(
                        settings.copyWith(vibrationEnabled: value),
                      );
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Daily Reminder'),
                    subtitle: Text(
                      settings.dailyReminder && settings.reminderTime != null
                          ? 'At ${settings.reminderTime!.format(context)}'
                          : 'Disabled',
                    ),
                    value: settings.dailyReminder,
                    onChanged: (value) async {
                      if (value && settings.reminderTime == null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 9, minute: 0),
                        );
                        if (time != null) {
                          settingsProvider.updateSettings(
                            settings.copyWith(
                              dailyReminder: value,
                              reminderTime: time,
                            ),
                          );
                        }
                      } else {
                        settingsProvider.updateSettings(
                          settings.copyWith(dailyReminder: value),
                        );
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Appearance Settings
              SettingsSection(
                title: 'Appearance',
                children: [
                  ListTile(
                    title: const Text('Theme'),
                    subtitle: Text(
                      settings.theme.substring(0, 1).toUpperCase() +
                          settings.theme.substring(1),
                    ),
                    onTap: () => _showThemePicker(
                      context,
                      settings,
                      settingsProvider,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showDurationPicker(
    BuildContext context,
    Settings settings,
    SettingsProvider provider,
  ) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Focus Duration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final duration in [1, 25, 30, 45, 60]) // Time Duration
              RadioListTile<int>(
                title: Text('$duration minutes'),
                value: duration,
                groupValue: settings.focusDuration,
                onChanged: (value) {
                  Navigator.pop(context, value);
                },
              ),
          ],
        ),
      ),
    );

    if (result != null) {
      provider.updateSettings(
        settings.copyWith(focusDuration: result),
      );
    }
  }

  Future<void> _showThemePicker(
    BuildContext context,
    Settings settings,
    SettingsProvider provider,
  ) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final theme in ['system', 'light', 'dark'])
              RadioListTile<String>(
                title: Text(
                  theme.substring(0, 1).toUpperCase() + theme.substring(1),
                ),
                value: theme,
                groupValue: settings.theme,
                onChanged: (value) {
                  Navigator.pop(context, value);
                },
              ),
          ],
        ),
      ),
    );

    if (result != null) {
      provider.updateSettings(
        settings.copyWith(theme: result),
      );
    }
  }
}
