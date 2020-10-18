import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as Auth;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shram/UI/utilities/resources.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shram/core/services/authentication_service.dart';
import 'package:shram/locator.dart';

class VerifyPhoneScreen extends StatefulWidget {
  static const String routeName = '/verify-phone';

  @override
  _VerifyPhoneScreenState createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  String _phoneNumber = '';
  String currentText = '';
  bool _isFirstTime = true;
  String verificationId;
  TextEditingController textEditingController = TextEditingController();
  bool _isLoading = false;
  var onTapRecognizer;
  StreamController<ErrorAnimationType> errorController;
  AuthenticationService _authenticationService;
  @override
  void initState() {
    onTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.pop(context);
      };
    errorController = StreamController<ErrorAnimationType>();
    _authenticationService = locator<AuthenticationService>();
    super.initState();
  }

  @override
  void dispose() {
    errorController.close();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isFirstTime) {
      _isFirstTime = false;
      _phoneNumber = ModalRoute.of(context).settings.arguments as String;
      _phoneNumber = '+91' + _phoneNumber;
      _sendCodeToPhoneNumber();
    }
    super.didChangeDependencies();
  }

  Future<void> _sendCodeToPhoneNumber() async {
    final Auth.PhoneVerificationCompleted verificationCompleted = (user) async {
      setState(() {
        textEditingController.text = user.smsCode != null ? user.smsCode : '';
        print(
            'Inside _sendCodeToPhoneNumber: signInWithPhoneNumber auto succeeded: $user');
      });
      if (await _authenticationService.checkInternetConnection()) {
        try {
          await Auth.FirebaseAuth.instance.currentUser.updatePhoneNumber(user);
          print('DONE');
          Navigator.of(context).pop('Success');
        } catch (err) {
          print(err);
          setState(() {
            textEditingController.text = '';
          });
        }
      }
    };

    final Auth.PhoneVerificationFailed verificationFailed = (authException) {
      setState(() {
        print(
            'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
      });
    };

    final Auth.PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      this.verificationId = verificationId;
      print("code sent to " + _phoneNumber);
    };

    final Auth.PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      this.verificationId = verificationId;
      print("time out");
    };

    await Auth.FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneNumber,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  Future _onOtpSubmit() async {
    var credential = Auth.PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: textEditingController.text);
    setState(() {
      _isLoading = true;
    });
    if (await _authenticationService.checkInternetConnection()) {
      try {
        await Auth.FirebaseAuth.instance.currentUser
            .updatePhoneNumber(credential);
        print('DONE');
        Navigator.of(context).pop('Success');
      } catch (err) {
        print(err);
        Fluttertoast.showToast(
            msg: "Code entered is incorrect",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          textEditingController.text = '';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      Fluttertoast.showToast(
          msg: "Please Check your Internet Connection and Try Again",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OTP Verification'),
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  margin: EdgeInsets.only(bottom: 30),
                  child: Image(
                    width: 120,
                    height: 120,
                    image: AssetImage(string.phone_verification),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(horizontal: 25),
                  child: Text(
                    'OTP has been sent on your mobile phone. Please enter it below',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                        alignment: Alignment.topCenter,
                        child: PinCodeTextField(
                          appContext: context,
                          length: 6,
                          obscureText: false,
                          animationType: AnimationType.fade,
                          keyboardType: TextInputType.phone,
                          pinTheme: PinTheme(
                              shape: PinCodeFieldShape.underline,
                              borderRadius: BorderRadius.circular(5),
                              fieldHeight: 40,
                              fieldWidth: 40,
                              selectedFillColor: Colors.white,
                              inactiveFillColor: Colors.white,
                              selectedColor: Colors.redAccent,
                              activeFillColor: Colors.white,
                              inactiveColor: Colors.redAccent,
                              activeColor: Colors.greenAccent,
                              borderWidth: 1,
                              disabledColor: Colors.white),
                          animationDuration: Duration(milliseconds: 300),
                          backgroundColor: Colors.white,
                          enableActiveFill: true,
                          errorAnimationController: errorController,
                          controller: textEditingController,
                          onCompleted: (v) {
                            print("Completed");
                          },
                          onChanged: (value) {
                            print(value);
                            setState(() {
                              currentText = value;
                            });
                          },
                          beforeTextPaste: (text) {
                            print("Allowing to paste $text");
                            return true;
                          },
                        )),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      child: InkWell(
                        onTap: () {
                          _onOtpSubmit();
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          child: Container(
                            color: Theme.of(context).primaryColor,
                            child: Container(
                                padding: EdgeInsets.all(10),
                                width: MediaQuery.of(context).size.width * 0.7,
                                alignment: Alignment.center,
                                child: Text(
                                  'Verify',
                                  style: Theme.of(context).textTheme.headline2,
                                )),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _isLoading
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
