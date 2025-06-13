import 'app_state.dart';
import 'auth_actions.dart';

AppState authReducer(AppState state, dynamic action) {
  if (action is SetTokenAction) {
    return state.copyWith(token: action.token);
  } else if (action is SetUserInfoAction) {
    return state.copyWith(userInfo: action.userInfo);
  } else if (action is ClearAuthAction) {
    return state.copyWith(token: null, userInfo: null);
  }
  return state;
}
