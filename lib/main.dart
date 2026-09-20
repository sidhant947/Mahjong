import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mahjong/data/repositories/settings_repository.dart';
import 'package:mahjong/data/services/hive_service.dart';
import 'package:mahjong/ui/core/theme/app_theme.dart';
import 'package:mahjong/ui/features/home/views/home_view.dart';
import 'package:mahjong/ui/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();

  final settingsRepository = SettingsRepository(hiveService: hiveService);
  await settingsRepository.init();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hiveService),
        settingsRepositoryProvider.overrideWith((ref) => settingsRepository),
      ],
      child: const MahjongApp(),
    ),
  );
}

class MahjongApp extends ConsumerWidget {
  const MahjongApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSkin = ref.watch(currentSkinProvider);

    return MaterialApp(
      title: 'Mahjong Solitaire',
      theme: AppTheme.fromSkin(currentSkin),
      home: const HomeView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
