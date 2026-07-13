import 'dart:ui';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 4 — Fase 1.
///
/// Abertura do Andar 4 (Camada de Transporte, "As Rotas Confiáveis"). Como toda
/// primeira fase de um andar, ela reintroduz os três elementos básicos do jogo
/// num cenário novo — inimigos, plataformas e buracos no chão (cair neles custa
/// uma vida). Mas por ser o andar mais avançado até aqui, a abertura sobe mais
/// um degrau em relação à Fase 1 do Andar 3: aquela tinha um arco de 3
/// plataformas com UM inimigo no alto; esta troca o arco por uma TORRE de 4
/// plataformas (sobe, topo, ponte, desce) que sobe até 220px — a verticalidade
/// que é a marca do andar — e coloca DOIS inimigos em pleno ar sobre ela (topo
/// e ponte), cobrando combate aéreo em dois pontos durante a mesma travessia.
///
/// Estrutura (da esquerda para a direita):
///  1. Zona inicial no chão, com o primeiro inimigo (x=500) e um trecho livre
///     para o jogador se orientar.
///  2. Um salto direto simples de 170px (sem plataforma) — o mesmo obstáculo de
///     aquecimento da abertura do Andar 3, mas um pouco mais largo. No plano,
///     exige só um pulo bem cronometrado.
///  3. Zona intermediária no chão, com o segundo inimigo (x=1500).
///  4. Um buraco largo (1900 → 2900) sem chão nenhum, atravessado por uma TORRE
///     de 4 plataformas em arco alto (sobe, topo, ponte, desce). As plataformas
///     do topo ficam a 220px (contra os 200px do arco do Andar 3) e são mais
///     estreitas (110px, contra 130px). O terceiro e o quarto inimigos ficam em
///     cima da torre — um no topo e um na ponte —, atirando de dois ângulos
///     enquanto o jogador tenta cruzar pulando.
///  5. Zona final no chão, com um trecho livre até o portal.
///
/// ## Orçamento do pulo (ver a tabela em [Fase])
///
/// Todos os vãos abaixo cabem no pulo NORMAL, sem depender do DEV mode:
///  - chão 950 → chão 1120: vão 170, no plano (alcance 220) — folga 50.
///  - chão 1900 → degrau 1: vão 120, subida 100 (alcance 180) — folga 60.
///  - degrau 1 → degrau 2 (topo): vão 100, subida 120 (alcance 160) — folga 60.
///  - degrau 2 → ponte: vão 100, no plano (alcance 220) — folga de sobra.
///  - ponte → degrau 3 (desce): vão 100, descida de 120 — folga de sobra.
///  - degrau 3 → chão 2900: vão 140, descida de 100 — folga de sobra.
///
/// Tamanho horizontal próprio: a arte desta fase é 1983 × 793 px (aspecto 2.5).
/// O mapa acompanha a largura da arte (largura × 2 ≈ 3970), e o cenário é
/// travado na borda da imagem para nunca mostrar faixa branca.
final faseAndar4Fase1 = Fase(
  andar: 4,
  numero: 1,
  level: LevelData(
    size: const Size(3970, 600),
    offset: const Offset(800, 0),
    backgroundImage: 'lib/Images/Fases/Andar4/Fase4-1.png',
    larguraDoMapa: 3970,
    imgWidth: 1983,
    imgHeight: 793,
  ),

  // Chão em três pedaços: zona inicial, zona intermediária e zona final, com
  // dois buracos entre eles. O primeiro (950 → 1120) é um salto direto simples;
  // o segundo (1900 → 2900), bem mais largo, exige a torre de plataformas.
  groundSegments: const [
    GroundSegment(double.negativeInfinity, 950),
    GroundSegment(1120, 1900),
    GroundSegment(2900, double.infinity),
  ],

  // A torre de 4 plataformas (sobe, topo, ponte, desce) que atravessa o buraco
  // largo, posicionada relativa ao chão (groundY) para funcionar em qualquer
  // tamanho de tela. Sobe mais alto (220px) e é mais estreita (110px) que o
  // arco do Andar 3, exigindo pouso mais preciso. Vãos conferidos contra a
  // tabela de alcance do pulo normal (ver fase.dart):
  //  - chão 1900 → degrau 1: vão 120, subida 100 (alcance 180) — folga 60.
  //  - degrau 1 → degrau 2 (topo): vão 100, subida 120 (alcance 160) — folga 60.
  //  - degrau 2 → ponte: vão 100, no plano (alcance 220) — folga de sobra.
  //  - ponte → degrau 3 (desce): vão 100, descida de 120 — folga de sobra.
  //  - degrau 3 → chão 2900: vão 140, descida de 100 — folga de sobra.
  criarPlataformas: (groundY) => [
    Objects(x: 2020, y: groundY - 100, width: 110), // degrau 1 (sobe)
    Objects(x: 2230, y: groundY - 220, width: 110), // degrau 2 (topo)
    Objects(x: 2440, y: groundY - 220, width: 110), // ponte no topo
    Objects(x: 2650, y: groundY - 100, width: 110), // degrau 3 (desce)
  ],

  // 4 inimigos: dois no chão (início e zona intermediária, entre os dois
  // buracos) e dois em cima da torre — um no topo e um na ponte —, atirando de
  // dois ângulos enquanto o jogador cruza o buraco largo pulando.
  criarInimigos: (groundY) => [
    const EnemySpawn(500),
    const EnemySpawn(1500),
    EnemySpawn(2285, y: groundY - 220 - 64), // em cima do topo
    EnemySpawn(2495, y: groundY - 220 - 64), // em cima da ponte
  ],
);
