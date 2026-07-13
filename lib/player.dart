class Player {
  double x; // Posição atual do jogador em X.
  double y; // Posição atual do jogador em Y.

  double width; //tamanho horizontal do jogador define a hitbox
  double height; //tamanho vertical do jogador
  double position; //estado direcional do jogador

  Vector velocity = Vector(0, 0); //velocidade do jogador

  String currentSprite = 'sprites/boneco_1.png'; //sprite atual do jogador

  Player({
    this.x = 0,
    this.y = 0,
    this.width = 70,
    this.height = 70,
    
    this.position = 0

  });

  double get top => y;
  double get bottom => y + height;
  double get left => x;
  double get right => x + width;
}

class Vector {
  double x;
  double y;

  Vector(
    this.x,
    this.y,
  );
}