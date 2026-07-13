import 'dart:ui';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 2 — Fase 3.
///
/// Mais um degrau de dificuldade acima da Fase 2: 4 inimigos e uma travessia
/// com plataformas mais estreitas (100px, contra os 130px da Fase 2) exigindo
/// pouso mais preciso, além de só 2 degraus (sobe, desce) sobre o buraco
/// largo — sem plataforma intermediária para corrigir um pulo mal dado.
///
/// Estrutura (da esquerda para a direita):
///  1. Zona inicial no chão. O jogador nasce no início real do mapa (x=50,
///     padrão do motor) e tem um trecho livre antes do primeiro inimigo
///     (x=400).
///  2. Um buraco direto de 170px (sem plataforma) — o maior salto direto no
///     plano que o pulo normal aguenta com folga.
///  3. Zona intermediária no chão, com o segundo inimigo (x=1350).
///  4. Um buraco largo (1650 → 2300) atravessado por 2 plataformas estreitas
///     (100px) em degrau (sobe, desce), com saltos de até 130px cada. O
///     terceiro inimigo fica em cima da plataforma mais alta, obrigando o
///     jogador a lidar com ele em pleno ar.
///  5. Trecho final no chão, com o quarto inimigo (x=2450), guardando o
///     caminho até o portal.
///
/// Tamanho horizontal próprio: a arte desta fase é 1983 × 793 px. O mapa
/// acompanha a largura da arte (largura da arte × 2 ≈ 3966), e o cenário é
/// travado na borda da imagem para nunca mostrar faixa branca.
final faseAndar2Fase3 = Fase(
  andar: 2,
  numero: 3,
  level: LevelData(
    size: const Size(3966, 600), // tamanho do mapa (largura da arte × 2, altura do chão)
    offset: const Offset(800, 0), // deslocamento inicial do mapa para a direita, para que o jogador nasça no início real do mapa (x=50) e não no canto esquerdo da tela
    backgroundImage: 'lib/Images/Fases/Andar2/Fase2-3.png',
    larguraDoMapa: 3966,
    imgWidth: 1983,
    imgHeight: 793,
  ),

  // Chão em três pedaços: zona inicial, zona intermediária e zona final, com
  // dois buracos entre eles (o segundo, mais largo, exige as duas plataformas
  // estreitas para ser atravessado).
  groundSegments: const [
    GroundSegment(double.negativeInfinity, 900),
    GroundSegment(1070, 1650),
    GroundSegment(2300, double.infinity),
  ],

  // 2 plataformas estreitas (100px, mais justas que as da Fase 2) em degrau
  // (sobe, desce) atravessando o segundo buraco, posicionadas relativas ao
  // chão (groundY). Vãos conferidos contra a tabela de alcance do pulo normal
  // (ver fase.dart):
  //  - chão 1650 → degrau 1: vão 130, subida 30 (alcance 200) — folga 70.
  //  - degrau 1 → degrau 2: vão 130, subida 100 (alcance 180) — folga 50.
  //  - degrau 2 → chão 2300: vão 190, descida de 130 — folga de sobra.
  criarPlataformas: (groundY) => [
    Objects(x: 1780, y: groundY - 30, width: 100), // degrau 1 (baixo)
    Objects(x: 2010, y: groundY - 130, width: 100), // degrau 2 (topo)
  ],

  // 4 inimigos: dois no chão antes do buraco largo, um em cima da plataforma
  // mais alta (atirando em pleno ar) e um guardando o trecho final antes do
  // portal.
  criarInimigos: (groundY) => [
    const EnemySpawn(400),
    const EnemySpawn(1350),
    EnemySpawn(2050, y: groundY - 130 - 64),
    const EnemySpawn(2450),
  ],
);
