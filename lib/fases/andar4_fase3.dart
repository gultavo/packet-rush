import 'dart:ui';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 4 — Fase 3.
///
/// Mais um degrau acima da Fase 2 do andar, e um passo acima da Fase 3 dos
/// Andares 1, 2 e 3: mantém a assinatura da "terceira fase" — a dificuldade
/// migra do vão largo para a PRECISÃO, com o buraco largo cruzado por apenas 2
/// plataformas estreitas em degrau (sobe, desce), sem plataforma intermediária
/// para corrigir um pulo mal dado. Por ser o andar mais avançado, aperta os
/// dois parafusos que definem a fase: as plataformas encolhem para 80px (contra
/// os 90px da Fase 3 do Andar 3 e os 100px da do Andar 2), e o gauntlet de
/// aproximação sobe de 2 para 3 inimigos, totalizando 6 — a fase mais povoada
/// do andar até aqui.
///
/// Estrutura (da esquerda para a direita):
///  1. Zona inicial no chão. O jogador nasce no início real do mapa (x=50,
///     padrão do motor) e tem um trecho livre antes do primeiro inimigo
///     (x=400).
///  2. Um salto direto de 170px (sem plataforma) — o maior salto direto no
///     plano que o pulo normal aguenta com folga.
///  3. Zona intermediária no chão, com um gauntlet de TRÊS inimigos (x=1300,
///     x=1700 e x=2100) que pressiona a corrida de embalo para a travessia de
///     precisão.
///  4. Um buraco largo (2400 → 3020) atravessado por 2 plataformas estreitíssimas
///     (80px) em degrau (sobe, desce), com pouso justo e sem correção
///     intermediária: um pulo mal dado no degrau do topo é queda no buraco. O
///     quinto inimigo fica em cima da plataforma do topo, atirando enquanto o
///     jogador tenta cruzar pulando.
///  5. Trecho final no chão, com o sexto inimigo (x=3400) guardando o caminho
///     até o portal.
///
/// ## Orçamento do pulo (ver a tabela em [Fase])
///
/// Todos os vãos abaixo cabem no pulo NORMAL, sem depender do DEV mode:
///  - chão 900 → chão 1070: vão 170, no plano (alcance 220) — folga 50.
///  - chão 2400 → degrau 1: vão 130, subida 30 (alcance 200) — folga 70.
///  - degrau 1 → degrau 2: vão 130, subida 100 (alcance 180) — folga 50.
///  - degrau 2 → chão 3020: vão 200, descida de 130 — folga de sobra.
///
/// Tamanho horizontal próprio: a arte desta fase é 1983 × 793 px (aspecto 2.5).
/// O mapa acompanha a largura da arte (largura × 2 ≈ 3970), e o cenário é
/// travado na borda da imagem para nunca mostrar faixa branca.
final faseAndar4Fase3 = Fase(
  andar: 4,
  numero: 3,
  level: LevelData(
    size: const Size(3970, 600),
    offset: const Offset(800, 0),
    backgroundImage: 'lib/Images/Fases/Andar4/Fase4-3.png',
    larguraDoMapa: 3970,
    imgWidth: 1983,
    imgHeight: 793,
  ),

  // Chão em três pedaços: zona inicial, zona intermediária e zona final, com
  // dois buracos entre eles. O primeiro (900 → 1070) é o salto direto de 170px;
  // o segundo (2400 → 3020), mais largo, exige as duas plataformas estreitas
  // para ser atravessado.
  groundSegments: const [
    GroundSegment(double.negativeInfinity, 900),
    GroundSegment(1070, 2400),
    GroundSegment(3020, double.infinity),
  ],

  // 2 plataformas estreitíssimas (80px, mais justas que os 90px da Fase 3 do
  // Andar 3) em degrau (sobe, desce), sem plataforma intermediária: um pulo mal
  // dado no degrau do topo é queda no buraco. Posicionadas relativas ao chão
  // (groundY). Vãos conferidos contra a tabela de alcance do pulo normal (ver
  // fase.dart):
  //  - chão 2400 → degrau 1: vão 130, subida 30 (alcance 200) — folga 70.
  //  - degrau 1 → degrau 2: vão 130, subida 100 (alcance 180) — folga 50.
  //  - degrau 2 → chão 3020: vão 200, descida de 130 — folga de sobra.
  criarPlataformas: (groundY) => [
    Objects(x: 2530, y: groundY - 30, width: 80), // degrau 1 (baixo)
    Objects(x: 2740, y: groundY - 130, width: 80), // degrau 2 (topo)
  ],

  // 6 inimigos: quatro no chão antes da travessia (um no início e três no
  // gauntlet de aproximação), um em cima da plataforma do topo (atirando em
  // pleno ar) e um guardando o trecho final antes do portal.
  criarInimigos: (groundY) => [
    const EnemySpawn(400),
    const EnemySpawn(1300),
    const EnemySpawn(1700),
    const EnemySpawn(2100),
    EnemySpawn(2780, y: groundY - 130 - 64), // em cima do topo
    const EnemySpawn(3400),
  ],
);
