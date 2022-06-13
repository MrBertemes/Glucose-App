import 'package:gluco/models/user.dart';

/// Model para body da requisição de login
class LoginRequestModel {
  late final String email;
  late final String password;

  LoginRequestModel({
    required this.email,
    required this.password,
  });

  LoginRequestModel.fromMap(Map<String, dynamic> json) {
    email = json['email'];
    password = json['password'];
  }

  Map<String, dynamic> toMap() {
    final _data = <String, dynamic>{};
    _data['email'] = email;
    _data['password'] = password;
    return _data;
  }
}

/// Model para body da requisição de signup
class SignUpRequestModel {
  // será que nome deveria ficar no perfil e não no cadastro?
  // assim teria um corpo padrão de requisição contendo email e senha,
  // e o que se quer recuperar fica no header???
  late final String name;
  late final String email;
  late final String password;

  SignUpRequestModel({
    required this.name,
    required this.email,
    required this.password,
  });

  SignUpRequestModel.fromMap(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    password = json['password'];
  }

  Map<String, dynamic> toMap() {
    final _data = <String, dynamic>{};
    _data['name'] = name;
    _data['email'] = email;
    _data['password'] = password;
    return _data;
  }
}

/// Model para resposta de requisição de perfil
class ProfileResponseModel {
  late final String message;
  late final Profile?
      profile; // usei o mesmo perfil de User do app, não sei o quanto isso faz sentido

  ProfileResponseModel({
    required this.message,
    required this.profile,
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
