import 'dart:ui';
import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Andar 1 — Fase 5.
///
/// Fase montada apenas com o cenário de fundo específico desta fase e um chão
/// infinito que cobre 100% do mapa. O comportamento (física, câmera, tiro,
/// inimigo) é comum e vive no GameBoard.
///
/// Tamanho horizontal próprio: a arte desta fase é 1634 × 817 px (a mais
/// estreita do Andar 1). O mapa acompanha a largura da arte (largura × 2 ≈ 3270),
/// e o cenário é travado na borda da imagem para nunca mostrar faixa branca.
final faseAndar1Fase5 = Fase(
  andar: 1,
  numero: 5,
  level: LevelData(
    size: const Size(3270, 600),
    offset: const Offset(800, 0),
    backgroundImage: 'lib/Images/Fases/Andar1/Fase1-5.png',
    larguraDoMapa: 3270,
    imgWidth: 1634,
    imgHeight: 817,
  ),

  // Chão único e contínuo cobrindo 100% do mapa, do início ao fim.
  groundSegments: const [
    GroundSegment(double.negativeInfinity, double.infinity),
  ],

  // Só cenário + chão: sem plataformas flutuantes nesta fase.
  criarPlataformas: (groundY) => [],
);
