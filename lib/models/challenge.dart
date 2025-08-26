import 'package:hive/hive.dart';

part 'challenge.g.dart';

@HiveType(typeId: 2)
class Challenge {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String condition;
  @HiveField(3)
  final int rewardXP;
  @HiveField(4)
  bool isCompleted;

  Challenge({
    required this.id,
    required this.title,
    required this.condition,
    required this.rewardXP,
    this.isCompleted = false,
  });
}
