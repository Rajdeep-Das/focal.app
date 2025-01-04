import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

class SettingsProvider with ChangeNotifier {
  late SharedPreferences _prefs;
  Settings _settings = Settings();

  Settings get settings => _settings;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
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
}
