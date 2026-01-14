import 'package:flutter/material.dart';
import '../models/challenge_model.dart';

class DifficultyChip extends StatelessWidget {
  final ChallengeDifficulty difficulty;

  const DifficultyChip({super.key, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (difficulty) {
      case ChallengeDifficulty.easy:
        color = Colors.green;
        label = "Easy";
        break;
      case ChallengeDifficulty.medium:
        color = Colors.orange;
        label = "Medium";
        break;
      case ChallengeDifficulty.hard:
        color = Colors.red;
        label = "Hard";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}