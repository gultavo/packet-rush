enum Type { plataforma, ground }


class Objects {
  double x;
  double y;
  double width;
  double height;

  Type type;

  Objects({
    required this.x,
    required this.y,
    this.width = 50,
    this.height = 50,
    this.type = Type.plataforma,
  });

  double get top => y;
  double get bottom => y + height;
  double get left => x;
  double get right => x + width;
}