import 'package:notas_diarias/helpers/db_const.dart';
import 'package:notas_diarias/model/compra.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CompraRepository {
  static final CompraRepository _compraRepository =
      CompraRepository._internal();
  Database? _db;
  var dbConsts = DbConst();

  factory CompraRepository() {
    return _compraRepository;
  }

  CompraRepository._internal() {}
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
    final localDB = join(caminhoDB, dbConsts.NomeTabela);

    var db = await openDatabase(localDB, version: 1, onCreate: _onCreate);
    return db;
  }

  Future<int> salvarCompra(Compra compra) async {
    var bancoDados = await db;
    int id = await bancoDados.insert(dbConsts.NomeTabela, compra.toMap());
    return id;
  }

  Future<int> AtualizarCompra(Compra compra) async {
    var bancoDados = await db;
    return await bancoDados.update(dbConsts.NomeTabela, compra.toMap(),
        where: "id = ?", whereArgs: [compra.id]);
  }

  Future<List> getCompras() async {
    var bancoDados = await db;
    String sql = "SELECT * FROM ${dbConsts.NomeTabela} ORDER BY data DESC";
    List listaCompras = await bancoDados.rawQuery(sql);
    return listaCompras;
  }

  Future<int> removerCompra(int id) async {
    var bancoDados = await db;
    return await bancoDados.delete(
      dbConsts.NomeTabela,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  _onCreate(Database db, int version) async {
    String sql = "CREATE TABLE ${dbConsts.NomeTabela} (" +
        "${dbConsts.ColunaId} INTEGER PRIMARY KEY AUTOINCREMENT," +
        "${dbConsts.ColunaProduto} VARCHAR," +
        "${dbConsts.ColunaDescricao} TEXT," +
        "${dbConsts.ColunaQuantidade} INTEGER," +
        "${dbConsts.ColunaValorUnitario} REAL," +
        "${dbConsts.ColunaData} DATETIME" +
        "${dbConsts.ColunaDone} INTEGER)";
    await db.execute(sql);
  }
}
