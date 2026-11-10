import 'package:flutter/material.dart';

/// Design System infantil (ver .claude/skills/flutter-kids-reading-design).
const kBrandGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [Color(0xFF7957F3), Color(0xFF8769FF)],
);

const kBackground = Color(0xFFF4F1FF);
const kOnSurfaceVariant = Color(0xFF6E6896);
const kTileDevocional = Color(0xFFE9E3FF);

// Colores vivos de los iconos del menú principal (círculo con icono blanco).
const kMenuDevocional = Color(0xFF7957F3);
const kMenuAyuda = Color(0xFF1FB5A3);
const kMenuPremios = Color(0xFFF5A300);
const kMenuDonacion = Color(0xFFFF6B6B);

const kCardShadow = [
  BoxShadow(
    color: Color(0x1A7957F3),
    blurRadius: 20,
    offset: Offset(0, 8),
  ),
];

ThemeData buildKidsTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF7957F3),
    primary: const Color(0xFF7957F3),
    surface: Colors.white,
    onSurface: const Color(0xFF2B2350),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: kBackground,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      bodyLarge: TextStyle(fontSize: 20, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      backgroundColor: Colors.transparent,
      elevation: 0,
      indicatorColor: kTileDevocional,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: const WidgetStatePropertyAll(
        TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
