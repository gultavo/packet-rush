import '../fases/fase.dart';
import '../fases/todas_as_fases.dart';
import 'configuracoes_service.dart';
import 'progresso_repository.dart';

/// Fachada de alto nível para o progresso do jogador.
///
/// Junta os dados do banco ([ProgressoRepository]) com a ordem das fases do
/// jogo para responder ao que a interface precisa: onde continuar, quais fases
/// estão desbloqueadas e quantas estrelas cada fase concluída tem.
///
/// Mantém tudo em memória (carregado uma vez no arranque) para que o seletor e
/// o botão CONTINUAR leiam os valores de forma síncrona.
class ProgressoService {
  ProgressoService._();

  /// Instância única usada em todo o app.
  static final ProgressoService instance = ProgressoService._();

  final ProgressoRepository _repo = ProgressoRepository();

  /// Mínimo de acertos (de 5) no quiz para a fase ser considerada aprovada —
  /// o que destrava a próxima fase. Tentativas abaixo disso ainda guardam as
  /// estrelas (melhor desempenho), só não avançam nem destravam nada.
  static const int minAcertosParaPassar = 3;

  /// Acertos (0–5) por fase, indexado por [_chave]. A presença da chave
  /// indica que a fase já foi tentada ao menos uma vez (não necessariamente
  /// aprovada — veja [faseConcluida]).
  final Map<String, int> _acertosPorFase = {};

  /// Cache da fase aprovada mais avançada (null = nenhuma aprovada ainda).
  Progresso? _ultima;

  String _chave(int andar, int fase) => '${andar}_$fase';

  /// Carrega o progresso salvo do banco para a memória. Chame no arranque do
  /// app, antes de mostrar telas que dependem do progresso.
  Future<void> carregar() async {
    _acertosPorFase.clear();
    final concluidas = await _repo.carregarConcluidas();
    for (final p in concluidas) {
      _acertosPorFase[_chave(p.andar, p.fase)] = p.acertos;
    }
    _ultima = await _repo.ultimaConcluida(minAcertos: minAcertosParaPassar);
  }

  /// Registra uma tentativa da fase [andar]/[numero] com [acertos] respostas
  /// certas, atualizando os caches em memória. Chamado em toda tentativa,
  /// aprovada ou não, para que as estrelas reflitam o melhor resultado real;
  /// só avança "onde continuar" quando a tentativa aprova a fase.
  Future<void> registrarConclusao(int andar, int numero, int acertos) async {
    await _repo.registrarConclusao(andar, numero, acertos);

    // Mantém o melhor desempenho também em memória.
    final chave = _chave(andar, numero);
    final atual = _acertosPorFase[chave] ?? 0;
    final melhor = acertos > atual ? acertos : atual;
    _acertosPorFase[chave] = melhor;

    if (melhor < minAcertosParaPassar) return;

    if (_ultima == null || _vemDepois(andar, numero, _ultima!)) {
      _ultima = Progresso(
        andar: andar,
        fase: numero,
        acertos: melhor,
        concluidaEm: DateTime.now(),
      );
    }
  }

  /// Se a fase [andar]/[numero] foi aprovada (acertos >= [minAcertosParaPassar]),
  /// o que é o que destrava a próxima fase.
  bool faseConcluida(int andar, int numero) =>
      estrelas(andar, numero) >= minAcertosParaPassar;

  /// Estrelas (0–5) de uma fase: o número de acertos guardado, ou 0 se ainda
  /// não foi concluída.
  int estrelas(int andar, int numero) =>
      _acertosPorFase[_chave(andar, numero)] ?? 0;

  /// Se a fase [andar]/[numero] está liberada para jogar.
  ///
  /// Regras: no modo DEV tudo é liberado; a primeira fase do jogo é sempre
  /// liberada; as demais liberam quando a fase anterior (na ordem global) foi
  /// concluída.
  bool faseDesbloqueada(int andar, int numero) {
    if (ConfiguracoesService.instance.devMode) return true;

    final fases = todasAsFases;
    final indice = fases.indexWhere(
      (f) => f.andar == andar && f.numero == numero,
    );
    if (indice <= 0) return true; // primeira fase (ou não encontrada) liberada.

    final anterior = fases[indice - 1];
    return faseConcluida(anterior.andar, anterior.numero);
  }

  /// A fase onde o jogador deve continuar:
  /// - sem progresso → a primeira fase do jogo;
  /// - com progresso → a fase seguinte à última concluída;
  /// - se já concluiu tudo → permanece na última fase.
  Fase get faseParaContinuar {
    final ultima = _ultima;
    if (ultima == null) return primeiraFase;
    return proximaFaseApos(ultima.andar, ultima.fase) ??
        faseDe(ultima.andar, ultima.fase) ??
        primeiraFase;
  }

  /// Se o jogador já concluiu ao menos uma fase (há de onde continuar).
  bool get temProgresso => _ultima != null;

  /// `true` se a fase [andar]/[numero] vem depois de [ref] na ordem global.
  bool _vemDepois(int andar, int numero, Progresso ref) {
    if (andar != ref.andar) return andar > ref.andar;
    return numero > ref.fase;
  }
}
