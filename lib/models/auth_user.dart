
class AuthUser {
  final int id;
  final String username;
  final String firstName;

  const AuthUser({
    required this.id,
    required this.username,
    required this.firstName,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      firstName: json['firstName'] as String? ?? '',
    );
  }
}
