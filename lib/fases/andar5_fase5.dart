import 'dart:ui';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 5 — Fase 5.
///
/// A penúltima fase do andar (o boss fica para a Fase 6) e o ápice de
/// verticalidade do jogo. Escala um degrau acima da Fase 5 do Andar 3 — que já
/// era uma "cadeia de montanhas" de DUAS torres em sequência — sem trair a regra
/// de ouro daquela fase (nunca empilhar duas ameaças no mesmo plano vertical, ou
/// o jogador fica sem saída: parado toma o tiro baixo, pulando toma o alto).
///
/// O degrau a mais vem da identidade do Andar 5: cada uma das duas torres é a
/// versão ESTICADA (sobe, topo, ponte 1, ponte 2, desce), com a crista mantida a
/// 220px por dois vãos seguidos — o maior tempo de ar do jogo. E cada crista é
/// contestada por DOIS atiradores aéreos (um por ponte), contra o único da Fase 5
/// do Andar 3. São 9 inimigos no total (contra os 7 daquela), a fase mais povoada
/// do jogo, todos espalhados na horizontal de propósito: em qualquer ponto do
/// mapa há no máximo uma ameaça por vez, sempre com resposta válida (pular o tiro
/// OU atirar de volta). Os dois aéreos de uma mesma crista estão à mesma altura,
/// mas 210px separados na horizontal — o jogador os cruza um de cada vez.
///
/// Estrutura (da esquerda para a direita):
///  1. Zona inicial no chão, com o primeiro inimigo (x=350).
///  2. Um salto direto de 170px (sem plataforma), no plano.
///  3. Zona intermediária no chão, com o segundo inimigo (x=1000), guardando a
///     aproximação da primeira torre.
///  4. TORRE 1 esticada: um buraco longo (1150 → 2240) atravessado por 5
///     plataformas (sobe, topo, ponte 1, ponte 2, desce) até 220px. Dois inimigos
///     nas pontes do topo contestam a crista inteira.
///  5. O VALE (chão 2240 → 2560): o respiro entre as duas torres, guardado por
///     dois inimigos no chão (x=2350 e x=2490) — combate em pé firme, sem risco
///     de queda, antes da segunda subida.
///  6. TORRE 2 esticada: um buraco longo (2560 → 3650) com as mesmas 5
///     plataformas até 220px. Mais dois inimigos nas pontes do topo desta torre.
///  7. Trecho final no chão, com o nono inimigo (x=3760) guardando o caminho até
///     o portal.
///
/// O portal é posicionado explicitamente (portalX) mais à frente que o padrão:
/// como as duas torres esticadas ocupam quase todo o mapa (mais estreito que o do
/// Andar 3), o final automático cairia dentro do buraco da Torre 2. Empurrá-lo
/// para 3850 preserva o trecho final em chão firme com o último guardião.
///
/// ## Orçamento do pulo (ver a tabela em [Fase])
///
/// Todos os vãos abaixo cabem no pulo NORMAL, sem depender do DEV mode. As duas
/// torres são idênticas em geometria (só mudam de posição no mapa):
///  - chão 650 → chão 820: vão 170, no plano (alcance 220) — folga 50.
///  - chão → degrau 1: vão 120, subida 100 (alcance 180) — folga 60.
///  - degrau 1 → degrau 2 (topo): vão 100, subida 120 (alcance 160) — folga 60.
///  - degrau 2 → ponte 1: vão 100, no plano (alcance 220) — folga de sobra.
///  - ponte 1 → ponte 2: vão 100, no plano (alcance 220) — folga de sobra.
///  - ponte 2 → degrau 3 (desce): vão 100, descida de 120 — folga de sobra.
///  - degrau 3 → chão: vão 20, descida de 100 — folga de sobra.
///
/// Tamanho horizontal próprio: a arte desta fase é 1983 × 793 px (aspecto 2.5).
/// O mapa acompanha a largura da arte (largura × 2 ≈ 3970), e o cenário é
/// travado na borda da imagem para nunca mostrar faixa branca.
final faseAndar5Fase5 = Fase(
  andar: 5,
  numero: 5,
  level: LevelData(
    size: const Size(3970, 600),
    offset: const Offset(800, 0),
    backgroundImage: 'lib/Images/Fases/Andar5/Fase5-5.png',
    larguraDoMapa: 3970,
    imgWidth: 1983,
    imgHeight: 793,
  ),

  // Portal empurrado para frente do padrão (ver cabeçalho): as duas torres
  // esticadas ocupam quase todo o mapa e o final automático (3595) cairia dentro
  // do buraco da Torre 2.
  portalX: 3850,

  // Chão em quatro pedaços, com três buracos entre eles: o salto direto, a Torre
  // 1 e a Torre 2. O vale (2240 → 2560) é o pedaço de chão entre as duas torres —
  // o único respiro em pé firme no meio da travessia vertical.
  groundSegments: const [
    GroundSegment(double.negativeInfinity, 650),
    GroundSegment(820, 1150),
    GroundSegment(2240, 2560), // o vale: respiro entre as duas torres
    GroundSegment(3650, double.infinity),
  ],

  // As duas torres esticadas, cada uma com 5 plataformas (sobe, topo, ponte 1,
  // ponte 2, desce) até 220px de altura, todas relativas ao chão (groundY).
  // Geometria idêntica; só muda a posição no mapa. Vãos conferidos contra a
  // tabela de alcance do pulo normal (ver o "Orçamento do pulo" acima e a tabela
  // em fase.dart).
  criarPlataformas: (groundY) => [
    // Torre 1 esticada (buraco 1150 → 2240)
    Objects(x: 1270, y: groundY - 100, width: 110), // degrau 1 (sobe)
    Objects(x: 1480, y: groundY - 220, width: 110), // degrau 2 (topo)
    Objects(x: 1690, y: groundY - 220, width: 110), // ponte 1 no topo
    Objects(x: 1900, y: groundY - 220, width: 110), // ponte 2 no topo
    Objects(x: 2110, y: groundY - 100, width: 110), // degrau 3 (desce)
    // Torre 2 esticada (buraco 2560 → 3650)
    Objects(x: 2680, y: groundY - 100, width: 110), // degrau 1 (sobe)
    Objects(x: 2890, y: groundY - 220, width: 110), // degrau 2 (topo)
    Objects(x: 3100, y: groundY - 220, width: 110), // ponte 1 no topo
    Objects(x: 3310, y: groundY - 220, width: 110), // ponte 2 no topo
    Objects(x: 3520, y: groundY - 100, width: 110), // degrau 3 (desce)
  ],

  // 9 inimigos, espalhados na horizontal para nunca empilhar dois no mesmo plano
  // vertical (ver a nota no cabeçalho): um no início, um na aproximação da Torre
  // 1, dois nas pontes da Torre 1, dois no vale (combate em chão firme), dois nas
  // pontes da Torre 2 e um guardando o trecho final antes do portal.
  criarInimigos: (groundY) => [
    const EnemySpawn(350),
    const EnemySpawn(1000),
    EnemySpawn(1745, y: groundY - 220 - 64), // ponte 1 da Torre 1
    EnemySpawn(1955, y: groundY - 220 - 64), // ponte 2 da Torre 1
    const EnemySpawn(2350),
    const EnemySpawn(2490),
    EnemySpawn(3155, y: groundY - 220 - 64), // ponte 1 da Torre 2
    EnemySpawn(3365, y: groundY - 220 - 64), // ponte 2 da Torre 2
    const EnemySpawn(3760),
  ],
);
