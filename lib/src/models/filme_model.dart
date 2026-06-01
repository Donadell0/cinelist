// =============================================================================
// ARQUIVO: lib/src/models/filme_model.dart
// PROPÓSITO: Estrutura de dados do Filme — agora com suporte a duas listas
// e avaliação por estrelas.
//
// NOVOS CAMPOS:
//   lista      → 'quero_assistir' ou 'ja_assisti'
//   avaliacao  → 0 a 5 estrelas (0 = não avaliado ainda)
// =============================================================================

class FilmeModel {
  final String imdbId;
  final String titulo;
  final String ano;
  final String poster;
  final String tipo;

  // 'quero_assistir' ou 'ja_assisti'
  final String lista;

  // 0 = sem avaliação | 1 a 5 = nota em estrelas
  final int avaliacao;

  const FilmeModel({
    required this.imdbId,
    required this.titulo,
    required this.ano,
    required this.poster,
    required this.tipo,
    this.lista = 'quero_assistir', // padrão: vai para "Quero Assistir"
    this.avaliacao = 0,
  });

  // JSON da API → FilmeModel
  factory FilmeModel.fromJson(Map<String, dynamic> json) {
    return FilmeModel(
      imdbId: json['imdbID'] ?? '',
      titulo: json['Title'] ?? 'Título desconhecido',
      ano: json['Year'] ?? 'Ano desconhecido',
      poster: json['Poster'] ?? '',
      tipo: json['Type'] ?? 'movie',
    );
  }

  // FilmeModel → Map para salvar no SQLite
  Map<String, dynamic> toMap() {
    return {
      'imdb_id': imdbId,
      'titulo': titulo,
      'ano': ano,
      'poster': poster,
      'tipo': tipo,
      'lista': lista,
      'avaliacao': avaliacao,
    };
  }

  // Map do SQLite → FilmeModel
  factory FilmeModel.fromMap(Map<String, dynamic> map) {
    return FilmeModel(
      imdbId: map['imdb_id'] ?? '',
      titulo: map['titulo'] ?? '',
      ano: map['ano'] ?? '',
      poster: map['poster'] ?? '',
      tipo: map['tipo'] ?? '',
      lista: map['lista'] ?? 'quero_assistir',
      avaliacao: map['avaliacao'] ?? 0,
    );
  }

  // copyWith: cria uma cópia do objeto alterando apenas os campos desejados.
  // Essencial para imutabilidade — nunca alteramos o objeto original.
  FilmeModel copyWith({
    String? lista,
    int? avaliacao,
  }) {
    return FilmeModel(
      imdbId: imdbId,
      titulo: titulo,
      ano: ano,
      poster: poster,
      tipo: tipo,
      lista: lista ?? this.lista,
      avaliacao: avaliacao ?? this.avaliacao,
    );
  }
}
