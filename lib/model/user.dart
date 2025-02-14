class User {
  final int id;

  final String name;
  final String mobileno;
  final String email;
  final String username;
  final String password;

  User({
    required this.id,
    required this.name,
    required this.mobileno,
    required this.email,
    required this.username,
    required this.password,
  });

  // Factory method for creating a User instance from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['assistant_id'],
      name: json['name'],
      mobileno: json['mobileno'],
      email: json['email'],
      username: json['username'],
      password: json['password'],
    );
  }

  // Method for converting a User instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobileno': mobileno,
      'email': email,
      'username': username,
      'password': password,
    };
  }

  @override
  String toString() {
    return 'User{id: $id,  name: $name, email: $email, username: $username, password: $password, }';
  }
}
