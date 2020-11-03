import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myGuide/controller/firebasecontroller.dart';
import 'package:myGuide/model/translation.dart';
import 'package:myGuide/screens/add_screen.dart';
import 'package:myGuide/screens/addfromimage_screen.dart';
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
  List<Translation> translations;
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

    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Home'),
          actions: <Widget>[
            Container(
              width: 170.0,
              child: Form(
                key: formKey,
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'translation search',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  autocorrect: false,
                  onSaved: con.onSavedSearchKey,
                ),
              ),
            ),
            con.delIndex == null
                ? IconButton(
                    icon: Icon(Icons.search),
                    onPressed: con.search,
                  )
                : IconButton(icon: Icon(Icons.delete), onPressed: con.delete),
            IconButton(
                    icon: Icon(Icons.sort_by_alpha),
                    onPressed: con.sort,
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                currentAccountPicture: ClipOval(
                  child: MyImageView.network(
                      imageUrl: user.photoUrl, context: context),
                ),
                accountEmail: Text(user.email),
                accountName: Text(user.displayName ?? 'N/A'),
              ),
              // ListTile(
              //   leading: Icon(Icons.translate),
              //   title: Text('New'),
              //   onTap: con.addTranslation,
              // ),
              Container(
                        color: Colors.blue[200],
                        child: PopupMenuButton<String>(
                          onSelected: con.add,
                          itemBuilder: (context) => <PopupMenuEntry<String>>[
                            PopupMenuItem(
                              value: 'camera',
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.photo_camera),
                                  Text('Camera'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'gallery',
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.photo_album),
                                  Text('Gallery'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: con.settings,
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Sign Out'),
                onTap: con.signOut,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: con.addButton,
        ),
        body: translations.length == 0
            ? Text(
                'No translations',
                style: TextStyle(fontSize: 30.0),
              )
            : ListView.builder(
                itemCount: translations.length,
                itemBuilder: (BuildContext context, int index) => Container(
                  color: con.delIndex != null && con.delIndex == index
                      ? Colors.red[200]
                      : Colors.white,
                  child: ListTile(
                    leading: Container(
                      height: 60,
                      width: 60,
                      child: MyImageView.network(
                          imageUrl: translations[index].photoURL, context: context, ),
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    title: Text(translations[index].title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Text: ${translations[index].orgtext}'),
                        Text('Translation: ${translations[index].sharedWith}'),
                        Text('Created By: ${translations[index].createdBy}'),                        
                        Text('Updated At: ${translations[index].updatedAt}'),
                        
                      ],
                    ),
                    onTap: () => {},//con.onTap(index),
                    onLongPress: () => con.onLongPress(index),
                  ),
                ),
              ),
      ),
    );
  }
}

class _Controller {
  _HomeState _state;
  int delIndex;
  String searchKey;

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
    Navigator.pop(_state.context);
  }

  void add(String src) {

  }

  void addTranslation() async {
    try {
      await Navigator.pushNamed(_state.context, AddScreen.routeName,
          arguments: {
            'user': _state.user,
            
          });
      Navigator.pop(_state.context); // close the drawer
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
    await Navigator.pushNamed(_state.context, AddfromImageScreen.routeName,
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
      Translation photoMemo = _state.translations[delIndex];
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

