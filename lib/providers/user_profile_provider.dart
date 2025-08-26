import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:questdo/models/user_profile.dart';

class UserProfileProvider with ChangeNotifier {
  final Box<UserProfile> _userProfileBox = Hive.box<UserProfile>('user_profile');

  UserProfile get userProfile {
    if (_userProfileBox.isEmpty) {
      final defaultProfile = UserProfile(
        xp: 0,
        coins: 0,
        level: 1,
        streak: 0,
        avatarId: 'basic_avatar',
        unlockedThemes: ['dark_mode'],
        unlockedQuotes: ['starter_pack'],
      );
      _userProfileBox.put('profile', defaultProfile);
      return defaultProfile;
    }
    return _userProfileBox.get('profile')!;
  }

  String get selectedTheme => userProfile.unlockedThemes.last;

  void selectTheme(String themeId) {
    final profile = userProfile;
    profile.unlockedThemes.remove(themeId);
    profile.unlockedThemes.add(themeId);
    _userProfileBox.put('profile', profile);
    notifyListeners();
  }

  void addXp(int xp) {
    final profile = userProfile;
    profile.xp += xp;
    profile.level = (profile.xp / 100).floor() + 1;
    _userProfileBox.put('profile', profile);
    notifyListeners();
  }

  void addCoins(int amount) {
    final profile = userProfile;
    profile.coins += amount;
    _userProfileBox.put('profile', profile);
    notifyListeners();
  }

  void unlockTheme(String themeId) {
    final profile = userProfile;
    if (!profile.unlockedThemes.contains(themeId)) {
      profile.unlockedThemes.add(themeId);
      _userProfileBox.put('profile', profile);
      notifyListeners();
    }
  }

  void updateStreak() {
    final profile = userProfile;
    final now = DateTime.now();
    if (profile.lastCompletionDate == null) {
      profile.streak = 1;
    } else {
      final difference = now.difference(profile.lastCompletionDate!).inDays;
      if (difference == 1) {
        profile.streak++;
      } else if (difference > 1) {
        profile.streak = 1;
      }
    }
    profile.lastCompletionDate = now;
    _userProfileBox.put('profile', profile);
    notifyListeners();
  }
}