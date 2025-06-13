class SetTokenAction {
  final String token;
  SetTokenAction(this.token);
}

class SetUserInfoAction {
  final Map<String, dynamic> userInfo;
  SetUserInfoAction(this.userInfo);
}

class ClearAuthAction {
  ClearAuthAction();
}
