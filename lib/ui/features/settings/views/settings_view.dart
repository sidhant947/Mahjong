import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mahjong/domain/models/app_skin.dart';
import 'package:mahjong/ui/core/services/haptic_service.dart';
import 'package:mahjong/ui/providers.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSkin = ref.watch(currentSkinProvider);
    final settingsRepo = ref.read(settingsRepositoryProvider);

    return Scaffold(
      backgroundColor: currentSkin.scaffoldBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.2),
            radius: 1.2,
            colors: currentSkin.bgGradient,
            stops: const [0.0, 0.65, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Navigation Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticService.lightImpact();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: currentSkin.surfaceColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white24,
                            width: 1.0,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: currentSkin.headingColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'SETTINGS',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: currentSkin.headingColor,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),

              // Game Helpers Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: currentSkin.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: currentSkin.accentColor.withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: currentSkin.primaryColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lightbulb_outline_rounded,
                          color: currentSkin.headingColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hint Helper',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: currentSkin.headingColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Show hint button in game',
                              style: TextStyle(
                                fontSize: 12,
                                color: currentSkin.subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: ref.watch(hintHelperEnabledProvider),
                        activeThumbColor: currentSkin.primaryColor,
                        activeTrackColor: currentSkin.primaryColor.withValues(alpha: 0.4),
                        inactiveThumbColor: currentSkin.subtextColor,
                        inactiveTrackColor: Colors.white10,
                        onChanged: (bool value) {
                          settingsRepo.setHintHelperEnabled(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Haptic Feedback Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: currentSkin.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: currentSkin.accentColor.withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: currentSkin.primaryColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.vibration_rounded,
                          color: currentSkin.headingColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Haptic Feedback',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: currentSkin.headingColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Vibrate on tile taps and matches',
                              style: TextStyle(
                                fontSize: 12,
                                color: currentSkin.subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: ref.watch(hapticsEnabledProvider),
                        activeThumbColor: currentSkin.primaryColor,
                        activeTrackColor: currentSkin.primaryColor.withValues(alpha: 0.4),
                        inactiveThumbColor: currentSkin.subtextColor,
                        inactiveTrackColor: Colors.white10,
                        onChanged: (bool value) {
                          settingsRepo.setHapticsEnabled(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  'CHOOSE YOUR THEME',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: currentSkin.subtextColor,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              // Themes List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: AppSkin.allSkins.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final skin = AppSkin.allSkins[index];
                    final isSelected = skin.id == currentSkin.id;

                    return GestureDetector(
                      onTap: () {
                        HapticService.selectionClick();
                        settingsRepo.setSkin(skin);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: skin.surfaceColor.withValues(alpha: isSelected ? 0.95 : 0.7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? skin.primaryColor : Colors.white12,
                            width: isSelected ? 2.5 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: skin.glowColor.withValues(alpha: 0.35),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            // Theme Color Palette Swatch
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    skin.primaryColor,
                                    skin.accentColor,
                                    skin.bgGradient.first,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: Colors.white30,
                                  width: 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            // Theme Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    skin.name.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: skin.headingColor,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    skin.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: skin.subtextColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: skin.primaryColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: skin.primaryColor, width: 1),
                                ),
                                child: Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: skin.headingColor,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
