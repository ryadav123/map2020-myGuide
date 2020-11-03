import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myGuide/screens/signin_screen.dart';
//import 'package:myGuide/controller/firebasecontroller.dart';
import 'package:myGuide/screens/view/mydialog.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  
  static const routeName = '/signInScreen/ForgotPasswordScreen';
  
  @override
  State<StatefulWidget> createState() {
    return _ForgotPasswordState();
  }

}

class _ForgotPasswordState extends State<ForgotPasswordScreen> {
  _Controller con;
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Forgot Password'),
      // ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0,30,0,0),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                Center(
                  child: Text('Please click the link to reset your password',
                  style: TextStyle(fontSize: 20.0
                  ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(38.0,0,38,0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    validator: con.validatorEmail,
                    
                  ),
                ),
                  RaisedButton(
                  child: Text('Send Reset Email',style: TextStyle(fontSize: 20.0, color: Colors.white),),
                  color: Colors.blue,
                  onPressed: con.sendLink,
                )
              ],
            ),
          ),
        ),
      )
    );
  }

}

class _Controller {
  _ForgotPasswordState _state;
  _Controller(this._state);
  String email;
  String password;

  void sendLink() async {
    
    try {
      if (_state.formKey.currentState.validate()) {
        FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        MyDialog.info(context:_state.context,title:'Reset Email Sent',content: 'Please check your email',
      );
    }
      
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Error',
        content: e.message ?? e.toString(),
      );
    } 
    
    //sleep(Duration(seconds:5));
   // Navigator.pushNamed(_state.context, SignInScreen.routeName);   
  }

  String validatorEmail(String value){
    if (value.contains('@') && value.contains('.'))  {
      email = value;
    } else {
      return 'Invalid email';
    }
    return null;
  }
  }