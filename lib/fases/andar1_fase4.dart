import 'dart:ui';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 1 — Fase 4.
///
/// Primeira fase a explorar a verticalidade do mapa: em vez de só cruzar
/// buracos na horizontal, o jogador sobe uma torre de 5 plataformas até
/// 360px de altura (mais que o dobro do pico da Fase 3), atravessa uma
/// "ponte" no topo guardada por um inimigo, e desce de volta ao chão. Um
/// erro em qualquer trecho da torre é queda livre até o chão — sem chão
/// intermediário para amortecer.
///
/// Estrutura (da esquerda para a direita):
///  1. Zona inicial no chão, com o primeiro inimigo (x=450).
///  2. Um buraco direto de 170px (sem plataforma) — o maior salto direto
///     no plano que o pulo normal aguenta com folga.
///  3. Zona intermediária no chão, com o segundo inimigo (x=1350).
///  4. A torre: um buraco longo (1600 → 2700) sem chão nenhum,
///     atravessado por 5 plataformas — sobe, sobe, sobe (até o topo),
///     ponte no topo (com o terceiro inimigo) e desce. Cada salto fica
///     entre 100 e 130px, mas a sequência é longa e qualquer erro é queda
///     livre até o chão.
///  5. Trecho final no chão, com o quarto e quinto inimigos (x=2900 e
///     x=3400), guardando o caminho até o portal.
///
/// Tamanho horizontal próprio: a arte desta fase é 2172 × 724 px (bem mais
/// larga, aspecto 3.0). O mapa acompanha a largura da arte (largura × 2 ≈
/// 4340), e o cenário é travado na borda da imagem para nunca mostrar
/// faixa branca.
final faseAndar1Fase4 = Fase(
  andar: 1,
  numero: 4,
  level: LevelData(
    size: const Size(4340, 600),
    offset: const Offset(800, 0),
    backgroundImage: 'lib/Images/Fases/Andar1/Fase1-4.png',
    larguraDoMapa: 4340,
    imgWidth: 2172,
    imgHeight: 724,
  ),

  // Chão em três pedaços: zona inicial, zona intermediária e zona final,
  // com o buraco da torre entre a segunda e a terceira (sem chão nenhum
  // ali — só as 5 plataformas em degrau).
  // O buraco direto era de 200px, contra um alcance máximo de 220px no
  // plano — 20px de folga, ou seja, exigia o pulo perfeito no pixel. Agora
  // são 170px, com folga de 50px. A torre em si não mudou: todos os seus
  // saltos já cabiam no pulo normal com folga.
  groundSegments: const [
    GroundSegment(double.negativeInfinity, 900),
    GroundSegment(1070, 1600),
    GroundSegment(2700, double.infinity),
  ],

  // A torre: 3 degraus subindo (até 360px de altura), uma ponte no topo e
  // 1 degrau descendo, tudo posicionado relativo ao chão (groundY) para
  // funcionar em qualquer tamanho de tela.
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
