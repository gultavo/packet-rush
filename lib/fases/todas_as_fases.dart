import 'fase.dart';
import 'fase_content.dart'; // Importante para puxar os conteúdos didáticos

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

/// Helper para injetar título, conteúdo didático e perguntas
/// diretamente da base central de conteúdos para a Fase correspondente.
Fase _injetar(Fase fase) {
  final chave = '${fase.andar}_${fase.numero}';
  final content = faseContents[chave];
  
  if (content != null) {
    fase.titulo = content.titulo;
    fase.conteudo = content.conteudo;
    fase.perguntas = content.perguntas;
  }
  
  return fase;
}

/// Registro central de todas as fases do jogo, agrupadas por andar e já em
/// ordem. As fases recebem o conteúdo didático ao serem listadas.
final List<List<Fase>> andares = [
  // Andar 1
  [
    _injetar(faseAndar1Fase1),
    _injetar(faseAndar1Fase2),
    _injetar(faseAndar1Fase3),
    _injetar(faseAndar1Fase4),
    _injetar(faseAndar1Fase5),
  ],
  // Andar 2
  [
    _injetar(faseAndar2Fase1),
    _injetar(faseAndar2Fase2),
    _injetar(faseAndar2Fase3),
    _injetar(faseAndar2Fase4),
    _injetar(faseAndar2Fase5),
  ],
  // Andar 3
  [
    _injetar(faseAndar3Fase1),
    _injetar(faseAndar3Fase2),
    _injetar(faseAndar3Fase3),
    _injetar(faseAndar3Fase4),
    _injetar(faseAndar3Fase5),
    _injetar(faseAndar3Fase6),
  ],
  // Andar 4
  [
    _injetar(faseAndar4Fase1),
    _injetar(faseAndar4Fase2),
    _injetar(faseAndar4Fase3),
    _injetar(faseAndar4Fase4),
    _injetar(faseAndar4Fase5),
  ],
  // Andar 5
  [
    _injetar(faseAndar5Fase1),
    _injetar(faseAndar5Fase2),
    _injetar(faseAndar5Fase3),
    _injetar(faseAndar5Fase4),
    _injetar(faseAndar5Fase5),
    _injetar(faseAndar5Fase6),
  ],
];

/// Fase "atual" do jogador — usada pelo botão CONTINUAR.
Fase get faseAtual => andares.first.first;