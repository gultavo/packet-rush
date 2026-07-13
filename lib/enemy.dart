/// Tipo do inimigo. O boss é uma versão maior e mais resistente do inimigo
/// normal: mesma IA (persegue e atira), mas 4x o tamanho, tiro 4x maior e
/// aguenta 4 tiros do jogador antes de morrer.
enum EnemyType { normal, boss }

class Enemy {
  /// Tamanho (largura e altura) do inimigo normal, em pixels de mundo.
  static const double tamanhoNormal = 64;

  /// Tamanho do tiro do inimigo normal.
  static const double larguraTiroNormal = 64;
  static const double alturaTiroNormal = 24;

  /// Quanto o boss é maior que o inimigo normal — vale para o corpo dele e
  /// para o tiro que ele dispara.
  static const double escalaBoss = 4;

  /// Quantos tiros do jogador o boss aguenta antes de morrer.
  static const int vidaBoss = 4;

  final EnemyType tipo; //se é boss ou inimigo normal

  double x; //posicao do inimigo
  double y;

  double width; //tamanho do inimigo
  double height;

  double position;

  /// Tiros do jogador que este inimigo ainda aguenta. Chega a zero quando ele
  /// morre (ver [vivo]).
  int vida;

  // Cooldown de tiro próprio de cada inimigo (permite vários atirando de
  // forma independente, cada um no seu próprio ritmo).
  bool podeAtirar = true;

  Vector velocity = Vector(0, 0);

  Enemy({
    this.x = 0, //0 se não informar
    this.y = 0,
    this.tipo = EnemyType.normal, //inimigo é normal se não informar
    double? width,
    double? height,
    this.position = 0,
  })  : width = width ?? tamanhoDe(tipo), //se nulo usa o tamanho padrão do tipo  
        height = height ?? tamanhoDe(tipo),
        vida = tipo == EnemyType.boss ? vidaBoss : 1;

  /// Tamanho do corpo de cada tipo de inimigo.
  static double tamanhoDe(EnemyType tipo) => // Método estático para calcular e retornar o tamanho correto.
      tipo == EnemyType.boss ? tamanhoNormal * escalaBoss : tamanhoNormal; // Se for boss, multiplica o tamanho normal 

  bool get boss => tipo == EnemyType.boss; //valor booleano que indica se é boss ou não

  /// Vivo enquanto ainda tiver vida. O normal morre no primeiro tiro; o boss,
  /// no quarto.
  bool get vivo => vida > 0;

  /// Registra um tiro do jogador acertando este inimigo.
  void levarTiro() {
    if (vida > 0) vida--;
  }

  /// Sprite do corpo. O boss usa a de tiro o tempo todo, de propósito: a de
  /// idle (`boss_1.png`, já removida do repo) tinha um enquadramento
  /// diferente, então alternar entre as duas fazia o boss mudar de tamanho na
  /// tela a cada disparo. Como o cooldown dele é de 1200ms, ele ficava em
  /// pose de tiro quase 100% do tempo de qualquer jeito — manter só essa
  /// sprite mata a oscilação e não perde nada.
  String get currentSprite =>
      boss ? 'sprites/Boss_atirando.png' : 'sprites/enemy_1.png';

  /// Se a sprite precisa ser espelhada para o inimigo ENCARAR o jogador.
  ///
  /// As duas artes são desenhadas para lados opostos, e é por isso que isto
  /// não é um simples `position == 1` para todo mundo:
  ///  - `enemy_1.png` olha para a ESQUERDA (viseira e braço da arma à
  ///    esquerda), então precisa espelhar quando o jogador está à direita.
  ///  - `Boss_atirando.png` olha para a DIREITA (a cabeça e a garra apontam
  ///    para a direita; o cilindro grande do lado esquerdo é peça de ombro,
  ///    não a arma), então é o contrário: espelha quando o jogador está à
  ///    ESQUERDA. Usar a mesma regra dos dois deixava o boss de costas para o
  ///    jogador, atirando por cima do próprio ombro.
  ///
  /// [position] é 0 quando o jogador está à esquerda e 1 quando está à direita.
  bool get espelhado => boss ? position == 0 : position == 1;

  String get spriteTiro => boss ? 'sprites/Tiro_boss.png' : 'sprites/tiro.png';

  double get larguraTiro =>
      boss ? larguraTiroNormal * escalaBoss : larguraTiroNormal;
  double get alturaTiro =>
      boss ? alturaTiroNormal * escalaBoss : alturaTiroNormal;

  /// Margens do inimigo, para facilitar a leitura de colisões.
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
