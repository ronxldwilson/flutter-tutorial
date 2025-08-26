import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:questdo/providers/challenge_provider.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final challengeProvider = Provider.of<ChallengeProvider>(context);
    final allChallenges = challengeProvider.allChallenges;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenges'),
      ),
      body: ListView.builder(
        itemCount: allChallenges.length,
        itemBuilder: (context, index) {
          final challenge = allChallenges[index];
          return ListTile(
            title: Text(challenge.title),
            subtitle: Text(challenge.condition),
            trailing: challenge.isCompleted
                ? const Icon(Icons.check_circle, color: Colors.green) 
                : const Icon(Icons.hourglass_empty),
          );
        },
      ),
    );
  }
}
