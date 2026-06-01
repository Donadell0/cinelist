// =============================================================================
// ARQUIVO: lib/src/pages/home_page.dart
// PROPÓSITO: Tela principal com duas abas via TabBar.
//
// ESTRUTURA:
//   Aba 0 → "Quero Assistir" (lista azul) com botão para marcar como assistido
//   Aba 1 → "Já Assisti" (lista verde) com avaliação por estrelas
//
// Por que DefaultTabController?
// Ele gerencia o estado das abas automaticamente sem precisar de StatefulWidget.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/filme_viewmodel.dart';
import '../widgets/filme_card_widget.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // DefaultTabController gerencia qual aba está ativa
    return DefaultTabController(
      length: 2, // Duas abas
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🎬 CineList'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Buscar filmes',
              onPressed: () => Navigator.pushNamed(context, '/busca'),
            ),
          ],
          // TabBar fica dentro da AppBar para visual integrado
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.bookmark_outlined),
                text: 'Quero Assistir',
              ),
              Tab(
                icon: Icon(Icons.check_circle_outline),
                text: 'Já Assisti',
              ),
            ],
          ),
        ),

        // TabBarView: cada filho corresponde a uma aba
        body: Consumer<FilmeViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.carregandoDB) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaria),
              );
            }

            return TabBarView(
              children: [
                // --- ABA 0: QUERO ASSISTIR ---
                _buildListaQueroAssistir(context, viewModel),

                // --- ABA 1: JÁ ASSISTI ---
                _buildListaJaAssisti(context, viewModel),
              ],
            );
          },
        ),

        // FAB para ir para a busca
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, '/busca'),
          backgroundColor: AppColors.primaria,
          icon: const Icon(Icons.add, color: AppColors.textoClaro),
          label: const Text('Buscar Filme',
              style: TextStyle(color: AppColors.textoClaro)),
        ),
      ),
    );
  }

  // --- LISTA "QUERO ASSISTIR" ---
  Widget _buildListaQueroAssistir(
      BuildContext context, FilmeViewModel viewModel) {
    if (viewModel.queroAssistir.isEmpty) {
      return _buildEstadoVazio(
        context,
        icone: Icons.bookmark_add_outlined,
        mensagem: 'Nenhum filme na lista ainda',
        detalhe: 'Busque filmes e adicione à sua lista!',
        corIcone: AppColors.queroAssistirCor,
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.carregarTudo(),
      color: AppColors.primaria,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: viewModel.queroAssistir.length,
        itemBuilder: (context, index) {
          final filme = viewModel.queroAssistir[index];
          return FilmeCardWidget(
            filme: filme,
            contextoLista: 'quero_assistir',
            onTap: () =>
                Navigator.pushNamed(context, '/detalhes', arguments: filme),
            // Botão de "Já assisti!" — move para a outra lista
            onMoverAssistido: () async {
              await viewModel.moverParaAssistidos(filme);
            },
            onRemover: () => _confirmarRemocao(context, viewModel, filme),
          );
        },
      ),
    );
  }

  // --- LISTA "JÁ ASSISTI" ---
  Widget _buildListaJaAssisti(
      BuildContext context, FilmeViewModel viewModel) {
    if (viewModel.jaAssisti.isEmpty) {
      return _buildEstadoVazio(
        context,
        icone: Icons.check_circle_outline,
        mensagem: 'Nenhum filme assistido ainda',
        detalhe: 'Quando assistir um filme, mova-o para cá!',
        corIcone: AppColors.jaAssistiCor,
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.carregarTudo(),
      color: AppColors.primaria,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: viewModel.jaAssisti.length,
        itemBuilder: (context, index) {
          final filme = viewModel.jaAssisti[index];
          return FilmeCardWidget(
            filme: filme,
            contextoLista: 'ja_assisti',
            onTap: () =>
                Navigator.pushNamed(context, '/detalhes', arguments: filme),
            // Quando o usuário toca em uma estrela, salva a avaliação
            onAvaliar: (estrelas) async {
              await viewModel.avaliarFilme(filme.imdbId, estrelas);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '⭐ "${filme.titulo}" avaliado com $estrelas estrela${estrelas > 1 ? 's' : ''}!'),
                  ),
                );
              }
            },
            onRemover: () => _confirmarRemocao(context, viewModel, filme),
          );
        },
      ),
    );
  }

  // Dialog de confirmação antes de remover — boa UX para ação destrutiva
  void _confirmarRemocao(BuildContext context, FilmeViewModel viewModel,
      dynamic filme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.fundoCard,
        title: const Text('Remover filme',
            style: TextStyle(color: AppColors.textoClaro)),
        content: Text(
          'Deseja remover "${filme.titulo}" da sua lista?',
          style: const TextStyle(color: AppColors.textoSecundario),
        ),
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
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('"${filme.titulo}" removido.'),
                  ),
                );
              }
            },
            child: const Text('Remover',
                style: TextStyle(color: AppColors.erro)),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoVazio(
      BuildContext context, {
        required IconData icone,
        required String mensagem,
        required String detalhe,
        required Color corIcone,
      }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icone, size: 80, color: corIcone.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(mensagem, style: AppTextStyles.tituloPrincipal),
          const SizedBox(height: 8),
          Text(detalhe,
              style: AppTextStyles.mensagem, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/busca'),
            icon: const Icon(Icons.search),
            label: const Text('Buscar Filmes'),
          ),
        ],
      ),
    );
  }
}