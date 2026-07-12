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

  // Plataformas flutuantes desta fase, em escada, posicionadas relativas ao
  // chão (groundY) para funcionar em qualquer tamanho de tela.
  criarPlataformas: (groundY) => [
    Objects(x: 350, y: groundY - 100, width: 64 * 4),
    Objects(x: 550, y: groundY - 190, width: 64 * 4),
    Objects(x: 750, y: groundY - 280, width: 64 * 4),
  ],
);
