import 'package:audioplayers/audioplayers.dart';

import 'configuracoes_service.dart';

/// Toca a trilha sonora do jogo em loop enquanto o app estiver aberto.
///
/// Uma única instância global (iniciada no `main`) toca continuamente por
/// trás de todas as telas. Respeita o interruptor MÚSICA das Configurações:
/// [aplicarPreferencia] pausa/retoma a trilha sem reiniciá-la do começo.
class MusicaService {
  MusicaService._();

  static final MusicaService instance = MusicaService._();

  static const _caminhoTrilha = 'lib/Music/Clearing_the_Last_Gate.mp3';

  // Nossos assets não ficam sob uma pasta "assets/", então zeramos o prefixo
  // padrão do AudioCache para usar o caminho do pubspec diretamente.
  final AudioPlayer _player = AudioPlayer()..audioCache = AudioCache(prefix: '');

  bool _iniciado = false;

  /// Prepara e começa a trilha sonora (se a música estiver ligada). Chame uma
  /// única vez, no arranque do app.
  Future<void> iniciar() async {
    if (_iniciado) return;
    _iniciado = true;

    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setSource(AssetSource(_caminhoTrilha));
    if (ConfiguracoesService.instance.musicaLigada) {
      await _player.resume();
    }
  }

  /// Chamado ao ligar/desligar o interruptor MÚSICA na tela de Configurações.
  Future<void> aplicarPreferencia() async {
    if (!_iniciado) return;
    if (ConfiguracoesService.instance.musicaLigada) {
      await _player.resume();
    } else {
      await _player.pause();
    }
  }
}
