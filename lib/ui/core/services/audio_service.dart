import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static bool isAudioEnabled = true;
  static final Set<AudioPlayer> _activePlayers = {};

  static Future<void> playTileMatch() async {
    await _playEffect('audio/tile_match.mp3');
  }

  static Future<void> playLevelClear() async {
    await _playEffect('audio/level_clear.mp3');
  }

  static Future<void> _playEffect(String assetPath) async {
    if (!isAudioEnabled) return;
    final player = AudioPlayer();
    _activePlayers.add(player);

    Timer? safetyTimer;
    void cleanup() {
      safetyTimer?.cancel();
      _activePlayers.remove(player);
      player.dispose().catchError((_) {});
    }

    safetyTimer = Timer(const Duration(seconds: 2), cleanup);

    try {
      await player.setPlayerMode(PlayerMode.lowLatency);
      player.onPlayerComplete.first.then((_) => cleanup()).catchError((_) => cleanup());
      await player.play(AssetSource(assetPath));
    } catch (_) {
      cleanup();
    }
  }

  static void dispose() {
    for (final player in _activePlayers.toList()) {
      player.dispose().catchError((_) {});
    }
    _activePlayers.clear();
  }
}
