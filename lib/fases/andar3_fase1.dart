import 'dart:ui';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 3 — Fase 1.
///
/// Abertura do Andar 3 (Camada de Rede, "A Cidade dos Pacotes"). Como toda
/// primeira fase de um andar, ela reintroduz os três elementos básicos do jogo
/// num cenário novo — inimigos, plataformas e buracos no chão (cair neles custa
/// uma vida). Mas por ser um andar mais avançado, a abertura já vem um degrau
/// acima das Fases 1 dos Andares 1 e 2: em vez de um único buraco e dois
/// inimigos no chão, esta tem DOIS buracos (um salto direto simples antes do
/// buraco largo), TRÊS inimigos e — a novidade — um deles no alto da travessia,
/// cobrando combate em pleno ar já na primeira fase.
///
/// Estrutura (da esquerda para a direita):
///  1. Zona inicial no chão, com o primeiro inimigo (x=500) e um trecho livre
///     para o jogador se orientar.
///  2. Um salto direto simples de 150px (sem plataforma) — o obstáculo extra
///     que as aberturas dos Andares 1 e 2 não tinham. No plano, exige só um
///     pulo bem cronometrado.
///  3. Zona intermediária no chão, com o segundo inimigo (x=1350).
///  4. Um buraco largo (1700 → 2620) sem chão nenhum, atravessado por 3
///     plataformas em arco (sobe, topo, desce). O terceiro inimigo fica em cima
///     da plataforma do topo (a mais alta), atirando enquanto o jogador tenta
///     cruzar pulando. As plataformas são um pouco mais estreitas (130px) que
///     as da abertura do Andar 2 (140px), exigindo pouso mais preciso.
///  5. Zona final no chão, com um trecho livre até o portal.
///
/// ## Orçamento do pulo (ver a tabela em [Fase])
///
/// Todos os vãos abaixo cabem no pulo NORMAL, sem depender do DEV mode:
///  - chão 900 → chão 1050: vão 150, no plano (alcance 220) — folga 70.
///  - chão 1700 → degrau 1: vão 120, subida 100 (alcance 180) — folga 60.
///  - degrau 1 → degrau 2: vão 100, subida 100 (alcance 180) — folga 80.
///  - degrau 2 → degrau 3: vão 140, descida de 100 — folga de sobra.
///  - degrau 3 → chão 2620: vão 170, descida de 100 — folga de sobra.
///
/// Tamanho horizontal próprio: a arte desta fase é 1983 × 793 px. O mapa
/// acompanha a largura da arte (largura da arte × 2 ≈ 3966), e o cenário é
/// travado na borda da imagem para nunca mostrar faixa branca.
final faseAndar3Fase1 = Fase(
  andar: 3,
  numero: 1,
  level: LevelData(
    size: const Size(3966, 600),
    offset: const Offset(800, 0),
    backgroundImage: 'lib/Images/Fases/Andar3/Fase3-1.png',
    larguraDoMapa: 3966,
    imgWidth: 1983,
    imgHeight: 793,
  ),

  // Chão em três pedaços: zona inicial, zona intermediária e zona final, com
  // dois buracos entre eles. O primeiro (900 → 1050) é um salto direto simples;
  // o segundo (1700 → 2620), bem mais largo, exige as plataformas do arco.
  groundSegments: const [
    GroundSegment(double.negativeInfinity, 900),
    GroundSegment(1050, 1700),
    GroundSegment(2620, double.infinity),
  ],

  // As 3 plataformas em arco (sobe, topo, desce) que atravessam o buraco largo,
  // posicionadas relativas ao chão (groundY) para funcionar em qualquer tamanho
  // de tela. Vãos conferidos contra a tabela de alcance do pulo normal (ver
  // fase.dart):
  //  - chão 1700 → degrau 1: vão 120, subida 100 (alcance 180) — folga 60.
  //  - degrau 1 → degrau 2: vão 100, subida 100 (alcance 180) — folga 80.
  //  - degrau 2 → degrau 3: vão 140, descida de 100 — folga de sobra.
  //  - degrau 3 → chão 2620: vão 170, descida de 100 — folga de sobra.
  criarPlataformas: (groundY) => [
    Objects(x: 1820, y: groundY - 100, width: 130), // degrau 1 (sobe)
    Objects(x: 2050, y: groundY - 200, width: 130), // degrau 2 (topo)
    Objects(x: 2320, y: groundY - 100, width: 130), // degrau 3 (desce)
  ],

  // 3 inimigos: dois no chão (início e zona intermediária, entre os dois
  // buracos) e um em cima da plataforma do topo, atirando enquanto o jogador
  // tenta cruzar o buraco largo pulando.
  criarInimigos: (groundY) => [
    const EnemySpawn(500),
    const EnemySpawn(1350),
    EnemySpawn(2115, y: groundY - 200 - 64),
  ],
);
