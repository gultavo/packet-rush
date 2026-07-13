import 'dart:ui';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 4 — Fase 4.
///
/// A fase da verticalidade do andar, e um degrau acima da Fase 4 dos Andares 1,
/// 2 e 3: mantém a assinatura da "quarta fase" — o jogador sobe uma TORRE de
/// plataformas sobre o vazio, cruza uma ponte guardada no topo e desce, com
/// qualquer erro sendo queda livre até o chão. Por ser o andar mais avançado,
/// leva a torre ao ápice do jogo: 560px de pico (contra os 470px da Fase 4 do
/// Andar 3 e os 360px da do Andar 2), com 5 degraus de subida (contra 4) e uma
/// descida em DOIS degraus. E o combate deixa de ser só o topo: a descida
/// inteira é contestada — ponte, primeiro e segundo degrau de descida —, num
/// total de 7 inimigos (contra os 6 do Andar 3).
///
/// Estrutura (da esquerda para a direita):
///  1. Zona inicial no chão, com o primeiro inimigo (x=450).
///  2. Um salto direto de 170px (sem plataforma) — o maior salto direto no
///     plano que o pulo normal aguenta com folga.
///  3. Zona intermediária no chão, com o segundo inimigo (x=1350).
///  4. A torre: um buraco longo (1600 → 3400) sem chão nenhum, atravessado por
///     8 plataformas — 5 degraus subindo (até 560px de altura), uma ponte no
///     topo e 2 degraus descendo. A subida é puro platforming sobre o vazio
///     (qualquer erro é queda livre até o chão). A crista e toda a descida são
///     contestadas por três inimigos: um na ponte, um no primeiro degrau de
///     descida e um no segundo, atirando enquanto o jogador desce a torre.
///  5. Trecho final no chão, com o sexto e sétimo inimigos (x=3600 e x=3850),
///     guardando o caminho até o portal.
///
/// ## Orçamento do pulo (ver a tabela em [Fase])
///
/// Todos os vãos abaixo cabem no pulo NORMAL, sem depender do DEV mode:
///  - chão 900 → chão 1070: vão 170, no plano (alcance 220) — folga 50.
///  - chão 1600 → degrau 1: vão 120, subida 100 (alcance 180) — folga 60.
///  - degrau 1 → degrau 2: vão 100, subida 120 (alcance 160) — folga 60.
///  - degrau 2 → degrau 3: vão 100, subida 120 (alcance 160) — folga 60.
///  - degrau 3 → degrau 4: vão 100, subida 120 (alcance 160) — folga 60.
///  - degrau 4 → degrau 5 (topo): vão 100, subida 100 (alcance 180) — folga 80.
///  - degrau 5 → ponte: vão 100, no plano (alcance 220) — folga de sobra.
///  - ponte → descida 1: vão 100, descida de 180 — folga de sobra.
///  - descida 1 → descida 2: vão 100, descida de 190 — folga de sobra.
///  - descida 2 → chão 3400: vão 100, descida de 190 — folga de sobra.
///
/// Tamanho horizontal próprio: a arte desta fase é 2172 × 724 px (larga,
/// aspecto 3.0). O mapa acompanha a largura da arte (largura × 2 ≈ 4340), e o
/// cenário é travado na borda da imagem para nunca mostrar faixa branca.
final faseAndar4Fase4 = Fase(
  andar: 4,
  numero: 4,
  level: LevelData(
    size: const Size(4340, 600),
    offset: const Offset(800, 0),
    backgroundImage: 'lib/Images/Fases/Andar4/Fase4-4.png',
    larguraDoMapa: 4340,
    imgWidth: 2172,
    imgHeight: 724,
  ),

  // Chão em três pedaços: zona inicial, zona intermediária e zona final, com
  // o buraco da torre entre a segunda e a terceira (sem chão nenhum ali — só as
  // 8 plataformas). O primeiro buraco (900 → 1070) é o salto direto de 170px.
  groundSegments: const [
    GroundSegment(double.negativeInfinity, 900),
    GroundSegment(1070, 1600),
    GroundSegment(3400, double.infinity),
  ],

  // A torre: 5 degraus subindo (até 560px de altura, o pico mais alto do jogo,
  // acima dos 470px do Andar 3), uma ponte no topo e 2 degraus descendo, tudo
  // relativo ao chão (groundY). Vãos conferidos contra a tabela de alcance do
  // pulo normal (ver fase.dart):
  //  - chão 1600 → degrau 1: vão 120, subida 100 (alcance 180) — folga 60.
  //  - degrau 1 → degrau 2: vão 100, subida 120 (alcance 160) — folga 60.
  //  - degrau 2 → degrau 3: vão 100, subida 120 (alcance 160) — folga 60.
  //  - degrau 3 → degrau 4: vão 100, subida 120 (alcance 160) — folga 60.
  //  - degrau 4 → degrau 5 (topo): vão 100, subida 100 (alcance 180) — folga 80.
  //  - degrau 5 → ponte: vão 100, no plano (alcance 220) — folga de sobra.
  //  - ponte → descida 1: vão 100, descida de 180 — folga de sobra.
  //  - descida 1 → descida 2: vão 100, descida de 190 — folga de sobra.
  //  - descida 2 → chão 3400: vão 100, descida de 190 — folga de sobra.
  criarPlataformas: (groundY) => [
    Objects(x: 1720, y: groundY - 100, width: 110), // degrau 1 (sobe)
    Objects(x: 1930, y: groundY - 220, width: 110), // degrau 2 (sobe mais)
    Objects(x: 2140, y: groundY - 340, width: 110), // degrau 3 (sobe mais)
    Objects(x: 2350, y: groundY - 460, width: 110), // degrau 4 (sobe mais)
    Objects(x: 2560, y: groundY - 560, width: 110), // degrau 5 (topo)
    Objects(x: 2770, y: groundY - 560, width: 110), // ponte no topo
    Objects(x: 2980, y: groundY - 380, width: 110), // descida 1
    Objects(x: 3190, y: groundY - 190, width: 110), // descida 2
  ],

  // 7 inimigos: dois no chão antes da torre, três contestando a crista e a
  // descida (ponte, descida 1 e descida 2 — os mais arriscados, cair é queda
  // livre até o chão) e dois guardando o trecho final antes do portal.
  criarInimigos: (groundY) => [
    const EnemySpawn(450),
    const EnemySpawn(1350),
    EnemySpawn(2825, y: groundY - 560 - 64), // na ponte do topo
    EnemySpawn(3035, y: groundY - 380 - 64), // no primeiro degrau de descida
    EnemySpawn(3245, y: groundY - 190 - 64), // no segundo degrau de descida
    const EnemySpawn(3600),
    const EnemySpawn(3850),
  ],
);
