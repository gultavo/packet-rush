import 'dart:ui';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 4 — Fase 2.
///
/// Um degrau mais difícil que a Fase 1 do andar, e já um passo acima da Fase 2
/// dos Andares 1, 2 e 3: mantém a assinatura da "segunda fase" (um salto direto
/// largo de 180px e inimigos no alto da travessia, cobrando combate em pleno
/// ar), mas sobe a aposta por ser o andar mais avançado. São 5 inimigos (contra
/// os 4 da Fase 2 do Andar 3), a travessia do buraco largo é a mesma TORRE de 4
/// plataformas da Fase 1 (sobe, topo, ponte, desce) — com DOIS inimigos aéreos,
/// não um — e há um TERCEIRO buraco: um segundo salto direto logo antes do
/// portal, guardado pelo último inimigo, para o jogador não relaxar no fim.
///
/// Estrutura (da esquerda para a direita):
///  1. Zona inicial no chão. O jogador nasce no início real do mapa (x=50,
///     padrão do motor) e tem um trecho livre antes do primeiro inimigo
///     (x=400).
///  2. Um salto direto de 180px (sem plataforma) — o maior salto direto que o
///     pulo normal aguenta com folga, exige um pulo bem cronometrado.
///  3. Zona intermediária no chão, com o segundo inimigo (x=1400).
///  4. Um buraco largo (1750 → 2750) sem chão nenhum, atravessado pela TORRE de
///     4 plataformas em arco alto (sobe, topo, ponte, desce) até 220px. O
///     terceiro e o quarto inimigos ficam em cima da torre — um no topo e um na
///     ponte —, atirando de dois ângulos enquanto o jogador cruza pulando.
///  5. Zona intermediária curta no chão (2750 → 3050).
///  6. Um segundo salto direto de 160px (sem plataforma) — a repetição do
///     obstáculo de abertura já cansado, com o portal à vista.
///  7. Trecho final no chão, com o quinto inimigo (x=3400) guardando o caminho
///     até o portal.
///
/// ## Orçamento do pulo (ver a tabela em [Fase])
///
/// Todos os vãos abaixo cabem no pulo NORMAL, sem depender do DEV mode:
///  - chão 850 → chão 1030: vão 180, no plano (alcance 220) — folga 40 (o salto
///    direto mais largo que o pulo normal aguenta, bem cronometrado).
///  - chão 1750 → degrau 1: vão 120, subida 100 (alcance 180) — folga 60.
///  - degrau 1 → degrau 2 (topo): vão 100, subida 120 (alcance 160) — folga 60.
///  - degrau 2 → ponte: vão 100, no plano (alcance 220) — folga de sobra.
///  - ponte → degrau 3 (desce): vão 100, descida de 120 — folga de sobra.
///  - degrau 3 → chão 2750: vão 140, descida de 100 — folga de sobra.
///  - chão 3050 → chão 3210: vão 160, no plano (alcance 220) — folga 60.
///
/// Tamanho horizontal próprio: a arte desta fase é 1981 × 793 px (levemente
/// mais estreita, aspecto ~2.5). O mapa acompanha a largura da arte
/// (largura × 2 ≈ 3960), e o cenário é travado na borda da imagem para nunca
/// mostrar faixa branca.
final faseAndar4Fase2 = Fase(
  andar: 4,
  numero: 2,
  level: LevelData(
    size: const Size(3960, 600),
    offset: const Offset(800, 0),
    backgroundImage: 'lib/Images/Fases/Andar4/Fase4-2.png',
    larguraDoMapa: 3960,
    imgWidth: 1981,
    imgHeight: 793,
  ),

  // Chão em quatro pedaços, com três buracos entre eles: o salto direto de
  // abertura (850 → 1030), o buraco largo da torre (1750 → 2750) e o segundo
  // salto direto antes do portal (3050 → 3210).
  groundSegments: const [
    GroundSegment(double.negativeInfinity, 850),
    GroundSegment(1030, 1750),
    GroundSegment(2750, 3050),
    GroundSegment(3210, double.infinity),
  ],

  // A torre de 4 plataformas (sobe, topo, ponte, desce) que atravessa o buraco
  // largo, posicionada relativa ao chão (groundY). Sobe até 220px e é estreita
  // (110px), exigindo pouso preciso. Vãos conferidos contra a tabela de alcance
  // do pulo normal (ver fase.dart):
  //  - chão 1750 → degrau 1: vão 120, subida 100 (alcance 180) — folga 60.
  //  - degrau 1 → degrau 2 (topo): vão 100, subida 120 (alcance 160) — folga 60.
  //  - degrau 2 → ponte: vão 100, no plano (alcance 220) — folga de sobra.
  //  - ponte → degrau 3 (desce): vão 100, descida de 120 — folga de sobra.
  //  - degrau 3 → chão 2750: vão 140, descida de 100 — folga de sobra.
  criarPlataformas: (groundY) => [
    Objects(x: 1870, y: groundY - 100, width: 110), // degrau 1 (sobe)
    Objects(x: 2080, y: groundY - 220, width: 110), // degrau 2 (topo)
    Objects(x: 2290, y: groundY - 220, width: 110), // ponte no topo
    Objects(x: 2500, y: groundY - 100, width: 110), // degrau 3 (desce)
  ],

  // 5 inimigos: três no chão (início, meio e trecho final antes do portal) e
  // dois em cima da torre — um no topo e um na ponte —, atirando de dois
  // ângulos enquanto o jogador cruza o buraco largo pulando.
  criarInimigos: (groundY) => [
    const EnemySpawn(400),
    const EnemySpawn(1400),
    EnemySpawn(2135, y: groundY - 220 - 64), // em cima do topo
    EnemySpawn(2345, y: groundY - 220 - 64), // em cima da ponte
    const EnemySpawn(3400),
  ],
);
