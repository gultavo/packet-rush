import 'dart:ui';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 1 — Fase 1.
///
/// Primeira fase do jogo: introduz o jogador aos três elementos básicos que
/// vão se repetir e ficar mais difíceis nas próximas fases — inimigos,
/// plataformas e buracos no chão (cair neles custa uma vida).
///
/// Estrutura (da esquerda para a direita):
///  1. Zona inicial no chão, com o primeiro inimigo (x=500).
///  2. Um buraco largo (1450 → 2400) sem chão nenhum, atravessado por 3
///     plataformas em "degraus" (sobe, sobe, desce) — o primeiro desafio de
///     pulo da fase. Cada salto entre chão/plataformas fica entre 110 e
///     150px, dentro do alcance confortável do pulo normal.
///  3. Zona final no chão, com o segundo inimigo (x=2550) logo após o
///     buraco, e um trecho livre até o portal.
///
/// Tamanho horizontal próprio: a arte desta fase é 1942 × 809 px. O mapa
/// acompanha a largura da arte (largura da arte × 2 ≈ 3880), e o cenário é
/// travado na borda da imagem para nunca mostrar faixa branca.
final faseAndar1Fase1 = Fase(
  andar: 1,
  numero: 1,
  level: LevelData(
    size: const Size(3880, 600),
    offset: const Offset(800, 0),
    backgroundImage: 'lib/Images/Fases/Andar1/Fase1-1.png',
    larguraDoMapa: 3880,
    imgWidth: 1942,
    imgHeight: 809,
  ),

  // Chão em dois pedaços: zona inicial e zona final, com um buraco largo
  // entre 1450 e 2400 (sem chão nenhum ali — só as plataformas abaixo).
  groundSegments: const [
    GroundSegment(double.negativeInfinity, 1450),
    GroundSegment(2400, double.infinity),
  ],

  // As 3 plataformas em degrau que atravessam o buraco, posicionadas
  // relativas ao chão (groundY) para funcionar em qualquer tamanho de tela.
  // Vãos conferidos contra o alcance real do pulo normal (ver a tabela de
  // alcance em fase.dart): todos com folga de 50px ou mais.
  criarPlataformas: (groundY) => [
    Objects(x: 1560, y: groundY - 30, width: 140), // degrau 1 (baixo)
    Objects(x: 1830, y: groundY - 130, width: 140), // degrau 2 (topo)
    Objects(x: 2140, y: groundY - 30, width: 140), // degrau 3 (desce)
  ],

  // 2 inimigos: um antes do buraco (combate simples) e um logo depois
  // (testa o jogador já cansado do trecho de pulos).
  criarInimigos: (groundY) => const [
    EnemySpawn(500),
    EnemySpawn(2550),
  ],
);
