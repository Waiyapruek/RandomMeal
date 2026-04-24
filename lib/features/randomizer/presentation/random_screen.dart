import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/image_utils.dart';
import 'random_provider.dart';
import 'spin_wheel_widget.dart';
import '../../../models/preset.dart';
import '../../../services/firebase_service.dart';

class RandomScreen extends ConsumerStatefulWidget {
  final String presetId;
  const RandomScreen({super.key, required this.presetId});

  @override
  ConsumerState<RandomScreen> createState() => _RandomScreenState();
}

class _RandomScreenState extends ConsumerState<RandomScreen> {
  double _rotation = 0;
  bool _isSpinning = false;

  /// Calculate which meal is under the top indicator based on rotation
  Meal _getWinningMeal(List<Meal> meals, double rotation) {
    final mealCount = meals.length;
    final sliceAngle = (2 * pi) / mealCount;

    // Convert rotation (turns) to radians and normalize to [0, 2π)
    final rotationRadians = (rotation * 2 * pi) % (2 * pi);

    // The indicator is at the top. After the wheel rotates clockwise by rotationRadians,
    // the slice that ends up under the indicator was originally at angle: -rotationRadians
    // Normalize to positive angle in [0, 2π)
    final effectiveAngle = (2 * pi - rotationRadians) % (2 * pi);

    // Find which slice contains this angle
    // Slice i covers from (i * sliceAngle) to ((i + 1) * sliceAngle)
    // Since slices start at -π/2 (top), we need to adjust
    final winningIndex = (effectiveAngle / sliceAngle).floor() % mealCount;

    return meals[winningIndex];
  }

  void _spinWheel(List<Meal> meals) {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _rotation += 5 + Random().nextDouble() * 10; // Random rotations
    });

    // Increment count using Riverpod
    ref.read(randomCountProviders(widget.presetId).notifier).state++;

    // Wait for animation to finish
    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;
      setState(() => _isSpinning = false);

      // Get the winning meal based on where the wheel stopped
      final result = _getWinningMeal(meals, _rotation);
      await _onSpinComplete(result);
    });
  }

  void _showResultDialog(Meal meal) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _MealResultCard(meal: meal),
    );
  }

  void _showMealsList() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final presetAsync = ref.watch(presetByIdProvider(widget.presetId));

    presetAsync.whenData((preset) {
      if (preset == null) return;

      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
                margin: const EdgeInsets.only(bottom: 16),
              ),
              Text(
                'Meals (${preset.meals.length})',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Divider(height: 24),
              Expanded(
                child: preset.meals.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu_rounded,
                              size: 48,
                              color: colorScheme.onSurfaceVariant
                                  .withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No meals available',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: preset.meals.length,
                        separatorBuilder: (_, __) => Divider(
                          color: colorScheme.outlineVariant.withOpacity(0.3),
                        ),
                        itemBuilder: (context, index) {
                          final meal = preset.meals[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              meal.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: meal.detail != null && meal.detail!.isNotEmpty
                                ? Text(
                                    meal.detail!,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : null,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showHistory() {
    final history = ref.read(historyProviders(widget.presetId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
              margin: const EdgeInsets.only(bottom: 16),
            ),
            Text(
              'Spin History',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Divider(height: 24),
            Expanded(
              child: history.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 48,
                            color: colorScheme.onSurfaceVariant
                                .withOpacity(0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No spin history yet',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.separated(
                        itemCount: history.length,
                        separatorBuilder: (_, __) => Divider(
                          color: colorScheme.outlineVariant.withOpacity(0.3),
                        ),
                      itemBuilder: (context, index) {
                        final entry = history[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.restaurant_rounded,
                              color: colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            entry.meal.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            entry.meal.detail ?? 'No details',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: entry.count > 1
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${entry.count}x',
                                    style:
                                        theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )
                              : null,
                          onTap: () {
                            Navigator.pop(context);
                            _showResultDialog(entry.meal);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Inside _spinWheel, update history when finished:
  Future<void> _onSpinComplete(Meal result) async {
    if (!mounted) return;
    setState(() => _isSpinning = false);

    // Add to history list - check if meal already exists anywhere in history
    ref.read(historyProviders(widget.presetId).notifier).update((state) {
      // Find if this meal already exists in history
      final existingIndex = state.indexWhere(
        (entry) => entry.meal.name == result.name,
      );

      if (existingIndex != -1) {
        // Meal exists - increment its count
        state[existingIndex].count++;
        return [...state]; // Return new list to trigger rebuild
      } else {
        // Add new entry at the top
        return [HistoryEntry(meal: result), ...state];
      }
    });

    // Also add to global history (persists across resets)
    // Get the preset title from Firebase
    final service = ref.read(firebaseServiceProvider);
    final preset = await service.fetchPresetById(widget.presetId);
    
    if (preset != null) {
      ref.read(globalHistoryProvider.notifier).update((state) {
        return [
          GlobalHistoryEntry(
            presetId: widget.presetId,
            presetTitle: preset.title,
            meal: result,
          ),
          ...state,
        ];
      });
    }

    _showResultDialog(result);
  }

  void _resetResult() {
    // Manually resetting the state of both providers
    ref.read(randomCountProviders(widget.presetId).notifier).state = 0;
    ref.read(historyProviders(widget.presetId).notifier).state = [];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Reset result!'),
        duration: const Duration(seconds: 1),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(randomCountProviders(widget.presetId));
    final presetAsync = ref.watch(presetByIdProvider(widget.presetId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return presetAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text("Can't read database")),
      ),
      data: (preset) {
        if (preset == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: const Center(child: Text('Preset not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.go('/presets/${widget.presetId}'),
            ),
            title: const Text('The Decider'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: _resetResult,
                tooltip: 'Reset result',
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Spins counter
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primaryContainer,
                              colorScheme.primaryContainer.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.casino_rounded,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Spins: $count',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // The Pie Wheel with shadow
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.15),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: SpinWheelWidget(
                          meals: preset.meals,
                          rotation: _rotation,
                          wheelSize: 280,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.history_rounded),
                              onPressed: _showHistory,
                              color: colorScheme.primary,
                              iconSize: 28,
                              tooltip: 'View history',
                            ),
                          ),
                          const SizedBox(width: 20),
                          FilledButton.icon(
                            icon: const Icon(Icons.casino_rounded),
                            label: Text(_isSpinning ? 'Spinning...' : 'SPIN!'),
                            onPressed: _isSpinning
                                ? null
                                : () => _spinWheel(preset.meals),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.restaurant_menu_rounded),
                              onPressed: _showMealsList,
                              color: colorScheme.primary,
                              iconSize: 28,
                              tooltip: 'View meals',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MealResultCard extends StatelessWidget {
  final Meal meal;

  const _MealResultCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Decorative top indicator
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),

                // Meal image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: meal.imageUrl != null
                            ? Image.network(
                                optimizeImageUrl(meal.imageUrl, width: 800, height: 450),
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
                                    size: 64,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              )
                            : Container(
                                color: colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.restaurant_rounded,
                                  size: 64,
                                  color: colorScheme.onSurfaceVariant,
                                ),
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
                              Colors.black.withOpacity(0.2),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Meal details
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        meal.detail ?? 'No details available',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Action button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.check_circle_rounded),
                          label: const Text('Let\'s Eat!'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
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
