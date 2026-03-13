import 'package:flutter_riverpod/legacy.dart';
import '../../../models/preset.dart';

// History entry with count for duplicate tracking
class HistoryEntry {
  final Meal meal;
  int count;

  HistoryEntry({required this.meal, this.count = 1});
}

// Per-preset spin count: keyed by presetId
final randomCountProviders = StateProvider.family<int, String>(
  (ref, presetId) => 0,
);

// Per-preset history: keyed by presetId
final historyProviders = StateProvider.family<List<HistoryEntry>, String>(
  (ref, presetId) => [],
);

// Global history (not affected by per-preset reset)
class GlobalHistoryEntry {
  final String presetId;
  final String presetTitle;
  final Meal meal;
  final DateTime timestamp;

  GlobalHistoryEntry({
    required this.presetId,
    required this.presetTitle,
    required this.meal,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

final globalHistoryProvider = StateProvider<List<GlobalHistoryEntry>>(
  (ref) => [],
);
