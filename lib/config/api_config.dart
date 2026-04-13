class ApiConfig {
  // Android emulator: 10.0.2.2 maps to host machine's localhost
  // Physical device: use your machine's local IP (e.g., 192.168.1.x)
  static const String baseUrl = 'http://10.0.2.2:3001/api';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/auth/profile';

  // Workouts
  static const String workouts = '/workouts';
  static const String activeWorkout = '/workouts/active';
  static const String startWorkout = '/workouts/start';
  static const String completeWorkout = '/workouts/complete';
  static const String logSet = '/workouts/log-set';
  static const String deleteSet = '/workouts/delete-set';

  // Exercises
  static const String exercises = '/exercises';
  static const String exercisesStrength = '/exercises/strength';
  static const String exerciseMuscleGroups = '/exercises/muscle-groups';
  static const String exerciseAlternatives = '/exercises/alternatives';
  static const String exerciseSwap = '/exercises/swap';

  // Routines
  static const String routines = '/routines';

  // Yoga
  static const String yogaPoses = '/yoga/poses';
  static const String yogaSession = '/yoga/session';
  static const String yogaComplete = '/yoga/complete';

  // Breathwork
  static const String breathworkTechniques = '/breathwork/techniques';
  static const String breathworkLog = '/breathwork/log';

  // Dashboard
  static const String dashboard = '/dashboard';
  static const String workoutToday = '/workout/today';

  // Analytics
  static const String progressionData = '/analytics/progression';
  static const String suggestions = '/analytics/suggestions';
  static const String calendar = '/analytics/calendar';

  // Body Metrics
  static const String bodyMetrics = '/body-metrics';

  // Sessions (5-phase)
  static const String sessions = '/sessions';

  // Helper to build full URL
  static String url(String endpoint) => '$baseUrl$endpoint';
}
