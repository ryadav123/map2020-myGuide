import 'dart:io';
//import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myGuide/controller/firebasecontroller.dart';
import 'package:myGuide/model/translation.dart';
import 'package:myGuide/screens/add_screen.dart';
import 'package:myGuide/screens/saved-trans_screen.dart';
//import 'package:photomemo/screens/detailed_screen.dart';
import 'package:myGuide/screens/settings_screen.dart';
//import 'package:photomemo/screens/sharedwith_screen.dart';
import 'package:myGuide/screens/signin_screen.dart';
//import 'package:myGuide/screens/view/mydialog.dart';
import 'package:myGuide/screens/view/myimageview.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/signInScreen/homeScreen';
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<HomeScreen> {
  _Controller con;
  FirebaseUser user;
  List<MyTranslation> translations;
  var formKey = GlobalKey<FormState>();
  bool ascending = true;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    Map arg = ModalRoute.of(context).settings.arguments;
    user ??= arg['user'];
    translations ??= arg['translationList'];

    return Scaffold(
      drawer: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.fromLTRB(10, 30, 100, 100),
            children: <Widget>[
              UserAccountsDrawerHeader(
                currentAccountPicture: ClipOval(
                  child: MyImageView.network(
                      imageUrl: user.photoUrl, context: context),
                ),
                accountEmail: Text('Email: ${user.email}'),
                accountName: Text(user.displayName ?? 'N/A'),
              ),
              Card(
                color: Colors.greenAccent,
                elevation: 5,
                  child: ListTile(
                  leading: Icon(Icons.translate),
                  title: Text('New',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                  onTap: con.addTranslation,
                ),
              ), 
              Card(
                color: Colors.greenAccent,
                elevation: 5,
                              child: ListTile(
                  leading: Icon(Icons.save),
                  title: Text('Saved',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                  onTap: con.savedTranslation,
                ),
              ),             
              Card(
                color: Colors.greenAccent,
                elevation: 5,
                              child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                  onTap: con.settings,
                ),
              ),
              Card(
                color: Colors.greenAccent,
                elevation: 5,
                              child: ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Sign Out',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                  onTap: con.signOut,
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: con.settings,
              icon: Icon(Icons.settings),
            )
          ],
          title: Center(
            child: Text(
              'Homepage',
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

      body: Column(
          children: [
            Center(
      child: Container(
        width: 200,
        height: 250,
        child: con.imageFile == null
                      ? MyImageView.network(
                          imageUrl: user.photoUrl, context: context)
                      : Image.file(con.imageFile, fit: BoxFit.fill),
      ),
            ),
            Text(user.displayName == null ? 'Hello':
      user.displayName,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10,),
            Expanded(
      child: Container(
        color: Colors.white70,
        height: 100,
        width: 260,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: GridView.count(
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              crossAxisCount: 2,
              primary: false,
              children: [
                GestureDetector(
                  child: Card(
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                    color: Colors.white,
                    elevation: 10,
                    child: Column(
                      children: [
                        Image.asset('assets/images/new.jpeg',width: 80,height: 80,),
                        Text(
                          'New \nTranslation',
                          style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                  onTap: con.addTranslation,
                ),                      
                GestureDetector(
                  child: Card(
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                    color: Colors.white,
                    elevation: 10,
                    child: Column(
                      children: [
                        SizedBox(height: 13,),
                        Image.asset('assets/images/saved.jpeg',width: 60,height: 60,),
                        SizedBox(height: 8,),
                        Text(
                          'Saved \nTranslations',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                  onTap: con.savedTranslation,
                ),
              ],
            ),
          ),
        ),
      ),
            ),
      FlatButton.icon(
        onPressed: con.signOut,
        icon: Icon(Icons.exit_to_app),
        label: Text("Sign Out"),
      ),      
          ],
        ),
    );
  }
}

class _Controller {
  _HomeState _state;
  int delIndex;
  String searchKey;
  File imageFile;
  _Controller(this._state);

  void settings() async {
    await Navigator.pushNamed(_state.context, SettingScreen.routeName,
        arguments: _state.user);

    // to get updated user profile do the following 2 steps
    await _state.user.reload();
    _state.user = await FirebaseAuth.instance.currentUser();
    //  Navigator.pop(_state.context);
    _state.render(() {});
  }

  void savedTranslation() async {
    try {
      await Navigator.pushNamed(_state.context, SavedTranslationScreen.routeName,
          arguments: {
            'user': _state.user, 'translationList': _state.translations
          });
   //   Navigator.pop(_state.context); // close the drawer
    } catch (e) {}
  }

  void addTranslation() async {
    try {
      await Navigator.pushNamed(_state.context, AddScreen.routeName,
          arguments: {
            'user': _state.user, 'translationList': _state.translations
          });
   //   Navigator.pop(_state.context); // close the drawer
    } catch (e) {}
  }

  void signOut() async {
    try {
      await FirebaseController.signOut();
    } catch (e) {
      print('signOut exception: ${e.message}');
    }
    Navigator.pushReplacementNamed(_state.context, SignInScreen.routeName);
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
