class User {
  String email;
  String password;
  Profile? profile;

  User({
    required this.email,
    required this.password,
    this.profile,
  });

  factory User.fromMap(Map<String, dynamic> json) => User(
        email: json['email'],
        password: json['password'],
        profile:
            json['profile'] == null ? null : Profile.fromMap(json['profile']),
      );

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'profile': profile?.toMap(),
    };
  }
}

class Profile {
  int id;
  String name;
  DateTime birthdate;
  double weight;
  double height;
  String sex;
  int diabetes;

  Profile({
    required this.id,
    required this.name,
    required this.birthdate,
    required this.weight,
    required this.height,
    required this.sex,
    required this.diabetes,
  });

  factory Profile.fromMap(Map<String, dynamic> json) => Profile(
        id: json['id'],
        name: json['name'],
        birthdate: DateTime.parse(json['birthdate']),
        weight: json['weight'],
        height: json['height'],
        sex: json['sex'],
        diabetes: json['diabetes'],
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'birthdate': birthdate.toString(),
      'weight': weight,
      'height': height,
      'sex': sex,
      'diabetes': diabetes,
    };
  }
}
