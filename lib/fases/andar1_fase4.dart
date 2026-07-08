import 'dart:ui';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 1 — Fase 4.
///
/// Fase montada apenas com o cenário de fundo específico desta fase e um chão
/// infinito que cobre 100% do mapa. O comportamento (física, câmera, tiro,
/// inimigo) é comum e vive no GameBoard.
///
/// Tamanho horizontal próprio: a arte desta fase é 2172 × 724 px (bem mais
/// larga, aspecto 3.0). O mapa acompanha a largura da arte (largura × 2 ≈ 4340),
/// e o cenário é travado na borda da imagem para nunca mostrar faixa branca.
final faseAndar1Fase4 = Fase(
  andar: 1,
  numero: 4,
  level: LevelData(
    size: const Size(4340, 600),
    offset: const Offset(800, 0),
    backgroundImage: 'lib/Images/Fases/Andar1/Fase1-4.png',
    larguraDoMapa: 4340,
    imgWidth: 2172,
    imgHeight: 724,
  ),

  // Chão único e contínuo cobrindo 100% do mapa, do início ao fim.
  groundSegments: const [
    GroundSegment(double.negativeInfinity, double.infinity),
  ],

  // Só cenário + chão: sem plataformas flutuantes nesta fase.
  criarPlataformas: () => [],
);
