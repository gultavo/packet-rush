import 'package:flutter/material.dart';
import 'data/configuracoes_service.dart';
import 'data/database_helper.dart';
import 'data/progresso_service.dart';
import 'menu/menu_inicial.dart';

Future<void> main() async {
  // Necessário antes de usar plugins/serviços assíncronos fora do runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Prepara o backend do SQLite (FFI no desktop, nativo no mobile) e carrega
  // progresso e configurações para a memória, para as telas já lerem síncrono.
  DatabaseHelper.inicializarFactory();
  await ProgressoService.instance.carregar();
  await ConfiguracoesService.instance.carregar();

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
      home: const MenuInicial(),
    );
  }
}
