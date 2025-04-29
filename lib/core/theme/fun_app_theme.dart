// lib/core/theme/fun_app_theme.dart
import 'package:flutter/material.dart';

/// Uygulama için tema sınıfı
class FunAppTheme {
  /// Ana renk
  static const Color primaryColor = Colors.purple;
  
  /// İkincil renk
  static const Color accentColor = Colors.amber;
  
  /// Arkaplan rengi
  static const Color backgroundColor = Colors.white;
  
  /// Metin rengi
  static const Color textColor = Colors.black87;
  
  /// Hata rengi
  static const Color errorColor = Colors.red;
  
  /// Başarı rengi
  static const Color successColor = Colors.green;
  
  /// Uyarı rengi
  static const Color warningColor = Colors.orange;
  
  /// Buton metin rengi
  static const Color buttonTextColor = Colors.white;
  
  /// Ana kodda kullanılan aydınlık tema getter'ı
  static ThemeData get lightTheme => theme;
  
  /// Ana kodda kullanılan karanlık tema getter'ı
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark()
      .copyWith(
        primary: primaryColor, 
        secondary: accentColor,
        error: errorColor,
      ),
    scaffoldBackgroundColor: Colors.grey[900],
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: Colors.white70,
        fontSize: 16.0,
      ),
      bodyMedium: TextStyle(
        color: Colors.white70,
        fontSize: 14.0,
      ),
      titleLarge: TextStyle(
        color: accentColor,
        fontSize: 22.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: buttonTextColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
  );
  
  /// Tema verisi
  static ThemeData get theme => ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.fromSwatch()
      .copyWith(
        primary: primaryColor, 
        secondary: accentColor,
        error: errorColor,
      ),
    scaffoldBackgroundColor: backgroundColor,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: textColor,
        fontSize: 16.0,
      ),
      bodyMedium: TextStyle(
        color: textColor,
        fontSize: 14.0,
      ),
      titleLarge: TextStyle(
        color: primaryColor,
        fontSize: 22.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: buttonTextColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
  );
}