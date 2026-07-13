import 'dart:ui';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 3 — Fase 5.
///
/// A penúltima fase do andar (o boss fica para a Fase 6) e o ápice de
/// verticalidade do Andar 3: em vez de uma única torre como a Fase 4, o jogador
/// atravessa DUAS torres completas em sequência — uma "cadeia de montanhas" em
/// que ele passa quase a fase inteira no ar, sobre dois vãos longos, com duas
/// subidas-crista-descidas de ponta a ponta. É também a fase com mais inimigos
/// do andar (7), mas eles são espalhados na horizontal de propósito.
///
/// ## Por que os inimigos NÃO ficam empilhados no mesmo plano vertical
///
/// Cada torre é contestada por UM único atirador aéreo, no alto da sua ponte, e
/// as duas pontes ficam a ~1300px uma da outra. Isso é deliberado: se dois
/// inimigos compartilhassem a mesma coluna (um no chão atirando rente e um no
/// alto atirando na altura do pulo), o jogador ficaria sem saída — parado toma
/// o tiro baixo, pulando toma o tiro alto. Espalhando os inimigos, em qualquer
/// ponto do mapa há no máximo uma ameaça por vez, e sempre com uma resposta
/// válida: pular o tiro OU atirar de volta.
///
/// Estrutura (da esquerda para a direita):
///  1. Zona inicial no chão, com o primeiro inimigo (x=450).
///  2. Um salto direto de 170px (sem plataforma), no plano.
///  3. Zona intermediária no chão, com o segundo inimigo (x=1250), guardando a
///     aproximação da primeira torre.
///  4. TORRE 1: um buraco longo (1450 → 2420) atravessado por 4 plataformas
///     (sobe, topo, ponte, desce) até 220px de altura. O terceiro inimigo fica
///     na ponte do topo, atirando enquanto o jogador cruza a crista.
///  5. O VALE (chão 2420 → 2750): o respiro entre as duas torres, guardado por
///     dois inimigos no chão (x=2550 e x=2690) — combate em pé firme, sem risco
///     de queda, antes da segunda subida.
///  6. TORRE 2: um buraco longo (2750 → 3720) com as mesmas 4 plataformas até
///     220px. O sexto inimigo fica na ponte do topo desta torre.
///  7. Trecho final no chão, com o sétimo inimigo (x=3820) guardando o caminho
///     até o portal.
///
/// ## Orçamento do pulo (ver a tabela em [Fase])
///
/// Todos os vãos abaixo cabem no pulo NORMAL, sem depender do DEV mode. As duas
/// torres são idênticas em geometria (só mudam de posição no mapa):
///  - chão 850 → chão 1020: vão 170, no plano (alcance 220) — folga 50.
///  - chão → degrau 1: vão 120, subida 100 (alcance 180) — folga 60.
///  - degrau 1 → degrau 2 (topo): vão 100, subida 120 (alcance 160) — folga 60.
///  - degrau 2 → ponte: vão 100, no plano (alcance 220) — folga de sobra.
///  - ponte → degrau 3 (desce): vão 100, descida de 120 — folga de sobra.
///  - degrau 3 → chão: vão 110, descida de 100 — folga de sobra.
///
/// Tamanho horizontal próprio: a arte desta fase é 2172 × 724 px (larga,
/// aspecto 3.0). O mapa acompanha a largura da arte (largura × 2 ≈ 4340), e o
/// cenário é travado na borda da imagem para nunca mostrar faixa branca.
final faseAndar3Fase5 = Fase(
  andar: 3,
  numero: 5,
  level: LevelData(
    size: const Size(4340, 600),
    offset: const Offset(800, 0),
    backgroundImage: 'lib/Images/Fases/Andar3/Fase3-5.png',
    larguraDoMapa: 4340,
    imgWidth: 2172,
    imgHeight: 724,
  ),

  // Chão em quatro pedaços, com três buracos entre eles: o salto direto, a
  // Torre 1 e a Torre 2. O vale (2420 → 2750) é o pedaço de chão entre as duas
  // torres — o único respiro em pé firme no meio da travessia vertical.
  groundSegments: const [
    GroundSegment(double.negativeInfinity, 850),
    GroundSegment(1020, 1450),
    GroundSegment(2420, 2750), // o vale: respiro entre as duas torres
    GroundSegment(3720, double.infinity),
  ],

  // As duas torres, cada uma com 4 plataformas (sobe, topo, ponte, desce) até
  // 220px de altura, todas relativas ao chão (groundY). Geometria idêntica; só
  // muda a posição no mapa. Vãos conferidos contra a tabela de alcance do pulo
  // normal (ver o "Orçamento do pulo" acima e a tabela em fase.dart).
  criarPlataformas: (groundY) => [
    // Torre 1 (buraco 1450 → 2420)
    Objects(x: 1570, y: groundY - 100, width: 110), // degrau 1 (sobe)
    Objects(x: 1780, y: groundY - 220, width: 110), // degrau 2 (topo)
    Objects(x: 1990, y: groundY - 220, width: 110), // ponte no topo
    Objects(x: 2200, y: groundY - 100, width: 110), // degrau 3 (desce)
    // Torre 2 (buraco 2750 → 3720)
    Objects(x: 2870, y: groundY - 100, width: 110), // degrau 1 (sobe)
    Objects(x: 3080, y: groundY - 220, width: 110), // degrau 2 (topo)
    Objects(x: 3290, y: groundY - 220, width: 110), // ponte no topo
    Objects(x: 3500, y: groundY - 100, width: 110), // degrau 3 (desce)
  ],

  // 7 inimigos, espalhados na horizontal para nunca empilhar dois no mesmo
  // plano vertical (ver a nota no cabeçalho): um no início, um na aproximação
  // da Torre 1, um na ponte da Torre 1, dois no vale (combate em chão firme),
  // um na ponte da Torre 2 e um guardando o trecho final antes do portal.
  criarInimigos: (groundY) => [
    const EnemySpawn(450),
    const EnemySpawn(1250),
    EnemySpawn(2045, y: groundY - 220 - 64), // ponte da Torre 1
    const EnemySpawn(2550),
    const EnemySpawn(2690),
    EnemySpawn(3345, y: groundY - 220 - 64), // ponte da Torre 2
    const EnemySpawn(3820),
  ],
);
