import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/main.dart';

const kThemeModeKey = '__theme_mode__';

void setDarkModeSetting(BuildContext context, ThemeMode themeMode) =>
    MyApp.of(context).setThemeMode(themeMode);

// ============================================================
// AppTheme — Terranex Smart City Operations
// Paleta: Vino institucional #7A1E3A
// ============================================================
abstract class AppTheme {
  static ThemeMode get themeMode {
    final darkMode = prefs.getBool(kThemeModeKey);
    return darkMode == null
        ? ThemeMode.light
        : darkMode ? ThemeMode.dark : ThemeMode.light;
  }

  static LightModeTheme lightTheme = LightModeTheme();
  static DarkModeTheme darkTheme = DarkModeTheme();

  static void saveThemeMode(ThemeMode mode) => mode == ThemeMode.system
      ? prefs.remove(kThemeModeKey)
      : prefs.setBool(kThemeModeKey, mode == ThemeMode.dark);

  static AppTheme of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkTheme
          : lightTheme;

  // Identidad Vino
  abstract Color primaryColor;
  abstract Color primaryLight;
  abstract Color primarySoft;

  // Semanticos operativos
  abstract Color critical;
  abstract Color criticalSoft;
  abstract Color high;
  abstract Color highSoft;
  abstract Color medium;
  abstract Color mediumSoft;
  abstract Color low;
  abstract Color lowSoft;
  abstract Color neutral;

  // Aliases para globals.dart / PlutoGrid
  abstract Color secondaryColor;
  abstract Color tertiaryColor;
  abstract Color alternate;
  abstract Color error;
  abstract Color warning;
  abstract Color success;
  abstract Color formBackground;

  // Fondos y superficies
  abstract Color background;
  abstract Color surface;
  abstract Color border;
  abstract Color primaryBackground;
  abstract Color secondaryBackground;
  abstract Color tertiaryBackground;
  abstract Color transparentBackground;

  // Texto
  abstract Color textPrimary;
  abstract Color textSecondary;
  abstract Color textDisabled;
  abstract Color primaryText;
  abstract Color secondaryText;
  abstract Color tertiaryText;
  abstract Color hintText;

  // Sidebar vino oscuro
  abstract Color sidebarBg;
  abstract Color sidebarActive;
  abstract Color sidebarText;
  abstract Color sidebarMuted;

  // Tipografia
  String get title1Family => typography.title1Family;
  TextStyle get title1 => typography.title1;
  String get title2Family => typography.title2Family;
  TextStyle get title2 => typography.title2;
  String get title3Family => typography.title3Family;
  TextStyle get title3 => typography.title3;
  String get subtitle1Family => typography.subtitle1Family;
  TextStyle get subtitle1 => typography.subtitle1;
  String get subtitle2Family => typography.subtitle2Family;
  TextStyle get subtitle2 => typography.subtitle2;
  String get bodyText1Family => typography.bodyText1Family;
  TextStyle get bodyText1 => typography.bodyText1;
  String get bodyText2Family => typography.bodyText2Family;
  TextStyle get bodyText2 => typography.bodyText2;
  String get bodyText3Family => typography.bodyText3Family;
  TextStyle get bodyText3 => typography.bodyText3;
  String get plutoDataTextFamily => typography.plutoDataTextFamily;
  TextStyle get plutoDataText => typography.plutoDataText;
  String get copyRightTextFamily => typography.copyRightTextFamily;
  TextStyle get copyRightText => typography.copyRightText;

  Typography get typography => ThemeTypography(this);
}

// ============================================================
// Modo Claro
// ============================================================
class LightModeTheme extends AppTheme {
  @override Color primaryColor    = const Color(0xFF7A1E3A);
  @override Color primaryLight    = const Color(0xFF9B2C4E);
  @override Color primarySoft     = const Color(0xFFF9E8EC);

  @override Color critical        = const Color(0xFFB91C1C);
  @override Color criticalSoft    = const Color(0xFFFEE2E2);
  @override Color high            = const Color(0xFFD97706);
  @override Color highSoft        = const Color(0xFFFEF3C7);
  @override Color medium          = const Color(0xFF1D4ED8);
  @override Color mediumSoft      = const Color(0xFFEFF6FF);
  @override Color low             = const Color(0xFF2D7A4F);
  @override Color lowSoft         = const Color(0xFFE8F5EE);
  @override Color neutral         = const Color(0xFF64748B);

  @override Color secondaryColor  = const Color(0xFF5C1528);
  @override Color tertiaryColor   = const Color(0xFF2D7A4F);
  @override Color alternate       = const Color(0xFFD97706);
  @override Color error           = const Color(0xFFB91C1C);
  @override Color warning         = const Color(0xFFD97706);
  @override Color success         = const Color(0xFF2D7A4F);
  @override Color formBackground  = const Color(0xFFF9E8EC);

  @override Color background          = const Color(0xFFF4F6F9);
  @override Color surface             = const Color(0xFFFFFFFF);
  @override Color border              = const Color(0xFFE3E8EF);
  @override Color primaryBackground   = const Color(0xFFF4F6F9);
  @override Color secondaryBackground = const Color(0xFFFFFFFF);
  @override Color tertiaryBackground  = const Color(0xFFF1F5F9);
  @override Color transparentBackground = const Color(0xFF64748B);

  @override Color textPrimary     = const Color(0xFF0F172A);
  @override Color textSecondary   = const Color(0xFF475569);
  @override Color textDisabled    = const Color(0xFF94A3B8);
  @override Color primaryText     = const Color(0xFF0F172A);
  @override Color secondaryText   = const Color(0xFF475569);
  @override Color tertiaryText    = const Color(0xFF94A3B8);
  @override Color hintText        = const Color(0xFF94A3B8);

  @override Color sidebarBg       = const Color(0xFF5C1528);
  @override Color sidebarActive   = const Color(0xFF7A1E3A);
  @override Color sidebarText     = const Color(0xFFF1E8EB);
  @override Color sidebarMuted    = const Color(0xFFB8909A);
}

// ============================================================
// Modo Oscuro
// ============================================================
class DarkModeTheme extends AppTheme {
  @override Color primaryColor    = const Color(0xFF9B2C4E);
  @override Color primaryLight    = const Color(0xFFBF4068);
  @override Color primarySoft     = const Color(0xFF3D0C1A);

  @override Color critical        = const Color(0xFFEF4444);
  @override Color criticalSoft    = const Color(0xFF450A0A);
  @override Color high            = const Color(0xFFFBBF24);
  @override Color highSoft        = const Color(0xFF451A03);
  @override Color medium          = const Color(0xFF60A5FA);
  @override Color mediumSoft      = const Color(0xFF0C1A3D);
  @override Color low             = const Color(0xFF34D399);
  @override Color lowSoft         = const Color(0xFF042F1A);
  @override Color neutral         = const Color(0xFF94A3B8);

  @override Color secondaryColor  = const Color(0xFF3D0C1A);
  @override Color tertiaryColor   = const Color(0xFF34D399);
  @override Color alternate       = const Color(0xFFFBBF24);
  @override Color error           = const Color(0xFFEF4444);
  @override Color warning         = const Color(0xFFFBBF24);
  @override Color success         = const Color(0xFF34D399);
  @override Color formBackground  = const Color(0xFF3D0C1A);

  @override Color background          = const Color(0xFF0D0F14);
  @override Color surface             = const Color(0xFF161B26);
  @override Color border              = const Color(0xFF252D3D);
  @override Color primaryBackground   = const Color(0xFF0D0F14);
  @override Color secondaryBackground = const Color(0xFF161B26);
  @override Color tertiaryBackground  = const Color(0xFF1E2A3B);
  @override Color transparentBackground = const Color(0xFF94A3B8);

  @override Color textPrimary     = const Color(0xFFF1F5F9);
  @override Color textSecondary   = const Color(0xFF94A3B8);
  @override Color textDisabled    = const Color(0xFF64748B);
  @override Color primaryText     = const Color(0xFFF1F5F9);
  @override Color secondaryText   = const Color(0xFF94A3B8);
  @override Color tertiaryText    = const Color(0xFF64748B);
  @override Color hintText        = const Color(0xFF64748B);

  @override Color sidebarBg       = const Color(0xFF3D0C1A);
  @override Color sidebarActive   = const Color(0xFF5C1528);
  @override Color sidebarText     = const Color(0xFFF1E8EB);
  @override Color sidebarMuted    = const Color(0xFF9A6A76);
}

// ============================================================
// TextStyle Helper
// ============================================================
extension TextStyleHelper on TextStyle {
  TextStyle override({
    required String fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    bool useGoogleFonts = true,
    TextDecoration? decoration,
    TextDecorationStyle? decorationStyle,
    double? lineHeight,
  }) =>
      useGoogleFonts
          ? GoogleFonts.getFont(
              fontFamily,
              color: color ?? this.color,
              fontSize: fontSize ?? this.fontSize,
              fontWeight: fontWeight ?? this.fontWeight,
              fontStyle: fontStyle ?? this.fontStyle,
              letterSpacing: letterSpacing ?? this.letterSpacing,
              decoration: decoration,
              decorationStyle: decorationStyle,
              height: lineHeight,
            )
          : copyWith(
              fontFamily: fontFamily,
              color: color,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              fontStyle: fontStyle,
              decoration: decoration,
              decorationStyle: decorationStyle,
              height: lineHeight,
            );
}

// ============================================================
// Tipografia — Inter
// ============================================================
abstract class Typography {
  String get title1Family;
  TextStyle get title1;
  String get title2Family;
  TextStyle get title2;
  String get title3Family;
  TextStyle get title3;
  String get subtitle1Family;
  TextStyle get subtitle1;
  String get subtitle2Family;
  TextStyle get subtitle2;
  String get bodyText1Family;
  TextStyle get bodyText1;
  String get bodyText2Family;
  TextStyle get bodyText2;
  String get bodyText3Family;
  TextStyle get bodyText3;
  String get plutoDataTextFamily;
  TextStyle get plutoDataText;
  String get copyRightTextFamily;
  TextStyle get copyRightText;
}

class ThemeTypography extends Typography {
  ThemeTypography(this.theme);
  final AppTheme theme;

  @override String get title1Family => 'Inter';
  @override TextStyle get title1 => GoogleFonts.inter(
      fontSize: 26, color: theme.primaryText,
      fontWeight: FontWeight.w700, letterSpacing: -0.5);

  @override String get title2Family => 'Inter';
  @override TextStyle get title2 => GoogleFonts.inter(
      fontSize: 20, color: theme.primaryText,
      fontWeight: FontWeight.w600, letterSpacing: -0.3);

  @override String get title3Family => 'Inter';
  @override TextStyle get title3 => GoogleFonts.inter(
      fontSize: 16, color: theme.primaryText, fontWeight: FontWeight.w600);

  @override String get subtitle1Family => 'Inter';
  @override TextStyle get subtitle1 => GoogleFonts.inter(
      fontSize: 30, color: theme.primaryText, fontWeight: FontWeight.w700);

  @override String get subtitle2Family => 'Inter';
  @override TextStyle get subtitle2 => GoogleFonts.inter(
      fontSize: 22, color: theme.primaryText, fontWeight: FontWeight.w600);

  @override String get bodyText1Family => 'Inter';
  @override TextStyle get bodyText1 => GoogleFonts.inter(
      fontSize: 14, color: theme.primaryText, fontWeight: FontWeight.w400);

  @override String get bodyText2Family => 'Inter';
  @override TextStyle get bodyText2 => GoogleFonts.inter(
      fontSize: 13, color: theme.secondaryText, fontWeight: FontWeight.w400);

  @override String get bodyText3Family => 'Inter';
  @override TextStyle get bodyText3 => GoogleFonts.inter(
      fontSize: 12, color: theme.secondaryText, fontWeight: FontWeight.w400);

  @override String get plutoDataTextFamily => 'Inter';
  @override TextStyle get plutoDataText => GoogleFonts.inter(
      fontSize: 12, color: theme.primaryText, fontWeight: FontWeight.w400);

  @override String get copyRightTextFamily => 'Inter';
  @override TextStyle get copyRightText => GoogleFonts.inter(
      fontSize: 11, color: theme.textDisabled, fontWeight: FontWeight.w500);
}
