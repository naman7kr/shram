import 'package:firebase_auth/firebase_auth.dart' as Auth;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:shram/UI/BaseView.dart';
import 'package:shram/UI/screens/home_screen.dart';
import 'package:shram/UI/screens/verify_phone_screen.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:shram/UI/widgets/Background.dart';
import 'package:shram/core/enums/result.dart';
import 'package:shram/core/models/user.dart';
import 'package:shram/core/services/authentication_service.dart';
import 'package:shram/core/viewmodel/login_page_model.dart';

import '../../locator.dart';

class RegistrationScreen extends StatefulWidget {
  static const String routeName = '/register';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _addressFocus = FocusNode();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _form = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  bool isPhoneVerified = false;
  bool _isLoading = false;
  bool _isFirstTime = true;
  var _user = User(
    userName: '',
    email: '',
    address: '',
    phoneNumber: '',
  );
  var initialValues = {
    'userName': '',
    'email': '',
    'address': '',
    'phoneNumber': ''
  };
  @override
  void dispose() {
    _addressFocus.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isFirstTime) {
      _isFirstTime = false;
      final authenticationService = locator<AuthenticationService>();
      initialValues['email'] = authenticationService.firebaseUser.email;
    }
    super.didChangeDependencies();
  }

  Future<void> _saveForm(LoginPageModel model) async {
    FocusScope.of(context).unfocus();
    var isValid = _form.currentState.validate();
    if (!isPhoneVerified) {
      Fluttertoast.showToast(
          msg: "Please verify phone number",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    if (isValid) {
      _form.currentState.save();
      setState(() {
        _isLoading = true;
      });
      _user.isAdmin = false;
      try {
        if (await model.checkInternetConnection()) {
          await model.registerUser(_user);
          if (await model.isUserRegistered() == ResultType.SUCCESSFUL) {
            setState(() {
              _isLoading = false;
            });
            _scaffoldKey.currentState.hideCurrentSnackBar();
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text(string.registered_successfully),
              duration: Duration(seconds: integer.snackbar_duration),
            ));
            // navigate to home page
            Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
          } else {
            setState(() {
              _isLoading = false;
            });
            _scaffoldKey.currentState.hideCurrentSnackBar();
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content:
                  Text('Registration unsuccessful. Please try again later'),
              duration: Duration(seconds: integer.snackbar_duration),
            ));
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          _scaffoldKey.currentState.hideCurrentSnackBar();
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(string.register_error),
            duration: Duration(seconds: integer.snackbar_duration),
          ));
        }
      } catch (err) {
        print(err);
        setState(() {
          _isLoading = false;
        });
        _scaffoldKey.currentState.hideCurrentSnackBar();
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Registration unsuccessful. Please try again later'),
          duration: Duration(seconds: integer.snackbar_duration),
        ));
      }
    }
  }

  Future _verifyPhone(LoginPageModel model, String phoneNumber) async {
    setState(() {
      _isLoading = true;
    });
    FocusScope.of(context).unfocus();
    if (phoneNumber.isEmpty) {
      Fluttertoast.showToast(
          msg: "Enter Phone Number",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        _isLoading = false;
      });
      return;
    }
    if (phoneNumber.length != 10) {
      Fluttertoast.showToast(
          msg: "Invalid Phone Number",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // check if phone number already exists
    if (await model.checkInternetConnection()) {
      try {
        bool phoneCheckResult = await model.checkIfMobileExists(phoneNumber);
        if (phoneCheckResult) {
          Fluttertoast.showToast(
              msg: "Phone number already registered",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.black54,
              textColor: Colors.white,
              fontSize: 16.0);
          setState(() {
            _isLoading = false;
          });
          return;
        }
      } catch (err) {
        print(err);
        Fluttertoast.showToast(
            msg: "Please try after some time",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          _isLoading = false;
        });
        return;
      }
    } else {
      Fluttertoast.showToast(
          msg: "Check your internet connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        _isLoading = false;
      });
      return;
    }
    var existingPhone = Auth.FirebaseAuth.instance.currentUser.phoneNumber;
    if (existingPhone.isNotEmpty &&
        existingPhone.compareTo(phoneController.text) == 0) {
      setState(() {
        isPhoneVerified = true;
        _isLoading = false;
      });
      Fluttertoast.showToast(
          msg: "Phone number is already verified",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    // check if auth phone is equal to provided number

    var result = await Navigator.of(context)
        .pushNamed(VerifyPhoneScreen.routeName, arguments: phoneNumber);
    setState(() {
      _isLoading = false;
    });
    if (result != null) {
      setState(() {
        isPhoneVerified = true;
      });
    }
  }

  @override
  Widget build(BuildContext ctx) {
    if (phoneController != null) {
      // print('wtf');
    }
    return BaseView<LoginPageModel>(
      onModelReady: (modal) => modal,
      builder: (context, modal, child) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(
              'Register',
              style: Theme.of(context).textTheme.headline1,
            ),
            actions: [
              FlatButton(
                onPressed: _isLoading ? null : () => _saveForm(modal),
                child: InkWell(
                  child: Text(
                    'Submit',
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  onTap: () => _saveForm(modal),
                ),
              )
            ],
          ),
          body: Stack(
            children: [
              Background(
                imageLocation: string.default_background,
                child: Container(
                  margin: EdgeInsets.only(
                    top: 80,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(50),
                                    topRight: Radius.circular(50))),
                            elevation: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 40, left: 20, right: 20, bottom: 20),
                              child: Form(
                                key: _form,
                                child: ListView(
                                  children: [
                                    TextFormField(
                                      initialValue: initialValues['userName'],
                                      decoration:
                                          InputDecoration(labelText: 'Name'),
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) {
                                        FocusScope.of(context)
                                            .requestFocus(_addressFocus);
                                      },
                                      onSaved: (val) {
                                        _user.userName = val.trim();
                                      },
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please Provide your Name';
                                        }
                                        return null;
                                      },
                                    ),
                                    TextFormField(
                                      initialValue: initialValues['email'],
                                      enabled: false,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration:
                                          InputDecoration(labelText: 'Email'),
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) {
                                        // FocusScope.of(context).requestFocus(_priceFocusNode);
                                      },
                                      onSaved: (val) {
                                        _user.email = val.trim();
                                      },
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please Provide your Email';
                                        }
                                        return null;
                                      },
                                    ),
                                    TextFormField(
                                      initialValue: initialValues['address'],
                                      focusNode: _addressFocus,
                                      keyboardType: TextInputType.multiline,
                                      decoration:
                                          InputDecoration(labelText: 'Address'),
                                      maxLines: 4,
                                      textInputAction: TextInputAction.newline,
                                      onSaved: (val) {
                                        _user.address = val.trim();
                                      },
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please Provide your Address';
                                        }
                                        if (value.trim().length < 15) {
                                          return 'Should be at least 15 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text('+91'),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                                labelText: 'Phone Number'),
                                            textInputAction:
                                                TextInputAction.done,
                                            controller: phoneController,
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Please Provide your Phone number';
                                              }
                                              if (value.trim().length != 10) {
                                                return 'Invalid Phone number';
                                              }
                                              if (int.parse(value).isNaN) {
                                                return 'Invalid Phone number';
                                              }
                                              return null;
                                            },
                                            onSaved: (val) {
                                              _user.phoneNumber = val.trim();
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        isPhoneVerified
                                            ? Icon(
                                                Icons.verified,
                                                color: Colors.greenAccent,
                                              )
                                            : RaisedButton(
                                                onPressed: () {
                                                  _verifyPhone(modal,
                                                      phoneController.text);
                                                },
                                                child: Text('Verify'),
                                              )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: FlatButton(
                          child: Text('Submit'),
                          color: Theme.of(context).accentColor,
                          onPressed: () => _saveForm(modal),
                        ),
                      ),
                    ],
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
                  : Container(),
            ],
          ),
        );
      },
    );
  }
}
