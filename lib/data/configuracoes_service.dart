import 'package:sqflite/sqflite.dart' show ConflictAlgorithm;

import 'database_helper.dart';

/// Preferências do app, persistidas na tabela `configuracoes` (chave/valor).
///
/// Carregado uma vez no arranque para que a interface leia os valores de forma
/// síncrona. Hoje guarda dois interruptores:
///  - [devMode]: quando ligado, libera todas as fases (para desenvolvimento e
///    testes, sem precisar concluí-las na ordem);
///  - [musicaLigada]: liga/desliga a trilha sonora tocada por [MusicaService].
class ConfiguracoesService {
  ConfiguracoesService._();

  /// Instância única usada em todo o app.
  static final ConfiguracoesService instance = ConfiguracoesService._();

  final DatabaseHelper _helper = DatabaseHelper.instance;

  static const String _chaveDev = 'dev_mode';
  static const String _chaveMusica = 'musica';

  bool _devMode = false;
  bool _musicaLigada = true; // padrão: música ligada quando existir.

  /// Lê as configurações salvas para a memória. Chame no arranque do app.
  Future<void> carregar() async {
    final db = await _helper.database;
    final linhas = await db.query('configuracoes');
    for (final linha in linhas) {
      final chave = linha['chave'] as String;
      final ligado = (linha['valor'] as String) == '1';
      switch (chave) {
        case _chaveDev:
          _devMode = ligado;
        case _chaveMusica:
          _musicaLigada = ligado;
      }
    }
  }

  /// Modo desenvolvedor: quando `true`, todas as fases ficam desbloqueadas.
  bool get devMode => _devMode;

  /// Se a música do jogo deve tocar.
  bool get musicaLigada => _musicaLigada;

  Future<void> setDevMode(bool valor) async {
    _devMode = valor;
    await _salvar(_chaveDev, valor);
  }

  Future<void> setMusica(bool valor) async {
    _musicaLigada = valor;
    await _salvar(_chaveMusica, valor);
  }

  Future<void> _salvar(String chave, bool valor) async {
    final db = await _helper.database;
    await db.insert(
      'configuracoes',
      {'chave': chave, 'valor': valor ? '1' : '0'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
