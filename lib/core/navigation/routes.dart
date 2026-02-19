import 'package:go_router/go_router.dart';
import 'package:randommeal/features/auth/presentation/login_screen.dart';
import 'package:randommeal/features/home/presentation/home_screen.dart';
import 'package:randommeal/features/randomizer/presentation/random_screen.dart';
import 'package:randommeal/features/presets/presentation/preset_detail_screen.dart';
import 'package:randommeal/features/settings/presentation/settings_screen.dart';
import 'route_names.dart';

/// Application routes configuration
final List<RouteBase> appRoutes = [
  GoRoute(
    path: RouteNames.login,
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: RouteNames.home,
    builder: (context, state) => const HomeScreen(),
  ),
  GoRoute(
    path: '/random/:presetId',
    builder: (context, state) {
      final presetId = state.pathParameters['presetId']!;
      return RandomScreen(presetId: presetId);
    },
  ),
  GoRoute(
    path: RouteNames.presetDetail,
    builder: (context, state) {
      final id = state.pathParameters['id'];
      return PresetDetailScreen(presetId: id);
    },
  ),
  GoRoute(
    path: RouteNames.settings,
    builder: (context, state) => const SettingsScreen(),
  ),
];
