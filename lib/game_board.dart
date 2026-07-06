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
  final tiros = <Objects>[];
  final keys = KeyMap();

  // Atalhos para os dados específicos da fase atual.
  Fase get fase => widget.fase;
  LevelData get level => fase.level;
  double get larguraDoMapa => fase.larguraDoMapa; // tamanho do mapa
  List<GroundSegment> get groundSegments => fase.groundSegments;

  double gravity = 10.0;
  double velocidade = 20.0;
  bool? isOnGround = false;

  Timer? timer;
  Size? screenSize;
  bool _podeAtirar = true; // Controla o timeout do tiro

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
  
  
  double get cameraY => 0; // câmera fixa no Y — player sobe/desce na tela livremente

  void spawnPLataformas() {
    plataformas.addAll(fase.criarPlataformas());

    update();
  }

  void update() {
    timer = Timer.periodic(fps, (t) {
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

      enemy.y += enemy.velocity.y; //TESTE
      enemy.x += enemy.velocity.x; //TESTE

      if (player.top > _gameHeight + 600) {
        reset();
      } else {
        player.velocity.y += gravity;
        enemy.velocity.x += gravity; //TESTE

        isOnGround = false;
      }

      // Movimento para os lados
      if (keys.left) {
        player.velocity.x = -velocidade;
      } else if (keys.right) {
        player.velocity.x = velocidade;
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

      // Tiro
      for (var tiro in tiros) {
        // Se estiver invertido, subtrai 40 (vai para a esquerda), senão soma 40 (vai para a direita)
        tiro.x += tiro.invertido ? -40 : 40;
      }
      tiros.removeWhere((t) => t.left > player.x + screenSize!.width);

      setState(() {});
    });
  }

  void _executarDisparo() {
    if (!_podeAtirar) return;

    setState(() {

      double posx = keys.left ? player.left - 64 : player.right;

      tiros.add(
        Objects(
          width: 64,
          height: 24,
          x: posx,
          y: player.top + player.height / 2 - 6,
          invertido: keys.left, // Define a direção do tiro com base na tecla pressionada
        ),
      );
      _podeAtirar = false;
    });

    // Define o tempo de espera (300ms). Altere o valor se quiser mais rápido ou devagar.
    Future.delayed(const Duration(milliseconds: 300), () {
      _podeAtirar = true;
    });
  }

  void reset() {
    enemy.velocity.x = 5;
    enemy.velocity.y = 2;

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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Focus(
        autofocus: true,
        onKeyEvent: keyListener,
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: Stack(
                  children: [

                    AnimatedPositioned(
                      duration: fps,
                      top: 0, // Começa no topo da tela
                      left: 0 - (cameraX * 0.4), // <--- O SEGREDO DO PARALLAX ESTÁ AQUI!
                      // Multiplicar por 0.4 faz o fundo se mover mais devagar que o boneco,
                      // dando uma sensação incrível de profundidade 3D no cenário.
                      // Se quiser que ele se mova na MESMA velocidade exata do chão, deixe apenas: 0 - cameraX
                      
                      width: 99999, // Largura gigante para a imagem se repetir infinitamente
                      height: _gameHeight, // Preenche a altura do jogo perfeitamente
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(level.backgroundImage),
                            alignment: Alignment.topLeft, 
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

                  AnimatedPositioned(
                    top: enemy.y - cameraY,
                    left: enemy.x - cameraX,
                    width: enemy.width,
                    height: enemy.height,
                    duration: fps,
                    child: Container(
                      color: const Color.fromARGB(255, 255, 14, 215),
                    ),
                  ),

                  AnimatedPositioned(
                    top: player.y - cameraY,
                    left: player.x - cameraX,
                    width: player.width,
                    height: player.height,
                    duration: fps,
                    child: Transform.flip(  // FAZER O MESMO PRO INIMIGO QUANDO PRONTO
                      
                      flipX: keys.left, // Flip horizontalmente se a tecla esquerda estiver pressionada

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
        )
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
