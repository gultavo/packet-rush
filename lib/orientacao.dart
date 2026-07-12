import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Orientação de tela: trava a orientação que cada tela precisa e garante que
/// a rotação física do aparelho TERMINE antes de qualquer coisa ser desenhada.
///
/// Sem essa espera, a tela nova aparecia por um instante na orientação velha
/// (menu deitado, quiz de lado) e só depois "pulava" para o lugar certo,
/// quando o giro terminava.
///
/// No desktop/web nada disso se aplica: a janela não gira, e esperar por uma
/// rotação que nunca vem deixaria a tela preta para sempre.

bool get _isMobile =>
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;

/// Pede ao sistema a orientação desejada.
void aplicarOrientacao({required bool retrato}) {
  SystemChrome.setPreferredOrientations(
    retrato
        ? [DeviceOrientation.portraitUp]
        : [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
  );
}

/// A tela já está na orientação pedida? Enquanto for `false`, não desenhe
/// nada: o aparelho ainda está girando.
bool orientacaoPronta(MediaQueryData mq, {required bool retrato}) {
  if (!_isMobile) return true;
  return (mq.orientation == Orientation.portrait) == retrato;
}

/// Tela preta mostrada enquanto o aparelho gira. Um frame preto é bem melhor
/// que ver a tela montada de lado e depois pular de lugar.
class TelaGirando extends StatelessWidget {
  const TelaGirando({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(),
    );
  }
}

/// Envolve uma tela que precisa de uma orientação fixa: pede a rotação e só
/// constrói [child] quando o aparelho já girou.
///
/// Reaplica a orientação sempre que a tela é reconstruída fora da orientação
/// certa — é o que faz o menu voltar para retrato sozinho quando o jogador
/// sai de uma fase que estava rodando em paisagem.
class OrientacaoFixa extends StatefulWidget {
  final bool retrato;
  final Widget child;

  const OrientacaoFixa({
    super.key,
    this.retrato = true,
    required this.child,
  });

  @override
  State<OrientacaoFixa> createState() => _OrientacaoFixaState();
}

class _OrientacaoFixaState extends State<OrientacaoFixa> {
  @override
  void initState() {
    super.initState();
    aplicarOrientacao(retrato: widget.retrato);
  }

  @override
  void didUpdateWidget(OrientacaoFixa oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.retrato != widget.retrato) {
      aplicarOrientacao(retrato: widget.retrato);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Uma rota que está POR BAIXO de outra (o menu enquanto a fase roda em
    // cima dele) continua no ar e é reconstruída quando a orientação muda.
    // Sem esta guarda, ela reagiria à paisagem da fase pedindo retrato de
    // volta — as duas telas ficariam brigando pela orientação. Só a tela
    // visível manda na rotação.
    final visivel = ModalRoute.of(context)?.isCurrent ?? true;
    if (!visivel) return widget.child;

    if (!orientacaoPronta(MediaQuery.of(context), retrato: widget.retrato)) {
      // Repete o pedido: esta tela pode ter voltado à tona depois de outra
      // (a fase, por exemplo) ter mexido na orientação.
      aplicarOrientacao(retrato: widget.retrato);
      return const TelaGirando();
    }
    return widget.child;
  }
}
