// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gluco/db/databasehelper.dart';
import 'package:gluco/models/measurement.dart';
import 'package:gluco/models/requests.dart';
import 'package:gluco/models/user.dart';

/// API para comunicação com o servidor
class API {
  API._privateConstructor();

  static final API instance = API._privateConstructor();

  static User? _user;
  User? get currentUser => _user;

  String? _token;
  String? _refresh_token;
  String? _client_id;

  ///// PRECISA RECEBER EM ALGUMA REQUISIÇÃO (LOGIN OU PERFIL?)
  bool _isDoctor = false;
  bool get isDoctor => _isDoctor;

  List<String> get pacientList => ['Eu', 'José', 'Alisson', 'Larissa'];

  // Detecção de conexão à internet
  final Connectivity _connectivity = Connectivity();
  Stream<ConnectivityResult> get connection =>
      _connection().asBroadcastStream();
  Stream<ConnectivityResult> _connection() async* {
    var result = await _connectivity.checkConnectivity();
    yield result;
    await for (final value in _connectivity.onConnectivityChanged) {
      yield value;
    }
  }

  Future<bool> hasConnection() async {
    ConnectivityResult result = await connection.first;
    return [
      ConnectivityResult.wifi,
      ConnectivityResult.mobile,
      ConnectivityResult.ethernet,
      ConnectivityResult.vpn
    ].contains(result);
  }

  /// Recupera mensagens de erro/confirmação recebida pelas requisições
  String? _responseMessage;
  String get responseMessage {
    String message = _responseMessage ?? '';
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

    Map<String, dynamic> responseBody =
        jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      TokenResponseModel responseModel =
          TokenResponseModel.fromMap(responseBody);
      //
      print('--- Refresh --- \n' + response.body + '\n--- Refresh --- \n');
      //
      _token = responseModel.token;
      _refresh_token = responseModel.refresh_token;
      _responseMessage = APIResponseMessages.success;
      return true;
    } else {
      //
      print('--- Refresh --- \n' +
          response.body +
          '\n' +
          (response.reasonPhrase ?? '') +
          '\n--- Refresh --- \n');
      //
      _responseMessage = responseBody['detail'];
    }

    return false;
  }

  // Método que encapsula as funcionalidades de autenticação e recuperação de
  // perfil dos bds, tratando status de conectividade
  Future<bool> login([String? email, String? password]) async {
    assert(!((email == null) ^ (password == null)));
    bool auto = email == null || password == null;

    _user = User();

    if (await hasConnection()) {
      // ### precisa dar timeout
      bool logged =
          auto ? await _fetchDBCredentials() : await _login(email, password);
      if (logged) {
        await _fetchUserInfo();
        if (await _fetchUserProfile()) {
          // temporario
          await _updateProfilePic();
          //
          await updateDBUserProfile();
        }
        _autoRefresh();
        await DatabaseHelper.instance
            .insertCredentials(_client_id!, _refresh_token!);
        // ### verificação se banco possui medições não enviadas
        return true;
      }
    } else {
      if (auto &&
          await _fetchDBCredentials(false) &&
          await _fetchDBUserProfile()) {
        // ### apiresponsemessage de modo offline
        print('--- login :: not connected, offline mode');
        _responseMessage = APIResponseMessages.offlineMode;
        return true;
      }
      // ### apiresponsemessage sem conexao
      _responseMessage = APIResponseMessages.noConnection;
      print('--- login :: not connected, no profile');
    }

    return false;
  }

  /// Busca por credenciais no banco local (autenticação automática),
  /// se houver realiza a atualização do token
  Future<bool> _fetchDBCredentials([bool refresh = true]) async {
    Map<String, String>? credentials =
        await DatabaseHelper.instance.queryCredentials();
    if (credentials == null) {
      return false;
    }
    _client_id = credentials['clientid'];
    _refresh_token = credentials['refreshtoken'];
    if (refresh) {
      if (!await _refreshToken()) {
        _client_id = null;
        _refresh_token = null;
        return false;
      }
    }
    return true;
  }

  @Deprecated('ter que ficar logando a cada 10 min tava me irritando')
  void _autoRefresh() async {
    Timer.periodic(const Duration(minutes: 8), (timer) {
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
  Future<bool> _login(String email, String password) async {
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

    Map<String, dynamic> responseBody =
        jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      LoginResponseModel responseModel =
          LoginResponseModel.fromMap(responseBody);
      //
      print('--- Login --- \n' + response.body + '\n--- Login --- \n');
      //
      _client_id = responseModel.client_id;
      _token = responseModel.token;
      _refresh_token = responseModel.refresh_token;
      _responseMessage = APIResponseMessages.success;
      return true;
    } else {
      //
      print("-reasonphrase: " + (response.reasonPhrase ?? ''));
      //
      try {
        _responseMessage = responseBody['detail'];
      } catch (e) {
        _responseMessage = responseBody['detail'][0]['msg'];
      }
    }

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

    Map<String, dynamic> responseBody =
        jsonDecode(utf8.decode(response.bodyBytes));

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

  Future<bool> createUserProfile(
    DateTime birthday,
    double weight,
    double height,
    String sex,
    String diabetes_type,
    String profile_pic,
  ) async {
    assert(sex == 'M' || sex == 'F');
    assert(diabetes_type == 'T1' ||
        diabetes_type == 'T2' ||
        diabetes_type == 'NP');

    Uri url = Uri.https(_authority, '/profile/${_client_id!}/user');

    Profile profile = Profile(
      birthday: birthday,
      weight: weight,
      height: height,
      sex: sex,
      diabetes_type: diabetes_type,
      profile_pic: profile_pic,
    );

    Response response = await _client.post(
      url,
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(profile.toMap()),
    );

    Map<String, dynamic> responseBody =
        jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      //
      print('--- create profile --- \n' +
          response.body +
          '\n--- create profile --- \n');
      //
      _responseMessage = responseBody['status'];
      _user!.profile = profile;
      return true;
    } else {
      //
      print('--- create profile --- \n' +
          (response.reasonPhrase ?? '') +
          '\n' +
          responseBody['detail'] +
          '\n--- create profile --- \n');
      //
    }

    return false;
  }

  // Requisição para alterar perfil do usuário (apenas peso e altura por enquanto)
  Future<bool> updateUserProfile(
    DateTime birthday,
    double weight,
    double height,
    String sex,
    String diabetes_type,
    String profile_pic,
  ) async {
    assert(sex == 'M' || sex == 'F');
    assert(diabetes_type == 'T1' ||
        diabetes_type == 'T2' ||
        diabetes_type == 'NP');

    Uri url = Uri.https(_authority, '/update_profile/${_client_id!}');

    Profile profile = Profile(
      birthday: birthday,
      weight: weight,
      height: height,
      sex: sex,
      diabetes_type: diabetes_type,
      profile_pic: profile_pic,
    );

    Response response = await _client.patch(
      url,
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(profile.toMap()),
    );

    Map<String, dynamic> responseBody =
        jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      //
      print('--- update profile --- \n' +
          response.body +
          '\n--- update profile --- \n');
      //
      _responseMessage = responseBody['status'];
      _user!.profile = profile;
      return true;
    } else {
      //
      print('--- update profile --- \n' +
          (response.reasonPhrase ?? '') +
          '\n' +
          responseBody['detail'] +
          '\n--- update profile --- \n');
      //
    }

    return false;
  }

  // Requisição para recuperar nome e email do usuário
  Future<bool> _fetchUserInfo() async {
    Uri url = Uri.https(_authority, '/user_info/${_client_id!}');

    Response response = await _client.get(
      url,
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    Map<String, dynamic> responseBody =
        jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      //
      print('--- fetch user info --- \n' +
          response.body +
          '\n--- fetch user info --- \n');
      //
      _user!.name = responseBody['name'];
      _user!.email = responseBody['email'];
      _responseMessage = APIResponseMessages.success;
      return true;
    } else {
      //
      print('--- fetch user info --- \n' +
          (response.reasonPhrase ?? '') +
          '\n--- fetch user info --- \n');
      //
      _responseMessage = responseBody['detail'];
      //
    }

    return false;
  }

  /// Requisição para recuperar perfil do usuário
  Future<bool> _fetchUserProfile() async {
    Uri url = Uri.https(_authority, '/profile/${_client_id!}');

    Response response = await _client.get(
      url,
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    Map<String, dynamic> responseBody =
        jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      //
      print('--- fetch profile --- \n' +
          response.body +
          '\n--- fetch profile --- \n');
      //
      _user!.profile = Profile.fromMap(responseBody);
      _responseMessage = APIResponseMessages.success;
      return true;
    } else {
      //
      print('--- fetch profile --- \n' +
          (response.reasonPhrase ?? '') +
          '\n' +
          responseBody['detail'] +
          '\n--- fetch profile --- \n');
      //
      _responseMessage = responseBody['detail'];
      //
    }

    return false;
  }

  @Deprecated('usado temporariamente enquanto a api não salva imagem de perfil')
  Future<void> _updateProfilePic() async {
    User? userData =
        await DatabaseHelper.instance.queryUserByClientID(_client_id!);
    if (userData != null) {
      _user!.profile.profile_pic = userData.profile.profile_pic;
    }
  }

  // era pra ser um método privado, mas por causa da foto de perfil tá temporariamente publico
  Future<bool> updateDBUserProfile() async {
    User? userData =
        await DatabaseHelper.instance.queryUserByClientID(_client_id!);
    if (userData == null) {
      await DatabaseHelper.instance.insertUser(_user!, _client_id!);
      // não é a maneira mais inteligente mas é o que tem,
      // dava pra fazer pelo banco mas eu não quis por questões de encapsulamento
      User? userID =
          await DatabaseHelper.instance.queryUserByClientID(_client_id!);
      _user!.id = userID!.id;
      return true;
    } else {
      _user!.id = userData.id;
      return await DatabaseHelper.instance.updateUser(_user!);
    }
  }

  Future<bool> _fetchDBUserProfile() async {
    User? userData =
        await DatabaseHelper.instance.queryUserByClientID(_client_id!);
    _user!.id = userData!.id;
    _user!.name = userData.name;
    _user!.email = userData.email;
    _user!.profile = userData.profile;
    return true;
  }

  /// Envia a medição coletada pelo bluetooth para ser processada na nuvem
  Future<bool> postMeasurements(
      MeasurementCollected measurement,
      // [User? user]) async {
      String user) async {
    return user == 'Eu'
        ? _postMeasurements(measurement)
        : _postPacientMeasurements(measurement, user);
  }

  Future<bool> _postMeasurements(MeasurementCollected measurement) async {
    Uri url = Uri.https(_authority, '/measure/${_client_id!}/glucose');

    Response response = await _client.post(
      url,
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(measurement.toMap()),
    );

    Map<String, dynamic> responseBody =
        jsonDecode(utf8.decode(response.bodyBytes));

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

  Future<bool> _postPacientMeasurements(
      // MeasurementCollected measurement, User user) async {
      MeasurementCollected measurement,
      String user) async {
    print('oi, enviei do paciente');
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

    Map<String, dynamic> responseBody =
        jsonDecode(utf8.decode(response.bodyBytes));

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
  static const String emptyProfile = 'Non-existent User Profile!';
  static const String clientIdError = 'Non-existent User!';
  static const String wrongPassword = 'Invalid password';
  static const String tokenExpired = 'Token expired';
  static const String invalidFields = 'value is not a valid email address';
  static const String noConnection = 'no internet connection established';
  static const String offlineMode = 'no internet connection, limited features';
}
