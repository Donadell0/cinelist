// =============================================================================
// ARQUIVO: lib/src/services/database_helper.dart
// PROPÓSITO: Gerenciar o banco de dados SQLite local.
//
// MUDANÇAS NESTA VERSÃO:
//   - Tabela agora tem colunas 'lista' e 'avaliacao'
//   - Novo método: moverParaAssistidos()
//   - Novo método: atualizarAvaliacao()
//   - Novo método: buscarPorLista()
// =============================================================================

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/filme_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cinelist.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE filmes (
        imdb_id   TEXT PRIMARY KEY,
        titulo    TEXT NOT NULL,
        ano       TEXT NOT NULL,
        poster    TEXT NOT NULL,
        tipo      TEXT NOT NULL,
        lista     TEXT NOT NULL DEFAULT 'quero_assistir',
        avaliacao INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // Salva um filme (INSERT ou substitui se já existir)
  Future<int> salvarFilme(FilmeModel filme) async {
    final db = await instance.database;
    return await db.insert(
      'filmes',
      filme.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Busca todos os filmes de uma lista específica
  // lista: 'quero_assistir' ou 'ja_assisti'
  Future<List<FilmeModel>> buscarPorLista(String lista) async {
    final db = await instance.database;
    final resultado = await db.query(
      'filmes',
      where: 'lista = ?',
      whereArgs: [lista],
    );
    return resultado.map((map) => FilmeModel.fromMap(map)).toList();
  }

  // Move o filme de 'quero_assistir' para 'ja_assisti'
  // Mantém todos os outros dados intactos, só muda o campo 'lista'
  Future<int> moverParaAssistidos(String imdbId) async {
    final db = await instance.database;
    return await db.update(
      'filmes',
      {'lista': 'ja_assisti'},
      where: 'imdb_id = ?',
      whereArgs: [imdbId],
    );
  }

  // Atualiza apenas a nota de avaliação do filme (1 a 5 estrelas)
  Future<int> atualizarAvaliacao(String imdbId, int avaliacao) async {
    final db = await instance.database;
    return await db.update(
      'filmes',
      {'avaliacao': avaliacao},
      where: 'imdb_id = ?',
      whereArgs: [imdbId],
    );
  }

  // Verifica se um filme já está salvo em qualquer lista
  Future<bool> filmeSalvo(String imdbId) async {
    final db = await instance.database;
    final resultado = await db.query(
      'filmes',
      where: 'imdb_id = ?',
      whereArgs: [imdbId],
    );
    return resultado.isNotEmpty;
  }

  // Retorna em qual lista o filme está (null se não estiver salvo)
  Future<String?> qualLista(String imdbId) async {
    final db = await instance.database;
    final resultado = await db.query(
      'filmes',
      columns: ['lista'],
      where: 'imdb_id = ?',
      whereArgs: [imdbId],
    );
    if (resultado.isEmpty) return null;
    return resultado.first['lista'] as String;
  }

  // Remove o filme completamente do banco
  Future<int> removerFilme(String imdbId) async {
    final db = await instance.database;
    return await db.delete(
      'filmes',
      where: 'imdb_id = ?',
      whereArgs: [imdbId],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
