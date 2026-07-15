import 'dart:ui';

class LevelData{
  Size size;  // tamanho do nível 
  Offset offset; // limite da câmera 
  final String backgroundImage; // background do nível
  double larguraDoMapa; // Tamanho total em pixels de largura jogável da fase.

  // Tamanho nativo (em pixels) da arte de fundo. Serve para o GameBoard saber
  // a proporção da imagem e travar o cenário exatamente na borda da arte,
  // evitando faixa branca no fim da fase.
  final double imgWidth; // Guarda a largura bruta e original da imagem de fundo.
  final double imgHeight; // Guarda a altura bruta e original da imagem de fundo.

  LevelData({
    required this.size, // Exige a dimensão total na criação da fase.
    required this.offset, // Exige o limite de câmera na criação da fase.
    required this.backgroundImage, // Exige o fundo cenário na criação da fase.
    required this.larguraDoMapa, // Exige a configuração da largura física do mapa.
    this.imgWidth = 1983, // Largura de fallback da imagem de fundo.
    this.imgHeight = 793, // Altura de fallback da imagem de fundo.
    });

  /// Proporção largura/altura da arte de fundo.
  double get aspect => imgHeight == 0 ? 2.5 : imgWidth / imgHeight; // Calcula a proporção (aspect ratio) da imagem de fundo protegendo contra divisão por zero.
}