import 'dart:async';

import 'package:flutter/material.dart';
import 'data/configuracoes_service.dart';
import 'data/database_helper.dart';
import 'data/musica_service.dart';
import 'data/progresso_service.dart';
import 'menu/menu_inicial.dart';
import 'orientacao.dart';

Future<void> main() async {
  // Necessário antes de usar plugins/serviços assíncronos fora do runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Prepara o backend do SQLite (nativo no mobile, FFI no desktop, WebAssembly
  // na web) e carrega progresso e configurações para a memória, para as telas
  // já lerem síncrono.
  //
  // Se o banco falhar, o jogo ABRE MESMO ASSIM: sem isto, qualquer erro aqui
  // acontece antes do `runApp` e o app inteiro vira uma tela em branco, sem
  // nada na interface explicando o porquê. Perder o progresso salvo é ruim;
  // não abrir o jogo é pior. Os serviços mantêm seus padrões em memória (nada
  // desbloqueado, música ligada), então tudo funciona — só não persiste.
  try {
    DatabaseHelper.inicializarFactory();
    await ProgressoService.instance.carregar(); // Puxa dados salvos do jogo (fases liberadas) antes da UI subir.
    await ConfiguracoesService.instance.carregar(); // Puxa volume e configurações antes da UI subir.
  } catch (e, s) {
    debugPrint('Falha ao carregar dados salvos; abrindo o jogo sem eles: $e\n$s');
  }

  // Trilha sonora do jogo, tocando em loop por trás de todas as telas.
  unawaited(MusicaService.instance.iniciar());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // No navegador a trilha sonora não pode começar sozinha: o autoplay só é
      // liberado depois que o usuário interage com a página. Este [Listener]
      // envolve todas as telas e usa o primeiro toque/clique — em qualquer
      // lugar — como esse gesto. Fora da web, a música já está tocando e isto
      // não faz nada.
      builder: (context, child) => Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => MusicaService.instance.retomarAposGesto(),
        child: child ?? const SizedBox.shrink(),
      ),
      // Todos os menus são desenhados em retrato: a rotação é pedida e a tela
      // só aparece depois que o aparelho girou (ver [OrientacaoFixa]). Só a
      // gameplay pode ir para paisagem, e ela cuida da própria orientação.
      home: const OrientacaoFixa(child: MenuInicial()),
    );
  }
}
