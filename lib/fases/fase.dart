import '../enemy.dart';
import '../levels.dart';
import '../objects.dart';
import 'fase_content.dart';

/// Ponto de nascimento de um inimigo. Por padrão nasce em pé sobre o chão
/// (Y calculado automaticamente); passe [y] para nascer sobre uma
/// plataforma elevada específica (ex.: `EnemySpawn(x, y: groundY - 190 - 64)`
/// para nascer em cima de uma plataforma cujo topo fica em `groundY - 190`).
///
/// Passe `tipo: EnemyType.boss` para um inimigo 4x maior, com tiro 4x maior e
/// que só morre com 4 tiros. Ao posicionar um boss sobre uma plataforma,
/// lembre que ele é mais alto: o Y é `topoDaPlataforma - Enemy.tamanhoDe(tipo)`.
class EnemySpawn {
  final double x;
  final double? y;
  final EnemyType tipo;
  const EnemySpawn(this.x, {this.y, this.tipo = EnemyType.normal});
}

List<EnemySpawn> _inimigoPadrao(double groundY) => const [EnemySpawn(200)];

/// Descreve a construção específica de uma fase do jogo.
///
/// O motor do jogo (GameBoard) é genérico: ele apenas executa a fase que
/// recebe. Tudo que muda de uma fase para outra (cenário, tamanho do mapa,
/// chão, plataformas e posições iniciais) fica aqui, e não no GameBoard.
///
/// ## Orçamento do pulo — leia antes de posicionar plataformas ou buracos
///
/// A física é toda em pixels de mundo e não depende da tela nem da
/// orientação (o motor simula num mundo de altura fixa). Com o pulo NORMAL
/// (o do jogador de verdade; o DEV mode pula muito mais e esconde erros de
/// construção), o arco sobe no máximo **162px** e é assim, tick a tick:
///
///     tick    1   2    3    4    5    6    7    8    9   10   11   12
///     altura  52  94  126  148  160  162  154  136  108   70   22  -36
///     avanço  20  40   60   80  100  120  140  160  180  200  220  240
///
/// O motor só aceita o pouso no ÚNICO tick em que o jogador cruza o topo do
/// destino descendo. Então, para um destino que fica `subida` px acima da
/// origem, o alcance horizontal útil é o avanço no último tick em que a
/// altura ainda é ≥ `subida`:
///
///     subida ≤   22  →  alcance 220
///     subida ≤   70  →  alcance 200
///     subida ≤  108  →  alcance 180
///     subida ≤  136  →  alcance 160
///     subida ≤  154  →  alcance 140
///     subida ≤  162  →  alcance 120
///     subida >  162  →  IMPOSSÍVEL
///
/// O vão a medir é `destino.left - origem.right` (borda a borda), e ele
/// precisa ser MENOR que o alcance — o motor exige `right > plat.left`,
/// estrito, então um vão igual ao alcance falha por zero. Deixe pelo menos
/// **40px de folga**. Descidas (subida negativa) ganham alcance extra.
class Fase {
  /// Em qual andar esta fase está.
  final int andar;

  /// Número da fase dentro do andar.
  final int numero;

  /// Dados do nível (cenário de fundo, tamanho do mapa, etc.).
  final LevelData level;

  /// Posição X inicial (e de respawn) do jogador. Por padrão, bem perto do
  /// início real do mapa — o jogador sempre nasce no começo da fase. A
  /// posição Y é sempre calculada automaticamente em cima do chão (ver
  /// [playerStartY]).
  final double playerStartX;

  /// Posição Y inicial (e de respawn) do jogador. Deixe `null` (padrão) para
  /// o jogador nascer já em pé sobre o chão; só defina um valor aqui se a
  /// fase precisar que ele comece sobre uma plataforma elevada específica.
  final double? playerStartY;

  /// Cria os pontos de nascimento dos inimigos desta fase. Cada um nasce
  /// sobre o chão por padrão, mas pode nascer sobre uma plataforma (veja
  /// [EnemySpawn.y]). Mais inimigos = fase mais difícil. Recebe a altura Y
  /// do chão pelo mesmo motivo de [criarPlataformas].
  final List<EnemySpawn> Function(double groundY) criarInimigos;

  /// Segmentos de chão. Permite criar buracos/gaps dividindo o chão em
  /// vários segmentos com intervalos entre eles. Onde não há segmento
  /// cobrindo o X do jogador, não há chão: cair ali custa uma vida.
  final List<GroundSegment> groundSegments;

  /// Cria as plataformas flutuantes desta fase.
  ///
  /// É uma função (e não uma lista pronta) para que cada início/reinício da
  /// fase gere objetos novos, sem reaproveitar instâncias antigas. Recebe a
  /// altura Y do chão (calculada em tempo de execução a partir do tamanho da
  /// tela) para que as plataformas sejam posicionadas relativas ao chão, e
  /// não com pixels absolutos que dependeriam do tamanho da janela.
  final List<Objects> Function(double groundY) criarPlataformas;

  // ── Conteúdo didático e quiz ──────────────────────────────────────────

  /// Título do cenário (ex.: "O Subsolo dos Sinais").
  String? titulo;

  /// Texto de leitura exibido no balão de texto antes da fase começar.
  String? conteudo;

  /// Perguntas do quiz exibido ao entrar no portal.
  List<Pergunta>? perguntas;

  /// Posição X do portal no mapa. Se null, será posicionado automaticamente
  /// no final do mapa (larguraDoMapa - 200).
  final double? portalX;

  Fase({
    required this.andar,
    required this.numero,
    required this.level,
    required this.groundSegments,
    required this.criarPlataformas,
    this.playerStartX = 50,
    this.playerStartY,
    this.criarInimigos = _inimigoPadrao,
    this.titulo,
    this.conteudo,
    this.perguntas,
    this.portalX,
  });

  /// Atalho para a largura do mapa definida no nível.
  double get larguraDoMapa => level.larguraDoMapa;

  /// Posição efetiva do portal (default: final do mapa - 375).
  double get portalEfetivo => portalX ?? (larguraDoMapa - 375);
}
