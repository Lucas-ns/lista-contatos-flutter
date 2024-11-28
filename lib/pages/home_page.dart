import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lista_contatos/model/contato_model.dart';
import 'package:lista_contatos/pages/contato_form_page.dart';
import 'package:lista_contatos/repository/contato_repository.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _contatos = ContatoModel([]);

  var contatoRepository = ContatoRepository();

  @override
  void initState() {
    super.initState();
    _obterContatos();
  }

  void _obterContatos() async {
    var contatos = await contatoRepository.obterContatos();
    setState(() {
      _contatos = contatos;
    });
  }

  void _deletarContato(Contatos contato) async {
    await contatoRepository.deletarContato(contato.objectId!);
    _obterContatos();
  }

  void _navegarParaFormulario({Contatos? contato}) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ContatoFormPage(
                  contato: contato,
                )));

    if (result == true) {
      _obterContatos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Lista de Contatos"),
        ),
        body: ListView.builder(
          itemCount: _contatos.contatos.length,
          itemBuilder: (context, index) {
            var contato = _contatos.contatos[index];
            return ListTile(
              leading: contato.caminhoFoto != null
                  ? CircleAvatar(
                      backgroundImage: FileImage(File(contato.caminhoFoto!)),
                    )
                  : const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      onPressed: () => _navegarParaFormulario(contato: contato),
                      icon: const Icon(Icons.edit)),
                  IconButton(
                      onPressed: () => _deletarContato(contato),
                      icon: const Icon(Icons.delete)),
                ],
              ),
              title: Text(contato.nome ?? ""),
              subtitle: Text(contato.numero ?? ""),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _navegarParaFormulario,
          tooltip: 'Adicionar contato',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
