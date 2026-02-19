import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PresetDetailScreen extends StatelessWidget {
  final String? presetId;
  final String? presetName;

  const PresetDetailScreen({super.key, this.presetId, this.presetName});

  @override
  Widget build(BuildContext context) {
    final displayName = presetName ?? 'Preset Details';

    return Scaffold(
      appBar: AppBar(title: Text(displayName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (presetId != null)
              Text(
                'Preset ID: $presetId',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            const SizedBox(height: 10),
            Text(
              'Viewing details for: $displayName',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Text('List of meals will appear here...'),
            // Inside build method
            ElevatedButton(
              onPressed: () {
                // Navigate to Random Screen with the actual preset ID
                if (presetId != null) {
                  context.push('/random/$presetId');
                }
              },
              child: const Text('Confirm & Spin'),
            ),
          ],
        ),
      ),
    );
  }
}
