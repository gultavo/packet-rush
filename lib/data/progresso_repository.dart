import 'database_helper.dart';

/// Uma fase concluída pelo jogador, como está guardada no banco.
class Progresso {
  final int andar;
  final int fase;

  /// Melhor número de respostas certas no quiz (0–5) — vira estrelas no seletor.
  final int acertos;
  final DateTime concluidaEm;

  const Progresso({
    required this.andar,
    required this.fase,
    required this.acertos,
    required this.concluidaEm,
  });

  factory Progresso.fromMap(Map<String, Object?> map) {
    return Progresso(
      andar: map['andar'] as int,
      fase: map['fase'] as int,
      acertos: (map['acertos'] as int?) ?? 0,
      concluidaEm: DateTime.parse(map['concluida_em'] as String),
    );
  }
}

/// Acesso de leitura/escrita ao progresso do jogador no banco SQLite.
///
/// Mantém apenas operações sobre a tabela `fases_concluidas`. Quem decide
/// *qual fase* jogar em seguida, quais estão desbloqueadas e quantas estrelas
/// exibir é o [ProgressoService], que combina estes dados com a ordem das fases.
class ProgressoRepository {
  final DatabaseHelper _helper;

  ProgressoRepository([DatabaseHelper? helper])
      : _helper = helper ?? DatabaseHelper.instance;

  /// Registra uma tentativa da fase [andar]/[fase], guardando [acertos]. Se a
  /// fase já tinha um registro, mantém o MAIOR número de acertos (o melhor
  /// desempenho do jogador) — chamado mesmo quando o jogador não passou, para
  /// que as estrelas do seletor reflitam o melhor resultado real.
  Future<void> registrarConclusao(int andar, int fase, int acertos) async {
    final db = await _helper.database;
    await db.rawInsert(
      '''
      INSERT INTO fases_concluidas (andar, fase, acertos, concluida_em)
      VALUES (?, ?, ?, ?)
      ON CONFLICT(andar, fase) DO UPDATE SET
        acertos = MAX(acertos, excluded.acertos),
        concluida_em = excluded.concluida_em
      ''',
      [andar, fase, acertos, DateTime.now().toIso8601String()],
    );
  }

  /// Todas as fases concluídas, em ordem (andar, fase).
  Future<List<Progresso>> carregarConcluidas() async {
    final db = await _helper.database;
    final linhas = await db.query(
      'fases_concluidas',
      orderBy: 'andar ASC, fase ASC',
    );
    return linhas.map(Progresso.fromMap).toList();
  }

  /// A fase efetivamente aprovada (acertos >= [minAcertos]) mais avançada
  /// (maior andar e, dentro dele, maior fase), ou `null` se nenhuma foi
  /// aprovada ainda. Tentativas registradas sem atingir [minAcertos] não
  /// contam aqui — só valem para as estrelas do seletor.
  Future<Progresso?> ultimaConcluida({required int minAcertos}) async {
    final db = await _helper.database;
    final linhas = await db.query(
      'fases_concluidas',
      where: 'acertos >= ?',
      whereArgs: [minAcertos],
      orderBy: 'andar DESC, fase DESC',
      limit: 1,
    );
    if (linhas.isEmpty) return null;
    return Progresso.fromMap(linhas.first);
  }

  /// Apaga todo o progresso (útil para um botão "recomeçar do zero").
  Future<void> limpar() async {
    final db = await _helper.database;
    await db.delete('fases_concluidas');
  }
}
