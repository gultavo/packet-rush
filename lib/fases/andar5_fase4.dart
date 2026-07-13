import 'dart:ui';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 5 — Fase 4.
///
/// A fase da verticalidade do andar, e um degrau acima da Fase 4 do Andar 4:
/// mantém a assinatura da "quarta fase" — o jogador sobe uma TORRE de plataformas
/// sobre o vazio, cruza o topo guardado e desce, com qualquer erro sendo queda
/// livre até o chão.
///
/// Aqui o andar esbarra num limite físico: a torre da Fase 4 do Andar 4 já chega
/// a 560px de pico, e isso NÃO é arbitrário — é praticamente o teto do mundo. O
/// mundo simulado tem altura fixa de 720px e o chão fica a 42px do fundo
/// (`_groundY` = 678), então uma plataforma a 560px tem o topo a apenas 118px da
/// borda de cima; com o jogador (70px de altura) em pé nela, a cabeça já quase
/// encosta no teto. Subir mais alto que isso empurraria o jogador para fora do
/// mundo. Por isso esta fase NÃO escala pela altura (que está no máximo), e sim
/// por dois outros vetores: (1) o topo deixa de ser uma ponte única e vira uma
/// CRISTA ESTICADA de duas pontes a 560px — o corredor aéreo mais longo do jogo,
/// herdando a assinatura das Fases 1 e 2 do andar; e (2) a crista inteira e toda
/// a descida são contestadas por QUATRO inimigos aéreos (contra os 3 do Andar 4),
/// num total de 8 inimigos e 9 plataformas (contra os 7 e 8 do Andar 4).
///
/// Estrutura (da esquerda para a direita):
///  1. Zona inicial no chão, com o primeiro inimigo (x=400).
///  2. Um salto direto de 170px (sem plataforma) — o maior salto direto no plano
///     que o pulo normal aguenta com folga.
///  3. Zona intermediária no chão, com o segundo inimigo (x=1150).
///  4. A torre: um buraco longo (1400 → 3310) sem chão nenhum, atravessado por 9
///     plataformas — 5 degraus subindo (até 560px, o teto do jogo), uma CRISTA de
///     2 pontes no topo e 2 degraus descendo. A subida é puro platforming sobre o
///     vazio (qualquer erro é queda livre até o chão). A crista esticada e toda a
///     descida são contestadas por quatro inimigos: um em cada ponte do topo e um
///     em cada degrau de descida, atirando enquanto o jogador cruza e desce.
///  5. Trecho final no chão, com o sétimo e oitavo inimigos (x=3430 e x=3560),
///     guardando o caminho até o portal.
///
/// ## Orçamento do pulo (ver a tabela em [Fase])
///
/// Todos os vãos abaixo cabem no pulo NORMAL, sem depender do DEV mode:
///  - chão 800 → chão 970: vão 170, no plano (alcance 220) — folga 50.
///  - chão 1400 → degrau 1: vão 100, subida 100 (alcance 180) — folga 80.
///  - degrau 1 → degrau 2: vão 100, subida 120 (alcance 160) — folga 60.
///  - degrau 2 → degrau 3: vão 100, subida 120 (alcance 160) — folga 60.
///  - degrau 3 → degrau 4: vão 100, subida 120 (alcance 160) — folga 60.
///  - degrau 4 → degrau 5 (topo): vão 100, subida 100 (alcance 180) — folga 80.
///  - degrau 5 → ponte 1: vão 100, no plano (alcance 220) — folga de sobra.
///  - ponte 1 → ponte 2: vão 100, no plano (alcance 220) — folga de sobra.
///  - ponte 2 → descida 1: vão 100, descida de 180 — folga de sobra.
///  - descida 1 → descida 2: vão 100, descida de 190 — folga de sobra.
///  - descida 2 → chão 3310: vão 20, descida de 190 — folga de sobra.
///
/// Tamanho horizontal próprio: a arte desta fase é 1983 × 793 px (aspecto 2.5).
/// O mapa acompanha a largura da arte (largura × 2 ≈ 3970), e o cenário é
/// travado na borda da imagem para nunca mostrar faixa branca.
final faseAndar5Fase4 = Fase(
  andar: 5,
  numero: 4,
  level: LevelData(
    size: const Size(3970, 600),
    offset: const Offset(800, 0),
    backgroundImage: 'lib/Images/Fases/Andar5/Fase5-4.png',
    larguraDoMapa: 3970,
    imgWidth: 1983,
    imgHeight: 793,
  ),

  // Chão em três pedaços: zona inicial, zona intermediária e zona final, com
  // o buraco da torre entre a segunda e a terceira (sem chão nenhum ali — só as
  // 9 plataformas). O primeiro buraco (800 → 970) é o salto direto de 170px.
  groundSegments: const [
    GroundSegment(double.negativeInfinity, 800),
    GroundSegment(970, 1400),
    GroundSegment(3310, double.infinity),
  ],

  // A torre: 5 degraus subindo (até 560px, o teto do jogo — ver a explicação do
  // limite de altura no cabeçalho), uma CRISTA de 2 pontes no topo (o corredor
  // aéreo esticado que substitui a subida por altura) e 2 degraus descendo, tudo
  // relativo ao chão (groundY). Vãos conferidos contra a tabela de alcance do
  // pulo normal (ver fase.dart):
  //  - chão 1400 → degrau 1: vão 100, subida 100 (alcance 180) — folga 80.
  //  - degrau 1 → degrau 2: vão 100, subida 120 (alcance 160) — folga 60.
  //  - degrau 2 → degrau 3: vão 100, subida 120 (alcance 160) — folga 60.
  //  - degrau 3 → degrau 4: vão 100, subida 120 (alcance 160) — folga 60.
  //  - degrau 4 → degrau 5 (topo): vão 100, subida 100 (alcance 180) — folga 80.
  //  - degrau 5 → ponte 1: vão 100, no plano (alcance 220) — folga de sobra.
  //  - ponte 1 → ponte 2: vão 100, no plano (alcance 220) — folga de sobra.
  //  - ponte 2 → descida 1: vão 100, descida de 180 — folga de sobra.
  //  - descida 1 → descida 2: vão 100, descida de 190 — folga de sobra.
  //  - descida 2 → chão 3310: vão 20, descida de 190 — folga de sobra.
  criarPlataformas: (groundY) => [
    Objects(x: 1500, y: groundY - 100, width: 110), // degrau 1 (sobe)
    Objects(x: 1710, y: groundY - 220, width: 110), // degrau 2 (sobe mais)
    Objects(x: 1920, y: groundY - 340, width: 110), // degrau 3 (sobe mais)
    Objects(x: 2130, y: groundY - 460, width: 110), // degrau 4 (sobe mais)
    Objects(x: 2340, y: groundY - 560, width: 110), // degrau 5 (topo)
    Objects(x: 2550, y: groundY - 560, width: 110), // ponte 1 no topo
    Objects(x: 2760, y: groundY - 560, width: 110), // ponte 2 no topo
    Objects(x: 2970, y: groundY - 380, width: 110), // descida 1
    Objects(x: 3180, y: groundY - 190, width: 110), // descida 2
  ],

  // 8 inimigos: dois no chão antes da torre, quatro contestando a crista e a
  // descida (ponte 1, ponte 2, descida 1 e descida 2 — os mais arriscados, cair
  // é queda livre até o chão) e dois guardando o trecho final antes do portal.
  criarInimigos: (groundY) => [
    const EnemySpawn(400),
    const EnemySpawn(1150),
    EnemySpawn(2605, y: groundY - 560 - 64), // na ponte 1 do topo
    EnemySpawn(2815, y: groundY - 560 - 64), // na ponte 2 do topo
    EnemySpawn(3025, y: groundY - 380 - 64), // no primeiro degrau de descida
    EnemySpawn(3235, y: groundY - 190 - 64), // no segundo degrau de descida
    const EnemySpawn(3430),
    const EnemySpawn(3560),
  ],
);
