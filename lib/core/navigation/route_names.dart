/// Route names for the application
abstract class RouteNames {
  const RouteNames._();

  static const String login = '/login';
  static const String home = '/home';
  static const String randomizer = '/random/:presetId';
  static const String presets = '/presets';
  static const String presetDetail = '/presets/:id';
  static const String settings = '/settings';
}
