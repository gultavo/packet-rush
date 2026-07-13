import 'dart:ui';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 3 — Fase 4.
///
/// A fase da verticalidade do andar, e um degrau acima da Fase 4 dos Andares 1
/// e 2: em vez de só cruzar buracos na horizontal, o jogador sobe uma TORRE de
/// plataformas onde qualquer erro é queda livre até o chão. Por ser um andar
/// mais avançado, a torre é mais alta que a do template — 470px de pico (contra
/// 360px), com 4 degraus de subida em vez de 3 — e o combate no topo é
/// contestado em DOIS pontos (a ponte e o degrau de descida), com 6 inimigos no
/// total (contra os 5 do template).
///
/// Estrutura (da esquerda para a direita):
///  1. Zona inicial no chão, com o primeiro inimigo (x=450).
///  2. Um salto direto de 170px (sem plataforma) — o maior salto direto no
///     plano que o pulo normal aguenta com folga.
///  3. Zona intermediária no chão, com o segundo inimigo (x=1350).
///  4. A torre: um buraco longo (1600 → 2950) sem chão nenhum, atravessado por
///     6 plataformas — 4 degraus subindo (até 470px de altura), uma ponte no
///     topo e 1 degrau descendo. A subida é puro platforming sobre o vazio
///     (qualquer erro é queda livre até o chão). O topo é contestado por dois
///     inimigos: um na ponte e um no degrau de descida, atirando enquanto o
///     jogador cruza a crista e começa a descer.
///  5. Trecho final no chão, com o quinto e sexto inimigos (x=3300 e x=3750),
///     guardando o caminho até o portal.
///
/// ## Orçamento do pulo (ver a tabela em [Fase])
///
/// Todos os vãos abaixo cabem no pulo NORMAL, sem depender do DEV mode:
///  - chão 900 → chão 1070: vão 170, no plano (alcance 220) — folga 50.
///  - chão 1600 → degrau 1: vão 120, subida 100 (alcance 180) — folga 60.
///  - degrau 1 → degrau 2: vão 100, subida 130 (alcance 160) — folga 60.
///  - degrau 2 → degrau 3: vão 100, subida 130 (alcance 160) — folga 60.
///  - degrau 3 → degrau 4 (topo): vão 100, subida 110 (alcance 160) — folga 60.
///  - degrau 4 → ponte: vão 100, no plano (alcance 220) — folga de sobra.
///  - ponte → degrau final: vão 100, descida de 190 — folga de sobra.
///  - degrau final → chão 2950: vão 70, descida de 280 — folga de sobra.
///
/// Tamanho horizontal próprio: a arte desta fase é 2172 × 724 px (larga,
/// aspecto 3.0). O mapa acompanha a largura da arte (largura × 2 ≈ 4340), e o
/// cenário é travado na borda da imagem para nunca mostrar faixa branca.
final faseAndar3Fase4 = Fase(
  andar: 3,
  numero: 4,
  level: LevelData(
    size: const Size(4340, 600),
    offset: const Offset(800, 0),
    backgroundImage: 'lib/Images/Fases/Andar3/Fase3-4.png',
    larguraDoMapa: 4340,
    imgWidth: 2172,
    imgHeight: 724,
  ),

  // Chão em três pedaços: zona inicial, zona intermediária e zona final, com
  // o buraco da torre entre a segunda e a terceira (sem chão nenhum ali — só as
  // 6 plataformas em degrau). O primeiro buraco (900 → 1070) é o salto direto
  // de 170px.
  groundSegments: const [
    GroundSegment(double.negativeInfinity, 900),
    GroundSegment(1070, 1600),
    GroundSegment(2950, double.infinity),
  ],

  // A torre: 4 degraus subindo (até 470px de altura, mais alta que os 360px do
  // template), uma ponte no topo e 1 degrau descendo, tudo relativo ao chão
  // (groundY). Vãos conferidos contra a tabela de alcance do pulo normal (ver
  // fase.dart):
  //  - chão 1600 → degrau 1: vão 120, subida 100 (alcance 180) — folga 60.
  //  - degrau 1 → degrau 2: vão 100, subida 130 (alcance 160) — folga 60.
  //  - degrau 2 → degrau 3: vão 100, subida 130 (alcance 160) — folga 60.
  //  - degrau 3 → degrau 4: vão 100, subida 110 (alcance 160) — folga 60.
  //  - degrau 4 → ponte: vão 100, no plano (alcance 220) — folga de sobra.
  //  - ponte → degrau final: vão 100, descida de 190 — folga de sobra.
  //  - degrau final → chão 2950: vão 70, descida de 280 — folga de sobra.
  criarPlataformas: (groundY) => [
    Objects(x: 1720, y: groundY - 100, width: 110), // degrau 1 (sobe)
    Objects(x: 1930, y: groundY - 230, width: 110), // degrau 2 (sobe mais)
    Objects(x: 2140, y: groundY - 360, width: 110), // degrau 3 (sobe mais)
    Objects(x: 2350, y: groundY - 470, width: 110), // degrau 4 (topo)
    Objects(x: 2560, y: groundY - 470, width: 110), // ponte no topo
    Objects(x: 2770, y: groundY - 280, width: 110), // degrau final (desce)
  ],

  // 6 inimigos: dois no chão antes da torre, dois contestando o topo (um na
  // ponte e um no degrau de descida — os mais arriscados, cair é queda livre
  // até o chão) e dois guardando o trecho final antes do portal.
  criarInimigos: (groundY) => [
    const EnemySpawn(450),
    const EnemySpawn(1350),
    EnemySpawn(2615, y: groundY - 470 - 64),
    EnemySpawn(2825, y: groundY - 280 - 64),
    const EnemySpawn(3300),
    const EnemySpawn(3750),
  ],
);
