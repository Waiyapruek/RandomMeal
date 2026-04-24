import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/preset.dart';
import '../../../services/firebase_service.dart';

/// Favorites provider - stores favorite meal names in local storage
final favoriteMealsProvider = StateProvider<List<String>>((ref) {
  return [];
});

/// Initialize favorites from SharedPreferences
final _initializeFavoritesProvider = FutureProvider<List<String>>((ref) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    // Update the state provider with loaded data
    ref.read(favoriteMealsProvider.notifier).state = favorites;
    return favorites;
  } catch (e) {
    print('Error loading favorites: $e');
    return [];
  }
});

/// Extension on StateNotifierProvider to add toggle favorite method
extension FavoritesMethods on WidgetRef {
  Future<void> toggleFavorite(String mealName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = read(favoriteMealsProvider);

      if (current.contains(mealName)) {
        final updated = current.where((name) => name != mealName).toList();
        read(favoriteMealsProvider.notifier).state = updated;
        await prefs.setStringList('favorites', updated.cast<String>());
      } else {
        final updated = [...current, mealName];
        read(favoriteMealsProvider.notifier).state = updated;
        await prefs.setStringList('favorites', updated.cast<String>());
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  bool isFavorite(String mealName) {
    return read(favoriteMealsProvider).contains(mealName);
  }
}

/// Get all favorite meals with details from Firebase
final favoriteMealsDetailsProvider = FutureProvider<List<Meal>>((ref) async {
  // Initialize favorites first
  await ref.watch(_initializeFavoritesProvider.future);
  
  final favoriteNames = ref.watch(favoriteMealsProvider);
  final service = ref.watch(firebaseServiceProvider);

  if (favoriteNames.isEmpty) {
    return [];
  }

  try {
    final presets = await service.fetchPresets();
    final favoriteMeals = <Meal>[];

    for (final preset in presets) {
      for (final meal in preset.meals) {
        if (favoriteNames.contains(meal.name)) {
          favoriteMeals.add(meal);
        }
      }
    }

    return favoriteMeals;
  } catch (e) {
    print('Error fetching favorite meals details: $e');
    return [];
  }
});
