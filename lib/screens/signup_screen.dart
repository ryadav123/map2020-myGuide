import 'package:flutter/material.dart';
import 'package:myGuide/controller/firebasecontroller.dart';
import 'package:myGuide/screens/signin_screen.dart';
import 'package:myGuide/screens/view/mydialog.dart';

class SignUpScreen extends StatefulWidget {  
  static const routeName = '/signInScreen/signUpScreen';  
  @override
  State<StatefulWidget> createState() {
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUpScreen> {
  _Controller con;
  var formKey = GlobalKey<FormState>();
  bool _secureText = true;
  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
            backgroundColor: Colors.white,
            title: Center(
            child: Text(
              'Sign Up',
              style: TextStyle(
                color: Colors.black,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          elevation: 0,
          flexibleSpace: ClipPath(
            clipper: _AppBarClipper(),
            child: Container(
                decoration: BoxDecoration(
              color: Colors.blue,              
            )),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0,30,0,0),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                Text('Create an Account',
                style: TextStyle(fontSize: 25.0
                ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18,0,18,0),
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
                  padding: const EdgeInsets.fromLTRB(18,0,18,0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(_secureText? Icons.remove_red_eye:Icons.security),
                        onPressed: () {setState(() {
                          _secureText = !_secureText;
                        });}),
                      hintText: 'Password',
                      
                    ),
                    obscureText: true,
                    autocorrect: false,
                    validator: con.validatorPassword,
                    onSaved: con.onSavedPassword,
                  ),
                ),
                RaisedButton(
                  child: Text('Create',style: TextStyle(fontSize: 20.0, color: Colors.white),),
                  color: Colors.blue,
                  onPressed: con.signUp,
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
  _SignUpState _state;
  _Controller(this._state);
  String email;
  String password;

  void signUp() async {
    if (!_state.formKey.currentState.validate()) return;
    _state.formKey.currentState.save();

    try {
      await FirebaseController.signUp(email, password);
      Navigator.pushReplacementNamed(_state.context, SignInScreen.routeName);
      MyDialog.info(
        context:_state.context,
        title:'Account Created',
        content: 'You can log in now!!',
      );  
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Error',
        content: e.message ?? e.toString(),
      );
    }
  }
  
  String validatorEmail(String value){
    if (value.contains('@') && value.contains('.')) return null;
    else return 'Invalid email';
  }

  void onSavedEmail(String value) {
    this.email = value;
  }

  String validatorPassword(String value){
    if (value.length<6) return 'min 6 chars';
    else return null;
  }

  void onSavedPassword(String value) {
    this.password = value;
  }
}

class _AppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}