
import 'auth_user.dart';

class AuthLoginResult {
  final AuthUser user;
  final String accessToken;
  final String refreshToken;

  const AuthLoginResult({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });
}
