import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../data/mock_body_map_data.dart';
import '_tokens.dart';

class Last4WeeksChart extends StatelessWidget {
  const Last4WeeksChart({super.key});

  @override
  Widget build(BuildContext context) {
    const weeks = mockLast4Weeks;
    final maxY = weeks
        .map((w) =>
            (w['strength'] as int) +
            (w['yoga'] as int) +
            (w['breath'] as int))
        .fold<int>(0, (a, b) => a > b ? a : b)
        .toDouble();

    return Container(
      decoration: kCardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LAST 4 WEEKS',
            style: kSectionLabel,
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              _LegendDot(color: kChartStrength, label: 'Strength'),
              SizedBox(width: 12),
              _LegendDot(color: kChartYoga, label: 'Yoga'),
              SizedBox(width: 12),
              _LegendDot(color: kChartBreath, label: 'Breath'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY + (maxY * 0.1),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= weeks.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            weeks[idx]['week'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              color: kSecondaryText,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(weeks.length, (i) {
                  final w = weeks[i];
                  final s = (w['strength'] as int).toDouble();
                  final y = (w['yoga'] as int).toDouble();
                  final b = (w['breath'] as int).toDouble();
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: s + y + b,
                        width: 28,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                        rodStackItems: [
                          BarChartRodStackItem(0, s, kChartStrength),
                          BarChartRodStackItem(s, s + y, kChartYoga),
                          BarChartRodStackItem(s + y, s + y + b, kChartBreath),
                        ],
                      ),
                    ],
                  );
                }),
                barTouchData: BarTouchData(enabled: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: kSecondaryText),
        ),
      ],
    );
  }
}
