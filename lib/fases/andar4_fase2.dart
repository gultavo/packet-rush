import 'dart:ui';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 4 — Fase 2.
///
/// Fase montada apenas com o cenário de fundo específico desta fase e um chão
/// infinito que cobre 100% do mapa. O comportamento (física, câmera, tiro,
/// inimigo) é comum e vive no GameBoard.
///
/// Tamanho horizontal próprio: a arte desta fase é 1981 × 793 px (levemente
/// mais estreita, aspecto ~2.5). O mapa acompanha a largura da arte
/// (largura × 2 ≈ 3960), e o cenário é travado na borda da imagem para nunca
/// mostrar faixa branca.
final faseAndar4Fase2 = Fase(
  andar: 4,
  numero: 2,
  level: LevelData(
    size: const Size(3960, 600),
    offset: const Offset(800, 0),
    backgroundImage: 'lib/Images/Fases/Andar4/Fase4-2.png',
    larguraDoMapa: 3960,
    imgWidth: 1981,
    imgHeight: 793,
  ),

  // Chão único e contínuo cobrindo 100% do mapa, do início ao fim.
  groundSegments: const [
    GroundSegment(double.negativeInfinity, double.infinity),
  ],

  // Só cenário + chão: sem plataformas flutuantes nesta fase.
  criarPlataformas: (groundY) => [],
);
