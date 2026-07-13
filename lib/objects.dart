enum Type { plataforma, ground }

class GroundSegment { // Representa visualmente e logicamente um segmento de piso do cenário.
  final double startX; // Onde o segmento de chão se inicia no mapa (coordenada horizontal).
  final double endX;  // Onde o segmento de chão termina no mapa (coordenada horizontal).
  const GroundSegment(this.startX, this.endX); // O construtor deste segmento, que é fixo e imutável (constante).
}

class Objects { // Estrutura base de todos os objetos renderizáveis (caixas, plataformas, etc).
  double x; // Posição atual do objeto em X.
  double y; // Posição atual do objeto em Y.
  double width; // Comprimento/largura horizontal do objeto.
  double height; // Altura vertical do objeto.

  Type type; // Tag que classifica que tipo de objeto é este (veja a Enum Type).

  String currentSpriteTiro; // Variável para armazenar sprites dinâmicos, se o objeto puder atirar.
  String currentSpritePlataforma = 'sprites/plataforma_1.png'; // Define o arquivo de arte padrão quando é uma plataforma.

  final bool invertido; // Determina se a arte gráfica do objeto deverá ser renderizada de trás para frente (espelhada).


  Objects({
    required this.x, // A posição inicial X é campo obrigatório.
    required this.y, // A posição inicial Y é campo obrigatório.
    this.width = 50, // Largura da hitbox assumida em 50 caso não especificada.
    this.height = 50, // Altura da hitbox assumida em 50 caso não especificada.
    this.type = Type.plataforma, // Defaultiza o tipo para plataforma se nada for dito.
    this.invertido  = false, // Garante que a orientação natural não é invertida no início.
    this.currentSpriteTiro = 'sprites/tiro.png', // Informa sprite de tiro se necessitar.
  });

  double get top => y; // Getter que facilita a leitura da margem superior do objeto.
  double get bottom => y + height; // Calcula a margem inferior (posição somada com altura).
  double get left => x; // Retorna diretamente a margem esquerda (coordenada).
  double get right => x + width; // Calcula a margem direita (posição somada com largura).
}