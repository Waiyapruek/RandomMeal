/// Route names for the application
abstract class RouteNames {
  const RouteNames._();

  static const String home = '/home';
  static const String randomizer = '/presets/:id/random';
  static const String presets = '/presets';
  static const String presetDetail = '/presets/:id';
  static const String settings = '/settings';
  static const String history = '/history';
}
