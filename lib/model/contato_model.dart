class ContatoModel {
  List<Contatos> contatos = [];

  ContatoModel(this.contatos);

  ContatoModel.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      contatos = <Contatos>[];
      json['results'].forEach((v) {
        contatos.add(Contatos.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['results'] = contatos.map((v) => v.toJson()).toList();
    return data;
  }
}

class Contatos {
  String? objectId;
  String? nome;
  String? numero;
  String? caminhoFoto;
  String? createdAt;
  String? updatedAt;

  Contatos(
      {this.objectId,
      this.nome,
      this.numero,
      this.caminhoFoto,
      this.createdAt,
      this.updatedAt});

  Contatos.criar(this.nome, this.numero, this.caminhoFoto);

  Contatos.fromJson(Map<String, dynamic> json) {
    objectId = json['objectId'];
    nome = json['nome'];
    numero = json['numero'];
    caminhoFoto = json['caminho_foto'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['objectId'] = objectId;
    data['nome'] = nome;
    data['numero'] = numero;
    data['caminho_foto'] = caminhoFoto;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }

  Map<String, dynamic> toCreateJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nome'] = nome;
    data['numero'] = numero;
    data['caminho_foto'] = caminhoFoto;
    return data;
  }

  Map<String, dynamic> toJsonEndpoint() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nome'] = nome;
    data['numero'] = numero;
    data['caminho_foto'] = caminhoFoto;
    return data;
  }
}
