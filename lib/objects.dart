enum Type { plataforma, ground }

class GroundSegment {
  final double startX;
  final double endX;
  const GroundSegment(this.startX, this.endX);
}

class Objects {
  double x;
  double y;
  double width;
  double height;

  Type type;

  String currentSpriteTiro;
  String currentSpritePlataforma = 'sprites/plataforma_1.png';

  final bool invertido;


  Objects({
    required this.x,
    required this.y,
    this.width = 50,
    this.height = 50,
    this.type = Type.plataforma,
    this.invertido  = false,
    this.currentSpriteTiro = 'sprites/tiro.png',
  });

  double get top => y;
  double get bottom => y + height;
  double get left => x;
  double get right => x + width;
}