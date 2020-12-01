import 'package:flutter/material.dart';
import 'package:myGuide/controller/firebasecontroller.dart';
import 'package:myGuide/model/translation.dart';
import 'package:myGuide/screens/add_screen.dart';
import 'package:myGuide/screens/detailed_screen.dart';
import 'package:myGuide/screens/view/mydialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myGuide/screens/view/myimageview.dart';

class SavedTranslationScreen extends StatefulWidget {  
  static const routeName = '/homeScreen/SavedTranslationScreen';  
  @override
  State<StatefulWidget> createState() {
    return _SavedTranslationState();
  }
}

class _SavedTranslationState extends State<SavedTranslationScreen> {
  _Controller con;
  FirebaseUser user;
  List<MyTranslation> translations;
  var formKey = GlobalKey<FormState>();
  bool ascending = true;
  bool _titleSearch = true;

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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
            backgroundColor: Colors.white,
          //   title: Center(
          //   child: Text(
          //     'Saved Translations',
          //     style: TextStyle(
          //       color: Colors.black,
          //       fontSize: 25,
          //       fontWeight: FontWeight.bold,
          //     ),
          //   ),
          // ),
          actions: [
            IconButton(
                    icon: Icon(Icons.sort_by_alpha),
                    onPressed: con.sort,
            ),
            Container(
              height: 50,
              width: 200.0,
              child: Form(
                key: formKey,
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Search by title/text',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  autocorrect: false,
                  onSaved: con.onSavedSearchKey,
                ),
              ),
            ),
            // con.delIndex == null
            //     ? IconButton(
            //         icon: Icon(Icons.search),
            //         onPressed: con.search,
            //       )
            //     : IconButton(icon: Icon(Icons.delete), onPressed: con.delete),
            
            IconButton(
                    icon: Icon(Icons.search),
                    onPressed: con.search,
                  ),            
            
            IconButton(icon: Icon(Icons.delete), onPressed: con.delete),
          ],
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: con.addButton,
        ),
      body: translations.length == 0
            ? Center(
              child: Text(
                  'No Saved Translations',
                  style: TextStyle(fontSize: 30.0),
                ),
            )
            : ListView.builder(
                itemCount: translations.length,
                itemBuilder: (BuildContext context, int index) => Container(
                  color: con.delIndex != null && con.delIndex == index
                      ? Colors.red[200]
                      : Colors.white,
                      padding: EdgeInsets.all(8),
                  
                  child: Card(      
                      shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(40)),                               
                      color: Colors.yellow[200],
                      elevation: 20,
                      child: ListTile(
                      leading: Container(
                        height: 60,
                        width: 60,
                        child: MyImageView.network(
                            imageUrl: translations[index].photoURL, context: context, ),
                      ),
                      trailing: Icon(Icons.keyboard_arrow_right),
                      title: translations[index].title == null ?
                      Center(child: Text('Not a valid Translation',style: TextStyle(fontSize: 20, color: Colors.red),))
                      :Center(child: Text(translations[index].title,style: TextStyle(fontSize: 20, color: Colors.red),)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Created By: ${translations[index].createdBy}'),
                         // Text('SharedWith: ${translations[index].sharedWith}'),
                          Text('Created On: ${translations[index].createdOn}'),
                          Center(child: Text('Text', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15))),
                          translations[index].orgtext == null ?
                          Text('\n No translation text provided', style: TextStyle(fontStyle: FontStyle.italic))
                          : Text('\n ${translations[index].orgtext}', style: TextStyle(fontStyle: FontStyle.italic)),
                          Center(child: Text('Translation', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15))),
                          translations[index].transtext == null ?
                          Text('\n No text were provided and translation wasnt done', style: TextStyle(fontStyle: FontStyle.italic))
                          :Text('\n ${translations[index].transtext}', style: TextStyle(fontStyle: FontStyle.italic)),                        
                        ],
                      ),
                      onTap: () => con.onTap(index),
                      onLongPress: () => con.onLongPress(index),
                    ),
                  ),
                ),
              ),
        
        
    );
  }
}

class _Controller {
  _SavedTranslationState _state;
  _Controller(this._state);
  int delIndex;
  String email;
  String password;
  String searchKey;

void addButton() async {
    // navigate to Addscreen
    await Navigator.pushNamed(_state.context, AddScreen.routeName,
        arguments: {'user': _state.user, 'translationList': _state.translations});
    _state.render(() {});
  }

  void sort() async {
        
    var sortresults;
    if (_state.ascending) {
      sortresults = await FirebaseController.getTranslationsascending(_state.user.email);
      _state.ascending = false;
    } else {
      sortresults = await FirebaseController.getTranslationsdescending(_state.user.email);
      _state.ascending = true;
    }

    _state.render(() => _state.translations = sortresults);
  }

  void onLongPress(int index) {
    _state.render(() {
      delIndex = (delIndex == index ? null : index);
    });
  }

  void onTap(int index) async {
    if (delIndex != null) {
      //cancel delete mode
      _state.render(() => delIndex = null);
      return;
    }
    await Navigator.pushNamed(_state.context, DetailedScreen.routeName,
        arguments: {
          'user': _state.user,
          'translation': _state.translations[index]
        });
    _state.render(() {});
  }
  void delete() async {
    try {
      MyTranslation trans = _state.translations[delIndex];
      await FirebaseController.deleteTranslation(trans);
      _state.render(() {
        _state.translations.removeAt(delIndex);
      });
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Delete Translation Error',
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
      results = await FirebaseController.getTranslations(_state.user.email);
    } else {
      //results = await FirebaseController.getTranslations(_state.user.email);
      if (_state._titleSearch) {
        results = await FirebaseController.searchInTitle(
        email: _state.user.email, searchLabel: searchKey);
        _state._titleSearch = false;
        MyDialog.info(
        context: _state.context,
        title: 'Search',
        content: 'Searched by Title',
      );
      }else {
        results = await FirebaseController.searchInText(
        email: _state.user.email, searchLabel: searchKey);
        _state._titleSearch = true;
        MyDialog.info(
        context: _state.context,
        title: 'Search',
        content: 'Searched by Text',
        );
      }
    }
    _state.render(() => _state.translations = results);
    
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