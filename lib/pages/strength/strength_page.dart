import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/strength_provider.dart';
import '../../widgets/glass_card.dart';
import 'widgets/muscle_filter_chips.dart';
import 'widgets/routine_card.dart';
import 'widgets/exercise_browse_card.dart';

class StrengthPage extends StatefulWidget {
  const StrengthPage({super.key});

  @override
  State<StrengthPage> createState() => _StrengthPageState();
}

class _StrengthPageState extends State<StrengthPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StrengthProvider>();
      provider.fetchMuscleGroups();
      provider.fetchRoutines();
      provider.fetchExercises(reset: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<StrengthProvider>(
          builder: (context, provider, child) {
            return CustomScrollView(
              slivers: [
                // A. Header
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Strength',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // B. Empty Workout Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GlassCard(
                      borderColor: AppColors.strength,
                      onTap: () => debugPrint('Navigate to empty workout'),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.strength.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.plus, color: AppColors.strength),
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Empty Workout',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Start from scratch',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // C. My Routines Section
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
                        child: Text(
                          'My Routines',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      _buildRoutinesSection(provider),
                    ],
                  ),
                ),

                // D. Exercise Browser Section
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                        child: Row(
                          children: [
                            const Text(
                              'Exercise Library',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (provider.totalExercises > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBorder,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${provider.totalExercises}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondaryText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          controller: _searchController,
                          onChanged: provider.setSearch,
                          decoration: InputDecoration(
                            hintText: 'Search exercises...',
                            prefixIcon: const Icon(LucideIcons.search, size: 20, color: AppColors.hintText),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      provider.setSearch('');
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const MuscleFilterChips(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Exercise List
                if (provider.isLoadingExercises && provider.exercises.isEmpty)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(color: AppColors.strength),
                      ),
                    ),
                  )
                else if (provider.exercises.isEmpty)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            Text('No exercises found', style: TextStyle(color: AppColors.secondaryText)),
                            SizedBox(height: 8),
                            Text('🔍', style: TextStyle(fontSize: 24)),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < provider.exercises.length) {
                          return ExerciseBrowseCard(exercise: provider.exercises[index]);
                        } else if (provider.hasMore) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: provider.isLoadingExercises
                                  ? const CircularProgressIndicator(color: AppColors.strength)
                                  : TextButton(
                                      onPressed: provider.loadMore,
                                      child: const Text('Load More', style: TextStyle(color: AppColors.strength)),
                                    ),
                            ),
                          );
                        }
                        return null;
                      },
                      childCount: provider.exercises.length + (provider.hasMore ? 1 : 0),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoutinesSection(StrengthProvider provider) {
    if (provider.isLoadingRoutines) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator(color: AppColors.strength)),
      );
    }

    if (provider.routines.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: GlassCard(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Text('📋', style: TextStyle(fontSize: 24)),
                SizedBox(height: 8),
                Text(
                  'No saved routines yet',
                  style: TextStyle(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: provider.routines.length,
        itemBuilder: (context, index) {
          return RoutineCard(routine: provider.routines[index]);
        },
      ),
    );
  }
}
