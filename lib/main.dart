import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:questdo/models/challenge.dart';
import 'package:questdo/models/task.dart';
import 'package:questdo/models/user_profile.dart';
import 'package:questdo/providers/achievement_provider.dart';
import 'package:questdo/providers/challenge_provider.dart';
import 'package:questdo/providers/task_provider.dart';
import 'package:questdo/providers/user_profile_provider.dart';
import 'package:questdo/screens/home_screen.dart';
import 'package:questdo/themes.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(ChallengeAdapter());
  await Hive.openBox<Task>('tasks');
  await Hive.openBox<UserProfile>('user_profile');
  await Hive.openBox<String>('unlocked_achievements');
  await Hive.openBox<Challenge>('challenges');
  runApp(const QuestDoApp());
}

class QuestDoApp extends StatelessWidget {
  const QuestDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TaskProvider()),
        ChangeNotifierProvider(create: (context) => UserProfileProvider()),
        ChangeNotifierProvider(create: (context) => AchievementProvider()),
        ChangeNotifierProvider(create: (context) => ChallengeProvider(Provider.of<UserProfileProvider>(context, listen: false))), // Pass UserProfileProvider
      ],
      child: Consumer<UserProfileProvider>(
        builder: (context, userProfileProvider, child) {
          return MaterialApp(
            title: 'QuestDo',
            theme: themes[userProfileProvider.selectedTheme],
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
