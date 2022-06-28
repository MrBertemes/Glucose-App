class User {
  int id;
  String name;
  String email;
  Profile? profile;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profile,
  });

  factory User.fromMap(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        profile:
            json['profile'] == null ? null : Profile.fromMap(json['profile']),
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile': profile?.toMap(),
    };
  }
}

class Profile {
  DateTime birthdate;
  double weight;
  double height;
  String sex;
  String diabetes;

  Profile({
    required this.birthdate,
    required this.weight,
    required this.height,
    required this.sex,
    required this.diabetes,
  });

  factory Profile.fromMap(Map<String, dynamic> json) => Profile(
        birthdate: DateTime.parse(json['birthdate']),
        weight: json['weight'],
        height: json['height'],
        sex: json['sex'],
        diabetes: json['diabetes'],
      );

  Map<String, dynamic> toMap() {
    return {
      'birthdate': birthdate.toString(),
      'weight': weight,
      'height': height,
      'sex': sex,
      'diabetes': diabetes,
    };
  }
}
