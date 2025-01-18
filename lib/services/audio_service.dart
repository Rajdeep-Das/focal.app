import 'package:flutter/services.dart';

class AudioService {
  Future<void> playTimerCompleteSound() async {
    await SystemSound.play(SystemSoundType.alert);
  }
}
