import 'dart:ui';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 1 — Fase 3.
///
/// Fase montada apenas com o cenário de fundo específico desta fase e um chão
/// infinito que cobre 100% do mapa. O comportamento (física, câmera, tiro,
/// inimigo) é comum e vive no GameBoard.
///
/// Tamanho horizontal próprio: a arte desta fase é 1774 × 887 px. O mapa
/// acompanha a largura da arte (largura da arte × 2 ≈ 3550), e o cenário é
/// travado na borda da imagem para nunca mostrar faixa branca.
final faseAndar1Fase3 = Fase(
  andar: 1,
  numero: 3,
  level: LevelData(
    size: const Size(3550, 600),
    offset: const Offset(800, 0),
    backgroundImage: 'lib/Images/Fases/Andar1/Fase1-3.png',
    larguraDoMapa: 3550,
    imgWidth: 1774,
    imgHeight: 887,
  ),

  // Chão único e contínuo cobrindo 100% do mapa, do início ao fim.
  groundSegments: const [
    GroundSegment(double.negativeInfinity, double.infinity),
  ],

  // Só cenário + chão: sem plataformas flutuantes nesta fase.
  criarPlataformas: () => [],
);
