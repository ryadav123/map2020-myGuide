import 'package:flutter/material.dart';
import 'package:myGuide/screens/addfromimage_screen.dart';
//import 'package:photomemo/screens/detailed_screen.dart';
//import 'package:photomemo/screens/edit_screen.dart';
import 'package:myGuide/screens/home_screen.dart';
import 'package:myGuide/screens/settings_screen.dart';
import 'package:myGuide/screens/add_screen.dart';
import 'package:myGuide/screens/signin_screen.dart';
import 'package:myGuide/screens/signup_screen.dart';
import 'package:myGuide/screens/passwordreset_screen.dart';


void main () {
  runApp(myGuide());
}

class myGuide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: SignInScreen.routeName,
      routes: {
        SignInScreen.routeName: (context) => SignInScreen(),
        HomeScreen.routeName: (context) => HomeScreen(),
        AddfromImageScreen.routeName: (context) => AddfromImageScreen(),
        //DetailedScreen.routeName: (context) => DetailedScreen(),
        //EditScreen.routeName: (context) => EditScreen(),
        AddScreen.routeName: (context) => AddScreen(),
        SignUpScreen.routeName: (context) => SignUpScreen(),
        SettingScreen.routeName: (context) => SettingScreen(),
        ForgotPasswordScreen.routeName: (context) => ForgotPasswordScreen(),
      }
    );
  }

}