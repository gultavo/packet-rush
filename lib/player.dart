class Player {
  double x;
  double y;

  double width;
  double height;

  Vector velocity = Vector(0, 0);

  Player({
    this.x = 0,
    this.y = 0,
    this.width = 64,
    this.height = 64,
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