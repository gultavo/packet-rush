import 'package:sqflite_common/sqflite.dart' show databaseFactory;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'
    show databaseFactoryFfiWeb;

/// Registra o backend do SQLite na web.
///
/// No navegador o SQLite roda compilado em WebAssembly, dentro de um web
/// worker, e os dados ficam guardados no IndexedDB. Do ponto de vista do resto
/// do app nada muda: a API do `sqflite` (openDatabase, query, insert...) é
/// exatamente a mesma, então os repositories e o SQL do jogo funcionam sem
/// nenhuma alteração — e o progresso continua sendo salvo entre sessões.
///
/// Isto depende de dois arquivos em `web/`, que precisam ir junto no deploy:
///
///  - `web/sqlite3.wasm`   — o próprio SQLite compilado;
///  - `web/sqflite_sw.js`  — o web worker que executa as consultas.
///
/// Ambos são gerados por `dart run sqflite_common_ffi_web:setup`. Atenção: o
/// `sqlite3.wasm` tem que ser da MESMA versão do pacote `sqlite3` resolvido no
/// `pubspec.lock` (o setup nem sempre baixa a versão correspondente); em caso
/// de dúvida, pegue-o na release `sqlite3-<versão>` de
/// https://github.com/simolus3/sqlite3.dart/releases.
void configurarDatabaseFactory() {
  databaseFactory = databaseFactoryFfiWeb;
}
