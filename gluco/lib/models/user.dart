class User {
  int id;
  String name;
  String email;
  late Profile profile;

  User({
    this.id = -1,
    this.name = '', // talvez venha a ser um problema
    this.email = '',
  });

  factory User.fromMap(Map<String, dynamic> json) {
    User user = User(
      id: json['iduser'],
      name: json['name'],
      email: json['email'],
    );
    user.profile = Profile.fromMap(json);
    return user;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> _data = {
      // 'iduser': id,
      'name': name,
      'email': email,
    };
    _data.addAll(profile.toMap());
    return _data;
  }
}

class Profile {
  DateTime birthday;
  double weight;
  double height;
  String sex;
  String diabetes_type;

  Profile({
    required this.birthday,
    required this.weight,
    required this.height,
    required this.sex,
    required this.diabetes_type,
  });

  factory Profile.fromMap(Map<String, dynamic> json) => Profile(
        birthday: DateTime.parse(json['birthday']),
        weight: json['weight'],
        height: json['height'],
        sex: json['sex'],
        diabetes_type: json['diabetes_type'],
      );

  Map<String, dynamic> toMap() {
    return {
      'birthday': birthday.toString().substring(0, 10),
      'weight': weight,
      'height': height,
      'sex': sex,
      'diabetes_type': diabetes_type,
    };
  }
}
