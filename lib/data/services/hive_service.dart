import 'package:hive_flutter/hive_flutter.dart';

import 'package:mahjong/domain/models/user_progress.dart';
import 'user_progress_adapter.dart';

class HiveService {
  static const String _progressBoxName = 'user_progress';
  static const String _progressKey = 'progress';

  late Box<UserProgress> _progressBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserProgressAdapter());
    _progressBox = await Hive.openBox<UserProgress>(_progressBoxName);
  }

  Future<UserProgress> getProgress() async {
    return _progressBox.get(_progressKey) ?? const UserProgress();
  }

  Future<void> saveProgress(UserProgress progress) async {
    await _progressBox.put(_progressKey, progress);
  }

  Future<String?> getSelectedSkinId() async {
    final settingsBox = await Hive.openBox('app_settings');
    return settingsBox.get('selected_skin_id') as String?;
  }

  Future<void> saveSelectedSkinId(String skinId) async {
    final settingsBox = await Hive.openBox('app_settings');
    await settingsBox.put('selected_skin_id', skinId);
  }

  Future<bool> getHintHelperEnabled() async {
    final settingsBox = await Hive.openBox('app_settings');
    return settingsBox.get('hint_helper_enabled', defaultValue: true) as bool;
  }

  Future<void> saveHintHelperEnabled(bool enabled) async {
    final settingsBox = await Hive.openBox('app_settings');
    await settingsBox.put('hint_helper_enabled', enabled);
  }

  Future<bool> getHapticsEnabled() async {
    final settingsBox = await Hive.openBox('app_settings');
    return settingsBox.get('haptics_enabled', defaultValue: true) as bool;
  }

  Future<void> saveHapticsEnabled(bool enabled) async {
    final settingsBox = await Hive.openBox('app_settings');
    await settingsBox.put('haptics_enabled', enabled);
  }

  Future<bool> getTraditionalTilesEnabled() async {
    final settingsBox = await Hive.openBox('app_settings');
    return settingsBox.get('traditional_tiles_enabled', defaultValue: false) as bool;
  }

  Future<void> saveTraditionalTilesEnabled(bool enabled) async {
    final settingsBox = await Hive.openBox('app_settings');
    await settingsBox.put('traditional_tiles_enabled', enabled);
  }
}

