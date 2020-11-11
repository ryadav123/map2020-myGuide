import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myGuide/controller/firebasecontroller.dart';
import 'package:myGuide/model/translation.dart';
import 'package:myGuide/screens/add_screen.dart';
//import 'package:photomemo/screens/detailed_screen.dart';
import 'package:myGuide/screens/settings_screen.dart';
//import 'package:photomemo/screens/sharedwith_screen.dart';
import 'package:myGuide/screens/signin_screen.dart';
import 'package:myGuide/screens/view/mydialog.dart';
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
  // var _scaffoldKey = GlobalKey<ScaffoldState>();
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
      // key: _scaffoldKey,
      drawer: Padding(
        padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
        child: Drawer(
          child: ListView(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.translate),
                title: Text('New',
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                onTap: () {},
              ),
              FlatButton(
                child: Text('From Text',
                    style:
                        TextStyle(fontWeight: FontWeight.w300, fontSize: 15)),
                onPressed: con.addTranslation,
              ),
              FlatButton(
                child: Text('From Image',
                    style:
                        TextStyle(fontWeight: FontWeight.w300, fontSize: 15)),
                onPressed: con.addTranslation,
              ),
              // ListTile(
              //   leading: Icon(Icons.settings),
              //   title: Text('Settings',
              //       style:
              //           TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
              //   onTap: con.settings,
              // ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Sign Out',
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                onTap: con.signOut,
              ),
            ],
          ),
        ),
      ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
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
              //   gradient: LinearGradient(
              // colors: [Color(0xFF696D77), Color(0xFF292C36)],
              // begin: Alignment.bottomRight,
              // end: Alignment.topLeft,
              // tileMode: TileMode.clamp,
            )),
          ),
        ),
      ),

      body: Column(
        children: [
          Center(
            child: Container(
              width: 100,
              height: 100,
              // decoration: BoxDecoration(
              //     border: Border.all(color: Colors.red, width: 5),
              //     shape: BoxShape.circle,
              //     color: Colors.white,
              //     image: DecorationImage(
              //         fit: BoxFit.cover, image: NetworkImage(user.photoUrl))),
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.count(
                mainAxisSpacing: 3,
                crossAxisSpacing: 3,
                crossAxisCount: 3,
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
                            'New Translation',
                            style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
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
                          Image.asset('assets/images/search.jpeg',width: 70,height: 70,),
                          Text(
                            'Search Translation',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),                            
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      print("Hello");
                    },
                  ),
                  GestureDetector(
                    child: Card(
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                      color: Colors.white,
                      elevation: 10,
                      child: Column(
                        children: [
                          Image.asset('assets/images/saved.jpeg',width: 80,height: 80,),
                          Text(
                            'Saved Translations',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      print("Hello");
                    },
                  ),
                ],
              ),
            ),
          ),
          Text('Recent Translations', style: TextStyle(fontSize:25, fontWeight:FontWeight.bold),textAlign: TextAlign.left,),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.count(
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
                crossAxisCount: 3,
                primary: false,
                children: [
                  GestureDetector(
                    child: Card(
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                      color: Colors.blue,
                      elevation: 10,
                      child: Column(
                        children: [
                          //  SvgPicture.network('C:\Users\badal\Downloads\google-translate.svg'),
                          Text(
                            'New Translation',
                            style: TextStyle(fontSize: 15),
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
                      color: Colors.blue,
                      elevation: 10,
                      child: Column(
                        children: [
                          //  SvgPicture.network('C:\Users\badal\Downloads\google-translate.svg'),
                          Text(
                            'New Translation',
                            style: TextStyle(fontSize: 15),
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      print("Hello");
                    },
                  ),
                  GestureDetector(
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      color: Colors.blue,
                      elevation: 10,
                      child: Column(
                        children: [
                          //  SvgPicture.network('C:\Users\badal\Downloads\google-translate.svg'),
                          Text(
                            'New Translation',
                            style: TextStyle(fontSize: 15),
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      print("Hello");
                    },
                  ),
                ],
              ),
            ),
          ),
          RaisedButton.icon(
            color: Colors.blue,
            onPressed: con.signOut,
            icon: Icon(Icons.exit_to_app),
            label: Text("Sign Out"),
          )
        ],
      ),
    );

    // return WillPopScope(
    //   onWillPop: () => Future.value(false),
    //   child: Scaffold(
    //     appBar: AppBar(
    //       title: Text('Home'),
    //       actions: <Widget>[
    //         Container(
    //           width: 170.0,
    //           child: Form(
    //             key: formKey,
    //             child: TextFormField(
    //               decoration: InputDecoration(
    //                 hintText: 'translation search',
    //                 fillColor: Colors.white,
    //                 filled: true,
    //               ),
    //               autocorrect: false,
    //               onSaved: con.onSavedSearchKey,
    //             ),
    //           ),
    //         ),
    //         con.delIndex == null
    //             ? IconButton(
    //                 icon: Icon(Icons.search),
    //                 onPressed: con.search,
    //               )
    //             : IconButton(icon: Icon(Icons.delete), onPressed: con.delete),
    //         IconButton(
    //                 icon: Icon(Icons.sort_by_alpha),
    //                 onPressed: con.sort,
    //         ),
    //       ],
    //     ),
    //     drawer: Drawer(
    //       child: ListView(
    //         children: <Widget>[
    //           UserAccountsDrawerHeader(
    //             currentAccountPicture: ClipOval(
    //               child: MyImageView.network(
    //                   imageUrl: user.photoUrl, context: context),
    //             ),
    //             accountEmail: Text(user.email),
    //             accountName: Text(user.displayName ?? 'N/A'),
    //           ),
    //           ListTile(
    //             leading: Icon(Icons.translate),
    //             title: Text('New'),
    //             onTap: con.addTranslation,
    //           ),

    //           ListTile(
    //             leading: Icon(Icons.settings),
    //             title: Text('Settings'),
    //             onTap: con.settings,
    //           ),
    //           ListTile(
    //             leading: Icon(Icons.exit_to_app),
    //             title: Text('Sign Out'),
    //             onTap: con.signOut,
    //           ),
    //         ],
    //       ),
    //     ),
    //     floatingActionButton: FloatingActionButton(
    //       child: Icon(Icons.add),
    //       onPressed: con.addButton,
    //     ),
    //     body: translations.length == 0
    //         ? Text(
    //             'No translations',
    //             style: TextStyle(fontSize: 30.0),
    //           )
    //         : ListView.builder(
    //             itemCount: translations.length,
    //             itemBuilder: (BuildContext context, int index) => Container(
    //               color: con.delIndex != null && con.delIndex == index
    //                   ? Colors.red[200]
    //                   : Colors.white,
    //               child: ListTile(
    //                 leading: Container(
    //                   height: 60,
    //                   width: 60,
    //                   child: MyImageView.network(
    //                       imageUrl: translations[index].photoURL, context: context, ),
    //                 ),
    //                 trailing: Icon(Icons.keyboard_arrow_right),
    //                 title: Text(translations[index].title),
    //                 subtitle: Column(
    //                   crossAxisAlignment: CrossAxisAlignment.start,
    //                   children: <Widget>[
    //                     Text('Text: ${translations[index].orgtext}'),
    //                     Text('Translation: ${translations[index].sharedWith}'),
    //                     Text('Created By: ${translations[index].createdBy}'),
    //                     Text('Updated At: ${translations[index].updatedAt}'),

    //                   ],
    //                 ),
    //                 onTap: () => {},//con.onTap(index),
    //                 onLongPress: () => con.onLongPress(index),
    //               ),
    //             ),
    //           ),
    //   ),
    // );
  }
}

class _Controller {
  _HomeState _state;
  int delIndex;
  String searchKey;
  File imageFile;
  _Controller(this._state);

  void sort() async {
    var sortresults;
    if (_state.ascending) {
      // sortresults = await FirebaseController.getPhotoMemosascending(_state.user.email);
      _state.ascending = false;
    } else {
      //  sortresults = await FirebaseController.getPhotoMemosdescending(_state.user.email);
      _state.ascending = true;
    }

    _state.render(() => _state.translations = sortresults);
  }

  void settings() async {
    await Navigator.pushNamed(_state.context, SettingScreen.routeName,
        arguments: _state.user);

    // to get updated user profile do the following 2 steps
    await _state.user.reload();
    _state.user = await FirebaseAuth.instance.currentUser();
    //  Navigator.pop(_state.context);
    _state.render(() {});
  }

  void add(String src) {}

  void addTranslation() async {
    try {
      await Navigator.pushNamed(_state.context, AddScreen.routeName,
          arguments: {
            'user': _state.user,
          });
   //   Navigator.pop(_state.context); // close the drawer
    } catch (e) {}
  }

  void onLongPress(int index) {
    _state.render(() {
      delIndex = (delIndex == index ? null : index);
    });
  }

  // void onTap(int index) async {
  //   if (delIndex != null) {
  //     //cancel delete mode
  //     _state.render(() => delIndex = null);
  //     return;
  //   }
  //   await Navigator.pushNamed(_state.context, DetailedScreen.routeName,
  //       arguments: {
  //         'user': _state.user,
  //         'photoMemo': _state.photoMemos[index]
  //       });
  //   _state.render(() {});
  // }

  void addButton() async {
    // navigate to Addscreen
    await Navigator.pushNamed(_state.context, AddScreen.routeName,
        arguments: {'user': _state.user, 'photoMemoList': _state.translations});
    _state.render(() {});
  }

  void signOut() async {
    try {
      await FirebaseController.signOut();
    } catch (e) {
      print('signOut exception: ${e.message}');
    }
    Navigator.pushReplacementNamed(_state.context, SignInScreen.routeName);
  }

  void delete() async {
    try {
      MyTranslation photoMemo = _state.translations[delIndex];
      await FirebaseController.deletePhotoMemo(photoMemo);
      _state.render(() {
        _state.translations.removeAt(delIndex);
      });
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Delete Photomemo error',
        content: e.message ?? e.toString(),
      );
    }
  }

  void onSavedSearchKey(String value) {
    searchKey = value;
  }

  void search() async {
    _state.formKey.currentState.save();

    var results;
    if (searchKey == null || searchKey.trim().isEmpty) {
      results = await FirebaseController.getPhotoMemos(_state.user.email);
    } else {
      results = await FirebaseController.searchImages(
          email: _state.user.email, imageLabel: searchKey);
    }

    _state.render(() => _state.translations = results);
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
