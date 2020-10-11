import 'package:firebase_auth/firebase_auth.dart' as Auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shram/UI/screens/add_worker/add_single_screen.dart';
import 'package:shram/UI/screens/search/search_screen.dart';
import 'package:shram/UI/screens/verify_phone_screen.dart';
import 'package:shram/core/enums/result.dart';
import 'package:shram/core/enums/user_type.dart';
import 'package:shram/core/models/user.dart';
import 'package:shram/core/services/authentication_service.dart';
import 'package:shram/locator.dart';

import 'package:firebase_core/firebase_core.dart';

import 'UI/screens/add_worker/add_multiple_worker_screen.dart';
import 'UI/screens/add_worker/select_add_screen.dart';
import 'UI/screens/home_screen.dart';
import 'UI/screens/login_screen.dart';
import 'UI/screens/registration_screen.dart';

import 'UI/screens/support_screen.dart';
import 'UI/screens/about_screen.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // get home page
  setupLocator();

  Widget home = await getHomePage();
  runApp(MyApp(home));
}

Future<Widget> getHomePage() async {
  final authenticationService = locator<AuthenticationService>();
  bool isLoggedIn = false;
  try {
    isLoggedIn = await authenticationService.isLoggedInUser();
  } catch (err) {
    return Future<Widget>.delayed(Duration(seconds: 1), () {
      return LoginScreen();
    });
  }
  if (!isLoggedIn) {
    return Future<Widget>.delayed(Duration(seconds: 1), () {
      return LoginScreen();
    });
  }
  if (await authenticationService.checkInternetConnection()) {
    ResultType isRegisteredResult = await authenticationService.isRegistered();
    if (isRegisteredResult == ResultType.SUCCESSFUL) {
      return HomeScreen();
    } else {
      return RegistrationScreen();
    }
  } else {
    if (await authenticationService.checkIsRegisteredFromCache()) {
      return HomeScreen();
    } else {
      return LoginScreen();
    }
  }
}

class MyApp extends StatelessWidget {
  final Widget home;
  MyApp(this.home);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<Auth.User>.value(
          initialData: null,
          value: locator<AuthenticationService>()
              .fireBaseUserStream
              .stream
              .asBroadcastStream(),
        ),
        StreamProvider<UserType>.value(
          initialData: UserType.UNKNOWN,
          value: locator<AuthenticationService>()
              .userTypeStream
              .stream
              .asBroadcastStream(),
        ),
        StreamProvider<bool>.value(
          initialData: null,
          value: locator<AuthenticationService>().isUserLoggedInStream.stream,
        ),
      ],
      child: MaterialApp(
        title: 'Shram',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Color(0xFFE040FB),
          buttonTheme: ButtonThemeData(
            buttonColor: Color(0xFFE040FB),
            textTheme: ButtonTextTheme.primary,
          ),
          textTheme: TextTheme(
              headline1: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              headline2: TextStyle(color: Colors.white, fontSize: 18),
              headline3: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              bodyText1: TextStyle(color: Colors.white, fontSize: 14),
              bodyText2: TextStyle(color: Colors.black, fontSize: 14)),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: home,
        routes: {
          HomeScreen.routeName: (_) => HomeScreen(),
          LoginScreen.routeName: (_) => LoginScreen(),
          RegistrationScreen.routeName: (_) => RegistrationScreen(),
          SearchScreen.routeName: (_) => SearchScreen(),
          SupportScreen.routeName: (_) => SupportScreen(),
          AboutScreen.routeName: (_) => AboutScreen(),
          SelectAddScreen.routeName: (_) => SelectAddScreen(),
          AddSingle.routeName: (_) => AddSingle(),
          AddMultipleScreen.routeName: (_) => AddMultipleScreen(),
          VerifyPhoneScreen.routeName: (_) => VerifyPhoneScreen(),
        },
      ),
    );
  }
}
