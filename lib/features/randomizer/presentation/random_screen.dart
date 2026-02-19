import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'random_provider.dart';
import 'spin_wheel_widget.dart';
import '../../../models/preset.dart';

class RandomScreen extends ConsumerStatefulWidget {
  final String presetId;
  const RandomScreen({super.key, required this.presetId});

  @override
  ConsumerState<RandomScreen> createState() => _RandomScreenState();
}

class _RandomScreenState extends ConsumerState<RandomScreen> {
  double _rotation = 0;
  bool _isSpinning = false;

  void _spinWheel(List<Meal> meals) {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _rotation += 5 + Random().nextDouble() * 10; // Random rotations
    });

    // Increment count using Riverpod
    ref.read(randomCountProvider.notifier).state++;

    // Wait for "animation" to finish
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isSpinning = false);

      final result = meals[Random().nextInt(meals.length)];
      _onSpinComplete(result);
    });
  }

  void _showResultDialog(Meal meal) {
    showDialog(
      context: context,
      barrierDismissible: false, // Force them to engage with the choice!
      builder: (context) => _MealResultCard(meal: meal),
    );
  }

  void _showHistory() {
    final history = ref.read(historyProvider);

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

    // Add to history list - check if same as previous (top) entry
    ref.read(historyProvider.notifier).update((state) {
      if (state.isNotEmpty && state.first.meal.name == result.name) {
        // Increment count of the top entry
        state.first.count++;
        return [...state]; // Return new list to trigger rebuild
      } else {
        // Add new entry at the top
        return [HistoryEntry(meal: result), ...state];
      }
    });

    _showResultDialog(result);
  }

  void _resetSession() {
    // Manually resetting the state of both providers
    ref.read(randomCountProvider.notifier).state = 0;
    ref.read(historyProvider.notifier).state = [];

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session reset!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(randomCountProvider);
    final preset = mockPresets.firstWhere((p) => p.id == widget.presetId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('The Decider'),
        actions: [
          // The Manual Reset Button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetSession,
            tooltip: 'Reset Session',
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Wrap content
        children: [
          // 1. Image Placeholder
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: meal.imageUrl != null
                ? Image.network(meal.imageUrl!, fit: BoxFit.cover)
                : const Icon(Icons.restaurant, size: 80, color: Colors.grey),
          ),

          // 2. Info Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  meal.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  meal.detail,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),

                // 3. Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Let\'s Eat!'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
