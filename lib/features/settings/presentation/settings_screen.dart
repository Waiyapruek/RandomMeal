import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/navigation/route_names.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('App Theme'),
            subtitle: Text(
              isDarkMode ? 'Dark Mode Active' : 'Light Mode Active',
            ),
            // Use Sun for light, Moon for dark as requested
            secondary: Icon(
              isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
              color: isDarkMode ? Colors.amber[200] : Colors.orange,
            ),
            value: isDarkMode,
            onChanged: (bool value) {
              ref.read(themeProvider.notifier).state = value
                  ? ThemeMode.dark
                  : ThemeMode.light;
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('History'),
            subtitle: const Text('View all random results'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(RouteNames.history),
          ),
        ],
      ),
    );
  }
}
