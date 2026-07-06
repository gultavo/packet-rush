import '../levels.dart';
import '../objects.dart';

/// Descreve a construção específica de uma fase do jogo.
///
/// O motor do jogo (GameBoard) é genérico: ele apenas executa a fase que
/// recebe. Tudo que muda de uma fase para outra (cenário, tamanho do mapa,
/// chão, plataformas e posições iniciais) fica aqui, e não no GameBoard.
class Fase {
  /// Em qual andar esta fase está.
  final int andar;

  /// Número da fase dentro do andar.
  final int numero;

  /// Dados do nível (cenário de fundo, tamanho do mapa, etc.).
  final LevelData level;

  /// Posição inicial (e de respawn) do jogador.
  final double playerStartX;
  final double playerStartY;

  /// Posição inicial do inimigo.
  final double enemyStartX;
  final double enemyStartY;

  /// Segmentos de chão. Permite criar buracos/gaps dividindo o chão em
  /// vários segmentos com intervalos entre eles.
  final List<GroundSegment> groundSegments;

  /// Cria as plataformas flutuantes desta fase.
  ///
  /// É uma função (e não uma lista pronta) para que cada início/reinício da
  /// fase gere objetos novos, sem reaproveitar instâncias antigas.
  final List<Objects> Function() criarPlataformas;

  Fase({
    required this.andar,
    required this.numero,
    required this.level,
    required this.groundSegments,
    required this.criarPlataformas,
    this.playerStartX = 130,
    this.playerStartY = 130,
    this.enemyStartX = 200,
    this.enemyStartY = 100,
  });

  /// Atalho para a largura do mapa definida no nível.
  double get larguraDoMapa => level.larguraDoMapa;
}
