import 'dart:ui';
import '../enemy.dart';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 5 — Fase 6 (fase final do andar E do jogo).
///
/// O confronto final: fecha o último andar com DOIS bosses na mesma arena, em vez
/// do boss único de todos os andares anteriores. É a maior escalada possível do
/// duelo afinado do jogo, um degrau acima da Fase 6 do Andar 3 (o outro andar de
/// seis fases): a aproximação herda a identidade vertical do Andar 5 (uma TORRE
/// ESTICADA no lugar da torre comum) e o duelo dobra — dois bosses, 8 tiros para
/// derrubar, duas esferas de plasma em cena.
///
/// ## Como dois bosses convivem numa arena só (e por que é justo)
///
/// Os dois bosses nascem na arena, colados no portal, e avançam para a beira do
/// fosso perseguindo o jogador. A IA anti-sobreposição do motor
/// (`_temInimigoAdiante`, em game_board.dart) impede que um ande por cima do
/// outro: eles EMPILHAM EM FILA — um na frente, travado na beira do fosso pela IA
/// de borda, e o outro logo atrás. Isso transforma o combate num duelo de DUAS
/// FASES: o jogador derruba o boss da frente (o tiro dele acerta o mais próximo
/// primeiro) e, quando ele cai, o de trás avança e assume a beira.
///
/// Os dois atiram rente ao chão (ver `_dispararInimigo`), então as duas esferas
/// são desviadas PULANDO, como sempre. Mas o boss de trás fica ~264px atrás do da
/// frente, então a esfera dele nasce mais à direita e chega ao jogador DEPOIS da
/// esfera do da frente: a barragem é escalonada, não simultânea — o jogador
/// sempre tem uma janela para pular e revidar. Dobrar os bosses dobra a pressão e
/// o HP sem criar a situação "sem saída" de duas esferas na mesma fração de
/// segundo.
///
/// ## A geometria do duelo — leia antes de mexer nas alturas
///
/// O boss não tem colisão de corpo (não empurra nem machuca no toque): ele
/// machuca só com a esfera, que dispara RENTE AO CHÃO. Com o chão em `G`, e já
/// contando os insets de dano do motor, a esfera ocupa a faixa `G-70` a `G-26`, e
/// a caixa de dano do jogador com os pés a `h` px do chão vai de `G-h-59` a
/// `G-h-10`. As duas faixas se cruzam quando:
///
///     h < 59  →  a esfera ACERTA
///     h > 59  →  a esfera passa POR BAIXO dos pés do jogador
///
/// Ou seja: **a esfera se desvia pulando**, e nada mais. Ela é larga demais
/// (256px) para ser evitada correndo. Duas consequências que sustentam a fase:
///
///  - Na TRINCHEIRA o jogador está no chão (h=0) e portanto EXPOSTO: cada esfera
///    tem que ser pulada. Mas ele acerta os bosses de pé no chão e igual no ar.
///    Esse é o duelo: pula as esferas, atira, repete, 8 vezes (4 por boss). É a
///    única parte da fase com chão firme e espaço para recuar enquanto faz isso.
///  - A plataforma do FOSSO está a 100px, ACIMA da faixa da esfera: é a ponte
///    segura, as esferas passam por baixo dela. Mas o chão do outro lado (a arena
///    dos bosses) NÃO é seguro: pisar lá com boss vivo é voltar para h=0 a menos
///    de 256px dele, onde a esfera nasce em cima do jogador sem tempo de pular.
///    Por isso derrubar OS DOIS antes de atravessar não é opcional — é a condição
///    de sobrevivência, imposta só pela geometria, sem trancar o portal.
///
/// Se alguém baixar a plataforma do fosso para menos de ~59px, ela vira armadilha
/// (o jogador toma esfera em cima dela). Se alguém encurtar o fosso, os bosses
/// chegam perto demais da trincheira e a esfera nasce dentro dela, sem reação.
///
/// ## Orçamento do pulo (ver a tabela em [Fase])
///
/// Todos os vãos abaixo cabem no pulo NORMAL, sem depender do DEV mode:
///  - Torre esticada (buraco 650 → 1740):
///    - chão 650 → degrau 1: vão 120, subida 100 (alcance 180) — folga 60.
///    - degrau 1 → degrau 2 (topo): vão 100, subida 120 (alcance 160) — folga 60.
///    - degrau 2 → ponte 1: vão 100, no plano (alcance 220) — folga de sobra.
///    - ponte 1 → ponte 2: vão 100, no plano (alcance 220) — folga de sobra.
///    - ponte 2 → degrau 3 (desce): vão 100, descida de 120 — folga de sobra.
///    - degrau 3 → chão 1740: vão 20, descida de 100 — folga de sobra.
///  - Arco (buraco 2050 → 2750):
///    - chão 2050 → degrau 1: vão 120, subida 100 (alcance 180) — folga 60.
///    - degrau 1 → degrau 2 (topo): vão 100, subida 100 (alcance 180) — folga 80.
///    - degrau 2 → degrau 3 (desce): vão 100, descida de 100 — folga de sobra.
///    - degrau 3 → trincheira 2750: vão 50, descida de 100 — folga de sobra.
///  - Fosso dos bosses:
///    - trincheira 3050 → ponte do fosso: vão 120, subida 100 (alcance 180) —
///      folga 60.
///    - ponte do fosso → arena 3350: vão 80, descida de 100 — folga de sobra (o
///      salto de saída tem que ser fácil: ele é dado com os bosses na cara).
///
/// O portal é posicionado explicitamente (portalX=3850) no fundo da arena: os
/// dois bosses nascem colados nele e avançam para a beira do fosso, liberando o
/// caminho só quando caem.
///
/// Tamanho horizontal próprio: a arte desta fase é 1983 × 793 px (aspecto 2.5).
/// O mapa acompanha a largura da arte (largura × 2 ≈ 3970), e o cenário é
/// travado na borda da imagem para nunca mostrar faixa branca.
final faseAndar5Fase6 = Fase(
  andar: 5,
  numero: 6,
  level: LevelData(
    size: const Size(3970, 600),
    offset: const Offset(800, 0),
    backgroundImage: 'lib/Images/Fases/Andar5/Fase5-6.png',
    larguraDoMapa: 3970,
    imgWidth: 1983,
    imgHeight: 793,
  ),

  // Portal no fundo da arena dos bosses (ver cabeçalho): os dois bosses nascem
  // colados nele e recuam para a beira do fosso ao perseguir o jogador.
  portalX: 3850,

  // Chão em quatro pedaços, com três buracos entre eles: a torre esticada e o
  // arco da aproximação, e o fosso dos bosses. A trincheira (2750 → 3050) é o
  // pedaço de chão entre o arco e o fosso: é a arena do duelo, e o último chão
  // seguro da fase enquanto qualquer boss estiver vivo.
  groundSegments: const [
    GroundSegment(double.negativeInfinity, 650),
    GroundSegment(1740, 2050),
    GroundSegment(2750, 3050), // trincheira: a arena do duelo
    GroundSegment(3350, double.infinity), // arena dos bosses + portal
  ],

  // 9 plataformas: a torre esticada (5) e o arco (3) da aproximação, mais a ponte
  // do fosso (1). Todas relativas ao chão (groundY). A altura da ponte do fosso
  // (100px) NÃO é arbitrária: está acima dos ~59px que a esfera alcança (ver "A
  // geometria do duelo"), então as esferas passam por baixo e a travessia em si é
  // segura. O perigo é o chão do outro lado, não a ponte.
  criarPlataformas: (groundY) => [
    // Torre esticada de aproximação (buraco 650 → 1740)
    Objects(x: 770, y: groundY - 100, width: 110), // degrau 1 (sobe)
    Objects(x: 980, y: groundY - 220, width: 110), // degrau 2 (topo)
    Objects(x: 1190, y: groundY - 220, width: 110), // ponte 1 no topo
    Objects(x: 1400, y: groundY - 220, width: 110), // ponte 2 no topo
    Objects(x: 1610, y: groundY - 100, width: 110), // degrau 3 (desce)
    // Arco de aproximação (buraco 2050 → 2750)
    Objects(x: 2170, y: groundY - 100, width: 110), // degrau 1 (sobe)
    Objects(x: 2380, y: groundY - 200, width: 110), // degrau 2 (topo)
    Objects(x: 2590, y: groundY - 100, width: 110), // degrau 3 (desce)
    // Ponte do fosso dos bosses (buraco 3050 → 3350)
    Objects(x: 3170, y: groundY - 100, width: 100), // ponte do fosso
  ],

  // 3 inimigos comuns na aproximação (chão inicial, ponte 1 da torre esticada e
  // chão intermediário — espalhados, nenhum empilhado, nenhum na arena do duelo),
  // mais os DOIS bosses. Cada boss nasce em pé no chão da arena, colado no portal:
  // o motor resolve o Y sozinho, já contando que ele é 4x mais alto. Assim que o
  // jogador se move, os dois avançam para a beira do fosso; a IA anti-sobreposição
  // os empilha em fila (ver cabeçalho), e a IA de borda trava o da frente na
  // beira — exatamente onde precisam estar para cobrir a travessia.
  criarInimigos: (groundY) => [
    const EnemySpawn(400),
    EnemySpawn(1245, y: groundY - 220 - 64), // ponte 1 da torre de aproximação
    const EnemySpawn(1900),
    const EnemySpawn(3500, tipo: EnemyType.boss), // boss 1 (fica na frente)
    const EnemySpawn(3700, tipo: EnemyType.boss), // boss 2 (empilha atrás)
  ],
);
