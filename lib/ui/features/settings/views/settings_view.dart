import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mahjong/domain/models/app_skin.dart';
import 'package:mahjong/ui/core/services/haptic_service.dart';
import 'package:mahjong/ui/providers.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  Future<void> _openUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      await launchUrl(url);
    }
  }

  Widget _buildLinkTile({
    required AppSkin skin,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: GestureDetector(
        onTap: () {
          HapticService.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: skin.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: skin.accentColor.withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: skin.primaryColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: skin.headingColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: skin.headingColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: skin.subtextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: skin.subtextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                  Icons.layers_rounded,
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
                                      'Dim Lower Tiles',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: currentSkin.headingColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Darken covered or blocked tiles',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: currentSkin.subtextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: ref.watch(dimLowerTilesEnabledProvider),
                                activeThumbColor: currentSkin.primaryColor,
                                activeTrackColor: currentSkin.primaryColor.withValues(alpha: 0.4),
                                inactiveThumbColor: currentSkin.subtextColor,
                                inactiveTrackColor: Colors.white10,
                                onChanged: (bool value) {
                                  settingsRepo.setDimLowerTilesEnabled(value);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
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
                                  Icons.grid_view_rounded,
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
                                      'Traditional Tiles',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: currentSkin.headingColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Chinese symbols & bamboos instead of emoji',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: currentSkin.subtextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: ref.watch(traditionalTilesEnabledProvider),
                                activeThumbColor: currentSkin.primaryColor,
                                activeTrackColor: currentSkin.primaryColor.withValues(alpha: 0.4),
                                inactiveThumbColor: currentSkin.subtextColor,
                                inactiveTrackColor: Colors.white10,
                                onChanged: (bool value) {
                                  settingsRepo.setTraditionalTilesEnabled(value);
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
                      SizedBox(
                        height: 72,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          itemCount: AppSkin.allSkins.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 14),
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
                                width: 56,
                                height: 56,
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
                                    color: isSelected ? skin.primaryColor : Colors.white24,
                                    width: isSelected ? 3.0 : 1.5,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Text(
                          'CONNECT & SUPPORT',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: currentSkin.subtextColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      _buildLinkTile(
                        skin: currentSkin,
                        icon: Icons.alternate_email_rounded,
                        title: 'Follow on Twitter',
                        subtitle: '@vgbhuop',
                        onTap: () => _openUrl('https://x.com/vgbhuop'),
                      ),
                      _buildLinkTile(
                        skin: currentSkin,
                        icon: Icons.public_rounded,
                        title: 'Follow on Mastodon',
                        subtitle: '@sidhant947@mastodon.social',
                        onTap: () => _openUrl('https://mastodon.social/@sidhant947'),
                      ),
                      _buildLinkTile(
                        skin: currentSkin,
                        icon: Icons.mail_outline_rounded,
                        title: 'Contact Email',
                        subtitle: 'sidhant947@proton.me',
                        onTap: () => _openUrl('mailto:sidhant947@proton.me'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
