// =============================================================================
// ARQUIVO: lib/src/widgets/filme_card_widget.dart
// PROPÓSITO: Card reutilizável de filme — adaptado para as duas listas.
//
// COMPORTAMENTO POR LISTA:
//   'quero_assistir' → mostra botão "Já assisti!" para mover de lista
//   'ja_assisti'     → mostra as estrelas de avaliação
//   null (busca)     → mostra botão de adicionar à lista "Quero Assistir"
// =============================================================================

import 'package:flutter/material.dart';
import '../models/filme_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'avaliacao_widget.dart';

class FilmeCardWidget extends StatelessWidget {
  final FilmeModel filme;

  // Contexto de onde o card está sendo exibido
  // null = tela de busca | 'quero_assistir' | 'ja_assisti'
  final String? contextoLista;

  final VoidCallback? onTap;
  final VoidCallback? onAdicionar;       // Usado na busca → adicionar à lista
  final VoidCallback? onMoverAssistido;  // Usado em "Quero Assistir" → mover
  final VoidCallback? onRemover;         // Remover de qualquer lista
  final Function(int)? onAvaliar;        // Usado em "Já Assisti" → dar nota

  // Indica se o filme já está salvo em alguma lista (controla o ícone na busca)
  final bool jaSalvo;

  const FilmeCardWidget({
    super.key,
    required this.filme,
    this.contextoLista,
    this.onTap,
    this.onAdicionar,
    this.onMoverAssistido,
    this.onRemover,
    this.onAvaliar,
    this.jaSalvo = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.fundoCard,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.sombra,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // --- LINHA PRINCIPAL: poster + info + ações ---
            Row(
              children: [
                // Poster
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    // Só arredonda embaixo se não tiver a barra de estrelas
                    bottomLeft: Radius.circular(12),
                  ),
                  child: _buildPoster(),
                ),

                // Título, ano, tipo
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          filme.titulo,
                          style: AppTextStyles.tituloCard,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 12, color: AppColors.textoSecundario),
                            const SizedBox(width: 4),
                            Text(filme.ano, style: AppTextStyles.subtitulo),
                            const SizedBox(width: 10),
                            _buildTipoBadge(),
                          ],
                        ),
                        // Se já foi assistido e tem avaliação, mostra mini estrelas
                        if (contextoLista == 'ja_assisti' &&
                            filme.avaliacao > 0) ...[
                          const SizedBox(height: 6),
                          AvaliacaoWidget(
                            avaliacao: filme.avaliacao,
                            tamanho: 16,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Botão de ação lateral (depende do contexto)
                _buildBotaoAcao(),
              ],
            ),

            // --- BARRA DE ESTRELAS (só em "Já Assisti") ---
            if (contextoLista == 'ja_assisti')
              _buildBarraAvaliacao(),
          ],
        ),
      ),
    );
  }

  // Botão lateral direito — muda conforme o contexto
  Widget _buildBotaoAcao() {
    if (contextoLista == null) {
      // Contexto: tela de busca — ícone muda se o filme já estiver salvo
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: IconButton(
          icon: Icon(
            jaSalvo ? Icons.bookmark : Icons.bookmark_add_outlined,
            color: jaSalvo ? AppColors.estrela : AppColors.textoSecundario,
          ),
          tooltip: jaSalvo ? 'Já está na sua lista' : 'Adicionar à lista',
          onPressed: jaSalvo ? null : onAdicionar,
        ),
      );
    }

    if (contextoLista == 'quero_assistir') {
      // Contexto: aba Quero Assistir — botão para mover + remover
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline,
                color: AppColors.jaAssistiCor),
            tooltip: 'Marcar como assistido',
            onPressed: onMoverAssistido,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.erro),
            tooltip: 'Remover',
            onPressed: onRemover,
          ),
        ],
      );
    }

    if (contextoLista == 'ja_assisti') {
      // Contexto: aba Já Assisti — só botão de remover
      return Padding(
        padding: const EdgeInsets.only(right: 4),
        child: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.erro),
          tooltip: 'Remover',
          onPressed: onRemover,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // Barra de avaliação com estrelas — só aparece em "Já Assisti"
  Widget _buildBarraAvaliacao() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: AppColors.divisor, height: 16),
          const Text(
            'Sua avaliação:',
            style: TextStyle(
              color: AppColors.textoSecundario,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          AvaliacaoWidget(
            avaliacao: filme.avaliacao,
            onAvaliar: onAvaliar, // Interativo — usuário pode tocar
            tamanho: 30,
          ),
        ],
      ),
    );
  }

  Widget _buildPoster() {
    final bool posterValido =
        filme.poster.isNotEmpty && filme.poster != 'N/A';
    return SizedBox(
      width: 80,
      height: contextoLista == 'ja_assisti' ? 130 : 110,
      child: posterValido
          ? Image.network(
        filme.poster,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: AppColors.fundoInput,
            child: const Center(
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primaria),
            ),
          );
        },
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() => Container(
    color: AppColors.fundoInput,
    child: const Icon(Icons.movie_outlined,
        color: AppColors.textoSecundario, size: 36),
  );

  Widget _buildTipoBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: AppColors.primaria.withOpacity(0.15),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: AppColors.primaria.withOpacity(0.4)),
    ),
    child: Text(
      filme.tipo.toUpperCase(),
      style: const TextStyle(
        color: AppColors.primaria,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    ),
  );
}