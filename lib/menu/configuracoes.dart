import 'package:flutter/material.dart';
import '../data/configuracoes_service.dart';

/// Tela de Configurações, aberta pelo botão OPTIONS do menu inicial.
///
/// Contém dois interruptores:
///  - DEV: quando ligado, libera todas as fases (para desenvolvimento/testes,
///    sem precisar concluí-las na ordem);
///  - MÚSICA: liga/desliga a música (a reprodução em si será implementada depois).
class Configuracoes extends StatefulWidget {
  const Configuracoes({super.key});

  @override
  State<Configuracoes> createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  final _config = ConfiguracoesService.instance;

  // Paleta neon laranja, igual à dos outros menus.
  static const _laranja = Color(0xFFFF8A00);
  static const _laranjaClara = Color(0xFFFFC061);
  static const _laranjaEscura = Color(0xFF6E3200);
  static const _creme = Color(0xFFF6EAD0);
  static const _interiorTopo = Color(0xF21A1206);
  static const _interiorBaixo = Color(0xF20A0702);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _topo(context),
              const SizedBox(height: 28),
              _switchTile(
                icone: Icons.developer_mode_rounded,
                titulo: 'DEV',
                subtitulo: 'Libera todas as fases (desenvolvimento e testes)',
                valor: _config.devMode,
                onChanged: (v) async {
                  await _config.setDevMode(v);
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),
              _switchTile(
                icone: Icons.music_note_rounded,
                titulo: 'MÚSICA',
                subtitulo: 'Liga/desliga a música do jogo',
                valor: _config.musicaLigada,
                onChanged: (v) async {
                  await _config.setMusica(v);
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topo(BuildContext context) {
    return Row(
      children: [
        _molduraBotao(
          onTap: () => Navigator.of(context).maybePop(),
          padding: const EdgeInsets.all(10),
          child: const Icon(Icons.chevron_left, color: _laranja, size: 26),
        ),
        const SizedBox(width: 16),
        Text(
          'CONFIGURAÇÕES',
          style: TextStyle(
            color: _laranja,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 3,
            shadows: [
              const Shadow(color: _laranja, blurRadius: 10),
              Shadow(color: _laranja.withValues(alpha: 0.6), blurRadius: 22),
            ],
          ),
        ),
      ],
    );
  }

  Widget _switchTile({
    required IconData icone,
    required String titulo,
    required String subtitulo,
    required bool valor,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_laranjaClara, _laranja, _laranjaEscura],
          stops: [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(color: _laranja.withValues(alpha: 0.4), blurRadius: 14),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_interiorTopo, _interiorBaixo],
          ),
          border: Border.all(color: _laranja.withValues(alpha: 0.45), width: 1),
        ),
        child: Row(
          children: [
            Icon(icone, color: _laranjaClara, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: _creme,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: TextStyle(
                      color: _creme.withValues(alpha: 0.7),
                      fontSize: 12.5,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Switch(
              value: valor,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: _laranja,
              inactiveThumbColor: _laranjaClara.withValues(alpha: 0.6),
              inactiveTrackColor: _interiorTopo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _molduraBotao({
    required VoidCallback onTap,
    required Widget child,
    required EdgeInsets padding,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: _laranja.withValues(alpha: 0.3),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_interiorTopo, _interiorBaixo],
            ),
            border: Border.all(color: _laranja.withValues(alpha: 0.6), width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }
}
