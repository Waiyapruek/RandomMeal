import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:randommeal/core/theme/theme_provider.dart';
import 'core/navigation/app_router.dart';

void main() {
  usePathUrlStrategy(); // Enable clean URLs without #
  runApp(
    const ProviderScope(
      // Required for Riverpod
      child: RandomMealApp(),
    ),
  );
}

class RandomMealApp extends ConsumerWidget {
  // Change to ConsumerWidget
  const RandomMealApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider); // Watch the theme state

    return MaterialApp.router(
      title: 'RandomMeal',
      themeMode: themeMode,
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      routerConfig: AppRouter.router,
    );
  }
}
