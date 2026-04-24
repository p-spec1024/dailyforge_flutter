// Shared types for the home-page 3D body map (S10-T5a/b/c).
//
// Both the live BodyMapService (HTTP) and mock_body_map_data.dart (offline)
// emit instances of these types — keep them aligned so the
// kUseMockBodyMap flip is a no-op for downstream widgets.

class RecentWin {
  final String icon;
  final String title;
  final String subtitle;

  const RecentWin({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  /// Backend contract: `List<{icon, title, subtitle}>`, all string values.
  /// See `server/src/routes/bodyMap.js` recent-wins handler.
  factory RecentWin.fromJson(Map<String, dynamic> json) {
    return RecentWin(
      icon: json['icon'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
    );
  }
}

/// Per-muscle tap-card detail (Last trained / Volume / Top exercise / Sets).
/// Currently mock-only — the backend endpoint lands in T5c-b. The fromJson
/// factory is included now so T5c-b is a service-only change.
class MuscleDetail {
  final String lastTrained;
  final String volumeLabel;
  final String topExercise;
  final int setsThisWeek;

  const MuscleDetail({
    required this.lastTrained,
    required this.volumeLabel,
    required this.topExercise,
    required this.setsThisWeek,
  });

  factory MuscleDetail.fromJson(Map<String, dynamic> json) {
    return MuscleDetail(
      lastTrained: json['lastTrained'] as String? ?? '',
      volumeLabel: json['volumeLabel'] as String? ?? '',
      topExercise: json['topExercise'] as String? ?? '',
      setsThisWeek: json['setsThisWeek'] as int? ?? 0,
    );
  }
}
