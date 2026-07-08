import 'dart:ui';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 1 — Fase 1.
///
/// Fase montada apenas com o cenário de fundo específico desta fase e um chão
/// infinito que cobre 100% do mapa. O comportamento (física, câmera, tiro,
/// inimigo) é comum e vive no GameBoard.
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

  // Chão único e contínuo cobrindo 100% do mapa, do início ao fim.
  groundSegments: const [
    GroundSegment(double.negativeInfinity, double.infinity),
  ],

  // Só cenário + chão: sem plataformas flutuantes nesta fase.
  criarPlataformas: () => [],
);
