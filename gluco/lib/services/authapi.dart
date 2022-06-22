import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'package:gluco/models/user.dart';
import 'package:gluco/models/authmodels.dart';
import 'package:gluco/services/autenticacaoteste.dart';

/// API para autenticação dos usuários
class AuthAPI {
  static User currentUser = User(
    id: -1,
    name: '',
    email: '',
    password: '',
  );

  static String _emailSecret = '';
  static String _passwordSecret = '';

  static bool _alreadyEncrypted = false;

  static String _responseMessage = '';

  static final _client = Client();

  static Future<bool> login(String email, String password) async {
    Uri url = Uri.http('api.egluco.bio.br', '/users/login');

    String encryptedPassword;
    LoginRequestModel model;

    if (_alreadyEncrypted) {
      model = LoginRequestModel(email: email, password: password);
      encryptedPassword = password;
      _alreadyEncrypted = false;
    } else {
      encryptedPassword = await _encrypt(password);
      model = LoginRequestModel(email: email, password: encryptedPassword);
    }

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
        _emailSecret = responseModel.emailsecret!;
        _passwordSecret = responseModel.passwordsecret!;
        currentUser.id = responseModel.id!;
        currentUser.name = responseModel.name!;
        currentUser.email = email;
        currentUser.password = encryptedPassword;
        await _saveCredentials();
        await fetchUserProfile();
        return true;
      case 403:
      case 404:
        _responseMessage = responseModel.message;
        return false;
      default:
        return false;
    }
  }

  static Future<bool> signUp(String name, String email, String password) async {
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
        _alreadyEncrypted = true;
        // apenas adiciono os dados no currentuser
        // ou faço login por questão de consistência?
        await login(email, encryptedPassword);
        return true;
      case 403:
      case 404:
        _responseMessage = responseTeste.body;
        return false;
      default:
        return false;
    }
  }

  static Future<bool> fetchUserProfile() async {
    Uri url = Uri.http('api.egluco.bio.br', '/users/userprofile');

    RequestModel model = RequestModel(
      emailsecret: _emailSecret,
      passwordsecret: _passwordSecret,
      email: currentUser.email,
      password: currentUser.password,
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
        currentUser.profile = responseModel.profile;
        return true;
      default:
        return false;
    }
  }

  static Future<bool> updateUserProfile(String birthdate, String weight,
      String height, String sex, String diabetes) async {
    Uri url = Uri.http('api.egluco.bio.br', '/users/userprofile');

    Profile profile = Profile(
      birthdate: DateTime.parse(birthdate),
      weight: double.parse(weight),
      height: double.parse(height),
      sex: sex,
      diabetes: diabetes,
    );

    ProfileRequestModel model = ProfileRequestModel(
      emailsecret: _emailSecret,
      passwordsecret: _passwordSecret,
      email: currentUser.email,
      password: currentUser.password,
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
        await fetchUserProfile();
        return true;
      case 400:
        _responseMessage = responseTeste.body;
        return false;
      default:
        return false;
    }
  }

  static Future<bool> logout() async {
    currentUser.email = '';
    currentUser.password = '';
    currentUser.profile = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.remove('email') && await prefs.remove('password');
  }

  static Future<bool> _saveCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString('email', currentUser.email) &&
        await prefs.setString('password', currentUser.password);
  }

  static Future<bool> fetchCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    /// finge que tem um usuário logado pra não ficar indo
    /// pra tela de login toda vez que builda
    if (!prefs.containsKey('email') && !prefs.containsKey('password')) {
      prefs.setString('email', 'lucassbrach@gmail.com');
      prefs.setString('password',
          '3d4f5f9202ef0203bc4505526152c4a5f3bcec94a90714387ceb2c8246342364');
    }
    //////

    _alreadyEncrypted = true;
    return login(
        prefs.getString('email') ?? '', prefs.getString('password') ?? '');
  }

  static String getResponseMessage() {
    String message = _responseMessage;
    // só pode ser lida uma vez
    _responseMessage = '';
    return message;
  }

  static Future<String> _encrypt(String string) async {
    await dotenv.load();
    String secret = dotenv.get('MOT');
    Hmac hmac = Hmac(sha256, secret.codeUnits);
    Digest digest = hmac.convert(string.codeUnits);
    return digest.toString();
  }
}
