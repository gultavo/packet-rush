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

bool get _isMobile => // Propriedade privada para testar se a plataforma é nativamente mobile (impede bugs na web/desktop).
    defaultTargetPlatform == TargetPlatform.android || // Retorna true se for um smartphone/tablet Android.
    defaultTargetPlatform == TargetPlatform.iOS; // Retorna true se for um iPhone/iPad.

/// Pede ao sistema a orientação desejada.
void aplicarOrientacao({required bool retrato}) { // Função responsável por pedir a trava de tela pro sistema operacional.
  SystemChrome.setPreferredOrientations( // Invoca o bloqueio oficial do SO via canais do Flutter.
    retrato // Uma condicional avalia: a tela pedida é 'retrato'?
        ? [DeviceOrientation.portraitUp] // Se sim, force e permita apenas o modo em pé.
        : [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight], // Se não, libere o aparelho para deitar p/ direita ou esquerda.
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
  final bool retrato; // verifica se a tela precisa estar em retrato (true) ou paisagem (false)
  final Widget child; // renderiza só dps de girar

  const OrientacaoFixa({
    super.key, 
    this.retrato = true, //true é default se n informar
    required this.child, //passa qual é a tela
  });

  @override
  State<OrientacaoFixa> createState() => _OrientacaoFixaState();
}

class _OrientacaoFixaState extends State<OrientacaoFixa> {
  @override
  void initState() {
    super.initState(); 
    aplicarOrientacao(retrato: widget.retrato); // aplica a orientação
  }

  @override
  void didUpdateWidget(OrientacaoFixa oldWidget) {
    super.didUpdateWidget(oldWidget); //padrão do flutter de reconstrução
    if (oldWidget.retrato != widget.retrato) { //compara com a orientação antiga, pra ver se mudou
      aplicarOrientacao(retrato: widget.retrato); // reaplica a orientação se mudou
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
