//import 'package:myGuide/main.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myGuide/controller/firebasecontroller.dart';
import 'package:myGuide/model/translation.dart';
import 'package:myGuide/screens/home_screen.dart';
import 'package:myGuide/screens/signup_screen.dart';
import 'package:myGuide/screens/pass-reset_screen.dart';
import 'package:myGuide/screens/view/mydialog.dart';

class SignInScreen extends StatefulWidget {
  static const routeName = '/signInScreen';
  @override
  State<StatefulWidget> createState() {
    return _SignInState();
  }
}

class _SignInState extends State<SignInScreen> {
  _Controller con;
  var formKey = GlobalKey<FormState>();
  bool _secureText= true;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    SizedBox(
                      height: 0.0,
                    ),
                    Image.asset(
                     // 'assets/images/translation.jpg',
                      'assets/images/translation1.png',
                      width: 210,
                      height: 210,
                    ),
                    Positioned(
                      top: 180.0,
                      left: 50.0,
                      child: Text(
                        'myGuide',
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontSize: 25.0,
                          fontFamily: 'Audiowide',                          
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    validator: con.validatorEmail,
                    onSaved: con.onSavedEmail,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(_secureText? Icons.remove_red_eye:Icons.security),
                        onPressed: () {setState(() {
                          _secureText = !_secureText;
                        });}),
                    ),
                    obscureText: _secureText,
                    autocorrect: false,
                    validator: con.validatorPassword,
                    onSaved: con.onSavedPassword,
                  ),
                ),
                RaisedButton(
                  child: Text(
                    'Sign In',
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                  color: Colors.blue,
                  onPressed: con.signIn,
                ),
                SizedBox(
                  height: 5.0,
                ),
                FlatButton(
                  onPressed: con.forgotPassword,
                  child: Text('Forgot Password?',style: TextStyle(fontSize: 15.0),),
                ),
                FlatButton(
                  onPressed: con.signUp,
                  child: Text('No account? Click here to create?',style: TextStyle(fontSize: 15.0),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _SignInState _state;
  _Controller(this._state);
  String email;
  String password;

  void forgotPassword() {
    Navigator.pushNamed(_state.context, ForgotPasswordScreen.routeName);
  }

  void signUp() {
    Navigator.pushNamed(_state.context, SignUpScreen.routeName);
  }

  void signIn() async {
    if (!_state.formKey.currentState.validate()) {
      return;
    }

    _state.formKey.currentState.save();

    MyDialog.circularProgressStart(_state.context);

    FirebaseUser user;
    try {
      user = await FirebaseController.signIn(email, password);
     // print('USER: $user');
    } catch (e) {
      MyDialog.circularProgressEnd(_state.context);
      MyDialog.info(
        context: _state.context,
        title: 'Sign In Error',
        content: e.message ?? e.toString(),
      );
      return;
    }

    // sign in succeedd
    // 1.  read all translations from firebase
    try {
      List<MyTranslation> translations =
          await FirebaseController.getTranslations(user.email);
      MyDialog.circularProgressEnd(_state.context);
      // 2.  navigate to Home screen to display photomemo
      Navigator.pushReplacementNamed(_state.context, HomeScreen.routeName,
          arguments: {'user': user, 'translationList': translations});
    } catch (e) {
      MyDialog.circularProgressEnd(_state.context);
      MyDialog.info(
        context: _state.context,
        title: 'Firebase/Firestore error',
        content:
            'Cannot get translations. Try again later! \n ${e.message}',
      );
    }
  }

  String validatorEmail(String value) {
    if (value == null || !value.contains('@') || !value.contains('.')) {
      return 'Invalid email address';
    } else {
      return null;
    }
  }

  void onSavedEmail(String value) {
    email = value;
  }

  String validatorPassword(String value) {
    if (value == null || value.length < 6) {
      return 'password min 6 chars';
    } else {
      return null;
    }
  }

  void onSavedPassword(String value) {
    password = value;
  }
}
