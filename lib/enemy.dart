class Enemy {
  double x;
  double y;

  double width;
  double height;

  double position;

  bool vivo = true; // false quando o inimigo é atingido por um tiro do player

  // Cooldown de tiro próprio de cada inimigo (permite vários atirando de
  // forma independente, cada um no seu próprio ritmo).
  bool podeAtirar = true;

  Vector velocity = Vector(0, 0);

  String currentSprite = 'sprites/enemy_1.png';

  Enemy({
    this.x = 0,
    this.y = 0,
    this.width = 64,
    this.height = 64,

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