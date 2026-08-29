import 'package:flutter/foundation.dart';
import 'package:mahjong/data/services/hive_service.dart';
import 'package:mahjong/domain/models/app_skin.dart';
import 'package:mahjong/ui/core/services/haptic_service.dart';

class SettingsRepository extends ChangeNotifier {
  SettingsRepository({required this.hiveService});

  final HiveService hiveService;
  AppSkin _currentSkin = AppSkin.jadeGarden;
  bool _hintHelperEnabled = true;
  bool _hapticsEnabled = true;

  AppSkin get currentSkin => _currentSkin;
  bool get hintHelperEnabled => _hintHelperEnabled;
  bool get hapticsEnabled => _hapticsEnabled;

  Future<void> init() async {
    final skinId = await hiveService.getSelectedSkinId();
    _currentSkin = AppSkin.fromId(skinId);
    _hintHelperEnabled = await hiveService.getHintHelperEnabled();
    _hapticsEnabled = await hiveService.getHapticsEnabled();
    HapticService.isHapticsEnabled = _hapticsEnabled;
    notifyListeners();
  }

  Future<void> setSkin(AppSkin skin) async {
    _currentSkin = skin;
    notifyListeners();
    await hiveService.saveSelectedSkinId(skin.id);
  }

  Future<void> setHintHelperEnabled(bool enabled) async {
    _hintHelperEnabled = enabled;
    notifyListeners();
    await hiveService.saveHintHelperEnabled(enabled);
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    _hapticsEnabled = enabled;
    HapticService.isHapticsEnabled = enabled;
    notifyListeners();
    await hiveService.saveHapticsEnabled(enabled);
  }
}
