import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gluco/models/user.dart';
import 'package:gluco/models/authmodels.dart';

/// Prima feia da historicoteste, faz a mesma coisa basicamente
/// Uma interface pra simular funcionamentos que ainda não funcionam de fato
/// Cadastra usuários em um mapa e recupera login
/// só pra conseguir testar as mensagens de erro das telas de login, signup e firstlogin
class AutenticacaoTeste {
  // teoricamente a definição de User pode ser diferente no app e na api,
  // mas vamos fingir que é o mesmo pra facilitar
  static final Map<String, User> _users = <String, User>{};

  /// recebe um email e senha e verifica se existe no banco,
  /// retorna o id e nome correspondente e os secrets
  static Future<Response> getLogin(LoginRequestModel model) async {
    int statuscode = 400;
    String body;
    LoginResponseModel response = LoginResponseModel(message: 'Unknown Error');

    if (_users.containsKey(model.email)) {
      if (_users[model.email]!.password == model.password) {
        statuscode = 200;
        response.message = 'Success';
        response.id = _users[model.email]!.id;
        response.name = _users[model.email]!.name;
        // não faço ideia como os secrets são gerados
        response.emailsecret = '*emailsecret*';
        response.passwordsecret = '*passwordsecret*';
        //
      } else {
        statuscode = 403;
        response.message = 'Invalid Password';
      }
    } else {
      statuscode = 404;
      response.message = 'Invalid Email';
    }
    body = jsonEncode(response.toMap());

    return Response(body, statuscode);
  }

  /// recebe um email e senha e cadastra no banco se não existe
  static Future<Response> postSignUp(SignUpRequestModel model) async {
    int statuscode = 400;
    String body = 'Unknown Error';

    if (!_users.containsKey(model.email)) {
      statuscode = 200;
      body = 'Success';
      _cadastraUsuario(
        User(
          id: _users.keys.length + 1,
          name: model.name,
          email: model.email,
          password: model.password,
        ),
      );
    } else {
      statuscode = 403;
      body = 'Invalid Email';
    }

    return Response(body, statuscode);
  }

  /// recebe um email e senha e secrets e retorna o perfil
  static Future<Response> getUserProfile(RequestModel model) async {
    int statuscode = 400;
    String body;
    ProfileResponseModel response =
        ProfileResponseModel(message: 'Unknown Error');

    if (_users.containsKey(model.email)) {
      statuscode = 200;
      response.profile = _users[model.email]?.profile;
      response.message = response.profile != null ? 'Success' : 'Empty profile';
    }
    body = jsonEncode(response.toMap());

    return Response(body, statuscode);
  }

  /// recebe um perfil de usuário e salva no banco
  static Future<Response> postUserProfile(ProfileRequestModel model) async {
    int statuscode = 400;
    String body = 'Unknown Error';

    if (_users.containsKey(model.email)) {
      User? user = _users[model.email];
      Map profile = jsonDecode(model.profile);
      user!.profile = Profile(
        birthdate: DateTime.parse(profile['birthdate']),
        weight: profile['weight'],
        height: profile['height'],
        sex: profile['sex'],
        diabetes: profile['diabetes'],
      );
      await _atualizaBanco();

      statuscode = 200;
      body = 'Success';
    } else {
      statuscode = 404;
      body = 'Invalid Email';
    }

    return Response(body, statuscode);
  }

  static Future<bool> _cadastraUsuario(User user) async {
    if (!_users.containsKey(user.email)) {
      _users[user.email] = user;
      await _atualizaBanco();
      return true;
    }
    return false;
  }

  static Future<void> _atualizaBanco() async {
    await SharedPreferences.getInstance()
        .then((value) async => await value.remove('db'));
    await populaBanco();
  }

  static Future<bool> populaBanco() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('db')) {
      // se o banco já existir, atualiza _users
      Map<String, dynamic> _BDToUsers =
          jsonDecode(prefs.getString('db') ?? '{}');

      for (String key in _BDToUsers.keys) {
        _users[key] = User.fromMap(_BDToUsers[key]);
      }
    } else {
      // se o banco não existir, cria inserindo _users

      if (_users.isEmpty) {
        // cria usuarios para popular, só acontece na primeira vez que builda
        _criaUsuarios();
      }

      Map<String, dynamic> _usersToDB = {};
      for (String key in _users.keys) {
        _usersToDB[key] = _users[key]?.toMap();
      }

      prefs.setString('db', jsonEncode(_usersToDB));
    }
    return true;
  }

  /// Adiciona credenciais fictícias apenas para testar, não possui utilidade real
  static void _criaUsuarios() {
    List<User> usuarios = [
      User(
        id: 1,
        name: 'Lucas Brach',
        email: 'lucassbrach@gmail.com',
        password: // a senha é lucas123
            '3d4f5f9202ef0203bc4505526152c4a5f3bcec94a90714387ceb2c8246342364',
        profile: Profile(
          birthdate: DateTime.parse('2000-10-19'),
          weight: 100,
          height: 1.82,
          sex: 'Masculino',
          diabetes: 'Não tenho diabetes',
        ),
      ),
    ];
    for (User user in usuarios) {
      _cadastraUsuario(user);
    }
  }
}
