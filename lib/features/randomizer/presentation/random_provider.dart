import 'package:flutter_riverpod/legacy.dart';
import '../../../models/preset.dart';

// History entry with count for duplicate tracking
class HistoryEntry {
  final Meal meal;
  int count;

  HistoryEntry({required this.meal, this.count = 1});
}

// Tracks how many times the user has hit 'Random'
final randomCountProvider = StateProvider<int>((ref) => 0);

// Tracks the meals selected in the current session with counts
final historyProvider = StateProvider<List<HistoryEntry>>((ref) => []);
