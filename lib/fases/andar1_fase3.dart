import 'dart:ui';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 1 — Fase 3.
///
/// Mais um degrau de dificuldade acima da Fase 2: 4 inimigos e saltos mais
/// largos (até 190px — o maior salto direto até agora, perto do limite
/// confortável do pulo normal), além de uma travessia com plataformas mais
/// estreitas (100px, contra os 130px da Fase 2) exigindo pouso mais preciso.
///
/// Estrutura (da esquerda para a direita):
///  1. Zona inicial no chão. Jogador nasce no início (x=50, padrão do
///     motor) e tem um trecho livre antes do primeiro inimigo (x=400).
///  2. Um buraco direto de 170px (sem plataforma) — o maior salto direto
///     da fase.
///  3. Zona intermediária no chão, com o segundo inimigo (x=1250).
///  4. Um buraco largo (1500 → 2200) atravessado por 2 plataformas
///     estreitas (100px) em degrau (sobe, desce), com saltos de até 180px
///     cada. O terceiro inimigo fica em cima da plataforma mais alta,
///     obrigando o jogador a lidar com ele em pleno ar.
///  5. Trecho final no chão, com o quarto inimigo (x=2400), guardando o
///     caminho até o portal.
///
/// Tamanho horizontal próprio: a arte desta fase é 1774 × 887 px. O mapa
/// acompanha a largura da arte (largura da arte × 2 ≈ 3550), e o cenário é
/// travado na borda da imagem para nunca mostrar faixa branca.
final faseAndar1Fase3 = Fase(
  andar: 1,
  numero: 3,
  level: LevelData(
    size: const Size(3550, 600),
    offset: const Offset(800, 0),
    backgroundImage: 'lib/Images/Fases/Andar1/Fase1-3.png',
    larguraDoMapa: 3550,
    imgWidth: 1774,
    imgHeight: 887,
  ),

  // Chão em três pedaços: zona inicial, zona intermediária e zona final,
  // com dois buracos entre eles (o segundo, mais largo, exige as duas
  // plataformas estreitas para ser atravessado).
  groundSegments: const [
    GroundSegment(double.negativeInfinity, 800),
    GroundSegment(970, 1500),
    GroundSegment(2200, double.infinity),
  ],

  // 2 plataformas estreitas (100px, mais justas que as da Fase 2) em
  // degrau (sobe, desce) atravessando o segundo buraco, posicionadas
  // relativas ao chão (groundY).
  //
  // O salto degrau 1 → degrau 2 era IMPOSSÍVEL com o pulo normal: subir
  // 110px obriga o pouso a acontecer no 8º tick do arco (alcance de 160px),
  // mas o vão era de 180px. Só passava com o DEV mode ligado. Agora o vão é
  // de 130px, com o degrau 2 um pouco mais baixo.
  criarPlataformas: (groundY) => [
    Objects(x: 1650, y: groundY - 30, width: 100), // degrau 1 (baixo)
    Objects(x: 1880, y: groundY - 130, width: 100), // degrau 2 (topo)
  ],

  // 4 inimigos: dois no chão antes do buraco duplo, um em cima da
  // plataforma mais alta (atirando em pleno ar) e um guardando o trecho
  // final antes do portal.
  criarInimigos: (groundY) => [
    const EnemySpawn(400),
    const EnemySpawn(1250),
    EnemySpawn(1898, y: groundY - 130 - 64),
    const EnemySpawn(2400),
  ],
);
