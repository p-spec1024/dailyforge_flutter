import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class StrengthProvider extends ChangeNotifier {
  final ApiService _api;

  // Exercise browser state
  List<Map<String, dynamic>> exercises = [];
  int totalExercises = 0;
  bool hasMore = false;
  bool isLoadingExercises = false;
  String? exerciseError;

  // Filters
  String searchQuery = '';
  String? selectedMuscle; // null = "All"
  List<String> muscleGroups = [];

  // Routines
  List<Map<String, dynamic>> routines = [];
  bool isLoadingRoutines = false;

  // Selected exercise for detail modal
  Map<String, dynamic>? selectedExercise;

  // Pagination
  int _offset = 0;
  static const int _pageSize = 30;

  Timer? _debounce;

  StrengthProvider(this._api);

  Future<void> fetchExercises({bool reset = false}) async {
    if (reset) {
      _offset = 0;
      exercises = [];
      hasMore = false;
    }

    isLoadingExercises = true;
    exerciseError = null;
    notifyListeners();

    try {
      final muscleParam = selectedMuscle != null ? '&muscle=$selectedMuscle' : '';
      final searchParam = searchQuery.isNotEmpty ? '&search=$searchQuery' : '';
      final path = '/api/exercises/strength?limit=$_pageSize&offset=$_offset$muscleParam$searchParam';
      
      final response = await _api.get(path);
      
      final newExercises = List<Map<String, dynamic>>.from(response['exercises']);
      totalExercises = response['total'] ?? 0;
      hasMore = response['hasMore'] ?? false;

      if (reset) {
        exercises = newExercises;
      } else {
        exercises.addAll(newExercises);
      }

      isLoadingExercises = false;
      notifyListeners();
    } catch (e) {
      exerciseError = e.toString();
      isLoadingExercises = false;
      notifyListeners();
    }
  }

  Future<void> fetchMuscleGroups() async {
    try {
      final response = await _api.get('/api/exercises/muscle-groups');
      muscleGroups = List<String>.from(response['groups']);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching muscle groups: $e');
    }
  }

  Future<void> fetchRoutines() async {
    isLoadingRoutines = true;
    notifyListeners();

    try {
      final response = await _api.get('/api/routines');
      routines = List<Map<String, dynamic>>.from(response as List);
      isLoadingRoutines = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching routines: $e');
      isLoadingRoutines = false;
      notifyListeners();
    }
  }

  Future<void> deleteRoutine(int id) async {
    try {
      await _api.delete('/api/routines/$id');
      routines.removeWhere((r) => r['id'] == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting routine: $e');
    }
  }

  void setSearch(String query) {
    if (searchQuery == query) return;
    searchQuery = query;

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      fetchExercises(reset: true);
    });
  }

  void setMuscleFilter(String? muscle) {
    if (selectedMuscle == muscle) return;
    selectedMuscle = muscle;
    fetchExercises(reset: true);
  }

  Future<void> loadMore() async {
    if (isLoadingExercises || !hasMore) return;
    _offset += _pageSize;
    await fetchExercises();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
