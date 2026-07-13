import 'dart:ui';
import '../enemy.dart';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 3 — Fase 6 (fase final do andar).
///
/// Fecha o Andar 3 com o BOSS do andar. Como este é o último andar com seis
/// fases, o boss chega depois de a Fase 5 ter levado a verticalidade ao ápice —
/// então o caminho ATÉ o duelo herda esse tema: em vez do "salto direto + arco"
/// das aberturas de boss dos Andares 1 e 2, a aproximação sobe uma torre e
/// depois um arco, um teste de movimento à altura do andar. O combate em si é o
/// mesmo duelo afinado: o boss é 4x maior, dispara uma esfera de plasma 4x maior
/// e só morre com 4 tiros, e é o único inimigo da arena.
///
/// Os inimigos comuns (3) ficam TODOS na aproximação, espalhados e longe da
/// arena do duelo, só para encarecer o trajeto — nenhum invade a trincheira,
/// onde a esfera do boss já é o único perigo que importa.
///
/// Estrutura (da esquerda para a direita):
///  1. Zona inicial no chão, com o primeiro inimigo (x=400).
///  2. TORRE de aproximação: um buraco longo (700 → 1620) atravessado por 4
///     plataformas (sobe, topo, ponte, desce) até 220px. O segundo inimigo fica
///     na ponte do topo, contestando a subida.
///  3. Zona intermediária no chão (1620 → 1900), com o terceiro inimigo
///     (x=1750) guardando a entrada do arco.
///  4. ARCO: um buraco longo (1900 → 2600) atravessado por 3 plataformas
///     (sobe, topo, desce). É o último trecho de movimento antes do duelo,
///     mantido limpo de inimigos para o jogador chegar composto à trincheira.
///  5. A TRINCHEIRA (chão 2600 → 2850): a arena do duelo. É o último chão antes
///     do fosso, e é daqui que o boss é derrubado.
///  6. O FOSSO DO BOSS (2850 → 3150): o último buraco, atravessado por uma
///     única plataforma a 100px de altura. Cair aqui custa uma vida.
///  7. Arena do boss (3150 em diante), com o portal ao fundo. O boss nasce
///     colado no portal (x=3970) e avança até a beira do fosso, onde a IA de
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
///  - Torre (buraco 700 → 1620):
///    - chão 700 → degrau 1: vão 120, subida 100 (alcance 180) — folga 60.
///    - degrau 1 → degrau 2 (topo): vão 100, subida 120 (alcance 160) — folga 60.
///    - degrau 2 → ponte: vão 100, no plano (alcance 220) — folga de sobra.
///    - ponte → degrau 3 (desce): vão 100, descida de 120 — folga de sobra.
///    - degrau 3 → chão 1620: vão 60, descida de 100 — folga de sobra.
///  - Arco (buraco 1900 → 2600):
///    - chão 1900 → degrau 1: vão 120, subida 100 (alcance 180) — folga 60.
///    - degrau 1 → degrau 2 (topo): vão 100, subida 100 (alcance 180) — folga 80.
///    - degrau 2 → degrau 3 (desce): vão 100, descida de 100 — folga de sobra.
///    - degrau 3 → trincheira 2600: vão 50, descida de 100 — folga de sobra.
///  - Fosso do boss:
///    - trincheira 2850 → ponte do fosso: vão 120, subida 100 (alcance 180) —
///      folga 60.
///    - ponte do fosso → arena 3150: vão 80, descida de 100 — folga de sobra (o
///      salto de saída tem que ser fácil: ele é dado com o boss na cara).
///
/// Tamanho horizontal próprio: a arte desta fase é 2172 × 724 px (larga,
/// aspecto 3.0). O mapa acompanha a largura da arte (largura × 2 ≈ 4340), e o
/// cenário é travado na borda da imagem para nunca mostrar faixa branca.
final faseAndar3Fase6 = Fase(
  andar: 3,
  numero: 6,
  level: LevelData(
    size: const Size(4340, 600),
    offset: const Offset(800, 0),
    backgroundImage: 'lib/Images/Fases/Andar3/Fase3-6.png',
    larguraDoMapa: 4340,
    imgWidth: 2172,
    imgHeight: 724,
  ),

  // Chão em quatro pedaços, com três buracos entre eles: a torre e o arco da
  // aproximação, e o fosso do boss. A trincheira (2600 → 2850) é o pedaço de
  // chão entre o arco e o fosso: é a arena do duelo, e o último chão seguro da
  // fase enquanto o boss estiver vivo.
  groundSegments: const [
    GroundSegment(double.negativeInfinity, 700),
    GroundSegment(1620, 1900),
    GroundSegment(2600, 2850), // trincheira: a arena do duelo
    GroundSegment(3150, double.infinity), // arena do boss + portal
  ],

  // 8 plataformas: a torre (4) e o arco (3) da aproximação, mais a ponte do
  // fosso (1). Todas relativas ao chão (groundY). A altura da ponte do fosso
  // (100px) NÃO é arbitrária: ela está acima dos ~59px que a esfera do boss
  // alcança (ver "A geometria do duelo"), então a esfera passa por baixo e a
  // travessia em si é segura. O perigo é o chão do outro lado, não a ponte.
  criarPlataformas: (groundY) => [
    // Torre de aproximação (buraco 700 → 1620)
    Objects(x: 820, y: groundY - 100, width: 110), // degrau 1 (sobe)
    Objects(x: 1030, y: groundY - 220, width: 110), // degrau 2 (topo)
    Objects(x: 1240, y: groundY - 220, width: 110), // ponte no topo
    Objects(x: 1450, y: groundY - 100, width: 110), // degrau 3 (desce)
    // Arco de aproximação (buraco 1900 → 2600)
    Objects(x: 2020, y: groundY - 100, width: 110), // degrau 1 (sobe)
    Objects(x: 2230, y: groundY - 200, width: 110), // degrau 2 (topo)
    Objects(x: 2440, y: groundY - 100, width: 110), // degrau 3 (desce)
    // Ponte do fosso do boss (buraco 2850 → 3150)
    Objects(x: 2970, y: groundY - 100, width: 100), // ponte do fosso
  ],

  // 3 inimigos comuns na aproximação (chão inicial, ponte da torre e chão
  // intermediário — espalhados, nenhum empilhado, nenhum na arena do duelo),
  // mais o boss. O boss nasce em pé no chão da arena, colado no portal: o motor
  // resolve o Y dele sozinho, já contando que ele é 4x mais alto. Assim que o
  // jogador se move, ele avança para a beira do fosso e trava ali (a IA de borda
  // não deixa inimigo andar para dentro de buraco) — exatamente onde precisa
  // estar para cobrir a travessia.
  criarInimigos: (groundY) => [
    const EnemySpawn(400),
    EnemySpawn(1295, y: groundY - 220 - 64), // ponte da torre de aproximação
    const EnemySpawn(1750),
    const EnemySpawn(3970, tipo: EnemyType.boss),
  ],
);
