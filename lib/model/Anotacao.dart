import 'package:notas_diarias/helper/AnotacaoHelper.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Anotacao {
  int? id;
  String? titulo;
  String? descricao;
  String? data;

  Anotacao(this.titulo, this.descricao, this.data);

  Anotacao.novo();

  Anotacao.fromMap(Map map) {
    this.id = map[AnotacaoHelper.colunaId];
    this.titulo = map[AnotacaoHelper.colunaTitulo];
    this.descricao = map[AnotacaoHelper.colunaDescricao];
    this.data = map[AnotacaoHelper.colunaData];
  }

  Atualizar(String titulo, String descricao) {
    this.titulo = titulo;
    this.descricao = descricao;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "titulo": this.titulo,
      "descricao": this.descricao,
      "data": this.data,
    };

    if (this.id != null) {
      map["id"] = this.id;
    }

    return map;
  }

  String formatarData() {
    initializeDateFormatting('pt_BR');
    var formatador = DateFormat.yMMMd("pt_BR");

    return formatador.format(DateTime.parse(this.data!));
  }
}
