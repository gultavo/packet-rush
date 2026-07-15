// Da API pura em Dart (ver [DatabaseHelper]): importar `sqflite` aqui puxaria
// o plugin nativo para o build da web.
import 'package:sqflite_common/sqflite.dart' show ConflictAlgorithm;

import 'database_helper.dart';

/// Preferências do app, persistidas na tabela `configuracoes` (chave/valor).
///
/// Carregado uma vez no arranque para que a interface leia os valores de forma
/// síncrona. Hoje guarda três interruptores:
///  - [devMode]: quando ligado, libera todas as fases (para desenvolvimento e
///    testes, sem precisar concluí-las na ordem);
///  - [musicaLigada]: liga/desliga a trilha sonora tocada por [MusicaService];
///  - [orientacaoPaisagem]: se a gameplay das fases roda com o celular
///    deitado (paisagem) ou em pé (retrato). Só afeta a fase em si — leitura
///    de conteúdo, quiz e menus continuam sempre em retrato.
class ConfiguracoesService {
  ConfiguracoesService._();

  /// Instância única usada em todo o app.
  static final ConfiguracoesService instance = ConfiguracoesService._();

  final DatabaseHelper _helper = DatabaseHelper.instance;

  static const String _chaveDev = 'dev_mode';
  static const String _chaveMusica = 'musica';
  static const String _chaveOrientacao = 'orientacao_paisagem';

  bool _devMode = false;
  bool _musicaLigada = true; // padrão: música ligada quando existir.
  bool _orientacaoPaisagem = true; // padrão: gameplay deitada.

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
        case _chaveOrientacao:
          _orientacaoPaisagem = ligado;
      }
    }
  }

  /// Modo desenvolvedor: quando `true`, todas as fases ficam desbloqueadas.
  bool get devMode => _devMode;

  /// Se a música do jogo deve tocar.
  bool get musicaLigada => _musicaLigada;

  /// Se a gameplay das fases roda em paisagem (`true`) ou em retrato
  /// (`false`). A geometria das fases é a mesma nos dois modos: o motor usa
  /// um mundo de altura lógica fixa, então o que muda é só quanto do mapa
  /// cabe na tela — em paisagem enxerga-se bem mais à frente.
  bool get orientacaoPaisagem => _orientacaoPaisagem;

  Future<void> setDevMode(bool valor) async {
    _devMode = valor;
    await _salvar(_chaveDev, valor);
  }

  Future<void> setMusica(bool valor) async {
    _musicaLigada = valor;
    await _salvar(_chaveMusica, valor);
  }

  Future<void> setOrientacaoPaisagem(bool valor) async {
    _orientacaoPaisagem = valor;
    await _salvar(_chaveOrientacao, valor);
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
