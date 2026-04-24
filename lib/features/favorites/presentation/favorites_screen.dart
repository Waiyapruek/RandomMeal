import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/meal_detail_dialog.dart';
import '../../../models/preset.dart';
import '../../../core/navigation/route_names.dart';
import '../../../core/utils/image_utils.dart';
import 'favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteMealsDetailsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Meals'),
        elevation: 0,
      ),
      body: favoritesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: colorScheme.error.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                "Can't read database",
                style: theme.textTheme.titleLarge,
              ),
            ],
          ),
        ),
        data: (favoriteMeals) => favoriteMeals.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite_border_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Favorites Yet',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Add meals to favorites by tapping the heart icon.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: favoriteMeals.length,
                itemBuilder: (context, index) {
                  final meal = favoriteMeals[index];
                  return _FavoriteMealCard(
                    meal: meal,
                    onTap: () => showMealDetailDialog(context, meal),
                  );
                },
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        elevation: 8,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant.withOpacity(0.6),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_rounded),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(RouteNames.home);
              break;
            case 1:
              context.go(RouteNames.favorites);
              break;
            case 2:
              context.go(RouteNames.history);
              break;
          }
        },
      ),
    );
  }
}

class _FavoriteMealCard extends ConsumerWidget {
  final Meal meal;
  final VoidCallback onTap;

  const _FavoriteMealCard({
    required this.meal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isFavorite = ref.watch(favoriteMealsProvider)
        .contains(meal.name);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shadowColor: colorScheme.error.withOpacity(0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                colorScheme.surface.withOpacity(0.5),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image section with favorite button
              Expanded(
                flex: 50,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    meal.imageUrl != null
                        ? Image.network(
                            optimizeImageUrl(meal.imageUrl, width: 400, height: 350),
                            fit: BoxFit.cover,
                            loadingBuilder:
                                (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color:
                                    colorScheme.surfaceContainerHighest,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              color:
                                  colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.restaurant_rounded,
                                size: 36,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )
                        : Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.restaurant_rounded,
                              size: 36,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                    // Overlay gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.15),
                          ],
                        ),
                      ),
                    ),
                    // Favorite button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: colorScheme.error,
                          ),
                          onPressed: () {
                            ref.toggleFavorite(meal.name);
                          },
                          iconSize: 20,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Details section
              Expanded(
                flex: 50,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          meal.detail ?? 'No details available',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
