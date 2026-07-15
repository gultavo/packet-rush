import 'dart:io' show Platform;

// Importar o `sqflite` é o que registra o plugin nativo do Android/iOS como
// fábrica padrão do banco. O import fica aqui, e não no `database_helper`,
// porque este arquivo só entra no build das plataformas nativas — na web o
// `sqflite` não roda, e quem assume é o `db_factory_web.dart`.
//
// O analisador acha o import inútil porque nenhum símbolo dele é citado no
// código: ele existe pelo efeito colateral de registrar o plugin. Sem ele, o
// `databaseFactory` fica nulo no celular e a primeira consulta estoura com
// "databaseFactory not initialized".
// ignore: unnecessary_import
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Registra o backend do SQLite nas plataformas nativas.
///
/// - Desktop (Windows/Linux/macOS): SQLite via FFI (`sqflite_common_ffi`).
/// - Mobile (Android/iOS): nada a fazer. O plugin nativo do `sqflite` já é a
///   fábrica padrão; sobrescrevê-la aqui só renderia um aviso do próprio
///   pacote ("You are changing sqflite default factory").
void configurarDatabaseFactory() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}
