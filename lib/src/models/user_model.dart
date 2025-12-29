class UserModel {
  int? id;
  String username;
  String password;
  String? email;

  UserModel({
    this.id,
    required this.username,
    required this.password,
    this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'],
        username: map['username'],
        password: map['password'],
        email: map['email'],
      );
}