import 'dart:ui';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 3 — Fase 2.
///
/// Um degrau mais difícil que a Fase 1 do andar, e já um passo acima da Fase 2
/// dos Andares 1 e 2: mantém a assinatura da "segunda fase" (um salto direto
/// largo e um inimigo no alto da travessia, cobrando combate em pleno ar), mas
/// sobe a aposta por ser um andar mais avançado — são 4 inimigos (contra os 3
/// do template), plataformas do arco mais estreitas (120px, contra os 130px da
/// Fase 1) e um mapa bem mais longo, com um inimigo extra guardando o trecho
/// final antes do portal.
///
/// Estrutura (da esquerda para a direita):
///  1. Zona inicial no chão. O jogador nasce no início real do mapa (x=50,
///     padrão do motor) e tem um trecho livre antes do primeiro inimigo
///     (x=400).
///  2. Um salto direto de 180px (sem plataforma) — o maior salto direto que o
///     pulo normal aguenta com folga, exige um pulo bem cronometrado.
///  3. Zona intermediária no chão, com o segundo inimigo (x=1600).
///  4. Um buraco largo (2100 → 3000) sem chão nenhum, atravessado por 3
///     plataformas em arco (sobe, topo, desce), mais estreitas (120px) que as
///     da Fase 1. O terceiro inimigo fica em cima da plataforma do topo (a mais
///     alta), atirando enquanto o jogador tenta cruzar pulando.
///  5. Trecho final no chão, com o quarto inimigo (x=3400) guardando o caminho
///     até o portal.
///
/// ## Orçamento do pulo (ver a tabela em [Fase])
///
/// Todos os vãos abaixo cabem no pulo NORMAL, sem depender do DEV mode:
///  - chão 1000 → chão 1180: vão 180, no plano (alcance 220) — folga 40 (o
///    salto direto mais largo que o pulo normal aguenta, bem cronometrado).
///  - chão 2100 → degrau 1: vão 120, subida 100 (alcance 180) — folga 60.
///  - degrau 1 → degrau 2: vão 110, subida 100 (alcance 180) — folga 70.
///  - degrau 2 → degrau 3: vão 150, descida de 100 — folga de sobra.
///  - degrau 3 → chão 3000: vão 160, descida de 100 — folga de sobra.
///
/// Tamanho horizontal próprio: a arte desta fase é 2171 × 724 px (larga,
/// aspecto 3.0). O mapa acompanha a largura da arte (largura × 2 ≈ 4340), e o
/// cenário é travado na borda da imagem para nunca mostrar faixa branca.
final faseAndar3Fase2 = Fase(
  andar: 3,
  numero: 2,
  level: LevelData(
    size: const Size(4340, 600),
    offset: const Offset(800, 0),
    backgroundImage: 'lib/Images/Fases/Andar3/Fase3-2.png',
    larguraDoMapa: 4340,
    imgWidth: 2171,
    imgHeight: 724,
  ),

  // Chão em três pedaços: zona inicial, zona intermediária e zona final, com
  // dois buracos entre eles. O primeiro (1000 → 1180) é o salto direto de
  // 180px; o segundo (2100 → 3000), bem mais largo, exige as plataformas do
  // arco para ser atravessado.
  groundSegments: const [
    GroundSegment(double.negativeInfinity, 1000),
    GroundSegment(1180, 2100),
    GroundSegment(3000, double.infinity),
  ],

  // As 3 plataformas em arco (sobe, topo, desce) que atravessam o buraco largo,
  // posicionadas relativas ao chão (groundY). Mais estreitas (120px) que as da
  // Fase 1 (130px), exigindo pouso mais preciso. Vãos conferidos contra a
  // tabela de alcance do pulo normal (ver fase.dart):
  //  - chão 2100 → degrau 1: vão 120, subida 100 (alcance 180) — folga 60.
  //  - degrau 1 → degrau 2: vão 110, subida 100 (alcance 180) — folga 70.
  //  - degrau 2 → degrau 3: vão 150, descida de 100 — folga de sobra.
  //  - degrau 3 → chão 3000: vão 160, descida de 100 — folga de sobra.
  criarPlataformas: (groundY) => [
    Objects(x: 2220, y: groundY - 100, width: 120), // degrau 1 (sobe)
    Objects(x: 2450, y: groundY - 200, width: 120), // degrau 2 (topo)
    Objects(x: 2720, y: groundY - 100, width: 120), // degrau 3 (desce)
  ],

  // 4 inimigos: dois no chão (início e zona intermediária), um em cima da
  // plataforma do topo (atirando em pleno ar) e um guardando o trecho final
  // antes do portal.
  criarInimigos: (groundY) => [
    const EnemySpawn(400),
    const EnemySpawn(1600),
    EnemySpawn(2510, y: groundY - 200 - 64),
    const EnemySpawn(3400),
  ],
);
