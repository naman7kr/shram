import 'package:flutter/material.dart';
import 'package:shram/UI/BaseView.dart';
import 'package:shram/UI/screens/home_screen.dart';
import 'package:shram/UI/screens/registration_screen.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/core/enums/result.dart';
import 'package:shram/core/viewmodel/login_page_model.dart';

class LoginScreen extends StatefulWidget {
  static final String routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _signInWithGoogle(BuildContext context, LoginPageModel model) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await model.onGoogleSignIn();
      ResultType isRegistered = await model.isUserRegistered();
      setState(() {
        _isLoading = false;
      });
      if (isRegistered == ResultType.SUCCESSFUL) {
        // go to home screen
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      } else {
        // go to registration page
        Navigator.of(context)
            .pushReplacementNamed(RegistrationScreen.routeName);
      }
    } catch (err) {
      // show snackbar or something
      setState(() {
        _isLoading = false;
      });
      print(err);
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(string.login_error),
        duration: Duration(seconds: integer.snackbar_duration),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<LoginPageModel>(
        onModelReady: (model) => model,
        builder: (context, model, child) {
          return Scaffold(
            key: _scaffoldKey,
            body: Container(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(
                                'assets/images/login_background.png'),
                            fit: BoxFit.cover)),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 60),
                      color: Colors.black54,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                      child: RaisedButton(
                        color: Colors.white,
                        splashColor: Colors.grey,
                        onPressed: () => _signInWithGoogle(context, model),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40)),
                        highlightElevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image(
                                  image: AssetImage(
                                      "assets/images/google_logo.png"),
                                  height: 35.0),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  'Log in with Google',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  _isLoading
                      ? Positioned.fill(
                          child: Container(
                            color: Colors.black26,
                            child: Align(
                              alignment: Alignment.center,
                              child: Container(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ),
          );
        });
  }
}
