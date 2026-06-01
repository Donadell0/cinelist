// =============================================================================
// ARQUIVO: lib/src/theme/app_text_styles.dart
// =============================================================================

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle tituloPrincipal = TextStyle(
    color: AppColors.textoClaro, fontSize: 24,
    fontWeight: FontWeight.bold, letterSpacing: 0.5,
  );
  static const TextStyle tituloCard = TextStyle(
    color: AppColors.textoClaro, fontSize: 15,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle subtitulo = TextStyle(
    color: AppColors.textoSecundario, fontSize: 13,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle botao = TextStyle(
    color: AppColors.textoClaro, fontSize: 14,
    fontWeight: FontWeight.w700, letterSpacing: 1.2,
  );
  static const TextStyle input = TextStyle(
    color: AppColors.textoClaro, fontSize: 16,
  );
  static const TextStyle mensagem = TextStyle(
    color: AppColors.textoSecundario, fontSize: 16,
    fontWeight: FontWeight.w400,
  );
}
