import 'package:flutter/material.dart';
import 'player.dart';
import 'dart:async';
import 'keys_map.dart';
import 'package:flutter/services.dart';
import 'objects.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  final player = Player(x: 100, y: 100);
  final fps = Duration(milliseconds: 50);
  final plataformas = <Objects>[];
  final tiros = <Objects>[];
  final keys = KeyMap();

  double gravity = 10.0;
  double velocidade = 20.0;
  bool? isOnGround = false;

  Timer? timer;
  Size? screenSize;

  void spawnPLataformas() {
    plataformas.addAll([
      Objects(x: 350, y: 300, width: 64 * 4),
      Objects(x: 550, y: 200, width: 64 * 4),

      for (var i = 0; i < screenSize!.width / 64; i++)
        Objects(
          x: i * 64,
          y: screenSize!.height - 64,
          width: 64,
          height: 64,
          type: Type.ground,
        ),
    ]);

    update();
  }

  void update() {
    timer = Timer.periodic(fps, (t) {
      player.y += player.velocity.y;
      player.x += player.velocity.x;

      // Movimento da gravidade
      // if (player.bottom + player.velocity.y <= screenSize!.height) {
      //   player.velocity.y += gravity;
      //   isOnGround = false;
      // } else {
      //   player.velocity.y = 0;
      //   isOnGround = true;
      // }

      if (player.top <= screenSize!.height) {
        player.velocity.y += gravity;
        isOnGround = false;
      } else {
        reset();
      }

      // Movimento para os lados
      if (keys.left && player.left > 0) {
        player.velocity.x = -velocidade;
      } else if (keys.right && player.right <= screenSize!.width) {
        player.velocity.x = velocidade;
      } else {
        player.velocity.x = 0;
      }

      // Colisão com as plataformas
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

      // Tiro
      for (var tiro in tiros) {
        tiro.x += 20;
      }
      tiros.removeWhere((t) => t.left > screenSize!.width);

      // Update three widgets
      setState(() {});
    });
  }

  void reset() {
    player.velocity.x = 0;
    player.velocity.y = 0;
    player.y = 100;
    player.x = 100;
  }

  @override
  void initState() {
    super.initState();

    // Delay
    Timer(const Duration(seconds: 1), spawnPLataformas);
  }

  bool get isMobile {
    return MediaQuery.of(context).size.width < 600;
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Focus(
        autofocus: true,
        onKeyEvent: keyListener,
        child: Stack(
          children: [
            for (var plataforma in plataformas)
              Positioned(
                top: plataforma.y,
                left: plataforma.x,
                width: plataforma.width,
                height: plataforma.height,
                child: Container(
                  color: plataforma.type == Type.ground
                      ? Colors.grey
                      : const Color.fromARGB(255, 15, 132, 187),
                ),
              ),

            for (var tiro in tiros)
              AnimatedPositioned(
                key: ValueKey(tiro),
                top: tiro.y,
                left: tiro.x,

                width: tiro.width,
                height: tiro.height,

                duration: fps,

                child: Container(color: Colors.red),
              ),

            AnimatedPositioned(
              key: const ValueKey('player'),
              top: player.y,
              left: player.x,

              width: player.width,
              height: player.height,

              duration: fps,

              // curve: Curves.linear,
              child: Container(
                height: 100,
                color: const Color.fromARGB(255, 235, 184, 18),
              ),
            ),

            if (isMobile) _buildMobileControls(),
            if (isMobile) _buildJumpButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildJumpButton() {
    return Positioned(
      top: 700,
      right: 173,
      child: GestureDetector(
        onTapDown: (_) {
          if (isOnGround == true) {
            player.velocity.y = -velocidade * 4;
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_upward, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Widget _buildMobileControls() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTapDown: (_) {
                keys.left = true;
              },
              onTapUp: (_) {
                keys.left = false;
              },
              onTapCancel: () {
                keys.left = false;
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 40),
            GestureDetector(
              onTapDown: (_) {
                tiros.add(Objects(
                  width: 32,
                  height: 12,
                  x: player.right,
                  y: player.top,
                ));
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_fire_department,
                    color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 40),
            GestureDetector(
              onTapDown: (_) {
                keys.right = true;
              },
              onTapUp: (_) {
                keys.right = false;
              },
              onTapCancel: () {
                keys.right = false;
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward, color: Colors.white, size: 24),
              ),
            ),
          ],
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
      tiros.add(Objects(width: 32, height: 12, x: player.right, y: player.top));
    }

    return KeyEventResult.handled;
  }
}
