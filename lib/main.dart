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

  // Prepara o backend do SQLite (FFI no desktop, nativo no mobile) e carrega
  // progresso e configurações para a memória, para as telas já lerem síncrono.
  DatabaseHelper.inicializarFactory();
  await ProgressoService.instance.carregar(); // Puxa dados salvos do jogo (fases liberadas) antes da UI subir.
  await ConfiguracoesService.instance.carregar(); // Puxa volume e configurações antes da UI subir.

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
      // Todos os menus são desenhados em retrato: a rotação é pedida e a tela
      // só aparece depois que o aparelho girou (ver [OrientacaoFixa]). Só a
      // gameplay pode ir para paisagem, e ela cuida da própria orientação.
      home: const OrientacaoFixa(child: MenuInicial()),
    );
  }
}
