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

/// Motor genérico do jogo.
///
/// O GameBoard não conhece nenhuma fase específica: ele recebe uma [Fase] e
/// executa o comportamento comum (física, câmera, controles, tiro e
/// renderização). A construção específica de cada fase (cenário, chão,
/// plataformas e posições iniciais) vive nos arquivos em `lib/fases/`.
class GameBoard extends StatefulWidget {
  final Fase fase;

  const GameBoard({super.key, required this.fase});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late final Player player;
  late final Enemy enemy;

  final fps = Duration(milliseconds: 50);
  final plataformas = <Objects>[];
  final tiros = <Objects>[]; // tiros do player
  final enemyTiros = <Objects>[]; // tiros do inimigo

  final keys = KeyMap();

  // Vidas do player (barra de vida no topo).
  static const int _maxVidas = 3;
  int vidas = _maxVidas;

  // Inimigo: velocidade lenta de perseguição e controle do cooldown do tiro.
  double enemyVelocidade = 3.0;
  bool _inimigoPodeAtirar = true;

  // Atalhos para os dados específicos da fase atual.
  Fase get fase => widget.fase;
  LevelData get level => fase.level;
  double get larguraDoMapa => fase.larguraDoMapa; // tamanho do mapa
  List<GroundSegment> get groundSegments => fase.groundSegments;

  double gravity = 10.0;
  double velocidade = 20.0;
  bool? isOnGround = false;
  bool? isOnGroundEnemy = false;

  Timer? timer;
  Size? screenSize;
  bool _podeAtirar = true; // Controla o timeout do tiro
  bool _pausado = false; // true enquanto o menu de pausa está aberto
  final FocusNode _focusNode = FocusNode(); // foco do teclado da fase

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

    // Cálculo original para centralizar a câmera no jogador
    double camX = player.x - screenSize!.width / 2 + player.width / 2;

    // Se a câmera tentar ir além do início (0), ela trava em 0.
    // Isso elimina a tela branca do começo do jogo!
    if (camX < 0) return 0;

    //Se a câmera tentar passar do fim do cenário, ela trava também.
    // Isso vai eliminar a tela branca do final do jogo!
    double maxCamX = larguraDoMapa - screenSize!.width;
    if (camX > maxCamX) return maxCamX;

    return camX;
  }

  double get cameraY =>
      0; // câmera fixa no Y — player sobe/desce na tela livremente

  // Largura com que a arte de fundo é exibida quando escalada para preencher
  // exatamente a altura do jogo (sem distorcer): altura × proporção da imagem.
  double get _bgDisplayWidth => _gameHeight * level.aspect;

  // Deslocamento horizontal do cenário (efeito parallax, mais lento que o chão).
  //
  // Mapeia o trajeto da câmera [0 .. cameraMax] EXATAMENTE sobre o deslocamento
  // possível da arte [0 .. larguraExibida - larguraDaTela]. Consequência:
  //  - no início da fase, a borda esquerda da arte encosta na esquerda da tela;
  //  - no fim da fase, a borda direita da arte encosta na direita da tela.
  // Ou seja, quando o jogador chega ao fim do mapa a imagem também termina —
  // sem "faltar um pedaço" da arte e sem faixa branca, em qualquer tela.
  //
  // Continua sendo parallax: como a arte exibida costuma ser mais estreita que
  // o mapa, o fundo anda mais devagar que o chão (dá a sensação de profundidade).
  double get _bgOffsetX {
    if (screenSize == null) return 0;
    final screenW = screenSize!.width;

    final maxOffset = _bgDisplayWidth - screenW;
    if (maxOffset <= 0) return 0; // a arte já cobre a largura da tela

    final cameraMax = larguraDoMapa - screenW;
    if (cameraMax <= 0) return 0; // mapa menor que a tela

    final t = (cameraX / cameraMax).clamp(0.0, 1.0); // 0 no começo, 1 no fim
    return t * maxOffset;
  }

  void spawnPLataformas() {
    plataformas.addAll(fase.criarPlataformas());

    update();
  }

  void update() {
    timer = Timer.periodic(fps, (t) {
      if (_pausado) return; // menu aberto: a fase fica congelada ao fundo
      player.y += player.velocity.y;
      player.x += player.velocity.x;

      // 1. Bloqueia a saída pela esquerda (Início do cenário)
      if (player.x < 0) {
        player.x = 0;
      }

      // 2. Bloqueia a saída pela direita (Fim do cenário)
      if (player.x > larguraDoMapa - player.width) {
        player.x = larguraDoMapa - player.width;
      }

      // IA do inimigo: segue o player devagar e atira quando ele está por perto.
      if (enemy.vivo) {
        final dx = player.x - enemy.x;
        enemy.position = dx < 0 ? 0 : 1; // vira para o lado do player

        // Persegue de leve, mas para a uma certa distância (fica atirando).
        const distanciaParada = 250.0;
        if (dx.abs() > distanciaParada) {
          enemy.velocity.x = dx < 0 ? -enemyVelocidade : enemyVelocidade;
        } else {
          enemy.velocity.x = 0;
        }

        // Só atira se o player estiver dentro do alcance (grosso modo, na tela).
        final alcance = screenSize?.width ?? 800;
        if (dx.abs() < alcance) {
          _dispararInimigo();
        }
      } else {
        enemy.velocity.x = 0;
      }

      enemy.y += enemy.velocity.y;
      enemy.x += enemy.velocity.x;

      // Trava o inimigo dentro dos limites do mapa, igual ao player
      if (enemy.x < 0) {
        enemy.x = 0;
      }
      if (enemy.x > larguraDoMapa - enemy.width) {
        enemy.x = larguraDoMapa - enemy.width;
      }

      if (player.top > _gameHeight + 600) {
        reset();
      } else {
        player.velocity.y += gravity;
        enemy.velocity.y += gravity; // era .x, isso fazia o inimigo acelerar pros lados em vez de cair

        isOnGround = false;
        isOnGroundEnemy = false;
      }

      // Movimento para os lados
      if (keys.left) {
        player.velocity.x = -velocidade;
        player.position = 0;
      } else if (keys.right) {
        player.velocity.x = velocidade;

        player.position = 1;
      } else {
        player.velocity.x = 0;
      }

      // Colisão com as plataformas flutuantes
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

      // Colisão com o chão (segmentos)
      for (var seg in groundSegments) {
        if (player.right > seg.startX && player.left < seg.endX) {
          if (player.bottom <= _groundY &&
              player.bottom + player.velocity.y >= _groundY) {
            player.velocity.y = 0;
            player.y = _groundY - player.height;
            isOnGround = true;
          }
        }
      }

      // Colisão do inimigo com as plataformas flutuantes
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

      // Colisão do inimigo com o chão (segmentos)
      for (var seg in groundSegments) {
        if (enemy.right > seg.startX && enemy.left < seg.endX) {
          if (enemy.bottom <= _groundY &&
              enemy.bottom + enemy.velocity.y >= _groundY) {
            enemy.velocity.y = 0;
            enemy.y = _groundY - enemy.height;
            isOnGroundEnemy = true;
          }
        }
      }

      // Tiro do player
      for (var tiro in tiros) {
        // Se estiver invertido, subtrai 40 (vai para a esquerda), senão soma 40 (vai para a direita)
        tiro.x += tiro.invertido ? -40 : 40;
      }
      tiros.removeWhere((t) => t.left > player.x + screenSize!.width);

      // Tiro do inimigo (um pouco mais lento que o do player)
      for (var tiro in enemyTiros) {
        tiro.x += tiro.invertido ? -18 : 18;
      }
      // Remove os tiros do inimigo que saíram da tela (dos dois lados)
      final camEsq = cameraX - 100;
      final camDir = cameraX + (screenSize?.width ?? 0) + 100;
      enemyTiros.removeWhere((t) => t.right < camEsq || t.left > camDir);

      // Colisão: tiro do inimigo acerta o player → perde uma vida.
      // Detecta os acertos primeiro e só depois aplica o dano, porque
      // _perderVida pode limpar a lista (evita ConcurrentModificationError).
      final acertosNoPlayer = enemyTiros
          .where((t) => _colide(t, player.left, player.top, player.right, player.bottom))
          .toList();
      if (acertosNoPlayer.isNotEmpty) {
        enemyTiros.removeWhere(acertosNoPlayer.contains);
        for (var _ in acertosNoPlayer) {
          _perderVida();
        }
      }

      // Colisão: tiro do player acerta o inimigo → inimigo morre
      if (enemy.vivo &&
          tiros.any((t) => _colide(t, enemy.left, enemy.top, enemy.right, enemy.bottom))) {
        tiros.removeWhere((t) => _colide(t, enemy.left, enemy.top, enemy.right, enemy.bottom));
        enemy.vivo = false;
      }

      setState(() {});
    });
  }

  void _executarDisparo() {
    if (!_podeAtirar) return;

    setState(() {
      double posx = player.position == 0 ? player.left - 64 : player.right;

      tiros.add(
        Objects(
          width: 64,
          height: 24,
          x: posx,
          y: player.top + player.height / 2 - 6,
          invertido:
              player.position ==
              0,
        ),
      );
      _podeAtirar = false;
    });

    // Define o tempo de espera (300ms). Altere o valor se quiser mais rápido ou devagar.
    Future.delayed(const Duration(milliseconds: 300), () {
      _podeAtirar = true;
    });
  }

  // Checagem simples de colisão (AABB) entre um objeto e um retângulo.
  bool _colide(Objects o, double left, double top, double right, double bottom) {
    return o.right > left && o.left < right && o.bottom > top && o.top < bottom;
  }

  // O inimigo dispara um tiro na direção do player, respeitando o cooldown.
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

  // Player leva um tiro: perde uma vida. Sem vidas, reinicia a fase.
  void _perderVida() {
    if (vidas <= 0) return;
    vidas--;

    if (vidas <= 0) {
      vidas = _maxVidas;
      tiros.clear();
      enemyTiros.clear();

      // Revive e reposiciona o inimigo para um recomeço limpo.
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
  }

  @override
  void initState() {
    super.initState();
    player = Player(x: fase.playerStartX, y: fase.playerStartY);
    enemy = Enemy(x: fase.enemyStartX, y: fase.enemyStartY);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    Timer(const Duration(seconds: 1), spawnPLataformas);
  }

  @override
  void dispose() {
    timer?.cancel();
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
        child: Column(
          children: [
            Expanded(
              child: Container(
                // Fundo preto de segurança: se por algum limite de tela a arte
                // não cobrir 100% da área, o que sobra fica preto (nunca branco).
                color: Colors.black,
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: fps,
                      top: 0, // Começa no topo da tela
                      // Parallax travado na borda da arte (ver _bgOffsetX):
                      // move mais devagar que o chão, dando profundidade, mas
                      // nunca passa do fim da imagem — sem faixa branca no fim.
                      left: 0 - _bgOffsetX,
                      // Uma única imagem, exibida na largura exata da arte
                      // (altura do jogo × proporção). Sem repetição.
                      width: _bgDisplayWidth,
                      height:
                          _gameHeight, // Preenche a altura do jogo perfeitamente
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(level.backgroundImage),
                            alignment: Alignment.topLeft,
                            // fitHeight: preenche a altura sem distorcer; como a
                            // caixa já tem a largura proporcional, a arte encaixa
                            // inteira (do céu ao chão do desenho).
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                    ),

                    for (var seg in groundSegments) _buildGroundSegment(seg),

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
                              image: AssetImage(
                                plataforma.currentSpritePlataforma,
                              ),
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
                          // Espelha o sprite conforme o lado que o inimigo está olhando
                          flipX: enemy.position == 0,
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

                        // Flip horizontalmente se a tecla esquerda estiver pressionada
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              // Pega dinamicamente o sprite que estiver ativo na classe Player
                              image: AssetImage(player.currentSprite),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Barra de vida (fixa no topo da tela)
                    Positioned(top: 16, left: 16, child: _buildBarraDeVida()),

                    // Botão de menu / pausa (canto superior direito da fase).
                    Positioned(top: 16, right: 16, child: _buildBotaoMenu()),
                  ],
                ),
              ),
            ),
            if (_isMobile) _buildTaskbar(),
          ],
        ),
      ),
    );
  }

  // Corações representando as vidas restantes do player.
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

  // ---- Menu de pausa (canto superior direito) -------------------------------

  static const _menuLaranja = Color(0xFFFF8A00);
  static const _menuLaranjaClara = Color(0xFFFFC061);
  static const _menuLaranjaEscura = Color(0xFF6E3200);
  static const _menuCreme = Color(0xFFF6EAD0);
  static const _menuInteriorTopo = Color(0xF21A1206);
  static const _menuInteriorBaixo = Color(0xF20A0702);

  // Botão de menu no topo-direito (aparece dentro da fase).
  Widget _buildBotaoMenu() {
    return _painelTech(
      onTap: _abrirMenu,
      padding: const EdgeInsets.all(9),
      child: const Icon(Icons.menu, color: _menuLaranjaClara, size: 26),
    );
  }

  // Abre o pop-up central, pausando a fase e mantendo-a congelada ao fundo.
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
      // Sai da fase → volta para a tela anterior (o seletor de mapas).
      Navigator.of(context).pop();
    } else {
      // Fechou pelo CONTINUAR ou tocando fora: retoma o jogo.
      setState(() => _pausado = false);
      _focusNode.requestFocus(); // devolve o foco do teclado à fase
    }
  }

  // Pop-up centralizado, no estilo dos painéis do jogo.
  Widget _dialogoPausa(BuildContext dialogContext) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Container(
          // Moldura biselada laranja + brilho.
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
            // Interior escuro quente.
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

  // Um item (botão largo) do pop-up de menu.
  Widget _itemMenu({
    required IconData icon,
    required String texto,
    required VoidCallback onTap,
  }) {
    return _painelTech(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
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

  // Moldura "tech" biselada laranja (assinatura visual do jogo), clicável.
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
          // Controles de movimento (esquerda)
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
          // Ações (direita)
          Row(
            children: [
              _controlButton(
                icon: Icons.arrow_upward,
                onStart: () {
                  if (isOnGround == true) {
                    player.velocity.y = -velocidade * 4;
                  }
                },
                onEnd: () {},
              ),
              _controlButton(
                icon: Icons.circle,
                onStart: _executarDisparo, // Agora usa a função com trava
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
      // HitTestBehavior.opaque garante que toda a área do botão seja clicável,
      // mesmo as partes transparentes do Container.
      behavior: HitTestBehavior.opaque,

      // O dedo tocou na tela (dentro do botão)
      onPointerDown: (_) => onStart(),

      // O dedo saiu da tela (não importa se estava fora do botão, ele avisa!)
      onPointerUp: (_) => onEnd(),

      // O sistema cancelou o toque (ex: o usuário recebeu uma ligação na hora)
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

    final visLeft = segLeft.clamp(0.0, screenW);
    final visRight = segRight.clamp(0.0, screenW);

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
    var pressed = HardwareKeyboard.instance.isLogicalKeyPressed(
      event.logicalKey,
    );

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      keys.left = pressed;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      keys.right = pressed;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (pressed && isOnGround == true) {
        player.velocity.y = -velocidade * 4;
      }
    } else if (event.logicalKey == LogicalKeyboardKey.space) {
      if (pressed) {
        _executarDisparo(); // Dispara respeitando o cooldown e apenas no evento de pressionar
      }
    }

    return KeyEventResult.handled;
  }
}