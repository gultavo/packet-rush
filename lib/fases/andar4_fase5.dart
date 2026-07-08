import 'dart:ui';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 4 — Fase 5.
///
/// Fase montada apenas com o cenário de fundo específico desta fase e um chão
/// infinito que cobre 100% do mapa. O comportamento (física, câmera, tiro,
/// inimigo) é comum e vive no GameBoard.
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

  // Chão único e contínuo cobrindo 100% do mapa, do início ao fim.
  groundSegments: const [
    GroundSegment(double.negativeInfinity, double.infinity),
  ],

  // Só cenário + chão: sem plataformas flutuantes nesta fase.
  criarPlataformas: () => [],
);
