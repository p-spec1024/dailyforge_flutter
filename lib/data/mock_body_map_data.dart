// Mock data for S10-T5a (UI-only ticket). When T5c wires real endpoints,
// swap these maps for API responses — the types are shaped to match.

const Map<String, int> mockMuscleVolumes = {
  'Chest': 72, 'Shoulders': 58, 'Biceps': 48, 'Triceps': 65,
  'Forearms': 32, 'Core': 55, 'Back': 78, 'Glutes': 12,
  'Quads': 85, 'Hamstrings': 38, 'Calves': 22,
};

class MockMuscleDetail {
  final String lastTrained;
  final String volumeLabel;
  final String topExercise;
  final int setsThisWeek;

  const MockMuscleDetail({
    required this.lastTrained,
    required this.volumeLabel,
    required this.topExercise,
    required this.setsThisWeek,
  });
}

const Map<String, MockMuscleDetail> mockMuscleDetails = {
  'Chest':      MockMuscleDetail(lastTrained: '2 days ago', volumeLabel: '14,280 kg', topExercise: 'Barbell Bench Press', setsThisWeek: 12),
  'Shoulders':  MockMuscleDetail(lastTrained: '3 days ago', volumeLabel: '8,450 kg',  topExercise: 'Overhead Press',      setsThisWeek: 9),
  'Biceps':     MockMuscleDetail(lastTrained: '4 days ago', volumeLabel: '5,120 kg',  topExercise: 'Barbell Curl',         setsThisWeek: 8),
  'Triceps':    MockMuscleDetail(lastTrained: '2 days ago', volumeLabel: '7,830 kg',  topExercise: 'Close-Grip Bench',     setsThisWeek: 10),
  'Forearms':   MockMuscleDetail(lastTrained: '5 days ago', volumeLabel: '1,200 kg',  topExercise: 'Wrist Curl',           setsThisWeek: 4),
  'Core':       MockMuscleDetail(lastTrained: '1 day ago',  volumeLabel: '—',         topExercise: 'Hanging Leg Raise',    setsThisWeek: 8),
  'Back':       MockMuscleDetail(lastTrained: 'Yesterday',  volumeLabel: '16,900 kg', topExercise: 'Deadlift',             setsThisWeek: 13),
  'Glutes':     MockMuscleDetail(lastTrained: '9 days ago', volumeLabel: '2,100 kg',  topExercise: 'Hip Thrust',           setsThisWeek: 2),
  'Quads':      MockMuscleDetail(lastTrained: 'Yesterday',  volumeLabel: '21,450 kg', topExercise: 'Barbell Squat',        setsThisWeek: 14),
  'Hamstrings': MockMuscleDetail(lastTrained: '4 days ago', volumeLabel: '4,800 kg',  topExercise: 'Romanian Deadlift',    setsThisWeek: 6),
  'Calves':     MockMuscleDetail(lastTrained: '6 days ago', volumeLabel: '3,200 kg',  topExercise: 'Standing Calf Raise',  setsThisWeek: 4),
};

const Map<String, int> mockFlexibilityScores = {
  'Spine': 68, 'Hips': 42, 'Shoulders': 75,
};

const Map<String, int> mockStats = {
  'streakDays': 47,
  'minutesThisWeek': 234,
  'sessionsThisYear': 89,
};

const List<Map<String, dynamic>> mockLast4Weeks = [
  {'week': 'W1', 'strength': 120, 'yoga': 60, 'breath': 30},
  {'week': 'W2', 'strength': 150, 'yoga': 45, 'breath': 40},
  {'week': 'W3', 'strength': 180, 'yoga': 90, 'breath': 20},
  {'week': 'W4', 'strength': 165, 'yoga': 75, 'breath': 50},
];

const List<Map<String, String>> mockRecentWins = [
  {'icon': 'trophy', 'title': 'New PR',           'subtitle': 'Barbell Bench Press — 100 kg × 5'},
  {'icon': 'flame',  'title': '45-day streak',    'subtitle': 'Longest streak yet'},
  {'icon': 'star',   'title': '10 yoga sessions', 'subtitle': 'This month'},
];

const String mockInspirationalStat = '47 days of practice in 2026';
