import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/randomizer/presentation/random_screen.dart';
import '../../features/presets/presentation/preset_detail_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/presets/presentation/custom_preset_screen.dart';
import 'route_names.dart';

class AppRouter {
  static final router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: RouteNames.home,
    routes: [
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RouteNames.customPreset,
        builder: (context, state) => const CustomPresetScreen(),
      ),
      GoRoute(
        path: RouteNames.presetDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'];
          final name = state.uri.queryParameters['name'];
          return PresetDetailScreen(presetId: id, presetName: name);
        },
        routes: [
          GoRoute(
            path: 'random',
            builder: (context, state) {
              final presetId = state.pathParameters['id']!;
              return RandomScreen(presetId: presetId);
            },
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.presets,
        builder: (context, state) => const PresetDetailScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.history,
        builder: (context, state) => const HistoryScreen(),
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Route not found: ${state.uri}')),
      );
    },
  );
}
