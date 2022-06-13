import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gluco/services/autenticacaoteste.dart';
import 'package:http/http.dart';
import 'package:gluco/models/user.dart';
import 'package:gluco/models/authmodels.dart';

/// API para autenticação dos usuários (não movi pra api.dart por preguiça, faz mal ficar assim?)
class AuthAPI {
  static User currentUser = User(
    email: '',
    password: '',
  );

  static String _responseMessage = '';

  static final _client = Client();

  static Future<bool> login(String email, String password) async {
    Uri url = Uri.http('egluco.bio.br', '/users/login');

    String encryptedPassword = await _encrypt(password);
    LoginRequestModel model =
        LoginRequestModel(email: email, password: encryptedPassword);

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
    Response responseTeste = await AutenticacaoTeste.postLogin(model);
    switch (responseTeste.statusCode) {
      /////////////////////////////////////
      // switch (response.statusCode) {
      case 200:
        _responseMessage = responseTeste.body;
        currentUser.email = email;
        currentUser.password = encryptedPassword;
        // deveria salvar no sharedpreferences pra manter logado se fechar o app
        await saveCredentials();
        await fetchUserProfile();
        return true;
      case 403:
      case 404:
        _responseMessage = responseTeste.body;
        return false;
      default:
        return false;
    }
  }

  static Future<bool> signUp(String name, String email, String password) async {
    Uri url = Uri.http('egluco.bio.br', '/users/signup');

    String encryptedPassword = await _encrypt(password);
    SignUpRequestModel model = SignUpRequestModel(
        name: name, email: email, password: encryptedPassword);

    /* precisa botar num bloco try catch
    Response response = await _client.post(
      url,
      body: jsonEncode(model.toMap()),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    */

    ///////////////////////////////////// isso é só pra teste
    Response responseTeste = await AutenticacaoTeste.postSignUp(model);
    switch (responseTeste.statusCode) {
      /////////////////////////////////////
      // switch (response.statusCode) {
      case 200:
        _responseMessage = responseTeste.body;
        // automaticamente loga após signup bem sucedido, será que login e signup são a mesma coisa?
        // logar == setar email e senha no usuário atual
        currentUser.email = email;
        currentUser.password = encryptedPassword;
        // deveria salvar no sharedpreferences pra manter logado se fechar o app
        await saveCredentials();
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
    Uri url = Uri.http('egluco.bio.br', '/users/userprofile');

    // não era pra ser uma requisção de login,
    // mas fiquei com preguiça de fazer outra que teria exatamente os mesmos campos
    LoginRequestModel model = LoginRequestModel(
        email: currentUser.email, password: currentUser.password);

    /* precisa botar num bloco try catch
    Response response = await _client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Basic ${loginDetails!.data.token}',
      },
    );
    */

    ///////////////////////////////////// isso é só pra teste
    Response responseTeste = await AutenticacaoTeste.postUserProfile(model);
    switch (responseTeste.statusCode) {
      /////////////////////////////////////
      // switch (response.statusCode) {
      case 200:
        ProfileResponseModel responseModel =
            ProfileResponseModel.fromMap(jsonDecode(responseTeste.body));
        if (responseModel.profile != null) {
          currentUser.profile = responseModel.profile;
          _responseMessage = responseModel.message;
        } else {
          _responseMessage = 'Empty profile';
        }
        return true;
      default:
        return false;
    }
  }

  static Future<void> logout() async {
    // exclui as credenciais do sharedpreferences
    currentUser.email = '';
    currentUser.password = '';
    currentUser.profile = null;
  }

  // esse nome não é exatamente sugestivo, seria melhor algo como 'temAsCredenciaisSalvasNoDispositivo?'
  // pq se tiver usa elas pra fazer login, é isso?
  static Future<bool> isLoggedIn() async {
    // recupera credenciais do sharedpreferences
    // chama login pra confirmar credenciais?
    // seta credenciais no usuário atual <-- importante

    // só pra fingir que tem um usuário logado
    if (currentUser.email == '') {
      currentUser.email = 'lucassbrach@gmail.com';
      currentUser.password =
          '3d4f5f9202ef0203bc4505526152c4a5f3bcec94a90714387ceb2c8246342364';
    }
    await fetchUserProfile(); // não sei se isso deveria estar aqui
    // deveria fazer fetch das medições também? mas não aqui
    return true;
  }

  static Future<void> saveCredentials() async {
    // salva no sharedpreferences as credenciais do usuário atual
  }

  static String getResponseMessage() {
    String message = _responseMessage;
    _responseMessage = ''; // só pode ser lida uma vez
    return message;
  }

  static Future<String> _encrypt(String string) async {
    await dotenv.load();
    String _secret = dotenv.get('MOT');
    Hmac hmac = Hmac(sha256, _secret.codeUnits);
    Digest digest = hmac.convert(string.codeUnits);
    return digest.toString();
  }
}
