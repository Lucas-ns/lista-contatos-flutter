import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lista_contatos/enum/origem_imagem.dart';
import 'package:lista_contatos/model/contato_model.dart';
import 'package:lista_contatos/repository/contato_repository.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;

class ContatoFormPage extends StatefulWidget {
  final Contatos? contato;

  const ContatoFormPage({super.key, this.contato});

  @override
  State<ContatoFormPage> createState() => _ContatoFormPageState();
}

class _ContatoFormPageState extends State<ContatoFormPage> {
  var contatoRepository = ContatoRepository();
  var contato = Contatos();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  OrigemImagem? origemImagem;

  String nome = "";
  String numero = "";
  XFile? foto;

  @override
  void initState() {
    super.initState();
    if (widget.contato != null) {
      nome = widget.contato!.nome!;
      numero = widget.contato!.numero!;
      if (widget.contato!.caminhoFoto != null) {
        foto = XFile(widget.contato!.caminhoFoto!);
      }
    }
  }

  Future<void> _salvarContato() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    }

    String? savedImagePath;
    if (foto != null) {
      if (origemImagem == OrigemImagem.camera) {
        savedImagePath = await _salvarImagemLocalmente(foto!);
      } else {
        savedImagePath = foto!.path;
      }
    } else if (widget.contato?.caminhoFoto != null) {
      savedImagePath = widget.contato?.caminhoFoto;
    } else {
      savedImagePath = null;
    }

    final contato = Contatos(
        objectId: widget.contato?.objectId,
        nome: nome,
        numero: numero,
        caminhoFoto: savedImagePath);

    if (widget.contato == null) {
      await contatoRepository.adicionarContato(contato);
    } else {
      await contatoRepository.editarContato(contato);
    }

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  _pegarFoto(ImageSource source) async {
    final imagem = await _picker.pickImage(source: source);
    if (imagem != null) {
      setState(() {
        foto = XFile(imagem.path);
        origemImagem = source == ImageSource.gallery
            ? OrigemImagem.gallery
            : OrigemImagem.camera;
      });
    }
  }

  _removerFoto() async {
    if (widget.contato?.caminhoFoto != null) {
      final fotoParaDeletar = File(widget.contato!.caminhoFoto!);
      if (await fotoParaDeletar.exists()) {
        await fotoParaDeletar.delete();
      }
    }

    setState(() {
      foto = null;
      widget.contato?.caminhoFoto = null;
    });
  }

  Future<String> _salvarImagemLocalmente(XFile foto) async {
    final String imagePath =
        (await path_provider.getApplicationDocumentsDirectory()).path;

    final String fileName = path.basename(foto.path);
    foto.saveTo("$imagePath/$fileName").toString();

    await GallerySaver.saveImage(foto.path);

    return foto.path;
  }

  Widget _construirImagem() {
    if (foto != null) {
      File file = File(foto!.path);
      return CircleAvatar(
        key: ValueKey(DateTime.now()),
        radius: 75,
        backgroundImage: FileImage(file),
      );
    } else if (widget.contato != null && widget.contato!.caminhoFoto != null) {
      return CircleAvatar(
        key: ValueKey(widget.contato!.caminhoFoto),
        radius: 75,
        backgroundImage: FileImage(File(widget.contato!.caminhoFoto!)),
      );
    } else {
      return const CircleAvatar(
        radius: 75,
        child: Icon(
          Icons.person,
          size: 50,
        ),
      );
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.of(context).pop();
                _pegarFoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Câmera'),
              onTap: () {
                Navigator.of(context).pop();
                _pegarFoto(ImageSource.camera);
              },
            ),
            if (foto != null || widget.contato?.caminhoFoto != null)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remover'),
                onTap: () {
                  Navigator.of(context).pop();
                  _removerFoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(widget.contato == null ? 'Novo Contato' : 'Editar Contato'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () => _showImageSourceActionSheet(),
                  child: _construirImagem(),
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  initialValue: nome,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome';
                    }
                    return null;
                  },
                  onSaved: (newValue) => nome = newValue!,
                ),
                TextFormField(
                  keyboardType: const TextInputType.numberWithOptions(),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    TelefoneInputFormatter()
                  ],
                  initialValue: numero,
                  decoration: const InputDecoration(labelText: 'Número'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o número';
                    }
                    return null;
                  },
                  onSaved: (newValue) => numero = newValue!,
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () async {
                      await _salvarContato();
                    },
                    child:
                        Text(widget.contato == null ? 'Salvar' : 'Atualizar')),
              ],
            )),
      ),
    ));
  }
}
