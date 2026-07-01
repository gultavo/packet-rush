import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'player.dart';
import 'enemy.dart';
import 'dart:async';
import 'keys_map.dart';
import 'package:flutter/services.dart';
import 'objects.dart';
import 'levels.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  final player = Player(x: 130, y: 130);
  final enemy = Enemy(x: 200, y: 100);

  final fps = Duration(milliseconds: 50);
  final plataformas = <Objects>[];
  final tiros = <Objects>[];
  final keys = KeyMap();

  LevelData level = levelOne;

  double gravity = 10.0;
  double velocidade = 20.0;
  bool? isOnGround = false;

  Timer? timer;
  Size? screenSize;

  // Para criar um GAP futuramente: divida em dois segmentos com intervalo entre eles,
  // ex: [GroundSegment(double.negativeInfinity, 300), GroundSegment(600, double.infinity)].
  final groundSegments = [
    const GroundSegment(double.negativeInfinity, double.infinity),
  ];
  static const _groundHeight = 42.0;
  static const _taskbarHeight = 100.0;

  bool get _isMobile =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  double get _gameHeight =>
      _isMobile ? screenSize!.height - _taskbarHeight : screenSize!.height;

  double get _groundY => _gameHeight - _groundHeight;

  double get cameraX => player.x - screenSize!.width / 2 + player.width / 2;
  double get cameraY =>
      0; // câmera fixa no Y — player sobe/desce na tela livremente

  void spawnPLataformas() {
    plataformas.addAll([
      Objects(x: 350, y: 500, width: 64 * 4),
      Objects(x: 550, y: 400, width: 64 * 4),
      Objects(x: 750, y: 300, width: 64 * 4),
    ]);

    update();
  }

  void update() {
    timer = Timer.periodic(fps, (t) {
      player.y += player.velocity.y;
      player.x += player.velocity.x;

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
        tiro.x += 40;
      }
      tiros.removeWhere((t) => t.left > player.x + screenSize!.width);

      setState(() {});
    });
  }

  void reset() {
    enemy.velocity.x = 5;
    enemy.velocity.y = 2;

    player.velocity.x = 0;
    player.velocity.y = 0;
    player.y = 100;
    player.x = 100;
  }

  @override
  void initState() {
    super.initState();
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
                // pega o backgroun definido no level.dart e chamado no levelData level = levelOne;
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(level.backgroundImage),
                    // BoxFit.cover faz a imagem preencher toda a área disponível 
                    // sem distorcer o seu aspecto visual
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
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
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(tiro.currentSpriteTiro),
                            fit: BoxFit.contain,
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
                onStart: () => setState(() {
                  tiros.add(
                    Objects(
                      width: 64,
                      height: 24,
                      x: player.right,
                      y: player.top + player.height / 2 - 6,
                    ),
                  );
                }),
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
    return GestureDetector(
      onTapDown: (_) => onStart(),
      onTapUp: (_) => onEnd(),
      onTapCancel: onEnd,
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
      left: 0 - cameraX,
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
      tiros.add(Objects(width: 64, height: 24, x: player.right, y: player.top)); //tamanho do tiro
    }

    return KeyEventResult.handled;
  }
}
