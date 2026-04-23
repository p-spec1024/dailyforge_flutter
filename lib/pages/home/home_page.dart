import 'package:flutter/material.dart';

import '../../data/mock_body_map_data.dart';
import 'widgets/_tokens.dart';
import 'widgets/body_map_3d.dart';
import 'widgets/heatmap_legend.dart';
import 'widgets/inspirational_stat.dart';
import 'widgets/last_4_weeks_chart.dart';
import 'widgets/mode_toggle.dart';
import 'widgets/recent_wins_list.dart';
import 'widgets/selected_muscle_card.dart';
import 'widgets/stats_row.dart';
import 'widgets/today_session_card.dart';

/// DailyForge home page (S10-T5a). Light aesthetic, hero 3D body map.
/// Sprint 8's dashboard version preserved at `_legacy/home_page_s8.dart`.
///
/// T5a is mock-data only — see `lib/data/mock_body_map_data.dart`. Real
/// data wiring arrives in T5b (endpoints) + T5c (provider integration).
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BodyMapMode _mode = BodyMapMode.muscles;
  String? _selectedGroup;

  void _onMuscleTap(String? group) {
    // Pure mirror of native selection — no tap-toggle logic here. Native
    // already handles "tap same mesh → deselect" (or equivalent semantics)
    // and reports the authoritative result via onSelectionChanged.
    setState(() {
      _selectedGroup = group;
    });
  }

  void _onModeChanged(BodyMapMode mode) {
    if (mode == _mode) return;
    setState(() {
      _mode = mode;
      _selectedGroup = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Local light Theme scoped to the home page only — other tabs keep
    // using the app-wide dark theme defined in config/theme.dart.
    return Theme(
      data: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: kCream,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: kCoral,
          selectionColor: Color(0x33D85A30),
          selectionHandleColor: kCoral,
        ),
      ),
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const _TopBar(),
                    const SizedBox(height: 24),
                    const Text('TODAY', style: kSectionLabel),
                    const SizedBox(height: 12),
                    ModeToggle(mode: _mode, onChanged: _onModeChanged),
                    const SizedBox(height: 16),
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                child: BodyMap3D(
                  mode: _mode,
                  muscleVolumes: mockMuscleVolumes,
                  flexibilityScores: mockFlexibilityScores,
                  onMuscleTap: _onMuscleTap,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    SelectedMuscleCard(
                      mode: _mode,
                      selectedGroup: _selectedGroup,
                      flexibilityScores: mockFlexibilityScores,
                    ),
                    const SizedBox(height: 16),
                    HeatmapLegend(mode: _mode),
                    const SizedBox(height: 24),
                    const TodaySessionCard(),
                    const SizedBox(height: 24),
                    const StatsRow(),
                    const SizedBox(height: 24),
                    const Last4WeeksChart(),
                    const SizedBox(height: 24),
                    const RecentWinsList(),
                    const InspirationalStat(),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'DailyForge',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: kPrimaryText,
          ),
        ),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: kCoral.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.person_outline, size: 18, color: kCoral),
        ),
      ],
    );
  }
}
