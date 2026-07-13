import 'dart:ui';
import '../enemy.dart';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 4 — Fase 5 (fase final do andar).
///
/// Fecha o Andar 4 com o BOSS do andar. O combate em si é o mesmo duelo afinado
/// de todos os andares: o boss é 4x maior, dispara uma esfera de plasma 4x maior
/// (256x96) e só morre com 4 tiros, e é o único inimigo da arena. O que sobe um
/// degrau, por ser o andar mais avançado, é a APROXIMAÇÃO — o caminho até o
/// duelo. Nas aberturas de boss dos Andares 1 e 2 ela era um "salto direto +
/// arco"; no Andar 3 virou "torre + arco". Aqui ela herda a verticalidade que é
/// a marca do Andar 4: uma TORRE de aproximação (sobe, topo, ponte, desce)
/// contestada em pleno ar, que despeja o jogador direto na trincheira do duelo.
///
/// Os inimigos comuns (4, contra os 3 do Andar 3) ficam TODOS na aproximação,
/// espalhados e longe da arena — dois no gauntlet de entrada da torre e um na
/// ponte dela, atirando durante a subida. Nenhum invade a trincheira, onde a
/// esfera do boss já é o único perigo que importa.
///
/// Estrutura (da esquerda para a direita):
///  1. Zona inicial no chão, com o primeiro inimigo (x=450).
///  2. Um salto direto de 170px (sem plataforma), no plano.
///  3. Zona intermediária no chão, com um gauntlet de dois inimigos (x=1150 e
///     x=1400) guardando a entrada da torre.
///  4. A TORRE de aproximação: um buraco longo (1500 → 2360) atravessado por 4
///     plataformas (sobe, topo, ponte, desce) até 220px. O quarto inimigo fica
///     na ponte do topo, contestando a subida em pleno ar. A torre desce direto
///     na trincheira — não há chão intermediário entre ela e o duelo.
///  5. A TRINCHEIRA (chão 2360 → 2610): a arena do duelo. É o último chão antes
///     do fosso, e é daqui que o boss é derrubado.
///  6. O FOSSO DO BOSS (2610 → 2910): o último buraco, atravessado por uma única
///     plataforma a 100px de altura. Cair aqui custa uma vida.
///  7. Arena do boss (2910 em diante), com o portal ao fundo. O boss nasce
///     colado no portal (x=3730) e avança até a beira do fosso, onde a IA de
///     borda o trava: ele fica ali, do outro lado, guardando a travessia.
///
/// ## A geometria do duelo — leia antes de mexer nas alturas
///
/// O boss não tem colisão de corpo (não empurra nem machuca no toque): ele
/// machuca só com a esfera, que ele dispara RENTE AO CHÃO (ver
/// `_dispararInimigo`, em game_board.dart). Com o chão em `G`, e já contando os
/// insets de dano do motor, a esfera ocupa a faixa `G-70` a `G-26`, e a caixa
/// de dano do jogador com os pés a `h` px do chão vai de `G-h-59` a `G-h-10`.
/// As duas faixas se cruzam quando:
///
///     h < 59  →  a esfera ACERTA
///     h > 59  →  a esfera passa POR BAIXO dos pés do jogador
///
/// Ou seja: **a esfera se desvia pulando**, e nada mais. Ela é larga demais
/// (256px) para ser evitada correndo — quando nasce, já ocupa 256px à frente do
/// boss. Duas consequências que sustentam a fase inteira:
///
///  - Na TRINCHEIRA o jogador está no chão (h=0) e portanto EXPOSTO: cada esfera
///    tem que ser pulada. Mas ele também acerta o boss de pé no chão (o tiro
///    dele sai a ~30px do chão e a caixa do boss começa a 16px), e acerta igual
///    no ar. Esse é o duelo: pula a esfera, atira, repete, 4 vezes. É a única
///    parte da fase em que ele tem chão firme e espaço para recuar enquanto faz
///    isso.
///  - A plataforma do FOSSO está a 100px, ou seja, ACIMA da faixa da esfera: ela
///    é a ponte segura, a esfera passa por baixo dela. Mas o chão do outro lado
///    (a arena do boss) NÃO é seguro: pisar lá com o boss vivo é voltar para h=0
///    a menos de 256px dele, onde a esfera nasce em cima do jogador sem tempo de
///    pular. Por isso matar o boss antes de atravessar não é opcional — é a
///    condição de sobrevivência, imposta só pela geometria, sem precisar trancar
///    o portal.
///
/// Se alguém baixar a plataforma do fosso para menos de ~59px, ela deixa de ser
/// ponte e vira armadilha (o jogador toma esfera em cima dela, sem espaço para
/// desviar). Se alguém encurtar o fosso, o boss chega perto demais da trincheira
/// e a esfera passa a nascer dentro dela, sem tempo de reação.
///
/// ## Orçamento do pulo (ver a tabela em [Fase])
///
/// Todos os vãos abaixo cabem no pulo NORMAL, sem depender do DEV mode:
///  - chão 850 → chão 1020: vão 170, no plano (alcance 220) — folga 50.
///  - Torre (buraco 1500 → 2360):
///    - chão 1500 → degrau 1: vão 100, subida 100 (alcance 180) — folga 80.
///    - degrau 1 → degrau 2 (topo): vão 100, subida 120 (alcance 160) — folga 60.
///    - degrau 2 → ponte: vão 100, no plano (alcance 220) — folga de sobra.
///    - ponte → degrau 3 (desce): vão 100, descida de 120 — folga de sobra.
///    - degrau 3 → trincheira 2360: vão 20, descida de 100 — folga de sobra.
///  - Fosso do boss:
///    - trincheira 2610 → ponte do fosso: vão 120, subida 100 (alcance 180) —
///      folga 60.
///    - ponte do fosso → arena 2910: vão 80, descida de 100 — folga de sobra (o
///      salto de saída tem que ser fácil: ele é dado com o boss na cara).
///
/// Tamanho horizontal próprio: a arte desta fase é 2048 × 768 px (aspecto
/// ~2.67, diferente das demais). O mapa acompanha a largura da arte
/// (largura × 2 ≈ 4100), e o cenário é travado na borda da imagem para nunca
/// mostrar faixa branca.
final faseAndar4Fase5 = Fase(
  andar: 4,
  numero: 5,
  level: LevelData(
    size: const Size(4100, 600),
    offset: const Offset(800, 0),
    backgroundImage: 'lib/Images/Fases/Andar4/Fase4-5.png',
    larguraDoMapa: 4100,
    imgWidth: 2048,
    imgHeight: 768,
  ),

  // Chão em quatro pedaços, com três buracos entre eles: o salto direto de
  // aquecimento (850 → 1020), a torre de aproximação (1500 → 2360) e o fosso do
  // boss (2610 → 2910). A trincheira (2360 → 2610) é o pedaço de chão entre a
  // torre e o fosso: é a arena do duelo, e o último chão seguro da fase enquanto
  // o boss estiver vivo.
  groundSegments: const [
    GroundSegment(double.negativeInfinity, 850),
    GroundSegment(1020, 1500),
    GroundSegment(2360, 2610), // trincheira: a arena do duelo
    GroundSegment(2910, double.infinity), // arena do boss + portal
  ],

  // 5 plataformas: a torre de aproximação (4) que desce direto na trincheira,
  // mais a ponte do fosso (1). Todas relativas ao chão (groundY). A altura da
  // ponte do fosso (100px) NÃO é arbitrária: ela está acima dos ~59px que a
  // esfera do boss alcança (ver "A geometria do duelo"), então a esfera passa
  // por baixo e a travessia em si é segura. O perigo é o chão do outro lado,
  // não a ponte.
  criarPlataformas: (groundY) => [
    // Torre de aproximação (buraco 1500 → 2360)
    Objects(x: 1600, y: groundY - 100, width: 110), // degrau 1 (sobe)
    Objects(x: 1810, y: groundY - 220, width: 110), // degrau 2 (topo)
    Objects(x: 2020, y: groundY - 220, width: 110), // ponte no topo
    Objects(x: 2230, y: groundY - 100, width: 110), // degrau 3 (desce)
    // Ponte do fosso do boss (buraco 2610 → 2910)
    Objects(x: 2730, y: groundY - 100, width: 100), // ponte do fosso
  ],

  // 4 inimigos comuns na aproximação (chão inicial, gauntlet de entrada da torre
  // e ponte da torre — espalhados, nenhum na arena do duelo), mais o boss. O
  // boss nasce em pé no chão da arena, colado no portal: o motor resolve o Y
  // dele sozinho, já contando que ele é 4x mais alto. Assim que o jogador se
  // move, ele avança para a beira do fosso e trava ali (a IA de borda não deixa
  // inimigo andar para dentro de buraco) — exatamente onde precisa estar para
  // cobrir a travessia.
  criarInimigos: (groundY) => [
    const EnemySpawn(450),
    const EnemySpawn(1150),
    const EnemySpawn(1400),
    EnemySpawn(2075, y: groundY - 220 - 64), // na ponte da torre de aproximação
    const EnemySpawn(3730, tipo: EnemyType.boss),
  ],
);
