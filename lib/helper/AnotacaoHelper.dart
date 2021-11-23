import 'package:notas_diarias/model/Anotacao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AnotacaoHelper {
  static final nomeTabela = "anotacao";
  static final colunaId = "id";
  static final colunaTitulo = "titulo";
  static final colunaDescricao = "descricao";
  static final colunaData = "data";
  static final AnotacaoHelper _anotacaoHelper = AnotacaoHelper._internal();
  Database? _db;

  factory AnotacaoHelper() {
    print("AnotacaoHelper");
    return _anotacaoHelper;
  }

  AnotacaoHelper._internal() {}
  get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await inicializarDB();
      return _db;
    }
  }

  inicializarDB() async {
    final caminhoDB = await getDatabasesPath();
    final localDB = join(caminhoDB, "db_anotacoes");
    print("local: $localDB");

    var db = await openDatabase(localDB, version: 1, onCreate: _onCreate);
    return db;
  }

  Future<int> salvarAnotacao(Anotacao anotacao) async {
    var bancoDados = await db;
    int id = await bancoDados.insert(nomeTabela, anotacao.toMap());
    return id;
  }

  Future<List> getAnotacoes() async {
    var bancoDados = await db;
    String sql = "SELECT * FROM $nomeTabela ORDER BY data DESC";
    List listaAnotacoes = await bancoDados.rawQuery(sql);
    return listaAnotacoes;
  }

  _onCreate(Database db, int version) async {
    String sql =
        "CREATE TABLE $nomeTabela (id INTEGER PRIMARY KEY AUTOINCREMENT, titulo VARCHAR, descricao TEXT, data DATETIME)";
    print("CREATE: ${sql}");
    await db.execute(sql);
  }
}
