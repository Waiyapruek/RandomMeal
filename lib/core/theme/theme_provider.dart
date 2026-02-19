import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

// This provider manages whether the app is in Light or Dark mode
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
