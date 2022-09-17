import 'dart:async';
import 'dart:convert';
import 'package:gluco/models/measurement.dart';
import 'package:http/http.dart';
import 'package:gluco/db/databasehelper.dart';
import 'package:gluco/models/user.dart';
import 'package:gluco/models/requests.dart';

/// API para comunicação com o servidor
class API {
  API._privateConstructor();

  static final API instance = API._privateConstructor();

  static User? _user;
  User? get currentUser => _user;

  String? _token;
  String? _refresh_token;

  String? _client_id;

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
  /// utilizando o refresh token, quando ambos expiram é necessário logar novamente
  Future<bool> _refreshToken() async {
    Uri url = Uri.https(_authority, '/token');

    Response response = await _client.get(
      url,
      headers: {
        'Authorization': 'Bearer $_refresh_token',
      },
    );

    Map<String, dynamic> responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      TokenResponseModel responseModel =
          TokenResponseModel.fromMap(jsonDecode(response.body));
      //
      print('--- Refresh --- \n' + response.body + '\n--- Refresh --- \n');
      //
      _token = responseModel.token;
      _refresh_token = responseModel.refresh_token;
      return true;
    } else {
      //
      print(response.reasonPhrase);
      print(response.body);
      //
      _responseMessage = jsonDecode(response.body)[
          'detail']; // talvez colocar detail na classe de response?
    }

    return false;
  }

  /// Busca por credenciais no banco local, se houver retorna o resultado da
  /// requisição de atualização do token (autenticação automática),
  /// caso contrário retorna false
  /// não busca perfil automaticamente
  Future<bool> tryCredentials() async {
    Map<String, String>? credentials =
        await DatabaseHelper.instance.queryCredentials();
    if (credentials == null) {
      return false;
    }
    _client_id = credentials['clientid'];
    _refresh_token = credentials['refreshtoken'];
    if (!await _refreshToken()) {
      return false;
    }
    _user = User(
        email: '',
        name: '',
        id: -1); // ainda não tem endpoints para recuperar dados do usuario
    await DatabaseHelper.instance
        .insertCredentials(_client_id!, _refresh_token!);
    _autoRefresh();
    return true;
  }

  @Deprecated('ter que ficar logando a cada 10 min tava me irritando')
  void _autoRefresh() async {
    Timer.periodic(Duration(minutes: 8), (timer) {
      _autoSave();
    });
  }

  @Deprecated('a função do timer do autorefresh não podia ser async')
  void _autoSave() async {
    if (await _refreshToken()) {
      await DatabaseHelper.instance
          .insertCredentials(_client_id!, _refresh_token!);
    }
  }

  /// Requisição para autenticação do usuário
  Future<bool> login(String email, String password) async {
    Uri url = Uri.https(_authority, '/login');

    LoginRequestModel model =
        LoginRequestModel(email: email, password: password);

    Response response = await _client.post(
      url,
      headers: {
        'Content-type': 'application/json',
      },
      body: jsonEncode(model.toMap()),
    );

    Map<String, dynamic> responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      LoginResponseModel responseModel =
          LoginResponseModel.fromMap(responseBody);
      //
      print('--- Login --- \n' + response.body + '\n--- Login --- \n');
      //
      _client_id = responseModel.client_id;
      _token = responseModel.token;
      _refresh_token = responseModel.refresh_token;
      _responseMessage = 'Success';
      _user = User(email: email, name: '', id: -1);
      await DatabaseHelper.instance
          .insertCredentials(_client_id!, _refresh_token!);
      return true;
    } else {
      //
      print("-reasonphrase: " + (response.reasonPhrase ?? ''));
      // print("-body: " + responseBody['detail'][0]['msg']);
      //
      try {
        _responseMessage = responseBody['detail'];
      } catch (e) {
        _responseMessage = responseBody['detail'][0]['msg'];
      }
    }

    return false;
  }

  /// Requisição de cadastro de usuário
  Future<bool> signUp(String name, String email, String password) async {
    Uri url = Uri.https(_authority, '/user/signup');

    SignUpRequestModel model =
        SignUpRequestModel(name: name, email: email, password: password);

    Response response = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(model.toMap()),
    );

    Map<String, dynamic> responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      //
      print('--- Signup --- \n' + response.body + '\n--- Signup --- \n');
      //
      _responseMessage = responseBody['status'];
      return true;
    } else {
      //
      print(response.reasonPhrase);
      //
      _responseMessage = responseBody['detail'];
    }

    return false;
  }

  /// Requisição para recuperar perfil do usuário
  @Deprecated('Não tem endpoint pra isso ainda')
  Future<bool> fetchUserProfile() async {
    Uri url = Uri.https(_authority, '/user/profile');

    /*
    Response response = await _client.get(
      url,
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    Map<String, dynamic> responseBody = jsonDecode(response.body);
    ProfileResponseModel responseModel =
        ProfileResponseModel.fromMap(responseBody);
    if (response.statusCode == 200) {
      _user!.profile = responseModel.profile;
      return true;
    } else {
      _responseMessage = responseBody['detail'];
    }
    */

    return false;
  }

  // Requisição para alterar perfil do usuário
  @Deprecated('Não tem endpoint pra isso ainda')
  Future<bool> updateUserProfile(String birthdate, String weight, String height,
      String sex, String diabetes) async {
    Uri url = Uri.https(_authority, '/user/profile');

    /*
    Profile profile = Profile(
      birthdate: DateTime.parse(birthdate),
      weight: double.parse(weight),
      height: double.parse(height),
      sex: sex,
      diabetes: diabetes,
    );

    ProfileRequestModel model = ProfileRequestModel(
      profile: jsonEncode(profile.toMap()),
    );

    Response response = await _client.post(
      url,
      body: jsonEncode(model.toMap()),
    );

    Map<String, dynamic> responseBody = jsonDecode(response.body);
    if (response.statusCode == 200) {
      _responseMessage = responseBody['status'];
      return true;
    } else {
      _responseMessage = responseBody['detail'];
    }
    */

    return false;
  }

  /// Encerra a sessão do usuário no aplicativo excluindo as credenciais
  /// do banco e setando variaveis como null
  Future<bool> logout() async {
    String client_id = _client_id!;
    _user = null;
    _client_id = null;
    _token = null;
    _refresh_token = null;
    return await DatabaseHelper.instance.deleteCredentials(client_id);
  }

  /// Envia a medição coletada pelo bluetooth para ser processada na nuvem
  Future<bool> postMeasurements(MeasurementCollected measurement) async {
    Uri url = Uri.https(_authority, '/measure/' + _client_id! + '/glucose');

    // como fazer para tratar resposta de token expirado ao tentar acessar
    // recursos protegidos? recursividade?
    // por enquanto o token é atualizado antes de enviar
    if (!await _refreshToken()) {
      // deveria dar uma mensagem que a sessão expirou ou algo nesse sentido
      return false;
    }

    Response response = await _client.post(
      url,
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(measurement.toMap()),
    );

    Map<String, dynamic> responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      //
      print('--- measure --- \n' + response.body + '\n--- measure --- \n');
      //
      _responseMessage = responseBody['status'];
      return true;
    } else {
      //
      print(response.reasonPhrase);
      //
      print(responseBody['detail']);
    }

    return false;
  }

  /// Busca tantas medições do banco remoto
  @Deprecated('Não tem endpoint pra isso ainda')
  Future<List<MeasurementCompleted>> fetchMeasurements() async {
    Uri url = Uri.https(_authority, '/measurements');

    List<MeasurementCompleted> measurementsList = <MeasurementCompleted>[];

    Response response = await get(
      url,
      headers: {
        'Authorization': 'Bearer $_token',
        "Content-Type": "application/json",
      },
    );

    Map<String, dynamic> responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      List<Map<String, dynamic>> list = responseBody['measurements'];
      for (Map<String, dynamic> measurement in list) {
        measurementsList.add(MeasurementCompleted.fromMap(measurement));
      }
    } else {
      //
      print(response.reasonPhrase);
      //
      _responseMessage = responseBody['detail'];
    }

    return measurementsList;
  }
}

/// Classe abstrata com as possíveis mensagens retornadas pelas requisições,
/// pra facilitar na tomada de decisão quando erros ocorrem e caso as mensagens
/// sejam trocadas elas estão agrupadas aqui
abstract class APIResponseMessages {
  static const String success = 'Success';
  static const String alreadyRegistered = 'Email already exists...';
  static const String notRegistered = 'Invalid username';
  static const String wrongPassword = 'Invalid password';
  static const String tokenExpired = 'Token expired';
  static const String invalidFields = 'value is not a valid email address';
}
