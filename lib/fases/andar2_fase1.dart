import 'dart:ui';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 2 — Fase 1.
///
/// Abertura do Andar 2 (Camada de Enlace, "O Salão dos Quadros"). Como toda
/// primeira fase de um andar, ela reintroduz os três elementos básicos do
/// jogo num cenário novo — inimigos, plataformas e buracos no chão (cair
/// neles custa uma vida) — para reambientar o jogador antes de a dificuldade
/// voltar a subir nas Fases 2–5.
///
/// Estrutura (da esquerda para a direita):
///  1. Zona inicial no chão, com o primeiro inimigo (x=500) e um trecho livre
///     para o jogador se orientar.
///  2. Um buraco largo (1500 → 2450) sem chão nenhum, atravessado por 3
///     plataformas em "degrau" (sobe, sobe, desce) — o desafio de pulo da
///     fase. Cada salto fica entre 90 e 180px, todos dentro do alcance
///     confortável do pulo normal (ver a tabela de alcance em fase.dart).
///  3. Zona final no chão, com o segundo inimigo (x=2600) logo após o buraco,
///     e um trecho livre até o portal.
///
/// Tamanho horizontal próprio: a arte desta fase é 1983 × 793 px. O mapa
/// acompanha a largura da arte (largura da arte × 2 ≈ 3966), e o cenário é
/// travado na borda da imagem para nunca mostrar faixa branca.
final faseAndar2Fase1 = Fase(
  andar: 2,
  numero: 1,
  level: LevelData(
    size: const Size(3966, 600),
    offset: const Offset(800, 0),
    backgroundImage: 'lib/Images/Fases/Andar2/Fase2-1.png',
    larguraDoMapa: 3966,
    imgWidth: 1983,
    imgHeight: 793,
  ),

  // Chão em dois pedaços: zona inicial e zona final, com um buraco largo
  // entre 1500 e 2450 (sem chão nenhum ali — só as plataformas abaixo).
  groundSegments: const [
    GroundSegment(double.negativeInfinity, 1500),
    GroundSegment(2450, double.infinity),
  ],

  // As 3 plataformas em degrau que atravessam o buraco, posicionadas
  // relativas ao chão (groundY) para funcionar em qualquer tamanho de tela.
  // Vãos conferidos contra o alcance real do pulo normal (tabela em fase.dart):
  //  - chão 1500 → degrau 1: vão 120, subida 100 (alcance 180) — folga 60.
  //  - degrau 1 → degrau 2: vão 90, subida 100 (alcance 180) — folga 90.
  //  - degrau 2 → degrau 3: vão 140, descida de 100 — folga de sobra.
  //  - degrau 3 → chão 2450: vão 180, descida de 100 — folga de sobra.
  criarPlataformas: (groundY) => [
    Objects(x: 1620, y: groundY - 100, width: 140), // degrau 1 (sobe)
    Objects(x: 1850, y: groundY - 200, width: 140), // degrau 2 (topo)
    Objects(x: 2130, y: groundY - 100, width: 140), // degrau 3 (desce)
  ],

  // 2 inimigos: um antes do buraco (combate simples) e um logo depois (testa
  // o jogador já saindo do trecho de pulos).
  criarInimigos: (groundY) => const [
    EnemySpawn(500),
    EnemySpawn(2600),
  ],
);
