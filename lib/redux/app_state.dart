class AppState {
  final String? token;
  final Map<String, dynamic>? userInfo;

  AppState({this.token, this.userInfo});

  factory AppState.initial() => AppState(token: null, userInfo: null);

  AppState copyWith({String? token, Map<String, dynamic>? userInfo}) {
    return AppState(
      token: token ?? this.token,
      userInfo: userInfo ?? this.userInfo,
    );
  }
}
