import 'package:flutter/material.dart';
import '../game_board.dart';
import '../data/progresso_service.dart';
import '../fases/fase.dart';
import '../fases/todas_as_fases.dart';

/// Uma camada do modelo TCP/IP, associada a um andar do jogo.
///
/// As cores vêm direto da arte `MenuJogar.png` (cada camada tem seu neon).
class Camada {
  final String nome;
  final Color cor;
  const Camada(this.nome, this.cor);
}

/// Camadas por andar (andar 1..5). Física é o andar 1 (base do prédio) e
/// Aplicação é o andar 5 (topo), como na arte do seletor.
const Map<int, Camada> camadas = {
  1: Camada('FÍSICA', Color(0xFFF5424C)), // vermelho
  2: Camada('ENLACE', Color(0xFFFF8A00)), // laranja
  3: Camada('REDE', Color(0xFF44E04A)), // verde
  4: Camada('TRANSPORTE', Color(0xFF2FD2FF)), // ciano
  5: Camada('APLICAÇÃO', Color(0xFFB44DFF)), // roxo
};

/// Fases de um andar mostradas como uma **torre**: a Fase 1 é o térreo (base) e
/// as demais sobem, até a última no topo. Cada fase tem 5 estrelas embaixo
/// (pintadas pelos acertos do quiz) e pode estar bloqueada até a anterior ser
/// concluída — o modo DEV, nas Configurações, libera todas.
class SeletorFasesDoAndar extends StatefulWidget {
  final int andar;
  const SeletorFasesDoAndar({super.key, required this.andar});

  @override
  State<SeletorFasesDoAndar> createState() => _SeletorFasesDoAndarState();
}

class _SeletorFasesDoAndarState extends State<SeletorFasesDoAndar> {
  int get andar => widget.andar;
  Camada get _camada => camadas[andar]!;
  List<Fase> get _fases => andares[andar - 1];
  String get _fundo => 'lib/Images/Fases/Andar$andar/Fase$andar-1.png';

  @override
  Widget build(BuildContext context) {
    final cor = _camada.cor;
    // Torre de cima para baixo: última fase no topo, Fase 1 (térreo) na base.
    final fasesDeCimaParaBaixo = _fases.reversed.toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Cidade daquele andar ao fundo.
          Image.asset(_fundo, fit: BoxFit.cover, alignment: Alignment.center),

          // Escurecimento com um leve tom da cor da camada + vinheta.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xF2070510),
                  cor.withValues(alpha: 0.10),
                  const Color(0xF2070510),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.1,
                colors: [Colors.transparent, Color(0x99000000)],
                stops: [0.55, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topo(context, cor),
                const SizedBox(height: 4),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
                    // Center + FittedBox: a torre fica sempre centralizada na
                    // tela e, se for mais alta que o espaço, encolhe por igual
                    // para caber inteira (sem rolagem e sem cortar fases).
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            for (int i = 0; i < fasesDeCimaParaBaixo.length; i++)
                              _andarDaTorre(
                                fasesDeCimaParaBaixo[i],
                                cor,
                                ehTopo: i == 0,
                                ehBase: i == fasesDeCimaParaBaixo.length - 1,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Voltar + "ANDAR n · NOME" no neon da camada.
  Widget _topo(BuildContext context, Color cor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 18, 8),
      child: Row(
        children: [
          _moldura(
            cor: cor,
            onTap: () => Navigator.of(context).maybePop(),
            padding: const EdgeInsets.all(10),
            child: Icon(Icons.chevron_left, color: cor, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: 2,
                ),
                children: [
                  const TextSpan(
                    text: 'ANDAR ',
                    style: TextStyle(color: Color(0xFFF6EAD0)),
                  ),
                  TextSpan(
                    text: '$andar  ·  ${_camada.nome}',
                    style: TextStyle(
                      color: cor,
                      shadows: [
                        Shadow(color: cor, blurRadius: 10),
                        Shadow(color: cor.withValues(alpha: 0.6), blurRadius: 22),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Um nível da torre: conector superior + botão da fase + estrelas.
  Widget _andarDaTorre(
    Fase fase,
    Color cor, {
    required bool ehTopo,
    required bool ehBase,
  }) {
    final desbloqueada = ProgressoService.instance.faseDesbloqueada(
      fase.andar,
      fase.numero,
    );
    final estrelas = ProgressoService.instance.estrelas(fase.andar, fase.numero);

    return Column(
      children: [
        // Conector para o andar de cima (não aparece no topo).
        if (!ehTopo) _conector(cor, desbloqueada),
        _botaoFase(fase, cor, desbloqueada, estrelas),
        const SizedBox(height: 8),
        _estrelas(estrelas),
        if (ehBase) ...[
          const SizedBox(height: 6),
          Text(
            'TÉRREO',
            style: TextStyle(
              color: cor.withValues(alpha: 0.8),
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 4,
            ),
          ),
        ],
      ],
    );
  }

  Widget _conector(Color cor, bool ativo) {
    return Container(
      width: 6,
      height: 26,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: (ativo ? cor : Colors.white24).withValues(alpha: ativo ? 0.6 : 0.2),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  // Botão da fase (largo, para empilhar como torre). Bloqueado mostra cadeado.
  Widget _botaoFase(Fase fase, Color cor, bool desbloqueada, int estrelas) {
    final corEfetiva = desbloqueada ? cor : const Color(0xFF6B6B6B);

    return Opacity(
      opacity: desbloqueada ? 1.0 : 0.72,
      child: _moldura(
        cor: corEfetiva,
        onTap: desbloqueada
            ? () => _abrirFase(fase)
            : () => _avisoBloqueada(),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
        child: SizedBox(
          width: 180,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'FASE',
                    style: TextStyle(
                      color: corEfetiva.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${fase.numero}',
                    style: TextStyle(
                      color: desbloqueada
                          ? const Color(0xFFF9F1DE)
                          : const Color(0xFFBDBDBD),
                      fontWeight: FontWeight.w900,
                      fontSize: 34,
                      height: 1.0,
                      shadows: desbloqueada
                          ? [Shadow(color: cor, blurRadius: 14)]
                          : null,
                    ),
                  ),
                ],
              ),
              if (!desbloqueada) ...[
                const SizedBox(width: 16),
                const Icon(Icons.lock_rounded, color: Color(0xFFBDBDBD), size: 30),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Cinco estrelas embaixo do botão, pintadas pelos acertos do quiz.
  Widget _estrelas(int qtd) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: Icon(
              i < qtd ? Icons.star_rounded : Icons.star_border_rounded,
              size: 22,
              color: i < qtd ? Colors.amber : Colors.grey,
            ),
          ),
      ],
    );
  }

  Future<void> _abrirFase(Fase fase) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GameBoard(fase: fase)),
    );
    // Ao voltar do jogo, atualiza estrelas e desbloqueios.
    if (mounted) setState(() {});
  }

  void _avisoBloqueada() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fase bloqueada — conclua a fase anterior para liberar.'),
        duration: Duration(milliseconds: 1600),
      ),
    );
  }

  // Moldura "tech" biselada no neon da camada.
  Widget _moldura({
    required Color cor,
    required VoidCallback onTap,
    required Widget child,
    required EdgeInsets padding,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: cor.withValues(alpha: 0.30),
        highlightColor: cor.withValues(alpha: 0.12),
        child: Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(cor, Colors.white, 0.35)!,
                cor,
                Color.lerp(cor, Colors.black, 0.55)!,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(color: cor.withValues(alpha: 0.55), blurRadius: 16),
              BoxShadow(color: cor.withValues(alpha: 0.22), blurRadius: 30, spreadRadius: 1),
            ],
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xF21A1206), Color(0xF20A0702)],
              ),
              border: Border.all(color: cor.withValues(alpha: 0.45), width: 1),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
