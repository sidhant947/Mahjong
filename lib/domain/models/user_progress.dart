import 'package:flutter/foundation.dart';

@immutable
class UserProgress {
  const UserProgress({
    this.currentLevel = 1,
    this.highestLevelCompleted = 0,
  });

  final int currentLevel;
  final int highestLevelCompleted;

  UserProgress copyWith({
    int? currentLevel,
    int? highestLevelCompleted,
  }) {
    return UserProgress(
      currentLevel: currentLevel ?? this.currentLevel,
      highestLevelCompleted: highestLevelCompleted ?? this.highestLevelCompleted,
    );
  }

  UserProgress incrementLevel() {
    return copyWith(
      currentLevel: currentLevel + 1,
      highestLevelCompleted: highestLevelCompleted + 1,
    );
  }
}

