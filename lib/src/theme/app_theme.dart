// =============================================================================
// ARQUIVO: lib/src/theme/app_theme.dart
// =============================================================================

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get temaEscuro {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.fundoPrincipal,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaria,
        secondary: AppColors.primariaEscura,
        surface: AppColors.fundoCard,
        error: AppColors.erro,
        onPrimary: AppColors.textoClaro,
        onSurface: AppColors.textoClaro,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.fundoPrincipal,
        foregroundColor: AppColors.textoClaro,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.tituloPrincipal,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.textoClaro,
        unselectedLabelColor: AppColors.textoSecundario,
        indicatorColor: AppColors.primaria,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: TextStyle(fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaria,
          foregroundColor: AppColors.textoClaro,
          textStyle: AppTextStyles.botao,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.fundoInput,
        hintStyle: AppTextStyles.subtitulo,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaria, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.fundoCard,
        contentTextStyle: TextStyle(color: AppColors.textoClaro),
      ),
    );
  }
}
