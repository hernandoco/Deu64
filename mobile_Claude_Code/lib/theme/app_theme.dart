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

// Fondos pastel de los círculos del menú principal (la ilustración a todo
// color va encima, ver lib/widgets/menu_illustrations.dart).
const kMenuDevocional = Color(0xFFEDE7FF); // lavanda
const kMenuAyuda = Color(0xFFD9F6F0); // menta
const kMenuPremios = Color(0xFFFFF1CC); // crema
const kMenuDonacion = Color(0xFFFFE2EC); // rosa claro

// Colores de los títulos de sección del Home: uno por sección, tomado de la
// tarjeta que la acompaña y de la paleta del título principal.
const kTitleDevocional = Color(0xFF4A2C8F); // morado
const kTitlePreguntas = Color(0xFFF57C00); // naranja
const kTitleOracion = Color(0xFFD6336C); // rosa
const kTitleReto = Color(0xFF00897B); // verde azulado

/// Títulos de sección con la fuente manuscrita del título principal
/// (GochiHand), en un solo color por título.
TextStyle sectionTitleStyle(Color color) => TextStyle(
  fontFamily: 'GochiHand',
  fontSize: 24,
  height: 1.2,
  fontWeight: FontWeight.w800,
  color: color,
);

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
