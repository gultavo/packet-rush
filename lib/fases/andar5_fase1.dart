import 'dart:ui';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 5 — Fase 1.
///
/// Abertura do Andar 5, o andar mais avançado do jogo. Como toda primeira fase
/// de um andar, ela reintroduz os três elementos básicos — inimigos, plataformas
/// e buracos no chão (cair neles custa uma vida) — num cenário novo. Mas por
/// coroar a progressão, ela sobe mais um degrau em relação à Fase 1 do Andar 4:
/// aquela troca o arco do Andar 3 por uma TORRE de 4 plataformas (sobe, topo,
/// ponte, desce) com DOIS inimigos aéreos; esta ESTICA o topo dessa torre num
/// corredor aéreo mais longo — 5 plataformas (sobe, topo, ponte1, ponte2, desce)
/// que se mantêm a 220px por dois vãos seguidos — e o povoa com TRÊS inimigos em
/// pleno ar (topo, ponte1 e ponte2), cobrando combate aéreo contínuo ao longo de
/// toda a travessia, e não só em dois pontos. São 5 inimigos no total (contra os
/// 4 do Andar 4), sendo 3 deles suspensos.
///
/// Estrutura (da esquerda para a direita):
///  1. Zona inicial no chão, com o primeiro inimigo (x=500) e um trecho livre
///     para o jogador se orientar.
///  2. Um salto direto de 180px (sem plataforma) — o maior salto direto que o
///     pulo normal aguenta com folga, o obstáculo de aquecimento do andar.
///  3. Zona intermediária no chão, com o segundo inimigo (x=1500).
///  4. Um buraco largo (1900 → 3000) sem chão nenhum, atravessado pela TORRE
///     ESTICADA de 5 plataformas em arco alto (sobe, topo, ponte1, ponte2,
///     desce). O topo se mantém a 220px por dois vãos seguidos (ponte1 e ponte2),
///     e o terceiro, quarto e quinto inimigos ficam em cima dele — topo, ponte1 e
///     ponte2 —, atirando de três ângulos enquanto o jogador cruza pulando.
///  5. Zona final no chão, com um trecho livre até o portal.
///
/// ## Orçamento do pulo (ver a tabela em [Fase])
///
/// Todos os vãos abaixo cabem no pulo NORMAL, sem depender do DEV mode:
///  - chão 950 → chão 1130: vão 180, no plano (alcance 220) — folga 40 (o salto
///    direto mais largo que o pulo normal aguenta, bem cronometrado).
///  - chão 1900 → degrau 1: vão 120, subida 100 (alcance 180) — folga 60.
///  - degrau 1 → degrau 2 (topo): vão 100, subida 120 (alcance 160) — folga 60.
///  - degrau 2 → ponte 1: vão 100, no plano (alcance 220) — folga de sobra.
///  - ponte 1 → ponte 2: vão 100, no plano (alcance 220) — folga de sobra.
///  - ponte 2 → degrau 3 (desce): vão 100, descida de 120 — folga de sobra.
///  - degrau 3 → chão 3000: vão 30, descida de 100 — folga de sobra.
///
/// Tamanho horizontal próprio: a arte desta fase é 1983 × 793 px (aspecto 2.5).
/// O mapa acompanha a largura da arte (largura × 2 ≈ 3970), e o cenário é
/// travado na borda da imagem para nunca mostrar faixa branca.
final faseAndar5Fase1 = Fase(
  andar: 5,
  numero: 1,
  level: LevelData(
    size: const Size(3970, 600),
    offset: const Offset(800, 0),
    backgroundImage: 'lib/Images/Fases/Andar5/Fase5-1.png',
    larguraDoMapa: 3970,
    imgWidth: 1983,
    imgHeight: 793,
  ),

  // Chão em três pedaços, com dois buracos entre eles: o salto direto de
  // aquecimento (950 → 1130) e o buraco largo da torre esticada (1900 → 3000).
  groundSegments: const [
    GroundSegment(double.negativeInfinity, 950),
    GroundSegment(1130, 1900),
    GroundSegment(3000, double.infinity),
  ],

  // A torre ESTICADA de 5 plataformas (sobe, topo, ponte1, ponte2, desce) que
  // atravessa o buraco largo, posicionada relativa ao chão (groundY) para
  // funcionar em qualquer tamanho de tela. O topo se mantém a 220px por dois
  // vãos seguidos (ponte1 e ponte2), estendendo o corredor aéreo do Andar 4.
  // Todas as plataformas são estreitas (110px), exigindo pouso preciso. Vãos
  // conferidos contra a tabela de alcance do pulo normal (ver fase.dart):
  //  - chão 1900 → degrau 1: vão 120, subida 100 (alcance 180) — folga 60.
  //  - degrau 1 → degrau 2 (topo): vão 100, subida 120 (alcance 160) — folga 60.
  //  - degrau 2 → ponte 1: vão 100, no plano (alcance 220) — folga de sobra.
  //  - ponte 1 → ponte 2: vão 100, no plano (alcance 220) — folga de sobra.
  //  - ponte 2 → degrau 3 (desce): vão 100, descida de 120 — folga de sobra.
  //  - degrau 3 → chão 3000: vão 30, descida de 100 — folga de sobra.
  criarPlataformas: (groundY) => [
    Objects(x: 2020, y: groundY - 100, width: 110), // degrau 1 (sobe)
    Objects(x: 2230, y: groundY - 220, width: 110), // degrau 2 (topo)
    Objects(x: 2440, y: groundY - 220, width: 110), // ponte 1 no topo
    Objects(x: 2650, y: groundY - 220, width: 110), // ponte 2 no topo
    Objects(x: 2860, y: groundY - 100, width: 110), // degrau 3 (desce)
  ],

  // 5 inimigos: dois no chão (início e zona intermediária, entre os dois
  // buracos) e três em cima da torre esticada — topo, ponte 1 e ponte 2 —,
  // atirando de três ângulos ao longo de toda a travessia do buraco largo.
  criarInimigos: (groundY) => [
    const EnemySpawn(500),
    const EnemySpawn(1500),
    EnemySpawn(2285, y: groundY - 220 - 64), // em cima do topo
    EnemySpawn(2495, y: groundY - 220 - 64), // em cima da ponte 1
    EnemySpawn(2705, y: groundY - 220 - 64), // em cima da ponte 2
  ],
);
