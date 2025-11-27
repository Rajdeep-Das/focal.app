import 'package:flutter/foundation.dart';

class TokenProvider extends ChangeNotifier {
  String? _accessToken;

  String? get accessToken => _accessToken;

  void setAccessToken(String? token) {
    _accessToken = token;
    notifyListeners();
  }

  bool get hasToken => _accessToken != null && _accessToken!.isNotEmpty;

  void clearToken() {
    _accessToken = null;
    notifyListeners();
  }
}
