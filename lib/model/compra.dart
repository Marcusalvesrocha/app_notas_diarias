import 'package:notas_diarias/helpers/db_const.dart';
import 'package:notas_diarias/repository/compra_repository.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Compra {
  int? id;
  String? produto;
  String? descricao;
  int? quantidade;
  double? valorUnitario;
  String? data;
  bool? done;

  Compra(this.produto, this.descricao, this.quantidade, this.valorUnitario,
      this.data, this.done);

  Compra.novo();

  Compra.fromMap(Map map) {
    id = map[DbConst.colunaId];
    produto = map[DbConst.colunaProduto];
    descricao = map[DbConst.colunaDescricao];
    quantidade = map[DbConst.colunaQuantidade];
    valorUnitario = map[DbConst.colunaValorUnitario];
    data = map[DbConst.colunaData];
    done = map[DbConst.colunaDone];
  }

  Atualizar(String produto, String descricao, int quantidade,
      double valorUnitario, bool done) {
    this.produto = produto;
    this.descricao = descricao;
    this.quantidade = quantidade;
    this.valorUnitario = valorUnitario;
    this.done = done;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      DbConst.colunaProduto: this.produto,
      DbConst.colunaDescricao: this.descricao,
      DbConst.colunaQuantidade: this.quantidade,
      DbConst.colunaValorUnitario: this.valorUnitario,
      DbConst.colunaData: this.data,
      DbConst.colunaDone: this.done,
    };

    if (this.id != null) {
      map[DbConst.colunaId] = this.id;
    }

    return map;
  }

  String formatarData() {
    initializeDateFormatting('pt_BR');
    var formatador = DateFormat.yMd("pt_BR");

    return formatador.format(DateTime.parse(this.data!));
  }
}
