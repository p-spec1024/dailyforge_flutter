import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../services/api_service.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _api;

  Map<String, dynamic>? _dashboardData;
  Map<String, dynamic>? _todayWorkout;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get dashboardData => _dashboardData;
  Map<String, dynamic>? get todayWorkout => _todayWorkout;
  bool get isLoading => _isLoading;
  String? get error => _error;

  DashboardProvider(this._api);

  // --- Computed getters ---

  String get greeting {
    final hour = DateTime.now().hour;
    final period =
        hour < 12 ? 'morning' : (hour < 17 ? 'afternoon' : 'evening');
    final name = _dashboardData?['user']?['name'] as String? ?? '';
    return name.isNotEmpty ? 'Good $period, $name' : 'Good $period';
  }

  int get currentStreak {
    final weekActivity = _dashboardData?['weekActivity'] as List<dynamic>?;
    if (weekActivity == null || weekActivity.isEmpty) return 0;

    // Count consecutive days ending at today (or most recent activity day)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final activityDates = weekActivity
        .map((e) => DateTime.tryParse(e['date'] as String? ?? ''))
        .whereType<DateTime>()
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();

    int streak = 0;
    // Count backwards from today (capped at 7 — API only returns this week)
    for (int i = 0; i <= 7; i++) {
      final day = today.subtract(Duration(days: i));
      if (activityDates.contains(day)) {
        streak++;
      } else if (i == 0) {
        // Today might not have activity yet — skip and continue
        continue;
      } else {
        break;
      }
    }
    return streak;
  }

  List<Map<String, dynamic>> get recentPRs {
    final prs = _dashboardData?['recentPRs'] as List<dynamic>?;
    if (prs == null) return [];
    return prs.whereType<Map<String, dynamic>>().toList();
  }

  /// 7 bools for Mon–Sun, true if any activity that day.
  List<bool> get weekDots {
    final weekActivity = _dashboardData?['weekActivity'] as List<dynamic>?;
    if (weekActivity == null) return List.filled(7, false);

    final activityDates = <String>{};
    for (final entry in weekActivity) {
      final date = entry['date'] as String?;
      if (date != null) activityDates.add(date);
    }

    // Build Mon–Sun for the current week
    final now = DateTime.now();
    // DateTime.monday == 1
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      final key =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      return activityDates.contains(key);
    });
  }

  Map<String, dynamic>? get milestone => _dashboardData?['milestone'] as Map<String, dynamic>?;

  // --- Data fetching ---

  Future<void> fetchDashboard() async {
    _dashboardData = await _api.get(ApiConfig.dashboard);
  }

  Future<void> fetchTodayWorkout() async {
    _todayWorkout = await _api.get(ApiConfig.workoutToday);
  }

  Future<void> refresh() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([fetchDashboard(), fetchTodayWorkout()]);
      _error = null;
    } on ApiException catch (e) {
      _dashboardData = null;
      _todayWorkout = null;
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
