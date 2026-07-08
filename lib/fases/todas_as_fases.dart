import 'fase.dart';

import 'andar1_fase1.dart';
import 'andar1_fase2.dart';
import 'andar1_fase3.dart';
import 'andar1_fase4.dart';
import 'andar1_fase5.dart';

import 'andar2_fase1.dart';
import 'andar2_fase2.dart';
import 'andar2_fase3.dart';
import 'andar2_fase4.dart';
import 'andar2_fase5.dart';

import 'andar3_fase1.dart';
import 'andar3_fase2.dart';
import 'andar3_fase3.dart';
import 'andar3_fase4.dart';
import 'andar3_fase5.dart';
import 'andar3_fase6.dart';

import 'andar4_fase1.dart';
import 'andar4_fase2.dart';
import 'andar4_fase3.dart';
import 'andar4_fase4.dart';
import 'andar4_fase5.dart';

import 'andar5_fase1.dart';
import 'andar5_fase2.dart';
import 'andar5_fase3.dart';
import 'andar5_fase4.dart';
import 'andar5_fase5.dart';
import 'andar5_fase6.dart';

/// Registro central de todas as fases do jogo, agrupadas por andar e já em
/// ordem. Serve para o seletor de fases montar a tela automaticamente e, no
/// futuro, para uma progressão (terminar uma fase leva à próxima).
///
/// `andares[i]` é a lista de fases do andar (i + 1).
final List<List<Fase>> andares = [
  // Andar 1
  [
    faseAndar1Fase1,
    faseAndar1Fase2,
    faseAndar1Fase3,
    faseAndar1Fase4,
    faseAndar1Fase5,
  ],
  // Andar 2
  [
    faseAndar2Fase1,
    faseAndar2Fase2,
    faseAndar2Fase3,
    faseAndar2Fase4,
    faseAndar2Fase5,
  ],
  // Andar 3
  [
    faseAndar3Fase1,
    faseAndar3Fase2,
    faseAndar3Fase3,
    faseAndar3Fase4,
    faseAndar3Fase5,
    faseAndar3Fase6,
  ],
  // Andar 4
  [
    faseAndar4Fase1,
    faseAndar4Fase2,
    faseAndar4Fase3,
    faseAndar4Fase4,
    faseAndar4Fase5,
  ],
  // Andar 5
  [
    faseAndar5Fase1,
    faseAndar5Fase2,
    faseAndar5Fase3,
    faseAndar5Fase4,
    faseAndar5Fase5,
    faseAndar5Fase6,
  ],
];

/// Fase "atual" do jogador — usada pelo botão CONTINUAR.
///
/// Por enquanto retorna sempre a primeira fase (Andar 1 / Fase 1). No futuro,
/// quando existir o banco de dados local, este é o ÚNICO ponto a mudar: basta
/// ler daqui a fase mais avançada que o jogador alcançou.
Fase get faseAtual => andares.first.first;
