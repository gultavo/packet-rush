import 'dart:ui';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 1 — Fase 2.
///
/// Um degrau mais difícil que a Fase 1: mais inimigos (3) e saltos mais
/// largos (até 180px, perto do limite confortável do pulo normal).
///
/// Estrutura (da esquerda para a direita):
///  1. Zona inicial no chão. O jogador nasce no início real do mapa
///     (x=50, padrão do motor) e tem um trecho livre para se orientar
///     antes do primeiro inimigo (x=400).
///  2. Um buraco direto de 180px (sem plataforma) — mais largo que qualquer
///     salto da Fase 1, exige um pulo bem cronometrado.
///  3. Zona intermediária no chão, com o segundo inimigo (x=1300).
///  4. Um buraco largo (1700 → 2650) atravessado por 3 plataformas em
///     degrau. O terceiro inimigo fica em cima da plataforma do meio (a mais
///     alta), obrigando o jogador a lidar com ele em pleno ar.
///  5. Trecho final no chão até o portal.
///
/// Tamanho horizontal próprio: a arte desta fase é 1774 × 887 px. O mapa
/// acompanha a largura da arte (largura da arte × 2 ≈ 3550), e o cenário é
/// travado na borda da imagem para nunca mostrar faixa branca.
final faseAndar1Fase2 = Fase(
  andar: 1,
  numero: 2,
  level: LevelData(
    size: const Size(3550, 600),
    offset: const Offset(800, 0),
    backgroundImage: 'lib/Images/Fases/Andar1/Fase1-2.png',
    larguraDoMapa: 3550,
    imgWidth: 1774,
    imgHeight: 887,
  ),

  // Chão em três pedaços: zona inicial, zona intermediária e zona final,
  // com dois buracos entre eles (o segundo, bem mais largo, exige as
  // plataformas para ser atravessado).
  groundSegments: const [
    GroundSegment(double.negativeInfinity, 850),
    GroundSegment(1030, 1700),
    GroundSegment(2650, double.infinity),
  ],

  // 3 plataformas em degrau (sobe, sobe mais, desce) atravessando o segundo
  // buraco, posicionadas relativas ao chão (groundY).
  //
  // O salto degrau 1 → degrau 2 era IMPOSSÍVEL com o pulo normal: subida de
  // 120px exige que o pouso aconteça no 8º tick do arco, quando o jogador só
  // avançou 160px — e o vão era exatamente 160px (o motor exige
  // `right > plat.left`, estrito, então errava por zero). Só passava com o
  // DEV mode ligado, que usa um pulo bem maior. Agora o degrau 2 está mais
  // perto e um pouco mais baixo: vão de 110px para 160px de alcance.
  criarPlataformas: (groundY) => [
    Objects(x: 1850, y: groundY - 30, width: 130), // degrau 1 (baixo)
    Objects(x: 2090, y: groundY - 140, width: 130), // degrau 2 (topo)
    Objects(x: 2400, y: groundY - 30, width: 130), // degrau 3 (desce)
  ],

  // 3 inimigos: dois no chão (início e meio da fase) e um em cima da
  // plataforma mais alta do segundo buraco, atirando enquanto o jogador
  // tenta cruzar pulando.
  criarInimigos: (groundY) => [
    const EnemySpawn(400),
    const EnemySpawn(1300),
    EnemySpawn(2123, y: groundY - 140 - 64),
  ],
);
