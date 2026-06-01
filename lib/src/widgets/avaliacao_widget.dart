// =============================================================================
// ARQUIVO: lib/src/widgets/avaliacao_widget.dart
// PROPÓSITO: Widget de avaliação por estrelas (1 a 5).
//
// Pode ser usado em modo interativo (o usuário toca para avaliar)
// ou em modo somente leitura (apenas exibe a nota já dada).
// =============================================================================

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AvaliacaoWidget extends StatelessWidget {
  // Nota atual (0 = sem avaliação, 1-5 = estrelas)
  final int avaliacao;

  // Callback chamado quando o usuário toca em uma estrela
  // Se for null, o widget fica em modo somente leitura
  final Function(int)? onAvaliar;

  // Tamanho de cada estrela
  final double tamanho;

  const AvaliacaoWidget({
    super.key,
    required this.avaliacao,
    this.onAvaliar,
    this.tamanho = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        // index vai de 0 a 4; estrela 1 = index 0, estrela 5 = index 4
        final numeroEstrela = index + 1;
        final estaPreenchida = numeroEstrela <= avaliacao;

        return GestureDetector(
          // onAvaliar?.call() → só chama se não for null (modo interativo)
          onTap: onAvaliar != null ? () => onAvaliar!(numeroEstrela) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              estaPreenchida ? Icons.star : Icons.star_border,
              color: estaPreenchida
                  ? AppColors.estrela
                  : AppColors.textoSecundario,
              size: tamanho,
            ),
          ),
        );
      }),
    );
  }
}
