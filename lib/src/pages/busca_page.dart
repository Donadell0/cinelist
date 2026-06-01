// =============================================================================
// ARQUIVO: lib/src/pages/busca_page.dart
// PROPÓSITO: Tela de busca — agora o botão adiciona à lista "Quero Assistir".
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/filme_viewmodel.dart';
import '../widgets/filme_card_widget.dart';
import '../widgets/campo_busca_widget.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class BuscaPage extends StatefulWidget {
  const BuscaPage({super.key});

  @override
  State<BuscaPage> createState() => _BuscaPageState();
}

class _BuscaPageState extends State<BuscaPage> {
  late final TextEditingController _controllerBusca;

  @override
  void initState() {
    super.initState();
    _controllerBusca = TextEditingController();
  }

  @override
  void dispose() {
    _controllerBusca.dispose();
    super.dispose();
  }

  void _realizarBusca(String termo) {
    if (termo.trim().isEmpty) return;
    context.read<FilmeViewModel>().buscarFilmes(termo.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Filmes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            context.read<FilmeViewModel>().limparBusca();
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          CampoBuscaWidget(
            controller: _controllerBusca,
            onBuscar: _realizarBusca,
            onLimpar: () => context.read<FilmeViewModel>().limparBusca(),
          ),
          Expanded(
            child: Consumer<FilmeViewModel>(
              builder: (context, viewModel, child) {

                if (viewModel.carregandoBusca) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.primaria),
                        SizedBox(height: 16),
                        Text('Buscando filmes...', style: AppTextStyles.mensagem),
                      ],
                    ),
                  );
                }

                if (viewModel.mensagemErro != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off_outlined,
                            size: 64, color: AppColors.erro),
                        const SizedBox(height: 16),
                        Text(viewModel.mensagemErro!,
                            style: AppTextStyles.mensagem,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              _realizarBusca(_controllerBusca.text),
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                if (viewModel.resultadosBusca.isEmpty &&
                    _controllerBusca.text.isNotEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_outlined,
                            size: 64, color: AppColors.textoSecundario),
                        SizedBox(height: 16),
                        Text('Nenhum filme encontrado.\nTente outro título.',
                            style: AppTextStyles.mensagem,
                            textAlign: TextAlign.center),
                      ],
                    ),
                  );
                }

                if (viewModel.resultadosBusca.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_movies_outlined,
                            size: 80, color: AppColors.textoSecundario),
                        SizedBox(height: 16),
                        Text('Digite um título para buscar',
                            style: AppTextStyles.mensagem),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: viewModel.resultadosBusca.length,
                  itemBuilder: (context, index) {
                    final filme = viewModel.resultadosBusca[index];
                    final onde = viewModel.ondeEstaOFilme(filme.imdbId);

                    return FilmeCardWidget(
                      filme: filme,
                      contextoLista: null, // contexto = tela de busca
                      jaSalvo: onde != null, // true = ícone muda para salvo
                      onTap: () => Navigator.pushNamed(
                          context, '/detalhes',
                          arguments: filme),
                      onAdicionar: onde != null
                          ? null // já salvo, botão desabilitado
                          : () async {
                        await viewModel.adicionarQueroAssistir(filme);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '🔖 "${filme.titulo}" adicionado à lista!'),
                              backgroundColor: AppColors.queroAssistirCor,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}