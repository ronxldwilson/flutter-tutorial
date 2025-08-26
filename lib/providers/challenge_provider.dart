import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:questdo/models/challenge.dart';
import 'package:questdo/models/task.dart';
import 'package:questdo/providers/user_profile_provider.dart';

class ChallengeProvider with ChangeNotifier {
  final Box<Challenge> _challengeBox = Hive.box<Challenge>('challenges');
  final UserProfileProvider _userProfileProvider;

  ChallengeProvider(this._userProfileProvider) {
    _initializeChallenges();
  }

  void _initializeChallenges() {
    if (_challengeBox.isEmpty) {
      _challengeBox.putAll({
        'daily_5_tasks': Challenge(
          id: 'daily_5_tasks',
          title: 'Complete 5 tasks today',
          condition: 'Complete 5 tasks in a single day',
          rewardXP: 30,
        ),
        'weekly_high_priority': Challenge(
          id: 'weekly_high_priority',
          title: 'Finish 10 high priority tasks this week',
          condition: 'Complete 10 high priority tasks in a single week',
          rewardXP: 100,
        ),
      });
    }
  }

  List<Challenge> get allChallenges => _challengeBox.values.toList();

  void checkChallenges(List<Task> tasks) {
    // Daily 5 tasks
    final daily5TasksChallenge = _challengeBox.get('daily_5_tasks');
    if (daily5TasksChallenge != null && !daily5TasksChallenge.isCompleted) {
      final completedToday = tasks.where((task) =>
          task.status == 'Completed' &&
          task.completedAt != null &&
          task.completedAt!.day == DateTime.now().day &&
          task.completedAt!.month == DateTime.now().month &&
          task.completedAt!.year == DateTime.now().year);
      if (completedToday.length >= 5) {
        daily5TasksChallenge.isCompleted = true;
        _challengeBox.put('daily_5_tasks', daily5TasksChallenge);
        _userProfileProvider.addXp(daily5TasksChallenge.rewardXP);
        notifyListeners();
      }
    }

    // Weekly high priority tasks
    final weeklyHighPriorityChallenge = _challengeBox.get('weekly_high_priority');
    if (weeklyHighPriorityChallenge != null && !weeklyHighPriorityChallenge.isCompleted) {
      final completedThisWeek = tasks.where((task) =>
          task.status == 'Completed' &&
          task.completedAt != null &&
          task.priority == 'High' &&
          task.completedAt!.isAfter(DateTime.now().subtract(const Duration(days: 7))));
      if (completedThisWeek.length >= 10) {
        weeklyHighPriorityChallenge.isCompleted = true;
        _challengeBox.put('weekly_high_priority', weeklyHighPriorityChallenge);
        _userProfileProvider.addXp(weeklyHighPriorityChallenge.rewardXP);
        notifyListeners();
      }
    }
  }
}
