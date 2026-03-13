import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:randommeal/models/preset.dart';
import '../../../core/widgets/meal_detail_dialog.dart';

class PresetDetailScreen extends StatelessWidget {
  final String? presetId;
  final String? presetName;

  const PresetDetailScreen({super.key, this.presetId, this.presetName});

  Preset? _findPreset() {
    if (presetId == null) return null;
    try {
      return mockPresets.firstWhere((p) => p.id == presetId);
    } catch (_) {
      return null;
    }
  }

  bool get _isCustomPreset => presetId != null && presetId!.length == 4;

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Preset'),
        content: const Text(
          'Are you sure you want to delete this preset? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      mockPresets.removeWhere((p) => p.id == presetId);
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final preset = _findPreset();
    final displayName = presetName ?? preset?.title ?? 'Preset Details';
    final meals = preset?.meals ?? [];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: Text(displayName),
        actions: [
          if (_isCustomPreset)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete Preset',
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: Column(
        children: [
          // Meal grid
          Expanded(
            child: meals.isEmpty
                ? const Center(child: Text('No meals in this preset.'))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1, // Square cards
                        ),
                    itemCount: meals.length,
                    itemBuilder: (context, index) {
                      final meal = meals[index];
                      return _MealCard(
                        meal: meal,
                        onTap: () => showMealDetailDialog(context, meal),
                      );
                    },
                  ),
          ),
          // Confirm & Spin button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: presetId != null
                      ? () => context.go('/presets/$presetId/random')
                      : null,
                  child: const Text('Confirm & Spin'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onTap;

  const _MealCard({required this.meal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Upper half — image
            Expanded(
              child: meal.imageUrl != null
                  ? Image.network(
                      meal.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: colorScheme.primaryContainer,
                        child: Icon(
                          Icons.restaurant,
                          size: 40,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    )
                  : Container(
                      color: colorScheme.primaryContainer,
                      child: Icon(
                        Icons.restaurant,
                        size: 40,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
            ),
            // Lower half — brief detail
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        meal.detail,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
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
    );
  }
}
