import 'package:flutter/material.dart';
import 'package:notas_diarias/repository/compra_repository.dart';
import 'package:notas_diarias/model/compra.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _produtoController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  TextEditingController _quantidadeController = TextEditingController();
  TextEditingController _valorUnitarioController = TextEditingController();
  var _db = CompraRepository();
  List<Compra> _listaCompras = [];

  _exibirTelaCadastro({var compra}) {
    final tela;
    final botao;
    if (compra.runtimeType == Compra) {
      tela = "Editar Compra";
      botao = "Editar";
      _produtoController.text = compra.titulo.toString();
      _descricaoController.text = compra.descricao.toString();
      _quantidadeController.text = compra.quantidade.toString();
      _valorUnitarioController.text = compra._valorUnitario.toString();
    } else {
      tela = "Nova Compra";
      botao = "Salvar";
      _produtoController.text = "";
      _descricaoController.text = "";
      _quantidadeController.text = "";
      _valorUnitarioController.text = "";
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(tela),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _produtoController,
                  decoration: InputDecoration(
                      labelText: "Produto", hintText: "Digite o produto..."),
                  autofocus: true,
                ),
                TextField(
                  controller: _descricaoController,
                  decoration: InputDecoration(
                      labelText: "Descrição",
                      hintText: "Digite a descrição..."),
                  autofocus: true,
                ),
                TextField(
                  controller: _descricaoController,
                  decoration: InputDecoration(
                      labelText: "Quantidade",
                      hintText: "Digite a quantidade..."),
                  autofocus: true,
                ),
                TextField(
                  controller: _descricaoController,
                  decoration: InputDecoration(
                      labelText: "Valor Unitário",
                      hintText: "Digite o valor unitário..."),
                  autofocus: true,
                ),
              ],
            ),
            actions: [
              FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar")),
              FlatButton(
                  onPressed: () {
                    print("Salvar Anotação");
                    _salvarAtualizarCompra(compraSelecionada: compra);
                    Navigator.pop(context);
                  },
                  child: Text(botao)),
            ],
          );
        });
  }

  _salvarAtualizarCompra({var compraSelecionada}) async {
    int resultado;
    String produto = _produtoController.text;
    String descricao = _descricaoController.text;
    int quantidade = _quantidadeController.text as int;
    double valorUnitario = _valorUnitarioController.text as double;

    if (compraSelecionada.runtimeType == Compra) {
      compraSelecionada.Atualizar(
          produto, descricao, quantidade, valorUnitario);
      resultado = await _db.AtualizarCompra(compraSelecionada);
    } else {
      print("Ação salvar");
      Compra compra = Compra(produto, descricao, quantidade, valorUnitario,
          DateTime.now().toString(), false);
      resultado = await _db.salvarCompra(compra);
      if (resultado != 0) {
        _produtoController.clear();
        _descricaoController.clear();
        _quantidadeController.clear();
        _valorUnitarioController.clear();
      }
    }

    _recuperarAnotacoes();
  }

  _removerAnotacao(int? id) async {
    await _db.removerCompra(id!);
    _recuperarAnotacoes();
  }

  _recuperarAnotacoes() async {
    if (_listaCompras.length != 0) {
      _listaCompras.removeRange(0, _listaCompras.length);
    }
    print("Quantidade: ${_listaCompras.length}");
    var listaAnotacoes = await _db.getCompras();

    for (var item in listaAnotacoes) {
      Compra itemCompra = Compra.fromMap(item);
      _listaCompras.add(itemCompra);
    }

    setState(() {
      _listaCompras;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarAnotacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Compra"),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: _listaCompras.length,
                  itemBuilder: (context, index) {
                    var compra = _listaCompras[index];
                    return Card(
                      child: ListTile(
                        title: Text(compra.produto.toString()),
                        subtitle: Text(
                            "${compra.formatarData()} - ${compra.descricao}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  print("Icone editar");
                                  _exibirTelaCadastro(compra: compra);
                                },
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.green,
                                )),
                            Padding(
                              padding: EdgeInsets.only(right: 16),
                            ),
                            GestureDetector(
                              onTap: () {
                                _removerAnotacao(compra.id);
                              },
                              child: Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: _exibirTelaCadastro,
        child: Icon(Icons.add),
      ),
    );
  }
}
