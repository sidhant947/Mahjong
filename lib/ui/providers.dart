import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mahjong/data/repositories/progress_repository.dart';
import 'package:mahjong/data/services/hive_service.dart';
import 'package:mahjong/domain/use_cases/mahjong_generator.dart';
import 'package:mahjong/ui/features/game/view_models/game_view_model.dart';
import 'package:mahjong/ui/features/home/view_models/home_view_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  throw UnimplementedError('Must be overridden in main');
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
