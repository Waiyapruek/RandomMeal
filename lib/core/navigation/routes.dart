import 'package:go_router/go_router.dart';
import 'package:randommeal/features/home/presentation/home_screen.dart';
import 'package:randommeal/features/randomizer/presentation/random_screen.dart';
import 'package:randommeal/features/presets/presentation/preset_detail_screen.dart';
import 'package:randommeal/features/settings/presentation/settings_screen.dart';
import 'package:randommeal/features/history/presentation/history_screen.dart';
import 'package:randommeal/features/presets/presentation/custom_preset_screen.dart';
import 'route_names.dart';

/// Application routes configuration
final List<RouteBase> appRoutes = [
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
      return PresetDetailScreen(presetId: id);
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
    path: RouteNames.settings,
    builder: (context, state) => const SettingsScreen(),
  ),
  GoRoute(
    path: RouteNames.history,
    builder: (context, state) => const HistoryScreen(),
  ),
];
