import 'dart:ui';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 5 — Fase 3.
///
/// Mais um degrau acima da Fase 2 do andar, e um passo acima da Fase 3 do Andar
/// 4: mantém a assinatura da "terceira fase" — a dificuldade mora na PRECISÃO,
/// com buracos largos cruzados por plataformas estreitíssimas (80px) em degrau
/// (sobe, desce), sem plataforma intermediária para corrigir um pulo mal dado.
/// A Fase 3 do Andar 4 já tinha encolhido as plataformas para 80px e cobrado UMA
/// travessia dessas. Como aqui as plataformas não têm mais para onde encolher
/// sem virar injustiça, o parafuso que aperta é a REPETIÇÃO: são DUAS travessias
/// de precisão separadas, cada uma com seu inimigo aéreo, e o gauntlet de
/// aproximação sobe para 3 inimigos, totalizando 7 — a fase mais povoada do
/// andar até aqui.
///
/// Estrutura (da esquerda para a direita):
///  1. Zona inicial no chão. O jogador nasce no início real do mapa (x=50,
///     padrão do motor) e tem um trecho livre antes do primeiro inimigo
///     (x=400).
///  2. Um salto direto de 180px (sem plataforma) — o maior salto direto no plano
///     que o pulo normal aguenta com folga.
///  3. Zona intermediária no chão, com um gauntlet de TRÊS inimigos (x=1250,
///     x=1550 e x=1850) que pressiona a corrida de embalo para a primeira
///     travessia de precisão.
///  4. Primeira travessia de precisão: um buraco largo (1900 → 2510) cruzado por
///     2 plataformas estreitíssimas (80px) em degrau (sobe, desce), com pouso
///     justo e sem correção intermediária. O quinto inimigo fica em cima do
///     degrau do topo, atirando enquanto o jogador cruza pulando.
///  5. Zona central curta no chão (2510 → 2950) para reembalar.
///  6. Segunda travessia de precisão: um segundo buraco largo (2950 → 3450),
///     idêntico em exigência ao primeiro (2 plataformas de 80px em degrau), com o
///     sexto inimigo em cima do topo. A repetição, já cansado, é o teste.
///  7. Trecho final no chão, com o sétimo inimigo (x=3520) guardando o caminho
///     até o portal.
///
/// ## Orçamento do pulo (ver a tabela em [Fase])
///
/// Todos os vãos abaixo cabem no pulo NORMAL, sem depender do DEV mode:
///  - chão 900 → chão 1080: vão 180, no plano (alcance 220) — folga 40.
///  - Primeira travessia (buraco 1900 → 2510):
///    - chão 1900 → degrau 1: vão 120, subida 30 (alcance 200) — folga 80.
///    - degrau 1 → degrau 2 (topo): vão 130, subida 100 (alcance 180) — folga 50.
///    - degrau 2 → chão 2510: vão 200, descida de 130 — folga de sobra.
///  - Segunda travessia (buraco 2950 → 3450):
///    - chão 2950 → degrau 1: vão 120, subida 30 (alcance 200) — folga 80.
///    - degrau 1 → degrau 2 (topo): vão 130, subida 100 (alcance 180) — folga 50.
///    - degrau 2 → chão 3450: vão 90, descida de 130 — folga de sobra.
///
/// Tamanho horizontal próprio: a arte desta fase é 1983 × 793 px (aspecto 2.5).
/// O mapa acompanha a largura da arte (largura × 2 ≈ 3970), e o cenário é
/// travado na borda da imagem para nunca mostrar faixa branca.
final faseAndar5Fase3 = Fase(
  andar: 5,
  numero: 3,
  level: LevelData(
    size: const Size(3970, 600),
    offset: const Offset(800, 0),
    backgroundImage: 'lib/Images/Fases/Andar5/Fase5-3.png',
    larguraDoMapa: 3970,
    imgWidth: 1983,
    imgHeight: 793,
  ),

  // Chão em quatro pedaços, com três buracos entre eles: o salto direto de
  // abertura (900 → 1080), a primeira travessia de precisão (1900 → 2510) e a
  // segunda travessia de precisão (2950 → 3450). A zona central (2510 → 2950) é o
  // pedaço de chão entre as duas travessias, onde o jogador reembala.
  groundSegments: const [
    GroundSegment(double.negativeInfinity, 900),
    GroundSegment(1080, 1900),
    GroundSegment(2510, 2950),
    GroundSegment(3450, double.infinity),
  ],

  // Duas travessias de precisão, cada uma com 2 plataformas estreitíssimas (80px)
  // em degrau (sobe, desce), sem plataforma intermediária: um pulo mal dado no
  // degrau do topo é queda no buraco. Posicionadas relativas ao chão (groundY).
  // Vãos conferidos contra a tabela de alcance do pulo normal (ver fase.dart):
  //  - Primeira travessia (buraco 1900 → 2510):
  //    - chão 1900 → degrau 1: vão 120, subida 30 (alcance 200) — folga 80.
  //    - degrau 1 → degrau 2: vão 130, subida 100 (alcance 180) — folga 50.
  //    - degrau 2 → chão 2510: vão 200, descida de 130 — folga de sobra.
  //  - Segunda travessia (buraco 2950 → 3450):
  //    - chão 2950 → degrau 1: vão 120, subida 30 (alcance 200) — folga 80.
  //    - degrau 1 → degrau 2: vão 130, subida 100 (alcance 180) — folga 50.
  //    - degrau 2 → chão 3450: vão 90, descida de 130 — folga de sobra.
  criarPlataformas: (groundY) => [
    // Primeira travessia de precisão
    Objects(x: 2020, y: groundY - 30, width: 80), // degrau 1 (baixo)
    Objects(x: 2230, y: groundY - 130, width: 80), // degrau 2 (topo)
    // Segunda travessia de precisão
    Objects(x: 3070, y: groundY - 30, width: 80), // degrau 1 (baixo)
    Objects(x: 3280, y: groundY - 130, width: 80), // degrau 2 (topo)
  ],

  // 7 inimigos: quatro no chão antes das travessias (um no início e três no
  // gauntlet de aproximação), dois em cima do topo de cada travessia (atirando em
  // pleno ar) e um guardando o trecho final antes do portal.
  criarInimigos: (groundY) => [
    const EnemySpawn(400),
    const EnemySpawn(1250),
    const EnemySpawn(1550),
    const EnemySpawn(1850),
    EnemySpawn(2270, y: groundY - 130 - 64), // em cima do topo da 1ª travessia
    EnemySpawn(3320, y: groundY - 130 - 64), // em cima do topo da 2ª travessia
    const EnemySpawn(3520),
  ],
);
