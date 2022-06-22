import 'package:gluco/models/user.dart';
// os toMaps e fromMaps comentados não foram usados na autenticação teste
// mas provavelmente serão usados nas requisições de verdade

/// Request genérico, é o que imagino que será usado no fetch das medições também
class RequestModel {
  late final String email;
  late final String password;
  late final String emailsecret;
  late final String passwordsecret;

  RequestModel({
    required this.email,
    required this.password,
    required this.emailsecret,
    required this.passwordsecret,
  });

  // RequestModel.fromMap(Map<String, dynamic> json) {
  //   email = json['email'];
  //   password = json['password'];
  //   emailsecret = json['emailsecret'];
  //   passwordsecret = json['passwordsecret'];
  // }

  // Map<String, dynamic> toMap() {
  //   final _data = <String, dynamic>{};
  //   _data['email'] = email;
  //   _data['password'] = password;
  //   _data['emailsecret'] = emailsecret;
  //   _data['passwordsecret'] = passwordsecret;
  //   return _data;
  // }
}

/// Model para body da requisição de login
class LoginRequestModel {
  late final String email;
  late final String password;

  LoginRequestModel({
    required this.email,
    required this.password,
  });

  // LoginRequestModel.fromMap(Map<String, dynamic> json) {
  //   email = json['email'];
  //   password = json['password'];
  // }

  Map<String, dynamic> toMap() {
    final _data = <String, dynamic>{};
    _data['email'] = email;
    _data['password'] = password;
    return _data;
  }
}

/// Model para resposta de requisição de login
class LoginResponseModel {
  late String message;
  late int? id;
  late String? name;
  late String? emailsecret;
  late String? passwordsecret;

  LoginResponseModel({
    required this.message,
    this.id,
    this.name,
    this.emailsecret,
    this.passwordsecret,
  });

  LoginResponseModel.fromMap(Map<String, dynamic> json) {
    message = json['message'];
    id = json['id'];
    name = json['name'];
    emailsecret = json['emailsecret'];
    passwordsecret = json['passwordsecret'];
  }

  Map<String, dynamic> toMap() {
    final _data = <String, dynamic>{};
    _data['message'] = message;
    _data['id'] = id;
    _data['name'] = name;
    _data['emailsecret'] = emailsecret;
    _data['passwordsecret'] = passwordsecret;
    return _data;
  }
}

/// Model para body da requisição de signup
class SignUpRequestModel {
  late final String name;
  late final String email;
  late final String password;

  SignUpRequestModel({
    required this.name,
    required this.email,
    required this.password,
  });

  // SignUpRequestModel.fromMap(Map<String, dynamic> json) {
  //   name = json['name'];
  //   email = json['email'];
  //   password = json['password'];
  // }

  Map<String, dynamic> toMap() {
    final _data = <String, dynamic>{};
    _data['name'] = name;
    _data['email'] = email;
    _data['password'] = password;
    return _data;
  }
}

/// Model para body da requisição de alteração de perfil
class ProfileRequestModel {
  late final String email;
  late final String password;
  late final String emailsecret;
  late final String passwordsecret;
  late final String profile;

  ProfileRequestModel({
    required this.email,
    required this.password,
    required this.emailsecret,
    required this.passwordsecret,
    required this.profile,
  });

  // ProfileRequestModel.fromMap(Map<String, dynamic> json) {
  //   email = json['email'];
  //   password = json['password'];
  //   emailsecret = json['emailsecret'];
  //   passwordsecret = json['passwordsecret'];
  //   profile = json['profile'];
  // }

  Map<String, dynamic> toMap() {
    final _data = <String, dynamic>{};
    _data['email'] = email;
    _data['password'] = password;
    _data['emailsecret'] = emailsecret;
    _data['passwordsecret'] = passwordsecret;
    _data['profile'] = profile;
    return _data;
  }
}

/// Model para resposta de requisição de perfil
class ProfileResponseModel {
  late String message;
  late Profile?
      profile; // usei o mesmo perfil de User do app, não sei o quanto isso faz sentido

  ProfileResponseModel({
    required this.message,
    this.profile,
  });

  ProfileResponseModel.fromMap(Map<String, dynamic> json) {
    message = json['message'];
    profile = json['profile'] == null ? null : Profile.fromMap(json['profile']);
  }

  Map<String, dynamic> toMap() {
    final _data = <String, dynamic>{};
    _data['message'] = message;
    _data['profile'] = profile?.toMap();
    return _data;
  }
}
