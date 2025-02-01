import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playTimerCompleteSound() async {
    await _audioPlayer.play(AssetSource('sounds/alert.wav'));
  }
}
