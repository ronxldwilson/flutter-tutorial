import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 1)
class UserProfile {
  @HiveField(0)
  int xp;

  @HiveField(1)
  int coins;

  @HiveField(2)
  int level;

  @HiveField(3)
  int streak;

  @HiveField(4)
  String avatarId;

  @HiveField(5)
  List<String> unlockedThemes;

  @HiveField(6)
  List<String> unlockedQuotes;

  @HiveField(7)
  DateTime? lastCompletionDate;

  UserProfile({
    required this.xp,
    required this.coins,
    required this.level,
    required this.streak,
    required this.avatarId,
    required this.unlockedThemes,
    required this.unlockedQuotes,
    this.lastCompletionDate,
  });
}