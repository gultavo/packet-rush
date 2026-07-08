import 'package:flutter/material.dart';
import '../game_board.dart';
import '../fases/todas_as_fases.dart';
import 'seletor_fases_do_andar.dart';

/// Tela de seleção de camadas (andares) — usa a arte `MenuJogar.png`.
///
/// A arte já traz o cenário, o título e os botões desenhados (as 5 camadas
/// TCP/IP, o voltar e o CONTINUAR). Aqui apenas sobrepomos áreas clicáveis
/// (hotspots) exatamente sobre cada botão, como no `MenuInicial`.
///
/// Mapa de camadas → andares (como na arte, o prédio vai da Física embaixo até
/// a Aplicação no topo):
///   5 APLICAÇÃO → Andar 5   |   4 TRANSPORTE → Andar 4   |   3 REDE → Andar 3
///   2 ENLACE    → Andar 2   |   1 FÍSICA     → Andar 1
class SeletorFases extends StatelessWidget {
  const SeletorFases({super.key});

  // Caminho e dimensões nativas da arte.
  static const String _bg = 'lib/Images/Menu/MenuJogar.png';
  static const double _imgW = 856;
  static const double _imgH = 1838;

  // Retângulos dos botões em frações da imagem (x, y, largura, altura), medidos
  // sobre a arte. Por serem frações, acompanham a imagem em qualquer tela.
  static const Rect _btnVoltar = Rect.fromLTWH(0.065, 0.048, 0.115, 0.058);

  // As 5 camadas, de cima para baixo (Aplicação → Física).
  static const Rect _btnAplicacao = Rect.fromLTWH(0.205, 0.280, 0.585, 0.101); // Andar 5
  static const Rect _btnTransporte = Rect.fromLTWH(0.205, 0.392, 0.585, 0.103); // Andar 4
  static const Rect _btnRede = Rect.fromLTWH(0.205, 0.509, 0.585, 0.103); // Andar 3
  static const Rect _btnEnlace = Rect.fromLTWH(0.205, 0.626, 0.585, 0.084); // Andar 2
  static const Rect _btnFisica = Rect.fromLTWH(0.205, 0.724, 0.585, 0.090); // Andar 1

  static const Rect _btnContinuar = Rect.fromLTWH(0.245, 0.878, 0.510, 0.072);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final geo = _CoverGeometry(constraints.biggest, _imgW, _imgH);
          return Stack(
            children: [
              // Fundo: a arte cobrindo a tela inteira.
              Positioned.fill(child: Image.asset(_bg, fit: BoxFit.cover)),

              // Voltar → menu.
              _hotspot(
                geo,
                _btnVoltar,
                const Color(0xFFFF8A00),
                () => Navigator.of(context).maybePop(),
              ),

              // Camadas → lista de fases do andar correspondente.
              _hotspot(geo, _btnAplicacao, camadas[5]!.cor, () => _abrirAndar(context, 5)),
              _hotspot(geo, _btnTransporte, camadas[4]!.cor, () => _abrirAndar(context, 4)),
              _hotspot(geo, _btnRede, camadas[3]!.cor, () => _abrirAndar(context, 3)),
              _hotspot(geo, _btnEnlace, camadas[2]!.cor, () => _abrirAndar(context, 2)),
              _hotspot(geo, _btnFisica, camadas[1]!.cor, () => _abrirAndar(context, 1)),

              // CONTINUAR → fase atual do jogador (hoje = Fase 1; futuro = DB).
              _hotspot(
                geo,
                _btnContinuar,
                const Color(0xFFFF8A00),
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => GameBoard(fase: faseAtual)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _abrirAndar(BuildContext context, int andar) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SeletorFasesDoAndar(andar: andar)),
    );
  }

  /// Área transparente e clicável exatamente sobre um botão da arte, com um
  /// leve brilho (na cor do botão) ao tocar.
  Widget _hotspot(_CoverGeometry geo, Rect frac, Color cor, VoidCallback onTap) {
    final r = geo.rectFromFraction(frac);
    return Positioned(
      left: r.left,
      top: r.top,
      width: r.width,
      height: r.height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(r.height * 0.28),
          splashColor: cor.withValues(alpha: 0.35),
          highlightColor: cor.withValues(alpha: 0.15),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

/// Calcula onde a imagem realmente aparece na tela com [BoxFit.cover], para que
/// os hotspots caiam exatamente sobre ela mesmo quando a proporção da tela é
/// diferente da proporção da imagem. (Mesma lógica do MenuInicial.)
class _CoverGeometry {
  final double left;
  final double top;
  final double dispW;
  final double dispH;

  _CoverGeometry._(this.left, this.top, this.dispW, this.dispH);

  factory _CoverGeometry(Size container, double imgW, double imgH) {
    final scaleX = container.width / imgW;
    final scaleY = container.height / imgH;
    final scale = scaleX > scaleY ? scaleX : scaleY; // cover = maior escala
    final dispW = imgW * scale;
    final dispH = imgH * scale;
    final left = (container.width - dispW) / 2;
    final top = (container.height - dispH) / 2;
    return _CoverGeometry._(left, top, dispW, dispH);
  }

  Rect rectFromFraction(Rect f) => Rect.fromLTWH(
        left + f.left * dispW,
        top + f.top * dispH,
        f.width * dispW,
        f.height * dispH,
      );
}
