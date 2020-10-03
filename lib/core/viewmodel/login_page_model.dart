import 'package:shram/core/enums/result.dart';
import 'package:shram/core/enums/view_state.dart';
import 'package:shram/core/models/user.dart';
import 'package:shram/core/services/authentication_service.dart';
import 'package:shram/core/viewmodel/BaseModel.dart';

import '../../locator.dart';

class LoginPageModel extends BaseModel {
  final _authenticationService = locator<AuthenticationService>();

  bool isUserLoggedIn() {
    return _authenticationService.isLoggedIn;
  }

  Future onGoogleSignIn() async {
    setState(ViewState.Busy);
    String user = await _authenticationService.signInWithGoogle();
    print(user);
    setState(ViewState.Idle);
  }

  Future<ResultType> isUserRegistered() async {
    return await _authenticationService.isRegistered();
  }

  Future registerUser(User user) async {
    await _authenticationService.registerUser(user);
  }

  Future<bool> checkInternetConnection() async {
    return _authenticationService.checkInternetConnection();
  }

  void signOut() {
    _authenticationService.signOutGoogle();
  }
}
