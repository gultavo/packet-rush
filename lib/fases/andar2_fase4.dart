import 'dart:ui';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 2 — Fase 4.
///
/// Primeira fase do andar a explorar a verticalidade do mapa: em vez de só
/// cruzar buracos na horizontal, o jogador sobe uma torre de 5 plataformas
/// até 360px de altura (mais que o dobro do pico da Fase 3), atravessa uma
/// "ponte" no topo guardada por um inimigo, e desce de volta ao chão. Um erro
/// em qualquer trecho da torre é queda livre até o chão — sem chão
/// intermediário para amortecer.
///
/// Estrutura (da esquerda para a direita):
///  1. Zona inicial no chão, com o primeiro inimigo (x=450).
///  2. Um buraco direto de 170px (sem plataforma) — o maior salto direto no
///     plano que o pulo normal aguenta com folga.
///  3. Zona intermediária no chão, com o segundo inimigo (x=1350).
///  4. A torre: um buraco longo (1600 → 2700) sem chão nenhum, atravessado
///     por 5 plataformas — sobe, sobe, sobe (até o topo), ponte no topo (com
///     o terceiro inimigo) e desce. Cada salto fica entre 30 e 120px, mas a
///     sequência é longa e qualquer erro é queda livre até o chão.
///  5. Trecho final no chão, com o quarto e quinto inimigos (x=2900 e
///     x=3400), guardando o caminho até o portal.
///
/// Tamanho horizontal próprio: a arte desta fase é 1983 × 793 px. O mapa
/// acompanha a largura da arte (largura da arte × 2 ≈ 3966), e o cenário é
/// travado na borda da imagem para nunca mostrar faixa branca.
final faseAndar2Fase4 = Fase(
  andar: 2,
  numero: 4,
  level: LevelData(
    size: const Size(3966, 600), // tamanho do mapa (largura da arte × 2, altura do chão)
    offset: const Offset(800, 0), // deslocamento inicial do mapa para a direita, para que o jogador nasça no início real do mapa (x=50) e não no canto esquerdo da tela
    backgroundImage: 'lib/Images/Fases/Andar2/Fase2-4.png',
    larguraDoMapa: 3966,
    imgWidth: 1983,
    imgHeight: 793,
  ),

  // Chão em três pedaços: zona inicial, zona intermediária e zona final, com
  // o buraco da torre entre a segunda e a terceira (sem chão nenhum ali — só
  // as 5 plataformas em degrau).
  groundSegments: const [
    GroundSegment(double.negativeInfinity, 900),
    GroundSegment(1070, 1600),
    GroundSegment(2700, double.infinity),
  ],

  // A torre: 3 degraus subindo (até 360px de altura), uma ponte no topo e
  // 1 degrau descendo, tudo relativo ao chão (groundY). Vãos conferidos
  // contra a tabela de alcance do pulo normal (ver fase.dart):
  //  - chão 1600 → degrau 1: vão 120, subida 110 (alcance 180) — folga 60.
  //  - degrau 1 → degrau 2: vão 100, subida 130 (alcance 160) — folga 60.
  //  - degrau 2 → degrau 3: vão 100, subida 120 (alcance 160) — folga 60.
  //  - degrau 3 → ponte: vão 100, no plano (alcance 220) — folga de sobra.
  //  - ponte → degrau final: vão 100, descida de 160 — folga de sobra.
  //  - degrau final → chão 2700: vão 30, descida de 200 — folga de sobra.
  criarPlataformas: (groundY) => [
    Objects(x: 1720, y: groundY - 110, width: 110), // degrau 1 (sobe)
    Objects(x: 1930, y: groundY - 240, width: 110), // degrau 2 (sobe mais)
    Objects(x: 2140, y: groundY - 360, width: 110), // degrau 3 (topo)
    Objects(x: 2350, y: groundY - 360, width: 110), // ponte no topo
    Objects(x: 2560, y: groundY - 200, width: 110), // degrau final (desce)
  ],

  // 5 inimigos: dois no chão antes da torre, um na ponte do topo (o mais
  // arriscado — cai, é queda livre até o chão) e dois guardando o trecho
  // final antes do portal.
  criarInimigos: (groundY) => [
    const EnemySpawn(450),
    const EnemySpawn(1350),
    EnemySpawn(2405, y: groundY - 360 - 64),
    const EnemySpawn(2900),
    const EnemySpawn(3400),
  ],
);
