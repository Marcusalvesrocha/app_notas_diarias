import 'package:flutter/material.dart';
import 'package:notas_diarias/helper/AnotacaoHelper.dart';
import 'package:notas_diarias/model/Anotacao.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  var _db = AnotacaoHelper();
  List<Anotacao> _listaAnotacoes = [];

  _exibirTelaCadastro({var anotacao}) {
    final tela;
    final botao;
    if (anotacao.runtimeType == Anotacao) {
      tela = "Editar Anotação";
      botao = "Editar";
      _tituloController.text = anotacao.titulo.toString();
      _descricaoController.text = anotacao.descricao.toString();
    } else {
      tela = "Nova Anotação";
      botao = "Salvar";
      _tituloController.text = "";
      _descricaoController.text = "";
    }

    print("----------> $anotacao");
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(tela),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _tituloController,
                  decoration: InputDecoration(
                      labelText: "Titulo", hintText: "Digite o título..."),
                  autofocus: true,
                ),
                TextField(
                  controller: _descricaoController,
                  decoration: InputDecoration(
                      labelText: "Descrição",
                      hintText: "Digite a descrição..."),
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
                    _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);
                    Navigator.pop(context);
                  },
                  child: Text(botao)),
            ],
          );
        });
  }

  _salvarAtualizarAnotacao({var anotacaoSelecionada}) async {
    int resultado;
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;
    if (anotacaoSelecionada.runtimeType == Anotacao) {
      print("Ação Atualizar");
      anotacaoSelecionada.Atualizar(titulo, descricao);
      resultado = await _db.AtualizarAnotacao(anotacaoSelecionada);
    } else {
      print("Ação salvar");
      Anotacao anotacao =
          Anotacao(titulo, descricao, DateTime.now().toString());
      resultado = await _db.salvarAnotacao(anotacao);
      if (resultado != 0) {
        _tituloController.clear();
        _descricaoController.clear();
      }
    }

    _recuperarAnotacoes();
  }

  _removerAnotacao(int? id) async {
    await _db.removerAnotacao(id!);
    _recuperarAnotacoes();
  }

  _recuperarAnotacoes() async {
    if (_listaAnotacoes.length != 0) {
      _listaAnotacoes.removeRange(0, _listaAnotacoes.length);
    }
    print("Quantidade: ${_listaAnotacoes.length}");
    var listaAnotacoes = await _db.getAnotacoes();

    for (var item in listaAnotacoes) {
      Anotacao nota = Anotacao.fromMap(item);
      _listaAnotacoes.add(nota);
    }

    setState(() {
      _listaAnotacoes;
    });

    print("Lista de anotacoes: ${_listaAnotacoes.length}");
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
        title: Text("Anotações"),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: _listaAnotacoes.length,
                  itemBuilder: (context, index) {
                    var anotacao = _listaAnotacoes[index];
                    return Card(
                      child: ListTile(
                        title: Text(anotacao.titulo.toString()),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  print("Icone editar");
                                  _exibirTelaCadastro(anotacao: anotacao);
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
                                _removerAnotacao(anotacao.id);
                              },
                              child: Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                            "${anotacao.formatarData()} - ${anotacao.descricao}"),
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
