import 'dart:ui';
import '../enemy.dart';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 2 — Fase 5 (fase final do andar).
///
/// Fecha o Andar 2 com o BOSS do andar, e ele é o ÚNICO inimigo da fase: 4x
/// maior que um inimigo comum, com um tiro 4x maior (uma esfera de plasma de
/// 256x96) e que só morre com 4 tiros. Um único boss já é mais perigoso que
/// os 5 inimigos comuns da Fase 4 juntos — encher a fase de inimigos comuns
/// em cima disso só transformaria o confronto em ruído.
///
/// Estrutura (da esquerda para a direita):
///  1. Zona inicial no chão, livre — sem inimigo nenhum, para o jogador se
///     orientar e cobrar o que as Fases 1–4 ensinaram de movimento antes de
///     cobrar o combate.
///  2. Um buraco direto de 170px (sem plataforma), no plano.
///  3. Zona intermediária no chão, com um inimigo comum (x=1400) guardando a
///     aproximação do arco — a única presença hostil antes do boss, longe da
///     arena do duelo para não virar ruído no confronto.
///  4. Um buraco longo (1900 → 2600) sem chão nenhum, atravessado por 3
///     plataformas em arco (sobe, topo, desce).
///  5. A TRINCHEIRA (chão 2600 → 2850): a arena do duelo. É o último chão
///     antes do fosso, e é daqui que o boss é derrubado.
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
/// `_dispararInimigo`, em game_board.dart). Com o chão em `G`, e já contando
/// os insets de dano do motor, a esfera ocupa a faixa `G-70` a `G-26`, e a
/// caixa de dano do jogador com os pés a `h` px do chão vai de `G-h-59` a
/// `G-h-10`. As duas faixas se cruzam quando:
///
///     h < 59  →  a esfera ACERTA
///     h > 59  →  a esfera passa POR BAIXO dos pés do jogador
///
/// Ou seja: **a esfera se desvia pulando**, e nada mais. Ela é larga demais
/// (256px) para ser evitada correndo — quando nasce, já ocupa 256px à frente
/// do boss. Duas consequências que sustentam a fase inteira:
///
///  - Na TRINCHEIRA o jogador está no chão (h=0) e portanto EXPOSTO: cada
///    esfera tem que ser pulada. Mas ele também acerta o boss de pé no chão
///    (o tiro dele sai a ~30px do chão e a caixa do boss começa a 16px), e
///    acerta igual no ar. Esse é o duelo: pula a esfera, atira, repete, 4
///    vezes. É a única parte da fase em que ele tem chão firme e espaço para
///    recuar enquanto faz isso.
///  - A plataforma do FOSSO está a 100px, ou seja, ACIMA da faixa da esfera:
///    ela é a ponte segura, a esfera passa por baixo dela. Mas o chão do
///    outro lado (a arena do boss) NÃO é seguro: pisar lá com o boss vivo é
///    voltar para h=0 a menos de 256px dele, onde a esfera nasce em cima do
///    jogador sem tempo de pular. Por isso matar o boss antes de atravessar
///    não é opcional — é a condição de sobrevivência, imposta só pela
///    geometria, sem precisar trancar o portal.
///
/// Se alguém baixar a plataforma do fosso para menos de ~59px, ela deixa de
/// ser ponte e vira armadilha (o jogador toma esfera em cima dela, sem espaço
/// para desviar). Se alguém encurtar o fosso, o boss chega perto demais da
/// trincheira e a esfera passa a nascer dentro dela, sem tempo de reação.
///
/// ## Orçamento do pulo (ver a tabela em [Fase])
///
/// Todos os vãos abaixo cabem no pulo NORMAL, sem depender do DEV mode:
///  - chão 900 → chão 1070: vão 170, no plano (alcance 220) — folga 50.
///  - chão 1900 → degrau 1: vão 120, subida 100 (alcance 180) — folga 60.
///  - degrau 1 → degrau 2: vão 100, subida 100 (alcance 180) — folga 80.
///  - degrau 2 → degrau 3: vão 100, descida de 100 — folga de sobra.
///  - degrau 3 → chão 2600: vão 50, descida de 100 — folga de sobra.
///  - trincheira 2850 → ponte do fosso: vão 120, subida 100 (alcance 180) —
///    folga 60.
///  - ponte do fosso → arena 3150: vão 80, descida de 100 — folga de sobra (o
///    salto de saída tem que ser fácil: ele é dado com o boss na cara).
///
/// Tamanho horizontal próprio: a arte desta fase é 2172 × 724 px (bem mais
/// larga, aspecto 3.0). O mapa acompanha a largura da arte (largura × 2 ≈ 4340),
/// e o cenário é travado na borda da imagem para nunca mostrar faixa branca.
final faseAndar2Fase5 = Fase(
  andar: 2,
  numero: 5,
  level: LevelData(
    size: const Size(4340, 600), // tamanho do mapa (largura da arte × 2, altura do chão)
    offset: const Offset(800, 0), // deslocamento inicial do mapa para a direita, para que o jogador nasça no início real do mapa (x=50) e não no canto esquerdo da tela
    backgroundImage: 'lib/Images/Fases/Andar2/Fase2-5.png',
    larguraDoMapa: 4340,
    imgWidth: 2172,
    imgHeight: 724,
  ),

  // Chão em quatro pedaços, com três buracos entre eles: o salto simples, o
  // buraco longo do arco, e o fosso do boss. A trincheira (2600 → 2850) é o
  // pedaço de chão entre os dois últimos buracos: é a arena do duelo, e o
  // último chão seguro da fase enquanto o boss estiver vivo.
  groundSegments: const [
    GroundSegment(double.negativeInfinity, 900),
    GroundSegment(1070, 1900),
    GroundSegment(2600, 2850), // trincheira: a arena do duelo
    GroundSegment(3150, double.infinity), // arena do boss + portal
  ],

  // 4 plataformas, todas relativas ao chão (groundY) para funcionar em
  // qualquer tela. As 3 primeiras formam o arco sobre o buraco longo; a
  // quarta é a única travessia do fosso do boss.
  //
  // A altura da ponte do fosso (100px) NÃO é arbitrária: ela está acima dos
  // ~59px que a esfera do boss alcança (ver "A geometria do duelo"), então a
  // esfera passa por baixo e a travessia em si é segura. O perigo é o chão do
  // outro lado, não a ponte.
  criarPlataformas: (groundY) => [
    Objects(x: 2020, y: groundY - 100, width: 110), // degrau 1 (sobe)
    Objects(x: 2230, y: groundY - 200, width: 110), // degrau 2 (topo)
    Objects(x: 2440, y: groundY - 100, width: 110), // degrau 3 (desce)
    Objects(x: 2970, y: groundY - 100, width: 100), // ponte do fosso
  ],

  // Um inimigo comum guardando a zona intermediária (x=1400), mais o boss.
  // O comum fica bem antes da trincheira, no chão intermediário, só para
  // encarecer a aproximação — não invade a arena do duelo, onde a esfera do
  // boss já é o único perigo que importa.
  //
  // O boss nasce em pé no chão da arena, colado no portal: o motor resolve o
  // Y dele sozinho, já contando que ele é 4x mais alto. Assim que o jogador
  // se move, ele avança para a beira do fosso e trava ali (a IA de borda não
  // deixa inimigo andar para dentro de buraco) — exatamente onde precisa
  // estar para cobrir a travessia.
  criarInimigos: (groundY) => const [
    EnemySpawn(1400),
    EnemySpawn(3970, tipo: EnemyType.boss),
  ],
);
