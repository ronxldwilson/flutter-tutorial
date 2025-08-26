import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:questdo/models/achievement.dart';

class AchievementProvider with ChangeNotifier {
  final Box<String> _unlockedAchievementsBox = Hive.box<String>('unlocked_achievements');

  List<Achievement> get allAchievements => [
        Achievement(
          id: 'first_task',
          title: 'Getting Started',
          condition: 'Complete your first task',
          rewardXP: 10,
        ),
        Achievement(
          id: 'streak_7',
          title: 'Consistency Hero',
          condition: 'Maintain a 7-day streak',
          rewardXP: 50,
        ),
        Achievement(
          id: 'task_master',
          title: 'Task Master',
          condition: 'Complete 100 tasks',
          rewardXP: 200,
        ),
      ];

  List<String> get unlockedAchievementIds => _unlockedAchievementsBox.values.toList();

  void unlockAchievement(String id) {
    if (!_unlockedAchievementsBox.containsKey(id)) {
      _unlockedAchievementsBox.put(id, id);
      notifyListeners();
    }
  }
}
