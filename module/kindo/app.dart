import 'package:flutter/material.dart';

import 'app/memory_king_page.dart';
import 'interface.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: GoldPalette.primary,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kindo',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: baseScheme.copyWith(
          primary: GoldPalette.primary,
          secondary: GoldPalette.highlight,
          surface: GoldPalette.surface,
          onSurface: GoldPalette.textPrimary,
        ),
        scaffoldBackgroundColor: GoldPalette.background,
        textTheme: ThemeData(brightness: Brightness.dark).textTheme.apply(
              bodyColor: GoldPalette.textPrimary,
              displayColor: GoldPalette.textPrimary,
            ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: GoldPalette.textPrimary,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: GoldPalette.primary,
            foregroundColor: GoldPalette.textOnGold,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
      home: Interface().authToken == null
          ? const LoginPage()
          : const MemoryKingHomePage(),
    );
  }
}
