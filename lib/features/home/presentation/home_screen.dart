import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/preset.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RandomMeal Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockPresets.length,
        itemBuilder: (context, index) {
          final preset = mockPresets[index];
          return Card(
            child: ListTile(
              title: Text(preset.title),
              subtitle: Text(preset.description),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to preset detail using ID and include name as query param
                final encodedName = Uri.encodeComponent(preset.title);
                context.push('/presets/${preset.id}?name=$encodedName');
              },
            ),
          );
        },
      ),
    );
  }
}
