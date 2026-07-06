import '../levels.dart';
import '../objects.dart';
import 'fase.dart';

/// Fase 1 do Andar 2.
///
/// Construção específica desta fase. O comportamento (física, câmera,
/// controles, tiro, renderização) mora no GameBoard e é comum a todas as fases.
final faseAndar2Fase1 = Fase(
  andar: 2,
  numero: 1,
  level: levelOne,

  // Chão único e contínuo ao longo de todo o mapa.
  // Para criar um GAP: divida em dois segmentos com intervalo entre eles,
  // ex: [GroundSegment(double.negativeInfinity, 300), GroundSegment(600, double.infinity)].
  groundSegments: const [
    GroundSegment(double.negativeInfinity, double.infinity),
  ],

  // Plataformas flutuantes desta fase.
  criarPlataformas: () => [
    Objects(x: 350, y: 500, width: 64 * 4),
    Objects(x: 550, y: 400, width: 64 * 4),
    Objects(x: 750, y: 300, width: 64 * 4),
  ],
);
