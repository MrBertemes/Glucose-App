// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:gluco/db/databasehelper.dart';
import 'package:gluco/services/api.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gluco/models/user.dart';
import 'package:gluco/models/authmodels.dart';

/// tirei a password de user pq não fazia sentido, porém pra essa bomba
/// continuar funcionando precisava armazenar a senha, assim nasceu a userdb
class UserDB {
  String password;
  User data;
  UserDB({required this.password, required this.data});
  factory UserDB.fromMap(Map<String, dynamic> json) => UserDB(
        password: json['password'],
        data: User.fromMap(json['data']),
      );
  Map<String, dynamic> toMap() {
    return {
      'password': password,
      'data': data.toMap(),
    };
  }
}

/// Prima feia da historicoteste, faz a mesma coisa basicamente
/// Uma interface pra simular funcionamentos que ainda não funcionam de fato
/// Cadastra usuários em um mapa e recupera login
/// só pra conseguir testar as mensagens de erro das telas de login, signup e firstlogin
class AutenticacaoTeste {
  static final Map<String, UserDB> _users = <String, UserDB>{};

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
        response.id = _users[model.email]!.data.id;
        response.name = _users[model.email]!.data.name;
        // não faço ideia como os secrets são gerados
        // coloquei pra retornar os proprios email e senha pro resto
        // da autenticaçãoteste poder funcionar
        response.emailsecret = model.email;
        response.passwordsecret = model.password;
        //
      } else {
        statuscode = 403;
        response.message = APIResponseMessages.wrongPassword;
      }
    } else {
      statuscode = 404;
      response.message = APIResponseMessages.notRegistered;
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
        UserDB(
          password: model.password,
          data: User(
            id: _users.keys.length + 1,
            name: model.name,
            email: model.email,
          ),
        ),
      );
    } else {
      statuscode = 403;
      body = APIResponseMessages.alreadyRegistered;
    }

    return Response(body, statuscode);
  }

  /// recebe secrets e retorna o perfil
  static Future<Response> getUserProfile(RequestModel model) async {
    int statuscode = 400;
    String body;
    ProfileResponseModel response =
        ProfileResponseModel(message: 'Unknown Error');

    // emailsecret não faz sentido nenhum mas vamos fingir que é isso
    // a busca era pra ser por email, mas email não é passado na requisição,
    // apenas o secret, então fiz os dois coincidirem pra não complicar,
    // mas no real não faço ideia de como o secret é gerado
    if (_users.containsKey(model.emailsecret)) {
      statuscode = 200;
      response.profile = _users[model.emailsecret]?.data.profile;
      response.message = response.profile != null ? 'Success' : 'Empty profile';
    }
    body = jsonEncode(response.toMap());

    return Response(body, statuscode);
  }

  /// recebe um perfil de usuário e salva no banco
  static Future<Response> postUserProfile(ProfileRequestModel model) async {
    int statuscode = 400;
    String body = 'Unknown Error';

    if (_users.containsKey(model.emailsecret)) {
      UserDB? user = _users[model.emailsecret];
      Map profile = jsonDecode(model.profile);
      user!.data.profile = Profile(
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

////////////////////////////////////////////////////////////////////////////////
//////////////////// daqui pra baixo nada faz sentido //////////////////////////
////////////////////////////////////////////////////////////////////////////////

  /// Insere no mapa em memória e atualiza o shared
  static Future<bool> _cadastraUsuario(UserDB user) async {
    if (!_users.containsKey(user.data.email)) {
      _users[user.data.email] = user;
      await _atualizaBanco();
      return true;
    }
    return false;
  }

  /// Busca por um banco no shared e traz pra memória
  static Future<bool> _recuperaBanco() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> _BDToUsers = jsonDecode(prefs.getString('db') ?? '{}');

    if (_BDToUsers.isEmpty) {
      return false;
    } else {
      for (String key in _BDToUsers.keys) {
        _users[key] = UserDB.fromMap(_BDToUsers[key]);
      }
      return true;
    }
  }

  /// apaga o banco no shared e coloca um novo contendo os usuários em memória
  static Future<bool> _atualizaBanco() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('db');

    Map<String, dynamic> _usersToDB = {};
    for (String key in _users.keys) {
      _usersToDB[key] = _users[key]?.toMap();
    }

    return await prefs.setString('db', jsonEncode(_usersToDB));
  }

  /// Adiciona usuarios no banco remoto simulado apenas para testar,
  /// não possui utilidade real além de evitar ter que criar uma conta toda
  /// vez que builda
  static Future<void> logaAutomaticoPraNaoFicarIrritante() async {
    if (!await _recuperaBanco()) {
      List<UserDB> usuarios = [
        UserDB(
          password: // a senha é lucas123
              '3d4f5f9202ef0203bc4505526152c4a5f3bcec94a90714387ceb2c8246342364',
          data: User(
            id: 1,
            name: 'Lucas Brach',
            email: 'lucassbrach@gmail.com',
            profile: Profile(
              birthdate: DateTime.parse('2000-10-19'),
              weight: 100,
              height: 1.82,
              sex: 'Masculino',
              diabetes: 'Não tenho diabetes',
            ),
          ),
        ),
      ];
      // deixei como uma lista caso desse nas ideia de adicionar mais do que um usuário
      for (UserDB user in usuarios) {
        _cadastraUsuario(user);
      }
    } // precisa adicionar as credenciais no banco pra funcionar, só adiciona se
    // já não existir alguma
    if (await DatabaseHelper.instance.queryCredentials() == null) {
      await DatabaseHelper.instance.insertCredentials('lucassbrach@gmail.com',
          '3d4f5f9202ef0203bc4505526152c4a5f3bcec94a90714387ceb2c8246342364');
    }
  }
}
