import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Colors
  static const Color background = Color(0xFF0A0A0B);
  static const Color surface = Color(0xFF141416);
  static const Color surface2 = Color(0xFF1C1C1F);
  static const Color panel = Color(0xFF2A2A2D);
  static const Color hairline = Color(0x993A3A3F); // 60% opacity
  static const Color text = Color(0xFFF2F2F3);
  static const Color textMuted = Color(0xFF9A9AA0);
  static const Color accent = Color(0xFFE8E8EA);

  // Status Colors
  static const Color statusSubmitted = Color(0xFF9A9AA0);
  static const Color statusVerified = Color(0xFF5B9DFF);
  static const Color statusAssigned = Color(0xFF8B7CFF);
  static const Color statusInProgress = Color(0xFFFFB547);
  static const Color statusResolved = Color(0xFF3DDC84);
  static const Color statusRejected = Color(0xFFFF5C5C);
  static const Color statusEscalated = Color(0xFFFF7A3D);
  static const Color statusUnknown = Color(0xFF9A9AA0);

  // Label Style
  static const TextStyle labelStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    letterSpacing: 1.4,
    color: textMuted,
    fontWeight: FontWeight.w600,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: accent,
        onPrimary: Colors.black,
        secondary: panel,
        onSurface: text,
      ),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Michroma', color: text),
        displayMedium: TextStyle(fontFamily: 'Michroma', color: text),
        displaySmall: TextStyle(fontFamily: 'Michroma', color: text),
        headlineLarge: TextStyle(fontFamily: 'Michroma', color: text),
        headlineMedium: TextStyle(fontFamily: 'Michroma', color: text),
        headlineSmall: TextStyle(fontFamily: 'Michroma', color: text),
        titleLarge: TextStyle(fontFamily: 'Michroma', color: text),
        bodyLarge: TextStyle(color: text),
        bodyMedium: TextStyle(color: text),
        bodySmall: TextStyle(color: textMuted),
        labelSmall: labelStyle,
      ),
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          side: BorderSide(color: hairline, width: 1),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: surface2,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: hairline, width: 1),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: hairline, width: 1),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accent, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          minimumSize: const Size(48, 48),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Michroma',
          fontSize: 20,
          color: text,
          letterSpacing: 1.0,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: text,
        unselectedItemColor: textMuted,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          letterSpacing: 1.4,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          letterSpacing: 1.4,
        ),
      ),
      iconTheme: const IconThemeData(
        color: text,
      ),
    );
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'submitted': return statusSubmitted;
      case 'verified': return statusVerified;
      case 'assigned': return statusAssigned;
      case 'in_progress': return statusInProgress;
      case 'resolved': return statusResolved;
      case 'rejected': return statusRejected;
      case 'escalated': return statusEscalated;
      default: return statusUnknown;
    }
  }
}
