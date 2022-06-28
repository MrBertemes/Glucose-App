import 'dart:convert';
import 'package:http/http.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gluco/db/databasehelper.dart';
import 'package:gluco/models/user.dart';
import 'package:gluco/models/authmodels.dart';
import 'package:gluco/services/autenticacaoteste.dart';

/// API para autenticação dos usuários
class AuthAPI {
  AuthAPI._privateConstructor();

  static final AuthAPI instance = AuthAPI._privateConstructor();

  static User? _user;
  User? get currentUser => _user;

  String? _emailSecret;
  String? _passwordSecret;

  String? _responseMessage;

  final _client = Client();

  /// Requisição para autenticação do usuário
  Future<bool> login(String email, String password) async {
    String encryptedPassword = await _encrypt(password);
    return await _privateLogin(email, encryptedPassword);
  }

  /// Requisição de login considerando senha já criptografada
  Future<bool> _privateLogin(String email, String password) async {
    Uri url = Uri.http('api.egluco.bio.br', '/users/login');

    LoginRequestModel model =
        LoginRequestModel(email: email, password: password);

    /* precisa botar num bloco try catch
    Response response = await _client.post(
      url,
      headers: {
        'Content-type': 'application/json',
      },
      body: jsonEncode(model.toMap()),
    );
    */

    ///////////////////////////////////// isso é só pra teste
    Response responseTeste = await AutenticacaoTeste.getLogin(model);
    LoginResponseModel responseModel =
        LoginResponseModel.fromMap(jsonDecode(responseTeste.body));
    switch (responseTeste.statusCode) {
      /////////////////////////////////////
      // switch (response.statusCode) {
      case 200:
        _responseMessage = responseModel.message;
        if (await DatabaseHelper.instance.insertCredentials(email, password)) {
          _user = User(
            id: responseModel.id!,
            email: email,
            name: responseModel.name!,
          );
          _emailSecret = responseModel.emailsecret!;
          _passwordSecret = responseModel.passwordsecret!;
          // não sei se isso tá certo, parece que o login tá fazendo coisa demais:
          // tenta puxar os dados do banco, se não tiver puxa da rede, se encontrar
          // salva no banco, se não tiver a página que chamou o login leva pra página
          // de primeiro login
          Map<String, Object?>? userdata =
              await DatabaseHelper.instance.queryUser(_user!);
          if (userdata == null) {
            if (await _fetchUserProfile()) {
              switch (_responseMessage) {
                case 'Success':
                  await DatabaseHelper.instance.insertUser(_user!);
              }
            }
          } else {
            // userdata retornado pelo banco é diferente da classe Profile, mas tem as mesmas chaves
            // deveria ter query propria do banco?
            _user!.profile = Profile.fromMap(userdata);
          }
        }
        return true;
      case 403:
      case 404:
        _responseMessage = responseModel.message;
        return false;
      default:
        return false;
    }
  }

  /// Requisição de cadastro de usuário,
  /// envia nome, email e senha e recebe se a operação foi bem sucedida ou não,
  /// no sucesso automaticamente envia requisição de login
  Future<bool> signUp(String name, String email, String password) async {
    Uri url = Uri.http('api.egluco.bio.br', '/users/signup');

    String encryptedPassword = await _encrypt(password);
    SignUpRequestModel model = SignUpRequestModel(
        name: name, email: email, password: encryptedPassword);

    /* precisa botar num bloco try catch
    Response response = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(model.toMap()),
    );
    */

    ///////////////////////////////////// isso é só pra teste
    Response responseTeste = await AutenticacaoTeste.postSignUp(model);
    switch (responseTeste.statusCode) {
      /////////////////////////////////////
      // switch (response.statusCode) {
      case 200:
        _responseMessage = responseTeste.body;
        await _privateLogin(email, encryptedPassword);
        return true;
      case 403:
      case 404:
        _responseMessage = responseTeste.body;
        return false;
      default:
        return false;
    }
  }

  /// Requisição para recuperar perfil do usuário,
  /// envia os secrets e recebe se a operação foi bem sucedida ou não,
  /// no sucesso recebe também os dados do perfil e atribui ao usuário atual em memória,
  /// não atualiza automaticamente o banco local
  Future<bool> _fetchUserProfile() async {
    Uri url = Uri.http('api.egluco.bio.br', '/users/userprofile');

    RequestModel model = RequestModel(
      emailsecret: _emailSecret!,
      passwordsecret: _passwordSecret!,
    );

    /* precisa botar num bloco try catch
    Response response = await _client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Basic ${}',
      body: jsonEncode(model.toMap()),
      },
    );
    */

    ///////////////////////////////////// isso é só pra teste
    Response responseTeste = await AutenticacaoTeste.getUserProfile(model);
    ProfileResponseModel responseModel =
        ProfileResponseModel.fromMap(jsonDecode(responseTeste.body));
    switch (responseTeste.statusCode) {
      /////////////////////////////////////
      // switch (response.statusCode) {
      case 200:
        _responseMessage = responseModel.message;
        _user!.profile = responseModel.profile;
        return true;
      default:
        return false;
    }
  }

  Future<bool> updateUserProfile(String birthdate, String weight, String height,
      String sex, String diabetes) async {
    Uri url = Uri.http('api.egluco.bio.br', '/users/userprofile');

    Profile profile = Profile(
      birthdate: DateTime.parse(birthdate),
      weight: double.parse(weight),
      height: double.parse(height),
      sex: sex,
      diabetes: diabetes,
    );

    ProfileRequestModel model = ProfileRequestModel(
      emailsecret: _emailSecret!,
      passwordsecret: _passwordSecret!,
      // email: currentUser.email,
      // password: currentUser.password,
      profile: jsonEncode(profile.toMap()),
    );

    /* precisa botar num bloco try catch
    Response response = await _client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Basic ${}',
      },
      body: jsonEncode(model.toMap()),
    );
    */

    ///////////////////////////////////// isso é só pra teste
    Response responseTeste = await AutenticacaoTeste.postUserProfile(model);
    switch (responseTeste.statusCode) {
      /////////////////////////////////////
      // switch (response.statusCode) {
      case 200:
        _responseMessage = responseTeste.body;
        // apenas adiciono as novas informações nos campos,
        // ou dou fetch por questão de consistência?
        if (await _fetchUserProfile()) {
          // salva os novos dados no banco
          await DatabaseHelper.instance.updateUser(_user!);
        }
        return true;
      case 400:
        _responseMessage = responseTeste.body;
        return false;
      default:
        return false;
    }
  }

  /// Encerra a sessão do usuário no aplicativo excluindo as credenciais
  /// do banco e setando currentUser como null
  Future<bool> logout() async {
    String email = _user!.email;
    _user = null;
    return await DatabaseHelper.instance.deleteCredentials(email);
  }

  /// Busca por credenciais no banco, se houver retorna o resultado da
  /// requisição de login (autenticação automática),
  /// caso contrário retorna false
  Future<bool> tryCredentials() async {
    Map<String, String>? credentials =
        await DatabaseHelper.instance.queryCredentials();
    if (credentials != null) {
      return await _privateLogin(
          credentials['email']!, credentials['password']!);
    }
    return false;
  }

  /// Recupera mensagens de erro/confirmação recebida pelas requisições
  String get responseMessage {
    String message = _responseMessage ?? '';
    // só pode ser lida uma vez
    _responseMessage = null;
    return message;
  }

  /// Utiliza sha256 para fazer a criptografia da senha juntamente com o secret do app
  Future<String> _encrypt(String string) async {
    await dotenv.load();
    String secret = dotenv.get('MOT');
    Hmac hmac = Hmac(sha256, secret.codeUnits);
    Digest digest = hmac.convert(string.codeUnits);
    return digest.toString();
  }
}
