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

class LoginResponseModel {
  late final String message;
  late final Data data;

  LoginResponseModel({
    required this.message,
    required this.data,
  });

  LoginResponseModel.fromMap(Map<String, dynamic> json) {
    message = json['message'];
    data = Data.fromMap(json['data']);
  }

  Map<String, dynamic> toMap() {
    final _data = <String, dynamic>{};
    _data['message'] = message;
    _data['data'] = data.toMap();
    return _data;
  }
}

class Data {
  late final String id;
  late final String email;
  late final String password;
  late final String token;
  late final String date;

  Data({
    required this.id,
    required this.email,
    required this.password,
    required this.token,
    required this.date,
  });

  Data.fromMap(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    password = json['password'];
    token = json['token'];
    date = json['date'];
  }

  Map<String, dynamic> toMap() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['email'] = email;
    _data['password'] = password;
    _data['token'] = token;
    _data['date'] = date;
    return _data;
  }
}
