import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../widgets/glass_card.dart';
import '../../../providers/strength_provider.dart';

class RoutineCard extends StatelessWidget {
  final Map<String, dynamic> routine;

  const RoutineCard({super.key, required this.routine});

  String _timeAgo(String dateString) {
    final date = DateTime.parse(dateString);
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'just now';
  }

  @override
  Widget build(BuildContext context) {
    final id = routine['id'];
    final name = routine['name'];
    final exerciseCount = routine['exercise_count'];
    final dateString = routine['updated_at'] ?? DateTime.now().toIso8601String();

    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        onTap: () => debugPrint('Start routine $id'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$exerciseCount exercises • ${_timeAgo(dateString)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.trash2, size: 20, color: AppColors.error),
                  onPressed: () => _showDeleteDialog(context, id, name),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.play, size: 16, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Routine?', style: TextStyle(color: Colors.white)),
        content: Text('Delete "$name"? This cannot be undone.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
          ),
          TextButton(
            onPressed: () {
              context.read<StrengthProvider>().deleteRoutine(id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
