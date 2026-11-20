import 'package:material_ui/material_ui.dart';

const primary = Color(0xFF1E6F5C);
const primarySoft = Color(0xFFE6F4F1);
const background = Color(0xFFF8FAFC);
const outline = Color(0xFFE2E8F0);
const ink = Color(0xFF0F172A);
const muted = Color(0xFF475569);
const income = Color(0xFF15803D);
const expense = Color(0xFFDC2626);
const warning = Color(0xFFF59E0B);
const spacing = 16.0;
const cardRadius = 16.0;
const sheetRadius = 24.0;
const numeric = [FontFeature.tabularFigures()];

final appTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Inter',
  colorScheme: ColorScheme.fromSeed(seedColor: primary).copyWith(
    primary: primary,
    secondaryContainer: primarySoft,
    surface: Colors.white,
    onSurface: ink,
    onSurfaceVariant: muted,
    error: expense,
  ),
  scaffoldBackgroundColor: background,
  appBarTheme: const AppBarTheme(
    backgroundColor: background,
    foregroundColor: ink,
    titleTextStyle: TextStyle(
      fontFamily: 'Inter',
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: ink,
    ),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    margin: EdgeInsets.zero,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(cardRadius),
      side: const BorderSide(color: outline),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  ),
);
