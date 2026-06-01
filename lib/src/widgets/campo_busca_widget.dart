// =============================================================================
// ARQUIVO: lib/src/widgets/campo_busca_widget.dart
// =============================================================================

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CampoBuscaWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onBuscar;
  final VoidCallback? onLimpar;

  const CampoBuscaWidget({
    super.key,
    required this.controller,
    required this.onBuscar,
    this.onLimpar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTextStyles.input,
              textInputAction: TextInputAction.search,
              onSubmitted: onBuscar,
              decoration: InputDecoration(
                hintText: 'Buscar filmes...',
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.textoSecundario),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, child) {
                    return value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: AppColors.textoSecundario),
                            onPressed: () {
                              controller.clear();
                              onLimpar?.call();
                            },
                          )
                        : const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => onBuscar(controller.text),
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }
}
