import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/meal_detail_dialog.dart';
import '../../randomizer/presentation/random_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalHistory = ref.watch(globalHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: globalHistory.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No history yet!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Spin the wheel to start building your history.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: globalHistory.length,
              itemBuilder: (context, index) {
                final entry = globalHistory[index];
                return _HistoryTile(
                  entry: entry,
                  onTap: () => showMealDetailDialog(
                    context,
                    entry.meal,
                    subtitle: entry.presetTitle,
                    timestamp: entry.timestamp,
                  ),
                );
              },
            ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final GlobalHistoryEntry entry;
  final VoidCallback onTap;

  const _HistoryTile({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(Icons.restaurant, color: colorScheme.onPrimaryContainer),
        ),
        title: Text(
          entry.meal.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(entry.presetTitle),
      ),
    );
  }
}
