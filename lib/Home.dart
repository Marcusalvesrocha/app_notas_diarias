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
  TextEditingController _doneController = TextEditingController();
  var _db = CompraRepository();
  List<Compra> _listaCompras = [];

  _exibirTelaCadastro({var compra}) {
    final tela;
    final botao;
    if (compra.runtimeType == Compra) {
      tela = "Editar Compra";
      botao = "Editar";
      print("Editar tela");
      _produtoController.text = compra.produto.toString();
      _descricaoController.text = compra.descricao.toString();
      _quantidadeController.text = compra.quantidade.toString();
      _valorUnitarioController.text = compra.valorUnitario.toString();
      _doneController.text = compra.done.toString();
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
            content: SingleChildScrollView(
              child: Column(
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
                    autofocus: false,
                  ),
                  TextField(
                    controller: _quantidadeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: "Quantidade",
                        hintText: "Digite a quantidade..."),
                    autofocus: false,
                  ),
                  TextField(
                    controller: _valorUnitarioController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: "Valor Unitário",
                        hintText: "Digite o valor unitário..."),
                    autofocus: false,
                  ),
                ],
              ),
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
    int quantidade = int.parse(_quantidadeController.text);
    double valorUnitario = double.parse(_valorUnitarioController.text);
    int done = int.parse(_doneController.text);

    if (compraSelecionada.runtimeType == Compra) {
      compraSelecionada.Atualizar(
          produto, descricao, quantidade, valorUnitario, done);
      resultado = await _db.AtualizarCompra(compraSelecionada);
    } else {
      print("Ação salvar");
      Compra compra = Compra(produto, descricao, quantidade, valorUnitario,
          DateTime.now().toString(), 0);
      resultado = await _db.salvarCompra(compra);
      if (resultado != 0) {
        _produtoController.clear();
        _descricaoController.clear();
        _quantidadeController.clear();
        _valorUnitarioController.clear();
      }
    }

    _recuperarCompras();
  }

  _removerAnotacao(int? id) async {
    await _db.removerCompra(id!);
    _recuperarCompras();
  }

  _recuperarCompras() async {
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
    _recuperarCompras();
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
                return Dismissible(
                  key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
                  child: Card(
                    child: ListTile(
                      title: Text(compra.produto.toString()),
                      subtitle: Text(
                          "${compra.formatarData()} - ${compra.descricao}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: compra.done == 0 ? false : true,
                            onChanged: (value) {
                              setState(() {
                                compra.done = value! ? 1 : 0;
                              });
                            },
                          ),
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
                  ),
                  background: Container(
                    padding: EdgeInsets.all(15),
                    color: Colors.green,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.edit,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                  secondaryBackground: Container(
                    padding: EdgeInsets.all(15),
                    color: Colors.red,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.delete,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
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
