import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../services/firebase_service.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/navigation/route_names.dart';
import '../../../core/utils/image_utils.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presetsAsync = ref.watch(presetsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('RandomMeal'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wb_sunny_rounded,
                      size: 20,
                      color: !isDarkMode
                          ? Colors.orange
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Switch(
                      value: isDarkMode,
                      onChanged: (value) {
                        ref.read(themeProvider.notifier).state =
                            value ? ThemeMode.dark : ThemeMode.light;
                      },
                      activeColor: colorScheme.primary,
                      inactiveTrackColor:
                          colorScheme.surfaceContainerHighest,
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.nightlight_rounded,
                      size: 20,
                      color: isDarkMode
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: presetsAsync.when(
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
        data: (presets) => presets.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant_menu_rounded,
                      size: 56,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No presets available',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add presets to Firestore to get started',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.80,
                  ),
                  itemCount: presets.length,
                  itemBuilder: (context, index) {
                    final preset = presets[index];
                    return _PresetCard(preset: preset);
                  },
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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

class _PresetCard extends StatelessWidget {
  final dynamic preset;

  const _PresetCard({required this.preset});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        final encodedName = Uri.encodeComponent(preset.title);
        context.go('/presets/${preset.id}?name=$encodedName');
      },
      child: Hero(
        tag: 'preset_${preset.id}',
        child: Card(
          elevation: 4,
          shadowColor: colorScheme.primary.withOpacity(0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
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
                // Image Section
                Expanded(
                  flex: 45,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      preset.imageUrl != null
                          ? Image.network(
                              optimizeImageUrl(preset.imageUrl, width: 500, height: 400),
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: colorScheme.surfaceContainerHighest,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => Container(
                                color: colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.restaurant_menu,
                                  size: 48,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            )
                          : Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.restaurant_menu,
                                size: 48,
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
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Details Section
                Expanded(
                  flex: 55,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preset.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          preset.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            preset.category,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.restaurant_rounded,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${preset.meals.length} meals',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
