import 'dart:ui';

class LevelData{
  Size size;  // tamanho do nível **Ajeitar**
  Offset offset; // limite da câmera **Ajeitar**
  final String backgroundImage; // background do nível
  double larguraDoMapa;

  // Tamanho nativo (em pixels) da arte de fundo. Serve para o GameBoard saber
  // a proporção da imagem e travar o cenário exatamente na borda da arte,
  // evitando faixa branca no fim da fase.
  final double imgWidth;
  final double imgHeight;

  LevelData({
    required this.size,
    required this.offset,
    required this.backgroundImage,
    required this.larguraDoMapa,
    this.imgWidth = 1983,
    this.imgHeight = 793,
    });

  /// Proporção largura/altura da arte de fundo.
  double get aspect => imgHeight == 0 ? 2.5 : imgWidth / imgHeight;
}

final levelOne = LevelData(
  size: const Size(1600, 600),
  offset: const Offset(800, 0),
  backgroundImage: 'sprites/Back_2-1.png',
  larguraDoMapa: 4340
);