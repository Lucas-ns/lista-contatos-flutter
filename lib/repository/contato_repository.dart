import 'package:lista_contatos/model/contato_model.dart';
import 'package:lista_contatos/repository/custom_dio.dart';

class ContatoRepository {
  final _customDio = CustomDio();

  Future<ContatoModel> obterContatos() async {
    var result = await _customDio.dio.get('/Contatos');
    return ContatoModel.fromJson(result.data);
  }

  Future<void> adicionarContato(Contatos contato) async {
    try {
      await _customDio.dio.post('/Contatos', data: contato.toCreateJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editarContato(Contatos contato) async {
    try {
      await _customDio.dio
          .put('/Contatos/${contato.objectId}', data: contato.toJsonEndpoint());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletarContato(String objectId) async {
    try {
      await _customDio.dio.delete('/Contatos/$objectId');
    } catch (e) {
      rethrow;
    }
  }
}
