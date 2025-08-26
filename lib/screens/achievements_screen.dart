import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:questdo/providers/achievement_provider.dart';
import 'package:share_plus/share_plus.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievementProvider = Provider.of<AchievementProvider>(context);
    final allAchievements = achievementProvider.allAchievements;
    final unlockedAchievementIds = achievementProvider.unlockedAchievementIds;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: ListView.builder(
        itemCount: allAchievements.length,
        itemBuilder: (context, index) {
          final achievement = allAchievements[index];
          final isUnlocked = unlockedAchievementIds.contains(achievement.id);

          return ListTile(
            title: Text(achievement.title),
            subtitle: Text(achievement.condition),
            trailing: isUnlocked
                ? IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      Share.share('I just unlocked the achievement "${achievement.title}" in QuestDo!');
                    },
                  )
                : const Icon(Icons.lock),
          );
        },
      ),
    );
  }
}