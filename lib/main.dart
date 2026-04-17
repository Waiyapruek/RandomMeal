import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:randommeal/core/theme/theme_provider.dart';
import 'firebase_options.dart';
import 'core/navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      theme: lightTheme,
      darkTheme: darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
