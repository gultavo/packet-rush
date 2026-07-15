import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

import 'configuracoes_service.dart';

/// Toca a trilha sonora do jogo em loop enquanto o app estiver aberto e em
/// primeiro plano.
///
/// Uma única instância global (iniciada no `main`) toca continuamente por
/// trás de todas as telas. Respeita o interruptor MÚSICA das Configurações
/// ([aplicarPreferencia]) e pausa automaticamente quando o app vai para
/// segundo plano, retomando ao voltar (via [WidgetsBindingObserver]).
class MusicaService with WidgetsBindingObserver {
  MusicaService._();

  static final MusicaService instance = MusicaService._();

  static const _caminhoTrilha = 'lib/Music/Clearing_the_Last_Gate.mp3';

  // Nossos assets não ficam sob uma pasta "assets/", então zeramos o prefixo
  // padrão do AudioCache para usar o caminho do pubspec diretamente.
  final AudioPlayer _player = AudioPlayer()..audioCache = AudioCache(prefix: '');

  bool _iniciado = false;

  /// Prepara e começa a trilha sonora (se a música estiver ligada). Chame uma
  /// única vez, no arranque do app.
  ///
  /// Tocar áudio pode falhar por motivos fora do nosso controle (no navegador,
  /// o autoplay é bloqueado até o usuário interagir com a página). A música é
  /// enfeite: se ela não subir, o jogo continua normalmente — por isso nada
  /// aqui pode escapar como exceção.
  Future<void> iniciar() async {
    if (_iniciado) return;
    _iniciado = true;

    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setSource(AssetSource(_caminhoTrilha));
      WidgetsBinding.instance.addObserver(this);
      if (ConfiguracoesService.instance.musicaLigada) {
        await _player.resume();
      }
    } catch (e) {
      debugPrint('Não foi possível iniciar a trilha sonora: $e');
    }
  }

  /// Tenta (re)tomar a trilha depois do primeiro toque/clique do usuário.
  ///
  /// Existe por causa da política de autoplay dos navegadores: na web, o
  /// `resume()` do arranque é recusado porque ainda não houve interação com a
  /// página, e a música só pode começar a partir de um gesto do usuário. Nas
  /// outras plataformas a trilha já está tocando e isto vira um no-op.
  Future<void> retomarAposGesto() async {
    if (!_iniciado) return;
    if (!ConfiguracoesService.instance.musicaLigada) return;
    if (_player.state == PlayerState.playing) return;
    try {
      await _player.resume();
    } catch (_) {
      // Segue sem música; nada a fazer.
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

  // Pausa a trilha quando o app sai de primeiro plano (minimizado, tela
  // bloqueada, trocado de app) e retoma ao voltar, se a música estiver ligada.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_iniciado) return;
    if (state == AppLifecycleState.resumed) {
      if (ConfiguracoesService.instance.musicaLigada) _player.resume();
    } else {
      _player.pause();
    }
  }
}
