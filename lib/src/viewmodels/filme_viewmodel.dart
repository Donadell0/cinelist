// =============================================================================
// ARQUIVO: lib/src/viewmodels/filme_viewmodel.dart
// PROPÓSITO: Toda a lógica de negócio do app — padrão MVVM.
//
// LÓGICA DAS DUAS ABAS:
//   _queroAssistir  → filmes salvos como "Quero Assistir"
//   _jaAssisti      → filmes salvos como "Já Assisti"
//
// FLUXO PRINCIPAL:
//   Busca → salvar em "Quero Assistir"
//   "Quero Assistir" → mover para "Já Assisti" + avaliar com estrelas
//   Qualquer lista → remover
// =============================================================================

import 'package:flutter/foundation.dart';
import '../models/filme_model.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';

class FilmeViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // --- ESTADO INTERNO ---
  List<FilmeModel> _resultadosBusca = [];
  List<FilmeModel> _queroAssistir = [];
  List<FilmeModel> _jaAssisti = [];
  bool _carregandoBusca = false;
  bool _carregandoDB = false;
  String? _mensagemErro;

  // Set para verificação rápida O(1)
  final Map<String, String> _listaDoFilme = {}; // imdbId → 'quero_assistir' | 'ja_assisti'

  // --- GETTERS PÚBLICOS ---
  List<FilmeModel> get resultadosBusca => _resultadosBusca;
  List<FilmeModel> get queroAssistir => _queroAssistir;
  List<FilmeModel> get jaAssisti => _jaAssisti;
  bool get carregandoBusca => _carregandoBusca;
  bool get carregandoDB => _carregandoDB;
  String? get mensagemErro => _mensagemErro;

  FilmeViewModel() {
    carregarTudo();
  }

  // Carrega ambas as listas do banco de dados ao iniciar
  Future<void> carregarTudo() async {
    _carregandoDB = true;
    notifyListeners();

    try {
      // .reversed + toList() garante que o mais recente (último inserido) fique no topo
      _queroAssistir = (await _dbHelper.buscarPorLista('quero_assistir')).reversed.toList();
      _jaAssisti = (await _dbHelper.buscarPorLista('ja_assisti')).reversed.toList();

      // Reconstrói o mapa de localização para verificação rápida
      _listaDoFilme.clear();
      for (final f in _queroAssistir) {
        _listaDoFilme[f.imdbId] = 'quero_assistir';
      }
      for (final f in _jaAssisti) {
        _listaDoFilme[f.imdbId] = 'ja_assisti';
      }
    } catch (e) {
      _mensagemErro = 'Erro ao carregar filmes salvos.';
    } finally {
      _carregandoDB = false;
      notifyListeners();
    }
  }

  // --- BUSCA NA API ---
  Future<void> buscarFilmes(String termoBusca) async {
    _mensagemErro = null;
    _carregandoBusca = true;
    _resultadosBusca = [];
    notifyListeners();

    try {
      _resultadosBusca = await _apiService.buscarFilmes(termoBusca);
    } catch (e) {
      _mensagemErro = 'Erro ao buscar filmes. Verifique sua conexão.';
    } finally {
      _carregandoBusca = false;
      notifyListeners();
    }
  }

  // --- ADICIONAR EM "QUERO ASSISTIR" ---
  Future<void> adicionarQueroAssistir(FilmeModel filme) async {
    final novoFilme = filme.copyWith(lista: 'quero_assistir');
    await _dbHelper.salvarFilme(novoFilme);
    // insert(0, ...) coloca no início — o mais recente fica no topo
    _queroAssistir.insert(0, novoFilme);
    _listaDoFilme[filme.imdbId] = 'quero_assistir';
    notifyListeners();
  }

  // --- MOVER PARA "JÁ ASSISTI" ---
  // Remove de "Quero Assistir" e adiciona em "Já Assisti"
  Future<void> moverParaAssistidos(FilmeModel filme) async {
    await _dbHelper.moverParaAssistidos(filme.imdbId);

    // Remove da lista local de quero assistir
    _queroAssistir.removeWhere((f) => f.imdbId == filme.imdbId);

    // Adiciona na lista local de já assisti (sem avaliação ainda)
    final filmeAtualizado = filme.copyWith(lista: 'ja_assisti', avaliacao: 0);
    // insert(0, ...) coloca no início — o mais recente fica no topo
    _jaAssisti.insert(0, filmeAtualizado);

    _listaDoFilme[filme.imdbId] = 'ja_assisti';
    notifyListeners();
  }

  // --- AVALIAR FILME COM ESTRELAS ---
  // Salva a nota (1-5) e atualiza a lista local
  Future<void> avaliarFilme(String imdbId, int estrelas) async {
    await _dbHelper.atualizarAvaliacao(imdbId, estrelas);

    // Atualiza o objeto na lista local sem precisar recarregar tudo do banco
    final index = _jaAssisti.indexWhere((f) => f.imdbId == imdbId);
    if (index != -1) {
      _jaAssisti[index] = _jaAssisti[index].copyWith(avaliacao: estrelas);
      notifyListeners();
    }
  }

  // --- REMOVER FILME (de qualquer lista) ---
  Future<void> removerFilme(FilmeModel filme) async {
    await _dbHelper.removerFilme(filme.imdbId);
    _queroAssistir.removeWhere((f) => f.imdbId == filme.imdbId);
    _jaAssisti.removeWhere((f) => f.imdbId == filme.imdbId);
    _listaDoFilme.remove(filme.imdbId);
    notifyListeners();
  }

  // Retorna em qual lista o filme está: 'quero_assistir', 'ja_assisti' ou null
  String? ondeEstaOFilme(String imdbId) => _listaDoFilme[imdbId];

  bool filmeSalvo(String imdbId) => _listaDoFilme.containsKey(imdbId);

  void limparBusca() {
    _resultadosBusca = [];
    _mensagemErro = null;
    notifyListeners();
  }
}