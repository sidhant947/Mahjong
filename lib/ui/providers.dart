import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mahjong/data/repositories/progress_repository.dart';
import 'package:mahjong/data/services/hive_service.dart';
import 'package:mahjong/domain/use_cases/mahjong_generator.dart';
import 'package:mahjong/ui/features/game/view_models/game_view_model.dart';
import 'package:mahjong/ui/features/home/view_models/home_view_model.dart';

import 'package:mahjong/data/repositories/settings_repository.dart';
import 'package:mahjong/domain/models/app_skin.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

final settingsRepositoryProvider = ChangeNotifierProvider<SettingsRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return SettingsRepository(hiveService: hiveService);
});

final currentSkinProvider = Provider<AppSkin>((ref) {
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  return settingsRepo.currentSkin;
});

final hintHelperEnabledProvider = Provider<bool>((ref) {
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  return settingsRepo.hintHelperEnabled;
});

final hapticsEnabledProvider = Provider<bool>((ref) {
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  return settingsRepo.hapticsEnabled;
});

final traditionalTilesEnabledProvider = Provider<bool>((ref) {
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  return settingsRepo.traditionalTilesEnabled;
});

final dimLowerTilesEnabledProvider = Provider<bool>((ref) {
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  return settingsRepo.dimLowerTilesEnabled;
});

final progressRepositoryProvider = ChangeNotifierProvider<ProgressRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return ProgressRepository(hiveService: hiveService);
});

final mahjongGeneratorProvider = Provider<SolvableMahjongGenerator>((ref) {
  return SolvableMahjongGenerator();
});

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeViewModelState>((ref) {
      final progressRepository = ref.read(progressRepositoryProvider);
      return HomeViewModel(progressRepository: progressRepository);
    });


final gameViewModelProvider =
    StateNotifierProvider.autoDispose<GameViewModel, GameViewModelState>((ref) {
      final progressRepository = ref.read(progressRepositoryProvider);
      final mahjongGenerator = ref.read(mahjongGeneratorProvider);
      return GameViewModel(
        progressRepository: progressRepository,
        mahjongGenerator: mahjongGenerator,
      );
    });
