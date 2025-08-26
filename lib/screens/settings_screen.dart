import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:questdo/providers/user_profile_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    final userProfile = userProfileProvider.userProfile;

    final themes = {
      'dark_mode': {'name': 'Dark Mode', 'cost': 50},
      'cyberpunk': {'name': 'Cyberpunk', 'cost': 200},
      'nature': {'name': 'Nature', 'cost': 150},
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView.builder(
        itemCount: themes.length,
        itemBuilder: (context, index) {
          final themeId = themes.keys.elementAt(index);
          final theme = themes[themeId]!;
          final isUnlocked = userProfile.unlockedThemes.contains(themeId);

          return ListTile(
            title: Text(theme['name'] as String),
            selected: userProfileProvider.selectedTheme == themeId,
            trailing: isUnlocked
                ? ElevatedButton(
                    onPressed: () {
                      userProfileProvider.selectTheme(themeId);
                    },
                    child: const Text('Select'),
                  )
                : ElevatedButton(
                    onPressed: userProfile.coins >= (theme['cost'] as int)
                        ? () {
                            userProfileProvider.unlockTheme(themeId);
                            userProfileProvider.addCoins(-(theme['cost'] as int));
                          }
                        : null,
                    child: Text('${theme['cost']} Coins'),
                  ),
          );
        },
      ),
    );
  }
}