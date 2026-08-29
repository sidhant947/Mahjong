import 'package:flutter/services.dart';

class HapticService {
  static bool isHapticsEnabled = true;

  static void lightImpact() {
    if (!isHapticsEnabled) return;
    HapticFeedback.lightImpact().catchError((_) {});
  }

  static void mediumImpact() {
    if (!isHapticsEnabled) return;
    HapticFeedback.mediumImpact().catchError((_) {});
  }

  static void heavyImpact() {
    if (!isHapticsEnabled) return;
    HapticFeedback.heavyImpact().catchError((_) {});
  }

  static void selectionClick() {
    if (!isHapticsEnabled) return;
    HapticFeedback.selectionClick().catchError((_) {});
  }

  static void vibrate() {
    if (!isHapticsEnabled) return;
    HapticFeedback.vibrate().catchError((_) {});
  }
}
