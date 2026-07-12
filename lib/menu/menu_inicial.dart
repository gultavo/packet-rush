import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'seletor_fases.dart';
import 'configuracoes.dart';

/// Tela inicial do jogo.
///
/// O fundo é a própria arte do wireframe (MenuInicial.png), que já contém o
/// cenário, o título e os botões desenhados. Aqui apenas sobrepomos áreas
/// clicáveis (hotspots) exatamente sobre os botões pintados, de modo que a
/// tela fica pixel-perfect e os botões passam a responder ao toque.
class MenuInicial extends StatelessWidget {
  const MenuInicial({super.key});

  // Caminho e dimensões nativas da imagem de fundo.
  static const String _bg = 'lib/Images/Menu/MenuInicial.png';
  static const double _imgW = 509;
  static const double _imgH = 1100;

  // Retângulos dos botões em frações da imagem (x, y, largura, altura),
  // medidos diretamente sobre a arte. Como são frações, os hotspots
  // acompanham a imagem em qualquer tamanho/proporção de tela.
  static const Rect _btnContinue = Rect.fromLTWH(0.236, 0.453, 0.530, 0.068);
  static const Rect _btnOptions = Rect.fromLTWH(0.236, 0.539, 0.530, 0.066);
  static const Rect _btnExit = Rect.fromLTWH(0.236, 0.625, 0.530, 0.066);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Preto por trás para que qualquer sobra fora da imagem não apareça.
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final geo = _CoverGeometry(constraints.biggest, _imgW, _imgH);
          return Stack(
            children: [
              // Fundo: réplica exata da arte, cobrindo a tela inteira.
              Positioned.fill(
                child: Image.asset(_bg, fit: BoxFit.cover),
              ),

              // Hotspots sobre os botões desenhados.
              _hotspot(geo, _btnContinue, () => _continuar(context)),
              _hotspot(geo, _btnOptions, () => _opcoes(context)),
              _hotspot(geo, _btnExit, _sair),
            ],
          );
        },
      ),
    );
  }

  /// Área transparente e clicável posicionada exatamente sobre um botão da arte.
  /// Dá um leve brilho laranja ao tocar, combinando com o neon dos botões.
  Widget _hotspot(_CoverGeometry geo, Rect frac, VoidCallback onTap) {
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
          splashColor: const Color(0x55FF8A00),
          highlightColor: const Color(0x22FF8A00),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  // CONTINUE → abre o seletor de fases.
  void _continuar(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SeletorFases()),
    );
  }

  // OPTIONS → abre a tela de Configurações (DEV, música).
  void _opcoes(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const Configuracoes()),
    );
  }

  // EXIT → fecha o aplicativo.
  void _sair() {
    SystemNavigator.pop();
  }
}

/// Calcula onde a imagem realmente aparece na tela quando exibida com
/// [BoxFit.cover], para que os hotspots caiam exatamente sobre ela mesmo
/// quando a proporção da tela é diferente da proporção da imagem.
class _CoverGeometry {
  final double left;
  final double top;
  final double dispW;
  final double dispH;

  _CoverGeometry._(this.left, this.top, this.dispW, this.dispH);

  factory _CoverGeometry(Size container, double imgW, double imgH) {
    final scaleX = container.width / imgW;
    final scaleY = container.height / imgH;
    // cover = usa a maior escala para preencher toda a tela.
    final scale = scaleX > scaleY ? scaleX : scaleY;

    final dispW = imgW * scale;
    final dispH = imgH * scale;
    final left = (container.width - dispW) / 2;
    final top = (container.height - dispH) / 2;
    return _CoverGeometry._(left, top, dispW, dispH);
  }

  /// Converte um retângulo em frações da imagem para pixels na tela.
  Rect rectFromFraction(Rect f) => Rect.fromLTWH(
    left + f.left * dispW,
    top + f.top * dispH,
    f.width * dispW,
    f.height * dispH,
  );
}
