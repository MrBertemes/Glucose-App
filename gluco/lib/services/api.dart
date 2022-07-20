import 'dart:convert';
import 'package:gluco/models/measurement.dart';
import 'package:http/http.dart';
import 'package:http/retry.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gluco/db/databasehelper.dart';
import 'package:gluco/models/user.dart';
import 'package:gluco/models/authmodels.dart';
import 'package:gluco/services/autenticacaoteste.dart';

/// API para comunicação com o servidor
class API {
  API._privateConstructor();

  static final API instance = API._privateConstructor();

  static User? _user;
  User? get currentUser => _user;

  String? _token;
  String? _refresh_token;

  String? _client_id; // isso deve ser salvo no banco?

  @Deprecated('nem sei pra q q serve isso')
  String? _emailSecret;
  @Deprecated('nem sei pra q q serve isso 2')
  String? _passwordSecret;

  /// Recupera mensagens de erro/confirmação recebida pelas requisições
  String? _responseMessage;
  String get responseMessage {
    String message = _responseMessage ?? '';
    // só pode ser lida uma vez
    _responseMessage = null;
    return message;
  }

  final Client _client = Client();
  final String _authority = 'api.egluco.bio.br';

  /// Requisição para solicitação de novo token quando este expira,
  /// utilizando o refresh token (o que acontece quando os dois expiram?)
  Future<bool> _refreshToken() async {
    Uri url = Uri.https(_authority, '/token');

    // não sabia como funcionava o header, peguei o modelo do postman
    Response response = await _client.get(
      url,
      headers: {
        'Authorization': 'Bearer $_refresh_token',
      },
    );

    // talvez fazer uma classe pro decode ficar mais bonitinho
    Map responseModel = jsonDecode(response.body);

    if (response.statusCode == 200) {
      //
      print(await response.body);
      //
      _token = responseModel["access_token"];
      _refresh_token = responseModel["refresh_token"];
      return true;
    } else {
      //
      print(response.reasonPhrase);
      //
    }

    return false;
  }

  /// Requisição para autenticação do usuário
  Future<bool> login(String email, String password) async {
    String encryptedPassword = await _encrypt(password);
    return await _privateLogin(email, encryptedPassword);
  }

  /// Requisição de login considerando senha já criptografada
  Future<bool> _privateLogin(String email, String password) async {
    Uri url = Uri.https(_authority, '/login');

    LoginRequestModel model =
        LoginRequestModel(email: email, password: password);

    // precisa botar num bloco try catch?
    Response response = await _client.post(
      url,
      headers: {
        'Content-type': 'application/json',
      },
      // body: jsonEncode(model.toMap()), // loginrequestmodel precisa ser atualizado
      body: jsonEncode({
        "username": email,
        "password": password,
      }),
    );
    Map responseModel2 = jsonDecode(response.body);
    //

    ///////////////////////////////////// isso é só pra teste
    Response responseTeste = await AutenticacaoTeste.getLogin(model);
    LoginResponseModel responseModel =
        LoginResponseModel.fromMap(jsonDecode(responseTeste.body));
    switch (responseTeste.statusCode) {
      /////////////////////////////////////
      // switch (response.statusCode) {
      case 200:
        //
        print(await response.body);
        _token = responseModel2["access_token"];
        _refresh_token = responseModel2["refresh_token"];
        //
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
      case 422:
        print(response.reasonPhrase);
        return false;
      default:
        return false;
    }
  }

  /// Requisição de cadastro de usuário,
  /// envia nome, email e senha e recebe se a operação foi bem sucedida ou não,
  /// no sucesso automaticamente envia requisição de login
  Future<bool> signUp(String name, String email, String password) async {
    Uri url = Uri.https(_authority, '/users/signup');

    String encryptedPassword = await _encrypt(password);
    SignUpRequestModel model = SignUpRequestModel(
        name: name, email: email, password: encryptedPassword);

    // precisa botar num bloco try catch
    Response response = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      // body: jsonEncode(model.toMap()),  // signuprequestmodel precisa ser atualizado
      body: jsonEncode({
        "email": email, // cade o nome??
        "password": password,
        "confirm_password":
            password, // precisa disso? deixei assim pra não colocar um segundo campo por enquanto
      }),
    );
    Map responseModel = jsonDecode(response.body);
    //

    ///////////////////////////////////// isso é só pra teste
    Response responseTeste = await AutenticacaoTeste.postSignUp(model);
    switch (responseTeste.statusCode) {
      /////////////////////////////////////
      // switch (response.statusCode) {
      case 200:
        //
        print(await response.body);
        _client_id = responseModel["client_id"];
        //
        _responseMessage = responseTeste.body;
        await _privateLogin(email, encryptedPassword);
        return true;
      case 403:
      case 404:
        _responseMessage = responseTeste.body;
        return false;
      case 422:
        print(response.reasonPhrase);
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
    Uri url = Uri.https(_authority, '/users/userprofile');

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
    Uri url = Uri.https(_authority, '/users/userprofile');

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

  /// Busca por credenciais no banco local, se houver retorna o resultado da
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

  /// Busca tantas medições do banco remoto
  Future<dynamic> fetchMeasurements(int id, String name) async {
    Uri url = Uri.https(_authority, '/measurements');
    Measurement? measurement;
    var token = await generateToken(id, name);
    final client = RetryClient(_client);
    try {
      var response = await get(url, headers: {
        "access-token": token,
        "Content-Type": "application/json",
      });
      if (response.statusCode == 200) {
        // success
        var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        measurement = Measurement.fromMap(jsonResponse);
        return measurement;
      } else {
        // failure
        print('Request failed with status: ${response.statusCode}.');
      }
    } finally {
      client.close();
    }
    return;
  }

  /// Envia a medição coletada pelo bluetooth para ser processada na nuvem
  Future<bool> postMeasurements(Measurement measurement) async {
    Uri url = Uri.https(_authority, '/measure/' + _client_id! + '/glucose');
    var measurementJson = measurement.toMap();

    final client = RetryClient(_client);
    try {
      var response = await post(
        url,
        body: measurementJson, // os valores vão separados
        headers: {
          'Authorization': 'Bearer $_token',
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        // success
        return true;
      }
    } finally {
      client.close();
    }
    return false;
  }

  ///
  Future<int> postDataStream(String dataStream) async {
    Uri url = Uri.https(_authority, '/');
    var success = 1;
    final client = RetryClient(_client);
    try {
      var response = await post(
        url,
        body: dataStream,
        headers: {
          "Accept": "application/json",
          "Content-type": "text/plain",
          "Content-lenght": dataStream.length.toString(),
        },
        encoding: Encoding.getByName("utf-8"),
      );
      if (response.statusCode == 200) {
        // success
        success = 0;
        return success;
      }
    } finally {
      client.close();
    }
    return success;
  }

  /// Utiliza sha256 para fazer a criptografia da senha juntamente com o secret do app
  @Deprecated("Não é a gente que faz a criptografia")
  Future<String> _encrypt(String string) async {
    await dotenv.load();
    String secret = dotenv.get('MOT');
    Hmac hmac = Hmac(sha256, secret.codeUnits);
    Digest digest = hmac.convert(string.codeUnits);
    return digest.toString();
  }

  @Deprecated("Não é a gente que gera tokens")
  Future<String> generateToken(int id, String name) async {
    await dotenv.load();
    var _secret = dotenv.get('MOT');

    // JWT
    // header
    var header = {
      "alg": "HS256",
      "typ": "JWT",
    };
    var header64 = base64Encode(jsonEncode(header).codeUnits);

    // Payload
    var payload = {
      "sub": id, // id
      "name": name,
      "exp": DateTime.now().microsecondsSinceEpoch +
          2400000, // 1 hora de expiração
    };
    var payload64 = base64Encode(jsonEncode(payload).codeUnits);

    // signature
    var hmac = Hmac(sha256, _secret.codeUnits);
    var digest = hmac.convert("$header64.$payload64".codeUnits);
    var sign = base64Encode(digest.bytes);

    return "$header64.$payload64.$sign";
  }
}

/// Classe abstrata com as possíveis mensagens retornadas pelas requisições,
/// pra facilitar na tomada de decisão quando erros ocorrem e caso as mensagens
/// sejam trocadas elas estão agrupadas aqui
abstract class APIResponseMessages {
  static const String alreadyRegistered = "Email already exists...";
  static const String notRegistered = "Invalid username";
  static const String wrongPassword = "Invalid password";
  static const String tokenExpired = "Token expired";
}
