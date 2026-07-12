import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
// `sqflite_ffi` re-exporta a API pública do `sqflite` (Database, openDatabase,
// getDatabasesPath, etc.), então um único import cobre mobile e desktop.
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Ponto único de acesso ao banco de dados SQLite local do jogo.
///
/// Encapsula a abertura da conexão e a criação do schema. O resto do app fala
/// com os *repositories* (ex.: [ProgressoRepository]) e nunca diretamente com
/// esta classe — assim, se um dia trocarmos o mecanismo de persistência, só
/// este arquivo muda.
///
/// Suporta tanto mobile (Android/iOS, via `sqflite` nativo) quanto desktop
/// (Windows/Linux/macOS, via `sqflite_common_ffi`), que é onde o projeto é
/// desenvolvido.
class DatabaseHelper {
  DatabaseHelper._();

  /// Instância única (singleton) usada em todo o app.
  static final DatabaseHelper instance = DatabaseHelper._();

  /// Nome do arquivo do banco gravado no dispositivo.
  static const String _nomeDoBanco = 'packet_rush.db';

  /// Versão do schema. Incremente ao mudar a estrutura das tabelas e trate a
  /// migração em [_onUpgrade].
  static const int _versao = 2;

  Database? _db;

  /// Garante que o backend correto esteja registrado antes de abrir o banco.
  ///
  /// Deve ser chamado uma vez no arranque do app (ver `main.dart`), antes de
  /// qualquer acesso ao banco. No desktop, ativa o backend FFI; no mobile, o
  /// `sqflite` nativo já é o padrão e nada precisa ser feito.
  static void inicializarFactory() {
    if (kIsWeb) return; // Web usaria outro backend; o jogo roda em app nativo.
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  /// Conexão aberta (abrindo-a de forma preguiçosa na primeira chamada).
  Future<Database> get database async {
    return _db ??= await _abrir();
  }

  Future<Database> _abrir() async {
    final dir = await getDatabasesPath();
    final caminho = p.join(dir, _nomeDoBanco);
    return openDatabase(
      caminho,
      version: _versao,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Cria as tabelas na primeira execução.
  Future<void> _onCreate(Database db, int version) async {
    // Cada linha registra uma fase que o jogador concluiu (passou pelo portal
    // respondendo o quiz). `acertos` guarda o melhor número de respostas certas
    // (0–5), usado para pintar as estrelas no seletor.
    await db.execute('''
      CREATE TABLE fases_concluidas (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        andar         INTEGER NOT NULL,
        fase          INTEGER NOT NULL,
        acertos       INTEGER NOT NULL DEFAULT 0,
        concluida_em  TEXT    NOT NULL,
        UNIQUE(andar, fase)
      )
    ''');

    await _criarTabelaConfiguracoes(db);
  }

  /// Trata migrações quando [_versao] muda.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // v1 → v2: coluna de acertos (estrelas) e tabela de configurações.
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE fases_concluidas ADD COLUMN acertos INTEGER NOT NULL DEFAULT 0',
      );
      await _criarTabelaConfiguracoes(db);
    }
  }

  /// Tabela simples chave/valor para preferências do app (DEV, música, etc.).
  Future<void> _criarTabelaConfiguracoes(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS configuracoes (
        chave  TEXT PRIMARY KEY,
        valor  TEXT NOT NULL
      )
    ''');
  }

  /// Fecha a conexão (útil em testes). Em uso normal o app mantém aberta.
  Future<void> fechar() async {
    await _db?.close();
    _db = null;
  }
}
