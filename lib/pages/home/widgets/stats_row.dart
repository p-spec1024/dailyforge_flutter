import 'package:flutter/material.dart';

import '../../../data/mock_body_map_data.dart';
import '_tokens.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final streak = mockStats['streakDays'] ?? 0;
    final minutes = mockStats['minutesThisWeek'] ?? 0;
    final sessions = mockStats['sessionsThisYear'] ?? 0;
    return Row(
      children: [
        Expanded(child: _stat('$streak', 'DAY STREAK')),
        Expanded(child: _stat('$minutes', 'MINUTES THIS WEEK')),
        Expanded(child: _stat('$sessions', 'SESSIONS IN 2026')),
      ],
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: kCoral,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: kSectionLabel,
        ),
      ],
    );
  }
}
