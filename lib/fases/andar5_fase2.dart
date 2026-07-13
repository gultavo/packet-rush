import 'dart:ui';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 5 — Fase 2.
///
/// Um degrau mais difícil que a Fase 1 do andar, e um passo acima da Fase 2 do
/// Andar 4: mantém a assinatura da "segunda fase" (um salto direto largo de
/// abertura e inimigos no alto da travessia, cobrando combate em pleno ar), mas
/// sobe a aposta por coroar a progressão do jogo. A travessia do buraco largo é
/// a mesma TORRE ESTICADA de 5 plataformas da Fase 1 (sobe, topo, ponte1,
/// ponte2, desce), com TRÊS inimigos aéreos — não dois —, e há um TERCEIRO
/// buraco: um segundo salto direto logo antes do portal, guardado pelo último
/// inimigo, para o jogador não relaxar no fim. São 6 inimigos (contra os 5 da
/// Fase 2 do Andar 4), sendo 3 deles suspensos.
///
/// Estrutura (da esquerda para a direita):
///  1. Zona inicial no chão. O jogador nasce no início real do mapa (x=50,
///     padrão do motor) e tem um trecho livre antes do primeiro inimigo
///     (x=400).
///  2. Um salto direto de 180px (sem plataforma) — o maior salto direto que o
///     pulo normal aguenta com folga, exige um pulo bem cronometrado.
///  3. Zona intermediária no chão, com o segundo inimigo (x=1400).
///  4. Um buraco largo (1750 → 2850) sem chão nenhum, atravessado pela TORRE
///     ESTICADA de 5 plataformas em arco alto (sobe, topo, ponte1, ponte2,
///     desce) até 220px. O topo se mantém a 220px por dois vãos seguidos, e o
///     terceiro, quarto e quinto inimigos ficam em cima dele — topo, ponte1 e
///     ponte2 —, atirando de três ângulos enquanto o jogador cruza pulando.
///  5. Zona intermediária curta no chão (2850 → 3130).
///  6. Um segundo salto direto de 160px (sem plataforma) — a repetição do
///     obstáculo de abertura já cansado, com o portal à vista.
///  7. Trecho final no chão, com o sexto inimigo (x=3420) guardando o caminho
///     até o portal.
///
/// ## Orçamento do pulo (ver a tabela em [Fase])
///
/// Todos os vãos abaixo cabem no pulo NORMAL, sem depender do DEV mode:
///  - chão 850 → chão 1030: vão 180, no plano (alcance 220) — folga 40 (o salto
///    direto mais largo que o pulo normal aguenta, bem cronometrado).
///  - chão 1750 → degrau 1: vão 120, subida 100 (alcance 180) — folga 60.
///  - degrau 1 → degrau 2 (topo): vão 100, subida 120 (alcance 160) — folga 60.
///  - degrau 2 → ponte 1: vão 100, no plano (alcance 220) — folga de sobra.
///  - ponte 1 → ponte 2: vão 100, no plano (alcance 220) — folga de sobra.
///  - ponte 2 → degrau 3 (desce): vão 100, descida de 120 — folga de sobra.
///  - degrau 3 → chão 2850: vão 30, descida de 100 — folga de sobra.
///  - chão 3130 → chão 3290: vão 160, no plano (alcance 220) — folga 60.
///
/// Tamanho horizontal próprio: a arte desta fase é 1942 × 809 px (aspecto 2.4).
/// O mapa acompanha a largura da arte (largura × 2 ≈ 3880), e o cenário é
/// travado na borda da imagem para nunca mostrar faixa branca.
final faseAndar5Fase2 = Fase(
  andar: 5,
  numero: 2,
  level: LevelData(
    size: const Size(3880, 600),
    offset: const Offset(800, 0),
    backgroundImage: 'lib/Images/Fases/Andar5/Fase5-2.png',
    larguraDoMapa: 3880,
    imgWidth: 1942,
    imgHeight: 809,
  ),

  // Chão em quatro pedaços, com três buracos entre eles: o salto direto de
  // abertura (850 → 1030), o buraco largo da torre esticada (1750 → 2850) e o
  // segundo salto direto antes do portal (3130 → 3290).
  groundSegments: const [
    GroundSegment(double.negativeInfinity, 850),
    GroundSegment(1030, 1750),
    GroundSegment(2850, 3130),
    GroundSegment(3290, double.infinity),
  ],

  // A torre ESTICADA de 5 plataformas (sobe, topo, ponte1, ponte2, desce) que
  // atravessa o buraco largo, posicionada relativa ao chão (groundY). O topo se
  // mantém a 220px por dois vãos seguidos (ponte1 e ponte2), e todas as
  // plataformas são estreitas (110px), exigindo pouso preciso. Vãos conferidos
  // contra a tabela de alcance do pulo normal (ver fase.dart):
  //  - chão 1750 → degrau 1: vão 120, subida 100 (alcance 180) — folga 60.
  //  - degrau 1 → degrau 2 (topo): vão 100, subida 120 (alcance 160) — folga 60.
  //  - degrau 2 → ponte 1: vão 100, no plano (alcance 220) — folga de sobra.
  //  - ponte 1 → ponte 2: vão 100, no plano (alcance 220) — folga de sobra.
  //  - ponte 2 → degrau 3 (desce): vão 100, descida de 120 — folga de sobra.
  //  - degrau 3 → chão 2850: vão 30, descida de 100 — folga de sobra.
  criarPlataformas: (groundY) => [
    Objects(x: 1870, y: groundY - 100, width: 110), // degrau 1 (sobe)
    Objects(x: 2080, y: groundY - 220, width: 110), // degrau 2 (topo)
    Objects(x: 2290, y: groundY - 220, width: 110), // ponte 1 no topo
    Objects(x: 2500, y: groundY - 220, width: 110), // ponte 2 no topo
    Objects(x: 2710, y: groundY - 100, width: 110), // degrau 3 (desce)
  ],

  // 6 inimigos: três no chão (início, meio e trecho final antes do portal) e
  // três em cima da torre esticada — topo, ponte 1 e ponte 2 —, atirando de três
  // ângulos enquanto o jogador cruza o buraco largo pulando.
  criarInimigos: (groundY) => [
    const EnemySpawn(400),
    const EnemySpawn(1400),
    EnemySpawn(2135, y: groundY - 220 - 64), // em cima do topo
    EnemySpawn(2345, y: groundY - 220 - 64), // em cima da ponte 1
    EnemySpawn(2555, y: groundY - 220 - 64), // em cima da ponte 2
    const EnemySpawn(3420),
  ],
);
