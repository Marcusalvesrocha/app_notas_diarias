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

  _exibirTelaCadastro() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Nova Anotação"),
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
                    _salvarAnotacao();
                    Navigator.pop(context);
                  },
                  child: Text("Salvar")),
            ],
          );
        });
  }

  _salvarAnotacao() async {
    print("Ação salvar");
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;

    Anotacao anotacao = Anotacao(titulo, descricao, DateTime.now().toString());
    int resultado = await _db.salvarAnotacao(anotacao);

    if (resultado != 0) {
      _tituloController.clear();
      _descricaoController.clear();
    }

    _recuperarAnotacoes();
  }

  _recuperarAnotacoes() async {
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
                        subtitle:
                            Text("${anotacao.data} - ${anotacao.descricao}"),
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
