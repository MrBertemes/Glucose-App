import 'dart:convert';
import 'package:http/http.dart';
import 'package:gluco/models/user.dart';
import 'package:gluco/models/authmodels.dart';

/// Prima feia da historicoteste, faz a mesma coisa basicamente
/// Uma interface pra simular funcionamentos que ainda não funcionam de fato
/// Cadastra usuários em um mapa e recupera login
class AutenticacaoTeste {
  // teoricamente a definição de User pode ser diferente no app e na api,
  // mas vamos fingir que é o mesmo pra facilitar
  static Map<String, User> _users = <String, User>{};

  /// simula resposta da api do banco
  /// nem sei se isso tá certo, o que deveria vir no body?
  /// fiz só pra testar mas parece que ficou bom até
  static Future<Response> postLogin(LoginRequestModel model) async {
    int statuscode = 400;
    String body = 'Unknown Error';

    if (_users.containsKey(model.email)) {
      if (_users[model.email]!.password == model.password) {
        statuscode = 200;
        body = 'Success';
      } else {
        statuscode = 403;
        body = 'Invalid Password';
      }
    } else {
      statuscode = 404;
      body = 'Invalid Email';
    }

    return Response(body, statuscode);
  }

  static Future<Response> postSignUp(SignUpRequestModel model) async {
    int statuscode = 400;
    String body = 'Unknown Error';

    if (!_users.containsKey(model.email)) {
      statuscode = 200;
      body = 'Success';
      _cadastra(
        User(
          email: model.email,
          password: model.password,
          // problema: não salva o nome no perfil !!
        ),
      );
    } else {
      statuscode = 403;
      body = 'Invalid Email';
    }

    return Response(body, statuscode);
  }

  static Future<Response> postUserProfile(LoginRequestModel model) async {
    int statuscode = 400;
    String body = 'Unknown Error';

    if (_users.containsKey(model.email)) {
      User? user = _users[model.email];
      Profile? userProfile;
      try {
        userProfile = user?.profile;
      } catch (e) {
        userProfile = null;
      }
      statuscode = 200;
      body = jsonEncode(ProfileResponseModel(
        message:
            'Success', // sucesso por ter encontrado o usuário ou sucesso por ter encontrado perfil do usuário?
        profile: userProfile,
      ).toMap());
    }

    return Response(body, statuscode);
  }

  /// insere o usuário no banco
  static bool _cadastra(User user) {
    if (!_users.containsKey(user.email)) {
      _users[user.email] = user;
      return true;
    }
    return false;
  }

  /// Adiciona credenciais fictícias apenas para testar, não possui utilidade real
  static bool populaBanco() {
    if (_users.isNotEmpty) return false;
    List<User> usuarios = [
      User(
        email: 'lucassbrach@gmail.com',
        password: // a senha é lucas123
            '3d4f5f9202ef0203bc4505526152c4a5f3bcec94a90714387ceb2c8246342364',
        profile: Profile(
          id: 1,
          name: 'Lucas Brach',
          birthdate: DateTime.parse('2000-10-19'),
          weight: 100,
          height: 1.82,
          sex: 'M',
          diabetes: 0,
        ),
      ),
    ];
    for (User user in usuarios) {
      _cadastra(user);
    }
    return true;
  }
}
