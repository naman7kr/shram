import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shram/UI/screens/home_screen.dart';

import 'package:shram/UI/screens/login_screen.dart';
import 'package:shram/UI/screens/registration_screen.dart';
import 'package:shram/core/enums/result.dart';
import 'package:shram/core/services/authentication_service.dart';
import 'package:shram/locator.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = false;
  bool _isConnectionIssue = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    Timer(Duration(seconds: 2), () {
      // print('Hello');
      _checkIfLoggedIn();
    });
    super.didChangeDependencies();
  }

  void _checkIfLoggedIn() async {
    setState(() {
      _isLoading = true;
      _isConnectionIssue = false;
    });
    final authenticationService = locator<AuthenticationService>();
    bool isRegistered = false;
    bool isLoggedIn = authenticationService.isLoggedIn;

    try {
      if (!isLoggedIn) {
        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      }
      if (await authenticationService.checkIsRegisteredFromCache()) {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      }
      if (await authenticationService.checkInternetConnection()) {
        ResultType isRegisteredResult =
            await authenticationService.isRegistered();
        if (isRegisteredResult == ResultType.SUCCESSFUL) {
          isRegistered = true;
        }
        setState(() {
          _isLoading = false;
        });
        if (isRegistered) {
          Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        } else // if (!isRegistered)
        {
          Navigator.of(context)
              .pushReplacementNamed(RegistrationScreen.routeName);
        }
      } else {
        _isLoading = false;
        _isConnectionIssue = true;
        setState(() {});
      }
    } on PlatformException catch (_) {
      setState(() {
        _isLoading = false;
      });
    } on TimeoutException catch (err) {
      print(err);
    } catch (err) {
      // gen error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/login_background.jpeg'),
                    fit: BoxFit.cover)),
          ),
          _isLoading || _isConnectionIssue
              ? Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                        margin: EdgeInsets.only(bottom: 60),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _isConnectionIssue
                                ? Container(
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.replay,
                                        color: Colors.white,
                                      ),
                                      onPressed: _checkIfLoggedIn,
                                    ),
                                  )
                                : CircularProgressIndicator(),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              !_isConnectionIssue
                                  ? 'Please Wait'
                                  : 'Check your internet connection',
                              style: Theme.of(context).textTheme.bodyText1,
                            )
                          ],
                        )),
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }
}
