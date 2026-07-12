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

class GameBoard extends StatefulWidget {
  final Fase fase;

  const GameBoard({super.key, required this.fase});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late final Player player;
  late final Enemy enemy;

  final fps = const Duration(milliseconds: 50);
  final plataformas = <Objects>[];
  final tiros = <Objects>[]; 
  final enemyTiros = <Objects>[];

  final keys = KeyMap();

  static const int _maxVidas = 3;
  int vidas = _maxVidas;

  double enemyVelocidade = 3.0;
  bool _inimigoPodeAtirar = true;

  Fase get fase => widget.fase;
  LevelData get level => fase.level;
  double get larguraDoMapa => fase.larguraDoMapa;
  List<GroundSegment> get groundSegments => fase.groundSegments;

  double gravity = 10.0;
  double velocidade = 20.0;
  bool? isOnGround = false;
  bool? isOnGroundEnemy = false;

  Timer? timer;
  Size? screenSize;
  bool _podeAtirar = true; 
  bool _pausado = false; 
  final FocusNode _focusNode = FocusNode();

  // Estados de Conteúdo Didático e Quiz
  bool _mostrandoConteudo = false;
  bool _podeContinuarConteudo = false;
  final ScrollController _conteudoScrollController = ScrollController();

  // Tela de "Fase concluída" mostrada ao alcançar o portal, antes do quiz.
  bool _mostrandoPortal = false;
  bool _portalAtivado = false; // trava para não reabrir a cada frame

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
  static const _taskbarHeight = 100.0;

  bool get _isMobile =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  double get _gameHeight =>
      _isMobile ? screenSize!.height - _taskbarHeight : screenSize!.height;

  double get _groundY => _gameHeight - _groundHeight;

  double get cameraX {
    if (screenSize == null) return 0;
    double camX = player.x - screenSize!.width / 2 + player.width / 2;
    if (camX < 0) return 0;
    double maxCamX = larguraDoMapa - screenSize!.width;
    if (camX > maxCamX) return maxCamX;
    return camX;
  }

  double get cameraY => 0; 
  double get _bgDisplayWidth => _gameHeight * level.aspect;

  double get _bgOffsetX {
    if (screenSize == null) return 0;
    final screenW = screenSize!.width;
    final maxOffset = _bgDisplayWidth - screenW;
    if (maxOffset <= 0) return 0;
    final cameraMax = larguraDoMapa - screenW;
    if (cameraMax <= 0) return 0;
    final t = (cameraX / cameraMax).clamp(0.0, 1.0); 
    return t * maxOffset;
  }

  void spawnPLataformas() {
    plataformas.addAll(fase.criarPlataformas());
    update();
  }

  void update() {
    timer = Timer.periodic(fps, (t) {
      if (_pausado || _mostrandoConteudo || _mostrandoQuiz || _mostrandoPortal) return;

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

      if (enemy.vivo) {
        final dx = player.x - enemy.x;
        enemy.position = dx < 0 ? 0 : 1;
        const distanciaParada = 250.0;
        if (dx.abs() > distanciaParada) {
          enemy.velocity.x = dx < 0 ? -enemyVelocidade : enemyVelocidade;
        } else {
          enemy.velocity.x = 0;
        }
        final alcance = screenSize?.width ?? 800;
        if (dx.abs() < alcance) {
          _dispararInimigo();
        }
      } else {
        enemy.velocity.x = 0;
      }

      enemy.y += enemy.velocity.y;
      enemy.x += enemy.velocity.x;

      if (enemy.x < 0) enemy.x = 0;
      if (enemy.x > larguraDoMapa - enemy.width) enemy.x = larguraDoMapa - enemy.width;

      if (player.top > _gameHeight + 600) {
        reset();
      } else {
        player.velocity.y += gravity;
        enemy.velocity.y += gravity; 
        isOnGround = false;
        isOnGroundEnemy = false;
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

      for (var plataforma in plataformas) {
        if (enemy.bottom <= plataforma.top &&
            enemy.bottom + enemy.velocity.y >= plataforma.top &&
            enemy.right > plataforma.left &&
            enemy.left < plataforma.right) {
          enemy.velocity.y = 0;
          enemy.y = plataforma.top - enemy.height;
          isOnGroundEnemy = true;
        }
      }

      for (var seg in groundSegments) {
        if (enemy.right > seg.startX && enemy.left < seg.endX) {
          if (enemy.bottom <= _groundY && enemy.bottom + enemy.velocity.y >= _groundY) {
            enemy.velocity.y = 0;
            enemy.y = _groundY - enemy.height;
            isOnGroundEnemy = true;
          }
        }
      }

      for (var tiro in tiros) {
        tiro.x += tiro.invertido ? -40 : 40;
      }
      tiros.removeWhere((t) => t.left > player.x + screenSize!.width);

      for (var tiro in enemyTiros) {
        tiro.x += tiro.invertido ? -18 : 18;
      }
      final camEsq = cameraX - 100;
      final camDir = cameraX + (screenSize?.width ?? 0) + 100;
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

      if (enemy.vivo && tiros.any((t) => _colide(t, enemy.left, enemy.top, enemy.right, enemy.bottom))) {
        tiros.removeWhere((t) => _colide(t, enemy.left, enemy.top, enemy.right, enemy.bottom));
        enemy.vivo = false;
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

  bool _colide(Objects o, double left, double top, double right, double bottom) {
    return o.right > left && o.left < right && o.bottom > top && o.top < bottom;
  }

  void _dispararInimigo() {
    if (!_inimigoPodeAtirar || !enemy.vivo) return;

    final paraEsquerda = player.x < enemy.x;
    final posx = paraEsquerda ? enemy.left - 64 : enemy.right;

    enemyTiros.add(
      Objects(
        width: 64,
        height: 24,
        x: posx,
        y: enemy.top + enemy.height / 2 - 12,
        invertido: paraEsquerda,
      ),
    );

    _inimigoPodeAtirar = false;
    Future.delayed(const Duration(milliseconds: 1200), () {
      _inimigoPodeAtirar = true;
    });
  }

  void _perderVida() {
    if (vidas <= 0) return;
    vidas--;

    if (vidas <= 0) {
      vidas = _maxVidas;
      tiros.clear();
      enemyTiros.clear();

      enemy.vivo = true;
      enemy.x = fase.enemyStartX;
      enemy.y = fase.enemyStartY;
      enemy.velocity.x = 0;
      enemy.velocity.y = 0;

      reset();
    }
  }

  void reset() {
    player.position = 1;
    player.velocity.x = 0;
    player.velocity.y = 0;
    player.x = fase.playerStartX;
    player.y = fase.playerStartY;
    _quizJaAberto = false;
    _portalAtivado = false;
    _mostrandoPortal = false;
  }

  /// Chamado quando o jogador encosta no portal. Congela o jogador e mostra a
  /// tela de "Fase concluída" com o botão SEGUIR, que então abre o quiz.
  void _encostarPortal() {
    if (_portalAtivado) return;
    _portalAtivado = true;

    keys.left = false;
    keys.right = false;
    player.velocity.x = 0;

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

  /// Mínimo de acertos (de 5) para concluir a fase e destravar a próxima.
  static const int _minAcertosParaPassar = 3;

  void _avancarFase() {
    final aprovado = _acertos >= _minAcertosParaPassar;

    // Só conclui/destrava se passou. Guarda o melhor resultado (estrelas).
    if (aprovado) {
      ProgressoService.instance.registrarConclusao(
        fase.andar,
        fase.numero,
        _acertos,
      );
    }

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
                  : 'Você precisa de pelo menos $_minAcertosParaPassar acertos para passar. Tente novamente!',
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
                    color: _menuLaranjaClara,
                    size: 34,
                    shadows: const [Shadow(color: _menuLaranja, blurRadius: 10)],
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
    player = Player(x: fase.playerStartX, y: fase.playerStartY);
    enemy = Enemy(x: fase.enemyStartX, y: fase.enemyStartY);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    if (fase.conteudo != null && fase.conteudo!.isNotEmpty) {
      _mostrandoConteudo = true;
    }

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

    Timer(const Duration(seconds: 1), spawnPLataformas);
  }

  @override
  void dispose() {
    timer?.cancel();
    _conteudoScrollController.dispose();
    _focusNode.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: keyListener,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.black,
                    child: Stack(
                      children: [
                        AnimatedPositioned(
                          duration: fps,
                          top: 0, 
                          left: 0 - _bgOffsetX,
                          width: _bgDisplayWidth,
                          height: _gameHeight, 
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

                        for (var seg in groundSegments) _buildGroundSegment(seg),

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

                        if (enemy.vivo)
                          AnimatedPositioned(
                            top: enemy.y - cameraY,
                            left: enemy.x - cameraX,
                            width: enemy.width,
                            height: enemy.height,
                            duration: fps,
                            child: Transform.flip(
                              flipX: enemy.position == 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(enemy.currentSprite),
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

                        Positioned(top: 16, left: 16, child: _buildBarraDeVida()),
                        Positioned(top: 16, right: 16, child: _buildBotaoMenu()),
                      ],
                    ),
                  ),
                ),
                if (_isMobile) _buildTaskbar(),
              ],
            ),
            
            // Overlays Cobrindo o game inteiro
            if (_mostrandoConteudo) Positioned.fill(child: _buildOverlayConteudo()),
            if (_mostrandoPortal) Positioned.fill(child: _buildOverlayPortal()),
            if (_mostrandoQuiz) Positioned.fill(child: _buildOverlayQuiz()),
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
              color: Colors.red,
              size: 32,
              shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
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
                      setState(() => _mostrandoConteudo = false);
                      _focusNode.requestFocus();
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

  Widget _buildTaskbar() {
    return Container(
      height: _taskbarHeight,
      color: Colors.black87,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _controlButton(
                icon: Icons.arrow_back,
                onStart: () => keys.left = true,
                onEnd: () => keys.left = false,
              ),
              _controlButton(
                icon: Icons.arrow_forward,
                onStart: () => keys.right = true,
                onEnd: () => keys.right = false,
              ),
            ],
          ),
          Row(
            children: [
              _controlButton(
                icon: Icons.arrow_upward,
                onStart: () {
                  if (isOnGround == true &&
                      !_mostrandoConteudo &&
                      !_mostrandoQuiz &&
                      !_mostrandoPortal) {
                    player.velocity.y = -velocidade * 4;
                  }
                },
                onEnd: () {},
              ),
              _controlButton(
                icon: Icons.circle,
                onStart: _executarDisparo, 
                onEnd: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required VoidCallback onStart,
    required VoidCallback onEnd,
  }) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => onStart(),
      onPointerUp: (_) => onEnd(),
      onPointerCancel: (_) => onEnd(),
      child: Container(
        width: 64,
        height: 64,
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildGroundSegment(GroundSegment seg) {
    final screenW = screenSize!.width;
    final segLeft = seg.startX - cameraX;
    final segRight = seg.endX - cameraX;

    if (segRight <= 0 || segLeft >= screenW) return const SizedBox.shrink();

    return AnimatedPositioned(
      duration: fps,
      top: _groundY - cameraY,
      left: -999 - cameraX,
      width: 99999,
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
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      keys.right = pressed;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (pressed &&
          isOnGround == true &&
          !_mostrandoConteudo &&
          !_mostrandoQuiz &&
          !_mostrandoPortal) {
        player.velocity.y = -velocidade * 4;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.space) {
      if (pressed) {
        _executarDisparo();
      }
    }

    return KeyEventResult.handled;
  }
}