import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/workout_session_provider.dart';
import '../widgets/workout/exercise_session_card.dart';
import '../widgets/workout/session_header.dart';

class WorkoutPage extends StatefulWidget {
  final int? workoutId;
  final List<Map<String, dynamic>>? initialExercises;

  const WorkoutPage({
    super.key,
    this.workoutId,
    this.initialExercises,
  });

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  String? _lastShownError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSession();
    });
  }

  Future<void> _initSession() async {
    final provider = context.read<WorkoutSessionProvider>();
    if (provider.isActive) return; // Already in a session

    if (widget.workoutId != null && widget.initialExercises != null) {
      await provider.startSession(
          widget.workoutId!, widget.initialExercises!);
    } else {
      await provider.startEmptySession();
    }
  }

  void _showErrorIfNeeded(WorkoutSessionProvider session) {
    final err = session.error;
    if (err != null && err != _lastShownError && session.isActive) {
      _lastShownError = err;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        session.clearError();
      });
    }
  }

  Future<void> _handleFinish(WorkoutSessionProvider session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Finish Workout?'),
        content: Text(
          '${session.totalSets} sets logged  •  ${session.totalVolume.toStringAsFixed(0)} kg total volume',
          style: const TextStyle(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Finish'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final result = await session.completeSession();
      if (mounted && result != null) {
        context.go('/home');
      }
    }
  }

  Future<void> _handleDiscard(WorkoutSessionProvider session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Discard Workout?'),
        content: const Text(
          'All logged sets will be lost. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await session.discardSession();
      if (mounted) {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutSessionProvider>(
      builder: (context, session, _) {
        // Show SnackBar for errors during active session
        _showErrorIfNeeded(session);

        if (session.isLoading && !session.isActive) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.strength),
            ),
          );
        }

        if (session.error != null && !session.isActive) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.alertCircle,
                        size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      session.error!,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.go('/home'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.strength,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (!session.isActive) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Text(
                'No active session',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            _handleDiscard(session);
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                children: [
                  SessionHeader(
                    elapsedNotifier: session.elapsedNotifier,
                    totalVolume: session.totalVolume,
                    totalSets: session.totalSets,
                    onFinish: () => _handleFinish(session),
                    onDiscard: () => _handleDiscard(session),
                    formatTime: session.formatTime,
                  ),
                  Expanded(
                    child: session.exercises.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(LucideIcons.dumbbell,
                                      size: 48,
                                      color: AppColors.secondaryText),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Empty workout\nAdd exercises to get started',
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: session.exercises.length,
                            itemBuilder: (context, index) {
                              final exercise = session.exercises[index];
                              final exerciseId = (exercise['id'] as num).toInt();
                              return ExerciseSessionCard(
                                exercise: exercise,
                                sets:
                                    session.exerciseSets[exerciseId] ?? const [],
                                previousData:
                                    session.previousPerformance[exerciseId],
                                onLogSet: (setNumber, weight, reps) {
                                  session.logSet(
                                      exerciseId, setNumber, weight, reps);
                                },
                                onAddSet: () {
                                  session.addSet(exerciseId);
                                },
                              );
                            },
                          ),
                  ),
                  _buildFinishButton(session),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFinishButton(WorkoutSessionProvider session) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.cardBorder),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: session.isLoading ? null : () => _handleFinish(session),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.success.withValues(alpha: 0.5),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.check, size: 20),
              SizedBox(width: 8),
              Text(
                'Finish Workout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
