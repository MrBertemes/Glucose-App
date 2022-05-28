class SignUpRequestModel {
  late final String username;
  late final String email;
  late final String password;

  SignUpRequestModel({
    required this.username,
    required this.email,
    required this.password,
  });

  SignUpRequestModel.fromMap(Map<String, dynamic> json) {
    username = json['username'];
    email = json['email'];
    password = json['password'];
  }

  Map<String, dynamic> toMap() {
    final _data = <String, dynamic>{};
    _data['username'] = username;
    _data['email'] = email;
    _data['password'] = password;
    return _data;
  }
}

class SignUpResponseModel {
  late final String message;
  late final Data data;

  SignUpResponseModel({
    required this.message,
    required this.data,
  });

  SignUpResponseModel.fromMap(Map<String, dynamic> json) {
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
  late final String username;
  late final String email;
  late final String date;

  Data({
    required this.id,
    required this.username,
    required this.email,
    required this.date,
  });

  Data.fromMap(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    date = json['date'];
  }

  Map<String, dynamic> toMap() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['username'] = username;
    _data['email'] = email;
    _data['date'] = date;
    return _data;
  }
}
