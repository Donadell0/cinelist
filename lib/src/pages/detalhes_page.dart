// =============================================================================
// ARQUIVO: lib/src/pages/detalhes_page.dart
// PROPÓSITO: Tela de detalhes com ações contextuais por lista.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/filme_model.dart';
import '../viewmodels/filme_viewmodel.dart';
import '../widgets/avaliacao_widget.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class DetalhesPage extends StatelessWidget {
  const DetalhesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final filme =
        ModalRoute.of(context)!.settings.arguments as FilmeModel;

    return Scaffold(
      body: Consumer<FilmeViewModel>(
        builder: (context, viewModel, child) {
          final onde = viewModel.ondeEstaOFilme(filme.imdbId);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppColors.fundoPrincipal,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildPosterBackground(filme),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(filme.titulo,
                          style: AppTextStyles.tituloPrincipal),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          _buildChip(Icons.calendar_today_outlined, filme.ano),
                          const SizedBox(width: 12),
                          _buildChip(Icons.movie_outlined,
                              filme.tipo.toUpperCase()),
                          // Badge de status da lista
                          if (onde != null) ...[
                            const SizedBox(width: 12),
                            _buildStatusBadge(onde),
                          ],
                        ],
                      ),

                      // Avaliação — só aparece se está em "Já Assisti"
                      if (onde == 'ja_assisti') ...[
                        const SizedBox(height: 20),
                        const Divider(color: AppColors.divisor),
                        const SizedBox(height: 12),
                        const Text('Sua avaliação:',
                            style: TextStyle(
                                color: AppColors.textoSecundario,
                                fontSize: 14)),
                        const SizedBox(height: 8),
                        // Busca o filme atualizado da lista para pegar nota atual
                        Consumer<FilmeViewModel>(
                          builder: (context, vm, _) {
                            final filmeAtual = vm.jaAssisti.firstWhere(
                              (f) => f.imdbId == filme.imdbId,
                              orElse: () => filme,
                            );
                            return AvaliacaoWidget(
                              avaliacao: filmeAtual.avaliacao,
                              tamanho: 36,
                              onAvaliar: (estrelas) async {
                                await vm.avaliarFilme(filme.imdbId, estrelas);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '⭐ Avaliado com $estrelas estrela${estrelas > 1 ? 's' : ''}!'),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ],

                      const SizedBox(height: 24),
                      const Divider(color: AppColors.divisor),
                      const SizedBox(height: 16),

                      // Botões de ação conforme o estado do filme
                      _buildBotoesAcao(context, viewModel, filme, onde),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBotoesAcao(BuildContext context, FilmeViewModel viewModel,
      FilmeModel filme, String? onde) {
    if (onde == null) {
      // Filme não está em nenhuma lista → botão para adicionar
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            await viewModel.adicionarQueroAssistir(filme);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('🔖 Adicionado à lista Quero Assistir!')),
              );
            }
          },
          icon: const Icon(Icons.bookmark_add_outlined),
          label: const Text('Adicionar à lista'),
        ),
      );
    }

    if (onde == 'quero_assistir') {
      // Está em "Quero Assistir" → opção de mover para "Já Assisti"
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await viewModel.moverParaAssistidos(filme);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('✅ Movido para Já Assisti!'),
                        backgroundColor: AppColors.jaAssistiCor),
                  );
                }
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Marcar como assistido'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.jaAssistiCor),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmarRemocao(context, viewModel, filme),
              icon: const Icon(Icons.delete_outline, color: AppColors.erro),
              label: const Text('Remover da lista',
                  style: TextStyle(color: AppColors.erro)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.erro),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      );
    }

    // Está em "Já Assisti" → só opção de remover
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _confirmarRemocao(context, viewModel, filme),
        icon: const Icon(Icons.delete_outline, color: AppColors.erro),
        label: const Text('Remover da lista',
            style: TextStyle(color: AppColors.erro)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.erro),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  void _confirmarRemocao(BuildContext context, FilmeViewModel viewModel,
      FilmeModel filme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.fundoCard,
        title: const Text('Remover filme',
            style: TextStyle(color: AppColors.textoClaro)),
        content: Text('Remover "${filme.titulo}" da sua lista?',
            style: const TextStyle(color: AppColors.textoSecundario)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textoSecundario)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await viewModel.removerFilme(filme);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Remover',
                style: TextStyle(color: AppColors.erro)),
          ),
        ],
      ),
    );
  }

  Widget _buildPosterBackground(FilmeModel filme) {
    final bool posterValido =
        filme.poster.isNotEmpty && filme.poster != 'N/A';
    return Stack(
      fit: StackFit.expand,
      children: [
        posterValido
            ? Image.network(filme.poster,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder())
            : _placeholder(),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, AppColors.fundoPrincipal],
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.fundoCard,
        child: const Icon(Icons.movie_outlined,
            color: AppColors.textoSecundario, size: 80),
      );

  Widget _buildChip(IconData icon, String texto) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.fundoCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divisor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.textoSecundario),
            const SizedBox(width: 6),
            Text(texto, style: AppTextStyles.subtitulo),
          ],
        ),
      );

  Widget _buildStatusBadge(String lista) {
    final isQuero = lista == 'quero_assistir';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isQuero ? AppColors.queroAssistirCor : AppColors.jaAssistiCor)
            .withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isQuero ? AppColors.queroAssistirCor : AppColors.jaAssistiCor,
        ),
      ),
      child: Text(
        isQuero ? '🔖 Quero Assistir' : '✅ Já Assisti',
        style: TextStyle(
          color:
              isQuero ? AppColors.queroAssistirCor : AppColors.jaAssistiCor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
