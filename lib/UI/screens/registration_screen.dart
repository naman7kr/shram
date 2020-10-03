import 'package:flutter/material.dart';

import 'package:shram/UI/BaseView.dart';
import 'package:shram/UI/screens/home_screen.dart';
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
  bool _isLoading = false;
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
  void didChangeDependencies() {
    final authenticationService = locator<AuthenticationService>();
    initialValues['email'] = authenticationService.firebaseUser.email;
    super.didChangeDependencies();
  }

  Future<void> _saveForm(LoginPageModel model) async {
    FocusScope.of(context).unfocus();
    var isValid = _form.currentState.validate();
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

  @override
  Widget build(BuildContext ctx) {
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
                                            initialValue:
                                                initialValues['phoneNumber'],
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                                labelText: 'Phone Number'),
                                            textInputAction:
                                                TextInputAction.done,
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
                                        RaisedButton(
                                          onPressed: () {},
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
