import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:questdo/providers/achievement_provider.dart';
import 'package:questdo/providers/challenge_provider.dart';
import 'package:questdo/providers/task_provider.dart';
import 'package:questdo/providers/user_profile_provider.dart';
import 'package:questdo/screens/add_task_screen.dart';
import 'package:questdo/screens/achievements_screen.dart';
import 'package:questdo/screens/challenges_screen.dart';
import 'package:questdo/screens/settings_screen.dart';
import 'package:confetti/confetti.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ConfettiController _confettiController;
  late int _currentLevel; // To track level changes

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _currentLevel = Provider.of<UserProfileProvider>(context, listen: false).userProfile.level;

    // Listen for level changes
    Provider.of<UserProfileProvider>(context, listen: false).addListener(_onUserProfileChanged);
  }

  void _onUserProfileChanged() {
    final newLevel = Provider.of<UserProfileProvider>(context, listen: false).userProfile.level;
    if (newLevel > _currentLevel) {
      _currentLevel = newLevel;
      _showLevelUpDialog(newLevel);
    }
  }

  void _showLevelUpDialog(int newLevel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Level Up!'),
        content: Text('Congratulations! You reached Level $newLevel!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    Provider.of<UserProfileProvider>(context, listen: false).removeListener(_onUserProfileChanged); // Remove listener
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<UserProfileProvider>(
          builder: (context, userProfileProvider, child) {
            final userProfile = userProfileProvider.userProfile;
            return Flexible(
              child: Text(
                'Level ${userProfile.level} (${userProfile.xp} XP)',
                overflow: TextOverflow.ellipsis, // Handle overflow gracefully
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.military_tech),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AchievementsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.flag), // New button for challenges
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ChallengesScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              final tasks = taskProvider.tasks;
              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return ListTile(
                    title: Text(task.title),
                    leading: Checkbox(
                      value: task.status == 'Completed',
                      onChanged: (bool? value) {
                        if (value != null) {
                          final newStatus = value ? 'Completed' : 'Pending';
                          Provider.of<TaskProvider>(context, listen: false)
                              .updateTaskStatus(task.id, newStatus);
                          if (newStatus == 'Completed') {
                            final userProfileProvider = Provider.of<UserProfileProvider>(context, listen: false);
                            final achievementProvider = Provider.of<AchievementProvider>(context, listen: false);
                            final taskProvider = Provider.of<TaskProvider>(context, listen: false);
                            final challengeProvider = Provider.of<ChallengeProvider>(context, listen: false);

                            int xp = 0;
                            switch (task.priority) {
                              case 'Low':
                                xp = 5;
                                break;
                              case 'Medium':
                                xp = 10;
                                break;
                              case 'High':
                                xp = 20;
                                break;
                            }
                            userProfileProvider.addXp(xp);
                            userProfileProvider.addCoins(5);
                            userProfileProvider.updateStreak();

                            // Check for achievements
                            if (taskProvider.tasks.where((task) => task.status == 'Completed').length == 1) {
                              achievementProvider.unlockAchievement('first_task');
                              userProfileProvider.addXp(10);
                            }
                            if (userProfileProvider.userProfile.streak == 7) {
                              achievementProvider.unlockAchievement('streak_7');
                              userProfileProvider.addXp(50);
                            }
                            if (taskProvider.tasks.where((task) => task.status == 'Completed').length == 100) {
                              achievementProvider.unlockAchievement('task_master');
                              userProfileProvider.addXp(200);
                            }

                            // Check for challenges
                            challengeProvider.checkChallenges(taskProvider.tasks);

                            _confettiController.play();
                          }
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddTaskScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
