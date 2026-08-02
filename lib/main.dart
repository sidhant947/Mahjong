import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mahjong/data/services/hive_service.dart';
import 'package:mahjong/ui/core/theme/app_theme.dart';
import 'package:mahjong/ui/providers.dart';
import 'package:mahjong/ui/features/home/views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hiveService),
      ],
      child: const MahjongApp(),
    ),
  );
}

class MahjongApp extends StatelessWidget {
  const MahjongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mahjong Solitaire',
      theme: AppTheme.dark,
      home: const HomeView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
