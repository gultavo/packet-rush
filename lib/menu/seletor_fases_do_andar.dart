import 'package:flutter/material.dart';
import '../game_board.dart';
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

/// Lista de fases de um andar (uma camada). Aberta ao tocar numa camada no
/// seletor. Combina com a arte: fundo é a cidade daquele andar (escurecida) e
/// os botões usam o neon da camada.
class SeletorFasesDoAndar extends StatelessWidget {
  final int andar;
  const SeletorFasesDoAndar({super.key, required this.andar});

  Camada get _camada => camadas[andar]!;
  List<Fase> get _fases => andares[andar - 1];
  String get _fundo => 'lib/Images/Fases/Andar$andar/Fase$andar-1.png';

  @override
  Widget build(BuildContext context) {
    final cor = _camada.cor;
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
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 10, 22, 36),
                    child: Wrap(
                      spacing: 18,
                      runSpacing: 18,
                      children: [
                        for (final fase in _fases) _botaoFase(context, fase, cor),
                      ],
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

  // Botão quadrado da fase: painel biselado no neon da camada + número grande.
  Widget _botaoFase(BuildContext context, Fase fase, Color cor) {
    return _moldura(
      cor: cor,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => GameBoard(fase: fase)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'FASE',
            style: TextStyle(
              color: cor.withValues(alpha: 0.9),
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${fase.numero}',
            style: TextStyle(
              color: const Color(0xFFF9F1DE),
              fontWeight: FontWeight.w900,
              fontSize: 34,
              height: 1.0,
              shadows: [Shadow(color: cor, blurRadius: 14)],
            ),
          ),
        ],
      ),
    );
  }

  // Moldura "tech" biselada no neon da camada (mesma linguagem dos botões do
  // menu, mas colorida por camada).
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
