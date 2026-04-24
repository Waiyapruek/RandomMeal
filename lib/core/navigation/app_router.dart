import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/randomizer/presentation/random_screen.dart';
import '../../features/presets/presentation/preset_detail_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import 'route_names.dart';

class AppRouter {
  static final router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: RouteNames.home,
    routes: [
      GoRoute(
        path: RouteNames.home,
        pageBuilder: (context, state) => MaterialPage(
          name: state.name,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.presetDetail,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'];
          return MaterialPage(
            name: state.name,
            child: PresetDetailScreen(presetId: id),
          );
        },
        routes: [
          GoRoute(
            path: 'random',
            pageBuilder: (context, state) {
              final presetId = state.pathParameters['id']!;
              return MaterialPage(
                name: state.name,
                child: RandomScreen(presetId: presetId),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.presets,
        pageBuilder: (context, state) => MaterialPage(
          name: state.name,
          child: const PresetDetailScreen(),
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => MaterialPage(
          name: state.name,
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.history,
        pageBuilder: (context, state) => MaterialPage(
          name: state.name,
          child: const HistoryScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.favorites,
        pageBuilder: (context, state) => MaterialPage(
          name: state.name,
          child: const FavoritesScreen(),
        ),
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