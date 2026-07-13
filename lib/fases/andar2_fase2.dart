import 'dart:ui';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 2 — Fase 2.
///
/// Um degrau mais difícil que a Fase 1 do andar: mais inimigos (3), um salto
/// direto largo (180px, sem plataforma) e um inimigo posicionado no topo da
/// travessia, obrigando o jogador a lidar com ele em pleno ar.
///
/// Estrutura (da esquerda para a direita):
///  1. Zona inicial no chão. O jogador nasce no início real do mapa (x=50,
///     padrão do motor) e tem um trecho livre antes do primeiro inimigo
///     (x=400).
///  2. Um buraco direto de 180px (sem plataforma) — mais largo que qualquer
///     salto da Fase 1, exige um pulo bem cronometrado.
///  3. Zona intermediária no chão, com o segundo inimigo (x=1400).
///  4. Um buraco largo (1800 → 2720) atravessado por 3 plataformas em degrau
///     (sobe, sobe, desce). O terceiro inimigo fica em cima da plataforma do
///     meio (a mais alta), atirando enquanto o jogador tenta cruzar pulando.
///  5. Trecho final no chão até o portal.
///
/// Tamanho horizontal próprio: a arte desta fase é 1983 × 793 px. O mapa
/// acompanha a largura da arte (largura da arte × 2 ≈ 3966), e o cenário é
/// travado na borda da imagem para nunca mostrar faixa branca.
final faseAndar2Fase2 = Fase(
  andar: 2,
  numero: 2,
  level: LevelData(
    size: const Size(3966, 600), // tamanho do mapa (largura da arte × 2, altura do chão)
    offset: const Offset(800, 0), // deslocamento inicial do mapa para a direita, para que o jogador nasça no início real do mapa (x=50) e não no canto esquerdo da tela
    backgroundImage: 'lib/Images/Fases/Andar2/Fase2-2.png',
    larguraDoMapa: 3966,
    imgWidth: 1983,
    imgHeight: 793,
  ),

  // Chão em três pedaços: zona inicial, zona intermediária e zona final, com
  // dois buracos entre eles (o segundo, bem mais largo, exige as plataformas
  // para ser atravessado).
  groundSegments: const [
    GroundSegment(double.negativeInfinity, 900),
    GroundSegment(1080, 1800),
    GroundSegment(2720, double.infinity),
  ],

  // 3 plataformas em degrau (sobe, sobe mais, desce) atravessando o segundo
  // buraco, posicionadas relativas ao chão (groundY). Vãos conferidos contra
  // a tabela de alcance do pulo normal (ver fase.dart):
  //  - chão 1800 → degrau 1: vão 120, subida 30 (alcance 200) — folga 80.
  //  - degrau 1 → degrau 2: vão 110, subida 110 (alcance 160) — folga 50.
  //  - degrau 2 → degrau 3: vão 150, descida de 110 — folga de sobra.
  //  - degrau 3 → chão 2720: vão 150, descida de 30 — folga de sobra.
  criarPlataformas: (groundY) => [
    Objects(x: 1920, y: groundY - 30, width: 130), // degrau 1 (baixo)
    Objects(x: 2160, y: groundY - 140, width: 130), // degrau 2 (topo)
    Objects(x: 2440, y: groundY - 30, width: 130), // degrau 3 (desce)
  ],

  // 3 inimigos: dois no chão (início e meio da fase) e um em cima da
  // plataforma mais alta do segundo buraco, atirando enquanto o jogador
  // tenta cruzar pulando.
  criarInimigos: (groundY) => [
    const EnemySpawn(400),
    const EnemySpawn(1400),
    EnemySpawn(2225, y: groundY - 140 - 64),
  ],
);
