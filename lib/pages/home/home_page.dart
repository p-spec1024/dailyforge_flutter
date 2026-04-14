import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/workout_session_provider.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/workout/resume_banner.dart';

/// Extract workout ID and exercises from the main phase only.
/// Warmup/cooldown phases contain yoga poses and are excluded.
({int? workoutId, List<Map<String, dynamic>> exercises}) _extractWorkoutData(
    Map<String, dynamic> workout) {
  final phases = workout['phases'] as List<dynamic>? ?? [];
  final exercises = <Map<String, dynamic>>[];
  int? workoutId;
  for (final phase in phases) {
    workoutId ??= phase['workout_id'] as int?;
    final phaseKey = phase['phase'] as String? ?? '';
    if (phaseKey != 'main') continue;
    final phaseExercises = phase['exercises'] as List<dynamic>? ?? [];
    for (final ex in phaseExercises) {
      if (ex is Map<String, dynamic>) exercises.add(ex);
    }
  }
  return (workoutId: workoutId, exercises: exercises);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _lastShownError;
  Map<String, dynamic>? _activeSession;
  bool _checkingActive = false;
  bool _wasSessionActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DashboardProvider>();
      provider.addListener(_maybeShowErrorSnack);
      if (provider.dashboardData == null) {
        provider.refresh();
      }
      final session = context.read<WorkoutSessionProvider>();
      _wasSessionActive = session.isActive;
      session.addListener(_onSessionChanged);
      _refreshActiveSession();
    });
  }

  @override
  void dispose() {
    context.read<DashboardProvider>().removeListener(_maybeShowErrorSnack);
    context.read<WorkoutSessionProvider>().removeListener(_onSessionChanged);
    super.dispose();
  }

  /// Re-check `/session/active` whenever the in-app session transitions
  /// (active → idle or idle → active) so the banner never goes stale when
  /// the user pops back from `/workout`.
  void _onSessionChanged() {
    final session = context.read<WorkoutSessionProvider>();
    if (session.isActive != _wasSessionActive) {
      _wasSessionActive = session.isActive;
      _refreshActiveSession();
    }
  }

  Future<void> _refreshActiveSession() async {
    if (_checkingActive) return;
    _checkingActive = true;
    try {
      final session = context.read<WorkoutSessionProvider>();
      // Don't show the banner while the user is actively in a session in-app.
      if (session.isActive) {
        if (!mounted) return;
        setState(() => _activeSession = null);
        return;
      }
      final data = await session.checkActiveSession();
      if (!mounted) return;
      setState(() => _activeSession = data);
    } finally {
      _checkingActive = false;
    }
  }

  void _handleResume() {
    final data = _activeSession;
    if (data == null) return;
    context.push('/workout/empty', extra: {'resumeData': data});
    setState(() => _activeSession = null);
  }

  Future<void> _handleDiscard() async {
    final data = _activeSession;
    if (data == null) return;
    final sessionJson = data['session'] as Map<String, dynamic>?;
    final rawId = sessionJson?['id'];
    final sessionId = rawId is num
        ? rawId.toInt()
        : (rawId is String ? int.tryParse(rawId) : null);
    if (sessionId == null) return;
    final ok = await context
        .read<WorkoutSessionProvider>()
        .discardActiveSession(sessionId);
    if (!mounted) return;
    if (ok) {
      setState(() => _activeSession = null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not discard session. Try again.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _maybeShowErrorSnack() {
    if (!mounted) return;
    final provider = context.read<DashboardProvider>();
    final err = provider.error;
    if (err == null) {
      _lastShownError = null;
      return;
    }
    if (err == _lastShownError) return;
    _lastShownError = err;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: AppColors.surface,
          action: SnackBarAction(
            label: 'Retry',
            textColor: AppColors.gold,
            onPressed: () => provider.refresh(),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.dashboardData == null) {
            return _buildSkeleton();
          }

          if (provider.error != null && provider.dashboardData == null) {
            return _buildError(provider);
          }

          return RefreshIndicator(
            color: AppColors.gold,
            backgroundColor: AppColors.surface,
            onRefresh: () async {
              await Future.wait([
                provider.refresh(),
                _refreshActiveSession(),
              ]);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 56, 16, 24),
              children: [
                _GreetingRow(provider: provider),
                const SizedBox(height: 20),
                if (_activeSession != null) ...[
                  ResumeBanner(
                    startedAt: DateTime.tryParse(
                          _activeSession!['session']?['started_at']
                                  as String? ??
                              '',
                        ) ??
                        DateTime.now(),
                    onResume: _handleResume,
                    onDiscard: _handleDiscard,
                  ),
                  const SizedBox(height: 20),
                ],
                _TodaySessionCard(provider: provider),
                const SizedBox(height: 20),
                _QuickStartButtons(provider: provider),
                const SizedBox(height: 20),
                _WeekProgress(provider: provider),
                const SizedBox(height: 20),
                _RecentWinsCard(provider: provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 56, 16, 24),
      children: [
        // Greeting skeleton
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _skeletonBox(180, 24),
            _skeletonBox(50, 24),
          ],
        ),
        const SizedBox(height: 20),
        // Today card skeleton
        _skeletonBox(double.infinity, 180),
        const SizedBox(height: 20),
        // Quick start skeleton
        Row(
          children: [
            Expanded(child: _skeletonBox(double.infinity, 80)),
            const SizedBox(width: 10),
            Expanded(child: _skeletonBox(double.infinity, 80)),
            const SizedBox(width: 10),
            Expanded(child: _skeletonBox(double.infinity, 80)),
          ],
        ),
        const SizedBox(height: 20),
        // Week dots skeleton
        _skeletonBox(double.infinity, 60),
        const SizedBox(height: 20),
        // Recent wins skeleton
        _skeletonBox(double.infinity, 100),
      ],
    );
  }

  Widget _skeletonBox(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildError(DashboardProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.wifiOff, size: 48, color: AppColors.secondaryText),
            const SizedBox(height: 16),
            Text(
              provider.error ?? 'Something went wrong',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.black,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Section Widgets ---

class _GreetingRow extends StatelessWidget {
  final DashboardProvider provider;
  const _GreetingRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            provider.greeting,
            style: Theme.of(context).textTheme.headlineSmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔥', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 4),
            Text(
              '${provider.currentStreak}',
              style: monoStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TodaySessionCard extends StatelessWidget {
  final DashboardProvider provider;
  const _TodaySessionCard({required this.provider});

  static const _phaseConfig = <String, _PhaseInfo>{
    'opening_breathwork': _PhaseInfo('Br', Color(0xFF3B82F6)),
    'warmup': _PhaseInfo('Wm', Color(0xFF14B8A6)),
    'main': _PhaseInfo('St', Color(0xFFF59E0B)),
    'cooldown': _PhaseInfo('Cl', Color(0xFF14B8A6)),
    'closing_breathwork': _PhaseInfo('En', Color(0xFF3B82F6)),
  };

  void _startWorkout(BuildContext context, Map<String, dynamic> workout) {
    final (:workoutId, :exercises) = _extractWorkoutData(workout);

    if (workoutId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not determine workout')),
      );
      return;
    }

    context.push('/workout', extra: {
      'workoutId': workoutId,
      'exercises': exercises,
    });
  }

  @override
  Widget build(BuildContext context) {
    final workout = provider.todayWorkout;

    if (workout == null) {
      return GlassCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'No workout scheduled for today',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    final dayLabel = (workout['day_label'] as String? ?? '').toUpperCase();
    final name = workout['name'] as String? ?? '';
    final phases = workout['phases'] as List<dynamic>? ?? [];
    final exerciseCount = phases.fold<int>(
        0, (sum, p) => sum + ((p['exercises'] as List<dynamic>?)?.length ?? 0));
    // Rough estimate: ~3 min per exercise
    final estMinutes = exerciseCount * 3;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dayLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          // Phase dots
          Row(
            children: phases.map<Widget>((p) {
              final phaseKey = p['phase'] as String? ?? '';
              final info = _phaseConfig[phaseKey];
              if (info == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: info.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      info.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: info.color,
                          ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(
            '$exerciseCount exercises  •  ~$estMinutes min',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _startWorkout(context, workout),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.strength,
                disabledBackgroundColor: AppColors.strength.withValues(alpha: 0.6),
                disabledForegroundColor: Colors.white70,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Start Full Session',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseInfo {
  final String label;
  final Color color;
  const _PhaseInfo(this.label, this.color);
}

class _QuickStartButtons extends StatelessWidget {
  final DashboardProvider provider;
  const _QuickStartButtons({required this.provider});

  void _startStrength(BuildContext context) {
    final workout = provider.todayWorkout;
    if (workout == null) {
      context.push('/workout');
      return;
    }

    final (:workoutId, :exercises) = _extractWorkoutData(workout);

    if (workoutId == null || exercises.isEmpty) {
      context.push('/workout');
      return;
    }

    context.push('/workout', extra: {
      'workoutId': workoutId,
      'exercises': exercises,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickStartCard(
            label: 'Strength',
            icon: LucideIcons.dumbbell,
            color: AppColors.strength,
            onTap: () => _startStrength(context),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: _QuickStartCard(
            label: 'Yoga',
            icon: LucideIcons.personStanding,
            color: AppColors.yoga,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: _QuickStartCard(
            label: 'Breathwork',
            icon: LucideIcons.wind,
            color: AppColors.purple,
          ),
        ),
      ],
    );
  }
}

class _QuickStartCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _QuickStartCard({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: color,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

class _WeekProgress extends StatelessWidget {
  final DashboardProvider provider;
  const _WeekProgress({required this.provider});

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final dots = provider.weekDots;
    // Monday = 1, today's index in 0-based Mon–Sun
    final todayIndex = DateTime.now().weekday - 1;

    return GlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (i) {
          final active = dots[i];
          final isToday = i == todayIndex;

          return Column(
            children: [
              Text(
                _dayLabels[i],
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? AppColors.gold : Colors.transparent,
                  border: Border.all(
                    color: isToday
                        ? AppColors.gold
                        : (active
                            ? AppColors.gold
                            : AppColors.secondaryText.withValues(alpha: 0.3)),
                    width: isToday ? 2 : 1,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _RecentWinsCard extends StatelessWidget {
  final DashboardProvider provider;
  const _RecentWinsCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final prs = provider.recentPRs;
    final milestone = provider.milestone;
    final hasContent = prs.isNotEmpty || milestone != null;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Wins',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 12),
          if (!hasContent)
            Text(
              'Start your first workout to see wins here!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          if (prs.isNotEmpty)
            ...prs.take(3).map((pr) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pr['exercise'] as String? ?? '',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      Text(
                        _formatPRValue(pr),
                        style: monoStyle.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                )),
          if (milestone != null) ...[
            if (prs.isNotEmpty) const SizedBox(height: 4),
            Row(
              children: [
                const Text('🎯', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  milestone['count'] != null
                      ? '${milestone['count']} sessions milestone!'
                      : 'Milestone reached!',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatPRValue(Map<String, dynamic> pr) {
    final weight = pr['weight'];
    final reps = pr['reps'];
    if (weight != null && reps != null) return '${weight}kg × $reps';
    if (weight != null) return '${weight}kg';
    if (reps != null) return '$reps reps';
    return '';
  }
}
