import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'player.dart';
import 'enemy.dart';
import 'dart:async';
import 'keys_map.dart';
import 'package:flutter/services.dart';
import 'objects.dart';
import 'levels.dart';
import 'fases/fase.dart';
import 'fases/fase_content.dart';
import 'data/progresso_service.dart';
import 'data/configuracoes_service.dart';
import 'orientacao.dart';

class GameBoard extends StatefulWidget {
  final Fase fase;

  const GameBoard({super.key, required this.fase});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

/// Os quatro botões de toque na tela.
enum _Botao { esquerda, direita, pular, atirar }

class _GameBoardState extends State<GameBoard> {
  late final Player player;
  final enemies = <Enemy>[];

  final fps = const Duration(milliseconds: 50);
  final plataformas = <Objects>[];
  final tiros = <Objects>[];
  final enemyTiros = <Objects>[];

  final keys = KeyMap();

  static const int _maxVidas = 3;
  int vidas = _maxVidas;

  double enemyVelocidade = 3.0;

  Fase get fase => widget.fase;
  LevelData get level => fase.level;
  double get larguraDoMapa => fase.larguraDoMapa;
  List<GroundSegment> get groundSegments => fase.groundSegments;

  double gravity = 10.0;
  double velocidade = 20.0;
  bool? isOnGround = false;

  /// Até onde o tiro do JOGADOR viaja, em pixels de MUNDO.
  ///
  /// Era `_larguraVisivel` — ou seja, o alcance da arma dependia do formato
  /// da tela. Em paisagem o jogador acertava a ~1440px; em retrato, a ~333px,
  /// e o tiro sumia no ar antes de chegar no alvo. Isso contradiz o motivo de
  /// o mundo ter altura fixa (a jogabilidade não deve mudar com a
  /// orientação), e quebrava justamente o boss: a esfera dele tem 256px e
  /// nasce colada nele, então em retrato a faixa em que o jogador alcançava o
  /// boss e a faixa em que a esfera nascia em cima dele quase não se cruzavam.
  ///
  /// O alcance do INIMIGO continua sendo a largura visível de propósito ("se
  /// eu te vejo, você me vê") — quem é limitado pela tela é quem atira em
  /// você, não a sua arma.
  static const double _alcanceTiroPlayer = 900.0;

  // Tamanho do pulo: o modo DEV mantém o pulo grande (útil para navegar
  // rápido pelas fases em teste); o modo normal usa um pulo mais contido,
  // dimensionado para as distâncias das fases.
  double get _multiplicadorPulo =>
      ConfiguracoesService.instance.devMode ? 4.0 : 2.6;

  Timer? timer;
  Size? screenSize;
  bool _podeAtirar = true;
  bool _pausado = false;

  // Grace period: inimigos só podem atirar depois que o jogador apertar
  // algum botão de movimento pela primeira vez (evita tomar dano assim que
  // a fase carrega, sem ter tido chance de reagir). Não é resetada em
  // reset()/game over — uma vez provado que o jogador sabe se mover, o
  // grace period não volta.
  bool _jogadorJaSeMoveu = false;
  final FocusNode _focusNode = FocusNode();

  // Estados de Conteúdo Didático e Quiz
  bool _mostrandoConteudo = false;
  bool _podeContinuarConteudo = false;
  final ScrollController _conteudoScrollController = ScrollController();

  // Tela "Iniciar": mostrada depois do conteúdo (ou logo de cara, se a fase
  // não tiver conteúdo), já em paisagem. Dá tempo da rotação física do
  // celular terminar e do tamanho de tela se estabilizar antes de
  // posicionar plataformas/inimigos/jogador de verdade — sem isso, esses
  // elementos nasciam com a altura de tela do retrato (ainda não tinha
  // girado) e ficavam no lugar errado depois que a tela virava paisagem.
  bool _mostrandoTelaIniciar = false;

  // Tela de "Fase concluída" mostrada ao alcançar o portal, antes do quiz.
  bool _mostrandoPortal = false;
  bool _portalAtivado = false; // trava para não reabrir a cada frame

  // Fase encerrada: o jogador chegou ao portal. A simulação fica congelada
  // do portal até o fim do quiz e do diálogo de resultado.
  bool _faseEncerrada = false;

  // Tela de "Game Over" mostrada quando o jogador perde todas as vidas.
  bool _mostrandoGameOver = false;

  bool _mostrandoQuiz = false;
  bool _quizJaAberto = false;
  // Perguntas da rodada atual, com as alternativas já embaralhadas. Preenchida
  // ao abrir o quiz para que a resposta certa não caia sempre na mesma letra.
  List<Pergunta> _perguntasQuiz = [];
  int _perguntaAtualIndex = 0;
  int? _alternativaSelecionada;
  bool _respostaCorreta = false;
  bool _respostaIncorreta = false;
  // Estrelas: conta quantas das 5 perguntas o jogador acertou.
  int _acertos = 0;

  static const _groundHeight = 42.0;

  bool get _isMobile =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  // ── Layout dos controles ──────────────────────────────────────────────

  /// Lado de cada botão de toque, em pixels de tela. Em paisagem sobra
  /// bastante tela e o celular é segurado com as duas mãos, então os botões
  /// podem (e devem) ser maiores que na barra do retrato.
  double get _ladoBotao => _emPaisagem ? 96.0 : 72.0;

  /// Orientação em que a tela está sendo desenhada agora. Definida no build.
  bool _emPaisagem = false;

  /// Altura da barra preta de controles no modo retrato (sem contar o inset
  /// do sistema). Cabem os botões (72) + a margem deles (8 de cada lado) +
  /// uma folga acima e abaixo.
  static const double _alturaBarraControles = 112.0;

  /// Recuo dos clusters em paisagem. Os controles flutuam sobre o jogo e vão
  /// para os cantos inferiores da tela, o mais para fora possível: o recuo é
  /// zero e o único afastamento das bordas é a margem do próprio botão (8px)
  /// mais o viewPadding do aparelho (notch/barra de navegação), que não pode
  /// ser invadido.
  static const double _recuoLateralPaisagem = 0.0;
  static const double _recuoInferiorPaisagem = 0.0;

  // ── Mundo de altura lógica fixa ───────────────────────────────────────
  //
  // O jogo é simulado num mundo de altura FIXA (não na altura da tela) e
  // depois desenhado com uma escala uniforme que faz esse mundo caber
  // exatamente na altura da tela.
  //
  // Isso existe porque a física é toda em pixels de mundo e não depende da
  // tela: o pulo sobe sempre ~162px e alcança ~250px na horizontal. Quando
  // o chão era `alturaDaTela - 42`, o espaço vertical jogável encolhia
  // junto com a tela — em paisagem sobravam só ~320px acima do chão, menos
  // que o necessário para o pulo (162px) mais qualquer torre de
  // plataformas. Uma fase montada para caber numa tela de ~720px de altura
  // virava literalmente impossível (a torre da Fase 4 chega a 360px acima
  // do chão, o que ficava *acima* do topo da tela em paisagem).
  //
  // Com a altura do mundo fixa, `_groundY` vira constante e a MESMA
  // geometria de fase vale igual em retrato e em paisagem. O que muda entre
  // as orientações é só a escala — e, por consequência, quanto do mapa cabe
  // na largura da tela: em paisagem a escala é menor, então enxerga-se
  // muito mais do mapa à frente (que é justamente a vantagem de jogar
  // deitado).
  //
  // 720 é a altura em que as fases foram construídas e validadas.
  static const double _alturaMundo = 720.0;

  /// Fator que leva pixels de mundo para pixels de tela.
  double get _escala => screenSize!.height / _alturaMundo;

  /// Largura do mapa (em pixels de MUNDO) que cabe na tela com a escala
  /// atual. É o substituto de `screenSize.width` em toda a lógica de jogo.
  double get _larguraVisivel => screenSize!.width / _escala;

  double get _groundY => _alturaMundo - _groundHeight;

  double get cameraX {
    if (screenSize == null) return 0;
    final visivel = _larguraVisivel;
    double camX = player.x - visivel / 2 + player.width / 2;
    if (camX < 0) return 0;
    double maxCamX = larguraDoMapa - visivel;
    if (maxCamX < 0) return 0;
    if (camX > maxCamX) return maxCamX;
    return camX;
  }

  double get cameraY => 0;

  // Zoom do fundo. A arte é desenhada com a altura do mundo, mas se nessa
  // altura ela ficar estreita demais para a área visível (o caso da
  // paisagem, que enxerga muito mais largura de mundo), damos zoom nela até
  // sobrar folga para deslizar. Sem isso o fundo apareceria inteiro de uma
  // vez e perderia o efeito de revelar aos poucos conforme o jogador anda.
  // O excesso de altura é cortado pelo OverflowBox no build().
  static const double _folgaPanoramicaFundo = 1.35;

  double get _alturaZoomFundo {
    final alturaParaFolga =
        (_larguraVisivel * _folgaPanoramicaFundo) / level.aspect;
    return alturaParaFolga > _alturaMundo ? alturaParaFolga : _alturaMundo;
  }

  double get _bgDisplayWidth => _alturaZoomFundo * level.aspect;

  double get _bgOffsetX {
    if (screenSize == null) return 0;
    final visivel = _larguraVisivel;
    final maxOffset = _bgDisplayWidth - visivel;
    if (maxOffset <= 0) return 0;
    final cameraMax = larguraDoMapa - visivel;
    if (cameraMax <= 0) return 0;
    final t = (cameraX / cameraMax).clamp(0.0, 1.0);
    return t * maxOffset;
  }

  void spawnPLataformas() {
    plataformas.addAll(fase.criarPlataformas(_groundY));
    update();
  }

  /// Posiciona jogador e inimigos já em pé sobre o chão assim que a tela
  /// tem um tamanho conhecido, em vez de deixá-los cair de uma posição fixa
  /// no topo da tela.
  void _posicionarNoChao() {
    if (!mounted) return;
    setState(() {
      player.y = _spawnYPlayer;
      enemies
        ..clear()
        ..addAll(_construirInimigos());
    });
  }

  /// Confirmado na tela "Iniciar": nesse ponto a orientação/tamanho de
  /// tela já é o definitivo da gameplay (a rotação física já terminou),
  /// então é seguro posicionar jogador, inimigos e plataformas de verdade
  /// e ligar a física. Não mexe no grace period — continua dependendo só
  /// do primeiro input de movimento do jogador.
  void _iniciarGameplay() {
    setState(() => _mostrandoTelaIniciar = false);
    _posicionarNoChao();
    spawnPLataformas();
    _focusNode.requestFocus();
  }

  void update() {
    timer = Timer.periodic(fps, (t) {
      if (_pausado ||
          _faseEncerrada ||
          _mostrandoConteudo ||
          _mostrandoQuiz ||
          _mostrandoPortal ||
          _mostrandoGameOver) return;

      player.y += player.velocity.y;
      player.x += player.velocity.x;

      if (player.x < 0) player.x = 0;
      if (player.x > larguraDoMapa - player.width) {
        player.x = larguraDoMapa - player.width;
      }

      // Portal ao final da fase. A arte é desenhada num box de 512px de largura
      // a partir de fase.portalEfetivo; o centro visual do portal fica em ~0.514
      // dessa largura (medido na arte), ou seja portalEfetivo + 263.
      // A hitbox é uma faixa centrada nesse ponto: basta o centro do jogador
      // entrar nela para abrir a tela de "Fase concluída".
      const double portalCentroOffset = 263.0;
      const double portalHitboxMeiaLargura = 60.0;
      final double portalCentroX = fase.portalEfetivo + portalCentroOffset;
      final double playerCentroX = player.x + player.width / 2;
      if (!_portalAtivado &&
          (playerCentroX - portalCentroX).abs() < portalHitboxMeiaLargura) {
        _encostarPortal();
      }

      for (final inimigo in enemies) {
        if (inimigo.vivo) {
          final dx = player.x - inimigo.x;
          inimigo.position = dx < 0 ? 0 : 1;
          if (!_jogadorJaSeMoveu) {
            // Grace period: inimigo fica parado (não persegue nem atira)
            // até o jogador apertar um botão de movimento pela primeira
            // vez. Sem isso, o inimigo já vinha se aproximando durante a
            // espera e atirava assim que o grace period acabava.
            inimigo.velocity.x = 0;
          } else {
            const distanciaParada = 250.0;
            if (dx.abs() > distanciaParada) {
              final direcao = dx < 0 ? -1.0 : 1.0;
              final podeAndar = _temChaoAdiante(inimigo, direcao) &&
                  !_temInimigoAdiante(inimigo, direcao);
              inimigo.velocity.x = podeAndar ? direcao * enemyVelocidade : 0;
            } else {
              inimigo.velocity.x = 0;
            }
            // "Se eu te vejo, você me vê": o inimigo só atira quando está
            // dentro da faixa de mundo que cabe na tela. Em paisagem essa
            // faixa é maior, mas o jogador também enxerga o inimigo antes.
            final alcance = screenSize == null ? 800.0 : _larguraVisivel;
            if (dx.abs() < alcance) {
              _dispararInimigo(inimigo);
            }
          }
        } else {
          inimigo.velocity.x = 0;
        }

        inimigo.y += inimigo.velocity.y;
        inimigo.x += inimigo.velocity.x;

        if (inimigo.x < 0) inimigo.x = 0;
        if (inimigo.x > larguraDoMapa - inimigo.width) {
          inimigo.x = larguraDoMapa - inimigo.width;
        }
      }

      // Chão ausente sob o jogador (buraco/gap): cai e morre na hora.
      if (player.top > _groundY + 260) {
        _perderVida();
        reset();
      } else {
        player.velocity.y += gravity;
        for (final inimigo in enemies) {
          inimigo.velocity.y += gravity;
        }
        isOnGround = false;
      }

      if (keys.left) {
        player.velocity.x = -velocidade;
        player.position = 0;
      } else if (keys.right) {
        player.velocity.x = velocidade;
        player.position = 1;
      } else {
        player.velocity.x = 0;
      }

      for (var plataforma in plataformas) {
        if (player.bottom <= plataforma.top &&
            player.bottom + player.velocity.y >= plataforma.top &&
            player.right > plataforma.left &&
            player.left < plataforma.right) {
          player.velocity.y = 0;
          player.y = plataforma.top - player.height;
          isOnGround = true;
        }
      }

      for (var seg in groundSegments) {
        if (player.right > seg.startX && player.left < seg.endX) {
          if (player.bottom <= _groundY && player.bottom + player.velocity.y >= _groundY) {
            player.velocity.y = 0;
            player.y = _groundY - player.height;
            isOnGround = true;
          }
        }
      }

      for (final inimigo in enemies) {
        for (var plataforma in plataformas) {
          if (inimigo.bottom <= plataforma.top &&
              inimigo.bottom + inimigo.velocity.y >= plataforma.top &&
              inimigo.right > plataforma.left &&
              inimigo.left < plataforma.right) {
            inimigo.velocity.y = 0;
            inimigo.y = plataforma.top - inimigo.height;
          }
        }

        for (var seg in groundSegments) {
          if (inimigo.right > seg.startX && inimigo.left < seg.endX) {
            if (inimigo.bottom <= _groundY &&
                inimigo.bottom + inimigo.velocity.y >= _groundY) {
              inimigo.velocity.y = 0;
              inimigo.y = _groundY - inimigo.height;
            }
          }
        }
      }

      for (var tiro in tiros) {
        tiro.x += tiro.invertido ? -40 : 40;
      }
      tiros.removeWhere(
        (t) => (t.left - player.x).abs() > _alcanceTiroPlayer,
      );

      for (var tiro in enemyTiros) {
        tiro.x += tiro.invertido ? -18 : 18;
      }
      final camEsq = cameraX - 100;
      final camDir = cameraX + (screenSize == null ? 0.0 : _larguraVisivel) + 100;
      enemyTiros.removeWhere((t) => t.right < camEsq || t.left > camDir);

      final acertosNoPlayer = enemyTiros
          .where((t) => _colide(t, player.left, player.top, player.right, player.bottom))
          .toList();
      if (acertosNoPlayer.isNotEmpty) {
        enemyTiros.removeWhere(acertosNoPlayer.contains);
        for (var _ in acertosNoPlayer) {
          _perderVida();
        }
      }

      for (final inimigo in enemies) {
        if (!inimigo.vivo) continue;
        // Cada tiro que acerta tira uma vida: o inimigo normal morre no
        // primeiro, o boss só no quarto.
        final acertos = tiros
            .where((t) => _colide(t, inimigo.left, inimigo.top, inimigo.right, inimigo.bottom))
            .toList();
        if (acertos.isEmpty) continue;
        tiros.removeWhere(acertos.contains);
        for (var _ in acertos) {
          inimigo.levarTiro();
        }
      }

      setState(() {});
    });
  }

  void _executarDisparo() {
    if (!_podeAtirar || _mostrandoConteudo || _mostrandoQuiz || _mostrandoPortal) return;

    setState(() {
      double posx = player.position == 0 ? player.left - 64 : player.right;
      tiros.add(
        Objects(
          width: 64,
          height: 24,
          x: posx,
          y: player.top + player.height / 2 - 6,
          invertido: player.position == 0,
        ),
      );
      _podeAtirar = false;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      _podeAtirar = true;
    });
  }

  // Insets aplicados só na colisão de dano (tiro x player/inimigo), não na
  // física de chão/plataforma nem no tamanho visual dos sprites. Os sprites
  // têm bastante espaço vazio ao redor do desenho, então usar a caixa
  // cheia fazia o tiro "acertar" com os sprites ainda visivelmente longe.
  static const double _insetAlvoX = 0.20;
  static const double _insetAlvoY = 0.15;
  static const double _insetTiroX = 0.225;
  static const double _insetTiroY = 0.275;

  // Teto do inset do ALVO, em pixels. A margem vazia de um sprite é mais ou
  // menos constante em pixels, mas o inset é uma porcentagem — então num
  // sprite grande ele vira um buraco enorme. No boss (256px), 15% de altura
  // são 38px: a caixa de dano dele começava 38px ACIMA dos pés, ou seja, as
  // esteiras inteiras ficavam fora, e o tiro do jogador de pé no chão (que
  // sai na cintura dele, a ~30px do chão) passava POR BAIXO do boss sem
  // acertar nunca. Com o teto, os sprites normais (inimigo 64px → 9.6px,
  // jogador 70px → 10.5px) ficam exatamente como estavam, e só o boss deixa
  // de ter a zona morta.
  static const double _maxInsetAlvo = 16.0;

  static double _inset(double tamanho, double fracao) {
    final valor = tamanho * fracao;
    return valor > _maxInsetAlvo ? _maxInsetAlvo : valor;
  }

  bool _colide(Objects o, double left, double top, double right, double bottom) {
    final tDx = o.width * _insetTiroX;
    final tDy = o.height * _insetTiroY;
    final tLeft = o.left + tDx;
    final tTop = o.top + tDy;
    final tRight = o.right - tDx;
    final tBottom = o.bottom - tDy;

    final aDx = _inset(right - left, _insetAlvoX);
    final aDy = _inset(bottom - top, _insetAlvoY);
    final aLeft = left + aDx;
    final aTop = top + aDy;
    final aRight = right - aDx;
    final aBottom = bottom - aDy;

    return tRight > aLeft && tLeft < aRight && tBottom > aTop && tTop < aBottom;
  }

  /// IA mínima de borda: antes de andar na [direcao] (-1 esquerda, 1
  /// direita), checa se ainda há chão ou plataforma logo à frente do
  /// inimigo. Evita que ele ande para dentro de um buraco enquanto
  /// persegue o jogador — ele simplesmente para na borda.
  bool _temChaoAdiante(Enemy inimigo, double direcao) {
    const double margemAFrente = 12.0;
    const double epsilonAltura = 4.0;
    final double xFrente =
        direcao < 0 ? inimigo.left - margemAFrente : inimigo.right + margemAFrente;
    final double bottomAtual = inimigo.bottom;

    for (final seg in groundSegments) {
      if (xFrente > seg.startX &&
          xFrente < seg.endX &&
          (bottomAtual - _groundY).abs() <= epsilonAltura) {
        return true;
      }
    }
    for (final plataforma in plataformas) {
      if (xFrente > plataforma.left &&
          xFrente < plataforma.right &&
          (bottomAtual - plataforma.top).abs() <= epsilonAltura) {
        return true;
      }
    }
    return false;
  }

  /// Evita que um inimigo ande por cima de outro: sem isso, dois inimigos
  /// perseguindo o jogador na mesma direção (ex.: ambos parados pela mesma
  /// borda de chão) convergem para o mesmo X e ficam empilhados no mesmo
  /// lugar — visualmente um inimigo só, mas com o dobro de vida e tiros.
  bool _temInimigoAdiante(Enemy inimigo, double direcao) {
    const double margemAFrente = 8.0;
    final double xFrente =
        direcao < 0 ? inimigo.left - margemAFrente : inimigo.right + margemAFrente;

    for (final outro in enemies) {
      if (identical(outro, inimigo) || !outro.vivo) continue;
      if (xFrente > outro.left - margemAFrente && xFrente < outro.right + margemAFrente) {
        return true;
      }
    }
    return false;
  }

  void _dispararInimigo(Enemy inimigo) {
    if (!_jogadorJaSeMoveu || !inimigo.podeAtirar || !inimigo.vivo) return;

    final larguraTiro = inimigo.larguraTiro;
    final alturaTiro = inimigo.alturaTiro;

    final paraEsquerda = player.x < inimigo.x;
    final posx = paraEsquerda ? inimigo.left - larguraTiro : inimigo.right;

    // De que altura do corpo sai o tiro. O inimigo normal (64px) tem quase a
    // altura do jogador (70px), então atirar da cintura dele acerta a cintura
    // do jogador — funciona. O boss NÃO: com 256px de altura, a cintura dele
    // fica a 128px do chão e o tiro passava inteiro POR CIMA da cabeça de um
    // jogador de pé, que ficava simplesmente imune a ele. O boss atira rente
    // ao chão (a caixa do tiro apoiada nos pés dele): a esfera de plasma vem
    // na altura do peito do jogador, acerta quem está no chão e é desviada
    // PULANDO por cima — que é o que a Fase 5 cobra.
    final double ySaida = inimigo.boss
        ? inimigo.bottom - alturaTiro
        : inimigo.top + inimigo.height / 2 - alturaTiro / 2;

    enemyTiros.add(
      Objects(
        width: larguraTiro,
        height: alturaTiro,
        x: posx,
        y: ySaida,
        invertido: paraEsquerda,
        currentSpriteTiro: inimigo.spriteTiro,
      ),
    );

    inimigo.podeAtirar = false;
    Future.delayed(const Duration(milliseconds: 1200), () {
      inimigo.podeAtirar = true;
    });
  }

  void _perderVida() {
    if (vidas <= 0) return;
    vidas--;

    if (vidas <= 0) {
      keys.left = false;
      keys.right = false;
      player.velocity.x = 0;
      player.velocity.y = 0;
      setState(() => _mostrandoGameOver = true);
    }
  }

  /// Chamado pelo botão "Reiniciar" da tela de Game Over: restaura vidas,
  /// posição do jogador e do inimigo, e fecha o overlay.
  void _reiniciarAposGameOver() {
    vidas = _maxVidas;
    tiros.clear();
    enemyTiros.clear();

    enemies
      ..clear()
      ..addAll(_construirInimigos());

    reset();
    setState(() => _mostrandoGameOver = false);
    _focusNode.requestFocus();
  }

  /// Chamado pelo botão "Sair da Fase" da tela de Game Over.
  void _sairDaFaseGameOver() {
    Navigator.of(context).pop();
  }

  void reset() {
    player.position = 1;
    player.velocity.x = 0;
    player.velocity.y = 0;
    player.x = fase.playerStartX;
    player.y = _spawnYPlayer;
    _quizJaAberto = false;
    _portalAtivado = false;
    _mostrandoPortal = false;
    // O jogador volta pro início ao morrer (queda no buraco ou game over):
    // sem resetar isso, os inimigos já liberados continuariam podendo
    // atirar assim que ele reaparecesse, sem nenhuma chance de reagir —
    // exatamente o que o grace period deveria evitar.
    _jogadorJaSeMoveu = false;
  }

  /// Posição Y de nascimento/respawn do jogador: por padrão, já em pé sobre
  /// o chão (evita o jogador "flutuar" no ar e cair de muito alto ao entrar
  /// na fase). Só usa um valor customizado se a fase pedir explicitamente.
  double get _spawnYPlayer => fase.playerStartY ?? (_groundY - player.height);

  /// Recria a lista de inimigos a partir dos spawns da fase, já com o Y
  /// resolvido: sobre o chão por padrão, ou no Y customizado do spawn (ex.:
  /// em cima de uma plataforma). Só pode ser chamado quando o chão (Y da
  /// tela) já é conhecido, isto é, depois do primeiro build.
  List<Enemy> _construirInimigos() => [
        for (final spawn in fase.criarInimigos(_groundY))
          Enemy(
            x: spawn.x,
            // O boss é mais alto que o inimigo normal, então o Y de "em pé
            // sobre o chão" depende do tipo — usar 64 fixo aqui enterraria
            // o boss até a cintura.
            y: spawn.y ?? (_groundY - Enemy.tamanhoDe(spawn.tipo)),
            tipo: spawn.tipo,
          ),
      ];

  /// Chamado quando o jogador encosta no portal. Congela o jogador e mostra a
  /// tela de "Fase concluída" com o botão SEGUIR, que então abre o quiz.
  void _encostarPortal() {
    if (_portalAtivado) return;
    _portalAtivado = true;

    keys.left = false;
    keys.right = false;
    player.velocity.x = 0;

    // A fase para AQUI e não volta a rodar: dali em diante é só tela de
    // conclusão → quiz → resultado. Antes, o loop só era barrado pelos
    // overlays (_mostrandoPortal/_mostrandoQuiz), então nas frestas entre
    // eles — e durante todo o diálogo de resultado, que é um showDialog e
    // não um overlay — o jogo voltava a simular no fundo: inimigos andavam,
    // atiravam e podiam até matar o jogador enquanto ele respondia o quiz.
    _faseEncerrada = true;

    setState(() => _mostrandoPortal = true);
  }

  void _abrirQuiz() {
    if (_quizJaAberto) return;
    _quizJaAberto = true;

    keys.left = false;
    keys.right = false;
    player.velocity.x = 0;

    // Fase sem quiz: conclui direto com estrelas cheias.
    if (fase.perguntas == null || fase.perguntas!.isEmpty) {
      _acertos = 5;
      _avancarFase();
      return;
    }

    // Embaralha as alternativas de cada pergunta para esta rodada do quiz.
    _perguntasQuiz = [for (final p in fase.perguntas!) p.embaralhada()];

    setState(() {
      _mostrandoQuiz = true;
      _perguntaAtualIndex = 0;
      _alternativaSelecionada = null;
      _respostaCorreta = false;
      _respostaIncorreta = false;
      _acertos = 0;
    });
    _definirOrientacao(retrato: true);
  }

  void _responderQuiz(int index) {
    if (_alternativaSelecionada != null) return;

    final pergunta = _perguntasQuiz[_perguntaAtualIndex];
    final acertou = index == pergunta.correta;
    if (acertou) _acertos++;

    setState(() {
      _alternativaSelecionada = index;
      _respostaCorreta = acertou;
      _respostaIncorreta = !acertou;
    });

    // Certa ou errada, a resposta é aceita e o quiz segue para a próxima
    // pergunta (a errada não se repete). As 5 estrelas refletem os acertos
    // reais. Ao errar, damos um tempo maior para o jogador ver a correta.
    Future.delayed(Duration(milliseconds: acertou ? 1200 : 2000), () {
      if (!mounted) return;
      if (_perguntaAtualIndex < _perguntasQuiz.length - 1) {
        setState(() {
          _perguntaAtualIndex++;
          _alternativaSelecionada = null;
          _respostaCorreta = false;
          _respostaIncorreta = false;
        });
      } else {
        setState(() => _mostrandoQuiz = false);
        _avancarFase();
      }
    });
  }

  void _avancarFase() {
    final aprovado = _acertos >= ProgressoService.minAcertosParaPassar;

    // Sempre guarda o melhor resultado (estrelas), mesmo se não aprovado; só
    // desbloqueia a próxima fase quando aprovado (o próprio ProgressoService
    // decide isso a partir do nº de acertos).
    ProgressoService.instance.registrarConclusao(
      fase.andar,
      fase.numero,
      _acertos,
    );

    _mostrarResultado(aprovado);
  }

  /// Reabre o quiz (com novas perguntas embaralhadas) após uma reprovação.
  void _reabrirQuiz() {
    _quizJaAberto = false;
    _abrirQuiz();
  }

  void _mostrarResultado(bool aprovado) {
    final corBorda = aprovado ? _menuLaranja : Colors.redAccent;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: _menuInteriorTopo,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: corBorda, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          aprovado ? 'FASE CONCLUÍDA!' : 'NÃO FOI DESSA VEZ',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: aprovado ? _menuLaranjaClara : Colors.redAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              aprovado
                  ? 'Você passou pelo portal!'
                  : 'Você precisa de pelo menos ${ProgressoService.minAcertosParaPassar} acertos para passar. Tente novamente!',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _menuCreme, fontSize: 16),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 5; i++)
                  Icon(
                    i < _acertos ? Icons.star_rounded : Icons.star_border_rounded,
                    color: i < _acertos ? Colors.amber : Colors.grey,
                    size: 34,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '$_acertos de 5 acertos',
              style: const TextStyle(color: _menuLaranjaClara, fontSize: 13, letterSpacing: 1),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: aprovado
            ? [
                _botaoDialogo(
                  texto: 'AVANÇAR',
                  cor: _menuLaranja,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ]
            : [
                _botaoDialogo(
                  texto: 'TENTAR NOVAMENTE',
                  cor: _menuLaranja,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _reabrirQuiz();
                  },
                ),
                _botaoDialogo(
                  texto: 'SAIR DA FASE',
                  cor: const Color(0xFF6E3200),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
      ),
    );
  }

  Widget _botaoDialogo({
    required String texto,
    required Color cor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: cor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(texto),
    );
  }

  @override
  void initState() {
    super.initState();
    // Posição Y provisória (0): o posicionamento de verdade só acontece
    // quando o jogador confirma a tela "Iniciar" (_iniciarGameplay), ponto
    // em que a orientação/tamanho de tela já está definitivo.
    player = Player(x: fase.playerStartX, y: 0);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    if (fase.conteudo != null && fase.conteudo!.isNotEmpty) {
      _mostrandoConteudo = true;
    }
    // Sem conteúdo: pula direto pra tela "Iniciar", já na orientação de
    // gameplay escolhida nas Configurações.
    _mostrandoTelaIniciar = !_mostrandoConteudo;
    _definirOrientacao(
      retrato: _mostrandoConteudo || !_gameplayEmPaisagem,
    );

    _conteudoScrollController.addListener(() {
      if (_conteudoScrollController.position.pixels >=
          _conteudoScrollController.position.maxScrollExtent - 20) {
        if (!_podeContinuarConteudo) {
          setState(() => _podeContinuarConteudo = true);
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mostrandoConteudo && _conteudoScrollController.hasClients) {
        if (_conteudoScrollController.position.maxScrollExtent <= 0) {
          setState(() => _podeContinuarConteudo = true);
        }
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _conteudoScrollController.dispose();
    _focusNode.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // Ao sair da fase já pede o retrato dos menus, em vez de liberar a
    // rotação: assim, quem estava jogando deitado não cai num menu deitado —
    // o giro começa aqui e o menu (que também espera a rotação terminar) só
    // aparece quando a tela já estiver em pé.
    aplicarOrientacao(retrato: true);
    super.dispose();
  }

  /// Trava a orientação: retrato para conteúdo/quiz (leitura), paisagem
  /// para a gameplay em si (mais área horizontal — o eixo em que a câmera
  /// rola e onde aparecem inimigos, buracos e plataformas à frente).
  ///
  /// Se a gameplay roda deitada ou em pé é escolha do jogador, no
  /// interruptor PAISAGEM das Configurações. A geometria das fases é a
  /// mesma nos dois modos (ver a nota em [_alturaMundo]): o que muda é só
  /// quanto do mapa cabe na tela.
  bool get _gameplayEmPaisagem =>
      ConfiguracoesService.instance.orientacaoPaisagem;

  /// Orientação que a tela DEVE ter agora. Enquanto o aparelho ainda não
  /// terminou de girar, o build não desenha nada além de preto (ver
  /// [_orientacaoPronta]): antes, a tela nova (conteúdo, quiz, gameplay)
  /// aparecia por um instante na orientação velha e depois "pulava" para o
  /// lugar certo quando a rotação física terminava.
  bool _retratoDesejado = true;

  void _definirOrientacao({required bool retrato}) {
    _retratoDesejado = retrato;
    aplicarOrientacao(retrato: retrato);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    // Rotação em andamento: não desenha NADA da fase (nem jogo, nem overlay,
    // nem controles) até a tela já estar na orientação certa. Não dá para
    // usar o widget OrientacaoFixa aqui porque este build calcula screenSize
    // e a escala do mundo a partir do MediaQuery — se ele rodasse durante a
    // rotação, a fase seria montada com as medidas da orientação velha.
    if (!orientacaoPronta(mq, retrato: _retratoDesejado)) {
      return const TelaGirando();
    }

    final retrato = mq.orientation == Orientation.portrait;
    _emPaisagem = !retrato;
    final insetInferior = mq.viewPadding.bottom;

    // Em retrato os controles ganham uma barra preta própria embaixo da
    // tela (como uma taskbar), em vez de flutuarem por cima do jogo: o
    // polegar cobria justamente o chão, onde tudo acontece. A barra também
    // afasta os botões da faixa de gestos do sistema (barra de navegação),
    // que roubava os toques colados na borda inferior.
    //
    // Em paisagem sobra largura de sobra, então os controles continuam
    // flutuando sobre o jogo (sem barra), só que bem mais para dentro.
    final alturaBarra =
        (_isMobile && retrato) ? _alturaBarraControles + insetInferior : 0.0;

    // O jogo enxerga apenas a área ACIMA da barra: a escala do mundo é
    // calculada a partir dela, então nada do mundo fica escondido atrás dos
    // controles. Só o que muda é a escala (em retrato o mundo fica um pouco
    // menor e, portanto, vê-se um pouco mais de mapa à frente).
    screenSize = Size(mq.size.width, mq.size.height - alturaBarra);

    return Scaffold(
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: keyListener,
        child: Stack(
          children: [
            // O mundo do jogo é montado em pixels de MUNDO (largura visível
            // × _alturaMundo) e só então escalado para caber exatamente na
            // tela. Assim a mesma geometria de fase serve para retrato e
            // paisagem — ver a nota em _alturaMundo.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: alturaBarra,
              child: ClipRect(
                child: Container(
                  color: Colors.black,
                  child: OverflowBox(
                    alignment: Alignment.topLeft,
                    minWidth: _larguraVisivel,
                    maxWidth: _larguraVisivel,
                    minHeight: _alturaMundo,
                    maxHeight: _alturaMundo,
                    child: Transform.scale(
                      scale: _escala,
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: _larguraVisivel,
                        height: _alturaMundo,
                        child: Stack(
                      children: [
                        AnimatedPositioned(
                          duration: fps,
                          top: 0,
                          left: 0 - _bgOffsetX,
                          width: _bgDisplayWidth,
                          height: _alturaMundo,
                          child: OverflowBox(
                            alignment: Alignment.topLeft,
                            minWidth: _bgDisplayWidth,
                            maxWidth: _bgDisplayWidth,
                            minHeight: _alturaZoomFundo,
                            maxHeight: _alturaZoomFundo,
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(level.backgroundImage),
                                  alignment: Alignment.topLeft,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            ),
                          ),
                        ),

                        for (var seg in groundSegments)
                          if (_segmentoVisivel(seg)) _buildGroundSegment(seg),

                        // Portal
                        AnimatedPositioned(
                          key: const ValueKey('portal'),
                          duration: fps,
                          top: _groundY - 418 - cameraY,
                          left: fase.portalEfetivo - cameraX,
                          width: 512,
                          height: 640,
                          child: Image.asset(
                            'lib/Images/portal.png',
                            fit: BoxFit.contain,
                          ),
                        ),

                        for (var plataforma in plataformas)
                          AnimatedPositioned(
                            key: ValueKey(plataforma),
                            top: plataforma.y - cameraY,
                            left: plataforma.x - cameraX,
                            width: plataforma.width,
                            height: plataforma.height,
                            duration: fps,
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(plataforma.currentSpritePlataforma),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),

                        for (var tiro in tiros)
                          AnimatedPositioned(
                            key: ValueKey(tiro),
                            top: tiro.y - cameraY,
                            left: tiro.x - cameraX,
                            width: tiro.width,
                            height: tiro.height,
                            duration: fps,
                            child: Transform.flip(
                              flipX: tiro.invertido,
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(tiro.currentSpriteTiro),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        for (var tiro in enemyTiros)
                          AnimatedPositioned(
                            key: ValueKey(tiro),
                            top: tiro.y - cameraY,
                            left: tiro.x - cameraX,
                            width: tiro.width,
                            height: tiro.height,
                            duration: fps,
                            child: Transform.flip(
                              flipX: tiro.invertido,
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(tiro.currentSpriteTiro),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        for (var inimigo in enemies)
                          if (inimigo.vivo)
                            AnimatedPositioned(
                              key: ValueKey(inimigo),
                              top: inimigo.y - cameraY,
                              left: inimigo.x - cameraX,
                              width: inimigo.width,
                              height: inimigo.height,
                              duration: fps,
                              child: Transform.flip(
                                flipX: inimigo.position == 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(inimigo.currentSprite),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                        AnimatedPositioned(
                          top: player.y - cameraY,
                          left: player.x - cameraX,
                          width: player.width,
                          height: player.height,
                          duration: fps,
                          child: Transform.flip(
                            flipX: player.position == 0,
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(player.currentSprite),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),

                      ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // HUD e controles ficam FORA da escala do mundo: são medidos em
            // pixels de tela, então não encolhem junto com o mundo quando a
            // escala cai (paisagem). Só o jogo em si é escalado.
            Positioned(top: 16, left: 16, child: _buildBarraDeVida()),
            Positioned(top: 16, right: 16, child: _buildBotaoMenu()),

            if (_isMobile)
              if (alturaBarra > 0)
                _buildBarraDeControles(alturaBarra, insetInferior)
              else
                ..._buildControlesFlutuantes(mq),

            // Overlays Cobrindo o game inteiro
            if (_mostrandoConteudo) Positioned.fill(child: _buildOverlayConteudo()),
            if (_mostrandoTelaIniciar) Positioned.fill(child: _buildOverlayIniciar()),
            if (_mostrandoPortal) Positioned.fill(child: _buildOverlayPortal()),
            if (_mostrandoQuiz) Positioned.fill(child: _buildOverlayQuiz()),
            if (_mostrandoGameOver) Positioned.fill(child: _buildOverlayGameOver()),
          ],
        ),
      ),
    );
  }

  Widget _buildBarraDeVida() {
    return Row(
      children: [
        for (int i = 0; i < _maxVidas; i++)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              i < vidas ? Icons.favorite : Icons.favorite_border,
              color: i < vidas ? Colors.red : Colors.grey,
              size: 32,
            ),
          ),
      ],
    );
  }

  static const _menuLaranja = Color(0xFFFF8A00);
  static const _menuLaranjaClara = Color(0xFFFFC061);
  static const _menuLaranjaEscura = Color(0xFF6E3200);
  static const _menuCreme = Color(0xFFF6EAD0);
  static const _menuInteriorTopo = Color(0xF21A1206);
  static const _menuInteriorBaixo = Color(0xF20A0702);

  Widget _buildBotaoMenu() {
    return _painelTech(
      onTap: _abrirMenu,
      padding: const EdgeInsets.all(9),
      child: const Icon(Icons.menu, color: _menuLaranjaClara, size: 26),
    );
  }

  Future<void> _abrirMenu() async {
    setState(() => _pausado = true);
    final sair = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.62),
      builder: (dialogContext) => _dialogoPausa(dialogContext),
    );
    if (!mounted) return;
    if (sair == true) {
      Navigator.of(context).pop();
    } else {
      setState(() => _pausado = false);
      _focusNode.requestFocus(); 
    }
  }

  Widget _dialogoPausa(BuildContext dialogContext) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_menuLaranjaClara, _menuLaranja, _menuLaranjaEscura],
              stops: [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: _menuLaranja.withValues(alpha: 0.5),
                blurRadius: 28,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_menuInteriorTopo, _menuInteriorBaixo],
              ),
              border: Border.all(
                color: _menuLaranja.withValues(alpha: 0.45),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'MENU',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _menuLaranja,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    letterSpacing: 6,
                    shadows: [
                      const Shadow(color: _menuLaranja, blurRadius: 12),
                      Shadow(
                        color: _menuLaranja.withValues(alpha: 0.6),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        _menuLaranja.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _itemMenu(
                  icon: Icons.play_arrow_rounded,
                  texto: 'CONTINUAR',
                  onTap: () => Navigator.of(dialogContext).pop(false),
                ),
                const SizedBox(height: 14),
                _itemMenu(
                  icon: Icons.exit_to_app_rounded,
                  texto: 'SAIR DA FASE',
                  onTap: () => Navigator.of(dialogContext).pop(true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Overlay de "Fase concluída" (ao alcançar o portal) ---
  Widget _buildOverlayPortal() {
    return Container(
      // Escurece o mapa ao fundo (o jogo já está pausado por trás).
      color: Colors.black.withValues(alpha: 0.72),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: _painelTech(
          onTap: () {},
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.flag_rounded,
                color: _menuLaranjaClara,
                size: 44,
                shadows: [Shadow(color: _menuLaranja, blurRadius: 16)],
              ),
              const SizedBox(height: 14),
              Text(
                'FASE CONCLUÍDA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _menuLaranja,
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                  letterSpacing: 4,
                  shadows: [
                    const Shadow(color: _menuLaranja, blurRadius: 12),
                    Shadow(
                      color: _menuLaranja.withValues(alpha: 0.6),
                      blurRadius: 24,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Você chegou ao portal! Responda ao quiz para concluir.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _menuCreme, fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 26),
              _itemMenu(
                icon: Icons.arrow_forward_rounded,
                texto: 'SEGUIR',
                onTap: () {
                  setState(() => _mostrandoPortal = false);
                  _abrirQuiz();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Overlay "Iniciar" (buffer entre a troca de orientação e a
  // gameplay de verdade, dá tempo do celular girar sem susto) ---
  Widget _buildOverlayIniciar() {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: _painelTech(
          onTap: () {},
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _gameplayEmPaisagem
                    ? Icons.screen_rotation_rounded
                    : Icons.videogame_asset_rounded,
                color: _menuLaranjaClara,
                size: 44,
                shadows: const [Shadow(color: _menuLaranja, blurRadius: 16)],
              ),
              const SizedBox(height: 14),
              Text(
                fase.titulo?.toUpperCase() ?? 'PREPARE-SE',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _menuLaranja,
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _gameplayEmPaisagem
                    ? 'Gire o celular na horizontal. Quando estiver pronto, aperte Iniciar.'
                    : 'Quando estiver pronto, aperte Iniciar.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: _menuCreme, fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 26),
              _itemMenu(
                icon: Icons.play_arrow_rounded,
                texto: 'INICIAR',
                onTap: _iniciarGameplay,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Overlay de "Game Over" (ao perder todas as vidas) ---
  Widget _buildOverlayGameOver() {
    return Container(
      color: Colors.black.withValues(alpha: 0.82),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: _painelTech(
          onTap: () {},
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.heart_broken_rounded,
                color: Colors.redAccent,
                size: 44,
                shadows: [Shadow(color: Colors.redAccent, blurRadius: 16)],
              ),
              const SizedBox(height: 14),
              const Text(
                'GAME OVER',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                  letterSpacing: 4,
                  shadows: [
                    Shadow(color: Colors.redAccent, blurRadius: 12),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Você perdeu todas as vidas.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _menuCreme, fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 26),
              _itemMenu(
                icon: Icons.refresh_rounded,
                texto: 'REINICIAR',
                onTap: _reiniciarAposGameOver,
              ),
              const SizedBox(height: 14),
              _itemMenu(
                icon: Icons.exit_to_app_rounded,
                texto: 'SAIR DA FASE',
                onTap: _sairDaFaseGameOver,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Overlay de Conteúdo Didático ---
  Widget _buildOverlayConteudo() {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 750, maxHeight: 600),
        child: _painelTech(
          padding: const EdgeInsets.all(24),
          onTap: () {}, 
          child: Column(
            children: [
              Text(
                fase.titulo?.toUpperCase() ?? 'CONTEÚDO',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _menuLaranja,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _menuLaranja.withValues(alpha: 0.3)),
                  ),
                  child: Scrollbar(
                    controller: _conteudoScrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _conteudoScrollController,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Text(
                          fase.conteudo ?? '',
                          style: const TextStyle(
                            color: _menuCreme,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Opacity(
                opacity: _podeContinuarConteudo ? 1.0 : 0.4,
                child: _itemMenu(
                  icon: Icons.check,
                  texto: 'COMEÇAR FASE',
                  onTap: () {
                    if (_podeContinuarConteudo) {
                      setState(() {
                        _mostrandoConteudo = false;
                        _mostrandoTelaIniciar = true;
                      });
                      _definirOrientacao(retrato: !_gameplayEmPaisagem);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Overlay de Quiz ---
  Widget _buildOverlayQuiz() {
    final pergunta = _perguntasQuiz[_perguntaAtualIndex];
    
    return Container(
      color: Colors.black.withValues(alpha: 0.92),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
        child: _painelTech(
          padding: const EdgeInsets.all(24),
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'PORTAL - PERGUNTA ${_perguntaAtualIndex + 1} DE ${_perguntasQuiz.length}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _menuLaranjaClara,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    pergunta.enunciado,
                    style: const TextStyle(color: _menuCreme, fontSize: 18, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(pergunta.alternativas.length, (i) {
                bool isSelected = _alternativaSelecionada == i;
                bool isCorrect = (isSelected && _respostaCorreta) || (_respostaIncorreta && pergunta.correta == i);
                bool isWrong = isSelected && _respostaIncorreta;

                Color btnColor = Colors.transparent;
                Color borderColor = _menuLaranja.withValues(alpha: 0.5);
                Color textColor = _menuCreme;

                if (isCorrect) {
                  btnColor = Colors.green.withValues(alpha: 0.4);
                  borderColor = Colors.greenAccent;
                  textColor = Colors.white;
                } else if (isWrong) {
                  btnColor = Colors.red.withValues(alpha: 0.4);
                  borderColor = Colors.redAccent;
                  textColor = Colors.white;
                } else if (isSelected) {
                  btnColor = _menuLaranja.withValues(alpha: 0.2);
                  borderColor = _menuLaranja;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => _responderQuiz(i),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: btnColor,
                        border: Border.all(color: borderColor, width: 1.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        pergunta.alternativas[i],
                        style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemMenu({
    required IconData icon,
    required String texto,
    required VoidCallback onTap,
  }) {
    return _painelTech(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: _menuLaranjaClara, size: 24),
          const SizedBox(width: 14),
          Text(
            texto,
            style: const TextStyle(
              color: _menuCreme,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _painelTech({
    required VoidCallback onTap,
    required Widget child,
    required EdgeInsets padding,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        splashColor: _menuLaranja.withValues(alpha: 0.30),
        highlightColor: _menuLaranja.withValues(alpha: 0.12),
        child: Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_menuLaranjaClara, _menuLaranja, _menuLaranjaEscura],
              stops: [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: _menuLaranja.withValues(alpha: 0.5),
                blurRadius: 14,
              ),
            ],
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_menuInteriorTopo, _menuInteriorBaixo],
              ),
              border: Border.all(
                color: _menuLaranja.withValues(alpha: 0.45),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  // ── Controles de toque ────────────────────────────────────────────────
  //
  // Cada dedo (pointer) é rastreado individualmente e fica "grudado" no
  // botão onde ele encostou até ser levantado:
  //
  //  - Multitoque: como cada botão tem seu próprio Listener e o estado é
  //    guardado por id de pointer, andar + pular + atirar ao mesmo tempo
  //    funciona — um dedo em um botão não cancela o dedo do outro.
  //  - Captura do dedo: uma vez pressionado, o botão só solta no
  //    pointerUp/pointerCancel daquele dedo. Se o dedo escorregar para fora
  //    do botão mas continuar na tela, o botão CONTINUA pressionado (é o
  //    comportamento de gamepad na tela: o polegar quase sempre desliza do
  //    centro do botão durante o jogo, e antes isso soltava o comando no
  //    meio de um pulo).
  //
  // Qual botão cada dedo está segurando. A chave é o id do pointer.
  final Map<int, _Botao> _pointerDoBotao = {};

  /// Botões pressionados agora (só para o destaque visual).
  final Set<_Botao> _botoesPressionados = {};

  void _pressionarControle(_Botao botao, int pointer) {
    _pointerDoBotao[pointer] = botao;

    switch (botao) {
      case _Botao.esquerda:
        keys.left = true;
        _jogadorJaSeMoveu = true;
      case _Botao.direita:
        keys.right = true;
        _jogadorJaSeMoveu = true;
      case _Botao.pular:
        if (isOnGround == true &&
            !_mostrandoConteudo &&
            !_mostrandoQuiz &&
            !_mostrandoPortal) {
          _jogadorJaSeMoveu = true;
          player.velocity.y = -velocidade * _multiplicadorPulo;
        }
      case _Botao.atirar:
        _executarDisparo();
    }

    setState(() => _botoesPressionados.add(botao));
  }

  void _soltarControle(int pointer) {
    final botao = _pointerDoBotao.remove(pointer);
    if (botao == null) return;

    // O mesmo botão pode estar sendo segurado por mais de um dedo: só solta
    // de verdade quando o último deles sair.
    if (_pointerDoBotao.containsValue(botao)) return;

    switch (botao) {
      case _Botao.esquerda:
        keys.left = false;
      case _Botao.direita:
        keys.right = false;
      case _Botao.pular:
      case _Botao.atirar:
        break; // disparados no toque, não têm estado de "segurando".
    }

    setState(() => _botoesPressionados.remove(botao));
  }

  // Cluster de movimento: esquerda/direita.
  List<Widget> get _botoesMovimento => [
        _controlButton(icon: Icons.arrow_back, botao: _Botao.esquerda),
        _controlButton(icon: Icons.arrow_forward, botao: _Botao.direita),
      ];

  // Cluster de ação: pular e atirar.
  List<Widget> get _botoesAcao => [
        _controlButton(icon: Icons.arrow_upward, botao: _Botao.pular),
        _controlButton(icon: Icons.circle, botao: _Botao.atirar),
      ];

  /// Retrato: barra preta fixa na base da tela ("taskbar"), com o cluster de
  /// movimento à esquerda e o de ação à direita. O jogo termina em cima
  /// dela, então nenhum dedo cobre o chão.
  Widget _buildBarraDeControles(double alturaBarra, double insetInferior) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: alturaBarra,
      child: Container(
        color: Colors.black,
        // O inset é a faixa da barra de navegação do sistema: os botões
        // ficam acima dela, mas o preto continua até a borda da tela.
        padding: EdgeInsets.only(
          bottom: insetInferior,
          left: 16,
          right: 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: _botoesMovimento),
            Row(mainAxisSize: MainAxisSize.min, children: _botoesAcao),
          ],
        ),
      ),
    );
  }

  /// Paisagem: controles flutuando sobre o jogo, um cluster grudado em cada
  /// canto inferior da tela — o mais para fora que dá, sem invadir o
  /// viewPadding do aparelho (notch e barra de navegação).
  List<Widget> _buildControlesFlutuantes(MediaQueryData mq) {
    // Nas laterais o viewPadding é ignorado de propósito: em paisagem ele
    // aparece só de um lado (o do recorte de câmera / barra do sistema) e
    // empurrava o cluster de movimento para o meio da tela, deixando os dois
    // clusters desalinhados entre si. Os botões vão para os cantos de fato.
    // Embaixo ele é respeitado, para não ficarem por baixo da barra de
    // navegação.
    final recuoEsquerda = _recuoLateralPaisagem;
    final recuoDireita = _recuoLateralPaisagem;
    final recuoBaixo = _recuoInferiorPaisagem + mq.viewPadding.bottom;

    return [
      Positioned(
        left: recuoEsquerda,
        bottom: recuoBaixo,
        child: Row(mainAxisSize: MainAxisSize.min, children: _botoesMovimento),
      ),
      Positioned(
        right: recuoDireita,
        bottom: recuoBaixo,
        child: Row(mainAxisSize: MainAxisSize.min, children: _botoesAcao),
      ),
    ];
  }

  Widget _controlButton({required IconData icon, required _Botao botao}) {
    final pressionado = _botoesPressionados.contains(botao);

    return Listener(
      behavior: HitTestBehavior.opaque,
      // Depois do pointerDown, o Flutter entrega os eventos seguintes DESTE
      // dedo sempre a este Listener, mesmo que ele saia da área do botão —
      // é o que dá a captura de graça. Só precisamos não soltar antes do up.
      onPointerDown: (e) => _pressionarControle(botao, e.pointer),
      onPointerUp: (e) => _soltarControle(e.pointer),
      onPointerCancel: (e) => _soltarControle(e.pointer),
      child: Container(
        width: _ladoBotao,
        height: _ladoBotao,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: pressionado ? Colors.white54 : Colors.white24,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: pressionado ? Colors.white : Colors.white30,
            width: 2,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }

  bool _segmentoVisivel(GroundSegment seg) {
    final visivel = _larguraVisivel;
    final startX = seg.startX.isFinite ? seg.startX : -999.0;
    final endX = seg.endX.isFinite ? seg.endX : 99000.0;
    final left = startX - cameraX;
    final width = endX - startX;
    return !(left + width <= 0 || left >= visivel);
  }

  Widget _buildGroundSegment(GroundSegment seg) {
    // Bordas infinitas (lado da fase sem buraco) são trocadas por um ponto
    // bem além de qualquer mapa real, fixo no mundo (não depende da
    // câmera), para a textura não "deslizar" ao mover a câmera e para o
    // chão desenhado sempre cobrir toda a área visível daquele lado.
    // Tratado por borda (não só quando os dois lados são infinitos), pois
    // um buraco pode deixar só um dos lados finito, ex.: (-inf, 1450).
    final startX = seg.startX.isFinite ? seg.startX : -999.0;
    final endX = seg.endX.isFinite ? seg.endX : 99000.0;
    final left = startX - cameraX;
    final width = endX - startX;

    return AnimatedPositioned(
      key: ValueKey(seg),
      duration: fps,
      top: _groundY - cameraY,
      left: left,
      width: width,
      height: _groundHeight,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('sprites/plataforma_1.png'),
            alignment: Alignment.topLeft,
            repeat: ImageRepeat.repeatX,
          ),
        ),
      ),
    );
  }

  KeyEventResult keyListener(FocusNode node, KeyEvent event) {
    var pressed = HardwareKeyboard.instance.isLogicalKeyPressed(event.logicalKey);

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      keys.left = pressed;
      if (pressed) _jogadorJaSeMoveu = true;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      keys.right = pressed;
      if (pressed) _jogadorJaSeMoveu = true;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (pressed &&
          isOnGround == true &&
          !_mostrandoConteudo &&
          !_mostrandoQuiz &&
          !_mostrandoPortal) {
        _jogadorJaSeMoveu = true;
        player.velocity.y = -velocidade * _multiplicadorPulo;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.space) {
      if (pressed) {
        _executarDisparo();
      }
    }

    return KeyEventResult.handled;
  }
}