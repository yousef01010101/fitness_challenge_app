import 'package:flutter/material.dart';
import '../models/challenge_model.dart';
import 'difficulty_chip.dart';

class ChallengeCard extends StatelessWidget {
  final ChallengeModel challenge;
  final VoidCallback onTap;
  
  // ✅ 1. أضفنا هذا المتغير (اختياري)
  final VoidCallback? onDelete; 

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.onTap,
    this.onDelete, // ✅ 2. أضفناه في الـ Constructor
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- قسم الصورة (كما هو) ---
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                image: challenge.imageUrl != null && challenge.imageUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(challenge.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: challenge.imageUrl == null || challenge.imageUrl!.isEmpty
                  ? Icon(Icons.fitness_center, size: 50, color: theme.primaryColor.withOpacity(0.5))
                  : null,
            ),

            // --- قسم المحتوى ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          challenge.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // ✅ 3. المنطق الجديد:
                      // إذا مررنا دالة حذف -> اعرض أيقونة سلة المهملات
                      // وإلا -> اعرض شارة الصعوبة (Difficulty Chip)
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: onDelete,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(), // لتقليل مساحة الزر
                        )
                      else
                        DifficultyChip(difficulty: challenge.difficulty),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    challenge.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  
                  // شريط المعلومات السفلي
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 16, color: theme.primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        '${challenge.goalValue} ${challenge.unit}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor),
                      ),
                      const Spacer(),
                      // إذا كانت أيقونة الحذف ظاهرة، نعرض الصعوبة في الأسفل بدلاً منها
                      if (onDelete != null) ...[
                         DifficultyChip(difficulty: challenge.difficulty),
                         const SizedBox(width: 8),
                      ],
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          challenge.exerciseType,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}