import 'package:flutter/material.dart';

import '_tokens.dart';

class TodaySessionCard extends StatelessWidget {
  const TodaySessionCard({super.key});

  // Same five phases the rest of the app uses (see legacy home). Colors:
  // opening_breathwork = blue, warmup = teal, main = gold, cooldown = teal,
  // closing_breathwork = blue.
  static const _phases = [
    Color(0xFF3B82F6),
    Color(0xFF14B8A6),
    Color(0xFFF59E0B),
    Color(0xFF14B8A6),
    Color(0xFF3B82F6),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kCardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Push Day',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kPrimaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: _phases
                      .map((c) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration:
                                  BoxDecoration(color: c, shape: BoxShape.circle),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              // TODO(S10-T5c): wire to today's real workout via provider.
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: kCoral,
              side: const BorderSide(color: kCoral),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'Start',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
