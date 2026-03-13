import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'random_provider.dart';
import 'spin_wheel_widget.dart';
import '../../../models/preset.dart';
import '../../../core/widgets/meal_detail_dialog.dart';

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
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isSpinning = false);

      // Get the winning meal based on where the wheel stopped
      final result = _getWinningMeal(meals, _rotation);
      _onSpinComplete(result);
    });
  }

  void _showResultDialog(Meal meal) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _MealResultCard(meal: meal),
    );
  }

  void _showHistory() {
    final history = ref.read(historyProviders(widget.presetId));

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: 300,
        child: Column(
          children: [
            const Text(
              'Spin History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: history.isEmpty
                  ? const Center(child: Text('No history yet!'))
                  : ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final entry = history[index];
                        return ListTile(
                          leading: const Icon(Icons.restaurant),
                          title: Text(entry.meal.name),
                          trailing: entry.count > 1
                              ? CircleAvatar(
                                  radius: 12,
                                  child: Text(
                                    '${entry.count}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                )
                              : null,
                          onTap: () {
                            Navigator.pop(context); // Close the history sheet
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
  void _onSpinComplete(Meal result) {
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
    final preset = mockPresets.firstWhere((p) => p.id == widget.presetId);
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

    _showResultDialog(result);
  }

  void _resetResult() {
    // Manually resetting the state of both providers
    ref.read(randomCountProviders(widget.presetId).notifier).state = 0;
    ref.read(historyProviders(widget.presetId).notifier).state = [];

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reset result!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(randomCountProviders(widget.presetId));
    final preset = mockPresets.firstWhere((p) => p.id == widget.presetId);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/presets/${widget.presetId}'),
        ),
        title: const Text('The Decider'),
        actions: [
          // The Manual Reset Button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetResult,
            tooltip: 'Reset result',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Total Spins: $count',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            // The Pie Wheel
            SpinWheelWidget(
              meals: preset.meals,
              rotation: _rotation,
              wheelSize: 280,
            ),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.history, size: 30),
                  onPressed: _showHistory,
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _isSpinning
                      ? null
                      : () => _spinWheel(preset.meals),
                  child: Text(_isSpinning ? 'Spinning...' : 'SPIN!'),
                ),
              ],
            ),
          ],
        ),
      ),
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
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Meal image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: meal.imageUrl != null
                      ? Image.network(
                          meal.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: colorScheme.primaryContainer,
                            child: Icon(
                              Icons.restaurant,
                              size: 64,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        )
                      : Container(
                          color: colorScheme.primaryContainer,
                          child: Icon(
                            Icons.restaurant,
                            size: 64,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                ),
              ),
              // Meal details
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      meal.detail,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Action button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Let\'s Eat!'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
