import 'dart:ui';

class LevelData{
  Size size;  // tamanho do nível **Ajeitar**  
  Offset offset; // limite da câmera **Ajeitar**
  final String backgroundImage; // background do nível

  LevelData({
    required this.size, 
    required this.offset, 
    required this.backgroundImage
    });

}

final levelOne = LevelData(
  size: const Size(1600, 600),
  offset: const Offset(800, 0),
  backgroundImage: 'sprites/Back_2-1.png',
);