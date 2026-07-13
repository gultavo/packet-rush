import 'dart:ui';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 3 — Fase 3.
///
/// Mais um degrau acima da Fase 2 do andar, e um passo acima da Fase 3 dos
/// Andares 1 e 2: aqui a dificuldade migra do vão largo para a PRECISÃO. O
/// buraco largo é cruzado por apenas 2 plataformas estreitas (90px, contra os
/// 100px do template e os 120px da Fase 2), em degrau (sobe, desce), sem
/// plataforma intermediária para corrigir um pulo mal dado. Por ser um andar
/// mais avançado, sobe a aposta com 5 inimigos (contra os 4 do template),
/// incluindo um gauntlet de aproximação antes da travessia.
///
/// Estrutura (da esquerda para a direita):
///  1. Zona inicial no chão. O jogador nasce no início real do mapa (x=50,
///     padrão do motor) e tem um trecho livre antes do primeiro inimigo
///     (x=400).
///  2. Um salto direto de 170px (sem plataforma) — o maior salto direto no
///     plano que o pulo normal aguenta com folga.
///  3. Zona intermediária no chão, com DOIS inimigos (x=1400 e x=1900) — um
///     gauntlet de aproximação que pressiona a corrida de embalo para a
///     travessia de precisão.
///  4. Um buraco largo (2200 → 2820) atravessado por 2 plataformas estreitas
///     (90px) em degrau (sobe, desce), com pouso justo e sem correção
///     intermediária. O quarto inimigo fica em cima da plataforma do topo,
///     atirando enquanto o jogador tenta cruzar pulando.
///  5. Trecho final no chão, com o quinto inimigo (x=3400) guardando o caminho
///     até o portal.
///
/// ## Orçamento do pulo (ver a tabela em [Fase])
///
/// Todos os vãos abaixo cabem no pulo NORMAL, sem depender do DEV mode:
///  - chão 1000 → chão 1170: vão 170, no plano (alcance 220) — folga 50.
///  - chão 2200 → degrau 1: vão 130, subida 30 (alcance 200) — folga 70.
///  - degrau 1 → degrau 2: vão 120, subida 100 (alcance 180) — folga 60.
///  - degrau 2 → chão 2820: vão 190, descida de 130 — folga de sobra.
///
/// Tamanho horizontal próprio: a arte desta fase é 2172 × 724 px (larga,
/// aspecto 3.0). O mapa acompanha a largura da arte (largura × 2 ≈ 4340), e o
/// cenário é travado na borda da imagem para nunca mostrar faixa branca.
final faseAndar3Fase3 = Fase(
  andar: 3,
  numero: 3,
  level: LevelData(
    size: const Size(4340, 600),
    offset: const Offset(800, 0),
    backgroundImage: 'lib/Images/Fases/Andar3/Fase3-3.png',
    larguraDoMapa: 4340,
    imgWidth: 2172,
    imgHeight: 724,
  ),

  // Chão em três pedaços: zona inicial, zona intermediária e zona final, com
  // dois buracos entre eles. O primeiro (1000 → 1170) é o salto direto de
  // 170px; o segundo (2200 → 2820), mais largo, exige as duas plataformas
  // estreitas para ser atravessado.
  groundSegments: const [
    GroundSegment(double.negativeInfinity, 1000),
    GroundSegment(1170, 2200),
    GroundSegment(2820, double.infinity),
  ],

  // 2 plataformas estreitas (90px, mais justas que os 100px do template e os
  // 120px da Fase 2) em degrau (sobe, desce), sem plataforma intermediária:
  // um pulo mal dado no degrau do topo é queda no buraco. Posicionadas
  // relativas ao chão (groundY). Vãos conferidos contra a tabela de alcance do
  // pulo normal (ver fase.dart):
  //  - chão 2200 → degrau 1: vão 130, subida 30 (alcance 200) — folga 70.
  //  - degrau 1 → degrau 2: vão 120, subida 100 (alcance 180) — folga 60.
  //  - degrau 2 → chão 2820: vão 190, descida de 130 — folga de sobra.
  criarPlataformas: (groundY) => [
    Objects(x: 2330, y: groundY - 30, width: 90), // degrau 1 (baixo)
    Objects(x: 2540, y: groundY - 130, width: 90), // degrau 2 (topo)
  ],

  // 5 inimigos: três no chão antes da travessia (um no início e dois no
  // gauntlet de aproximação), um em cima da plataforma do topo (atirando em
  // pleno ar) e um guardando o trecho final antes do portal.
  criarInimigos: (groundY) => [
    const EnemySpawn(400),
    const EnemySpawn(1400),
    const EnemySpawn(1900),
    EnemySpawn(2585, y: groundY - 130 - 64),
    const EnemySpawn(3400),
  ],
);
