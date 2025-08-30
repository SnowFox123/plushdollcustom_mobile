class RoleAccessDeniedException implements Exception {
  final String role;
  final String message;

  RoleAccessDeniedException(this.role, this.message);

  @override
  String toString() => message;
}

class AuthenticationException implements Exception {
  final String message;

  AuthenticationException(this.message);

  @override
  String toString() => message;
}
