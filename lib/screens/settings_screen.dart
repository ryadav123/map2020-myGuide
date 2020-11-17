import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myGuide/controller/firebasecontroller.dart';
import 'package:myGuide/screens/view/mydialog.dart';
import 'package:myGuide/screens/view/myimageview.dart';

class SettingScreen extends StatefulWidget {
  static const routeName = '/homescreen/settingsScreen';
  @override
  State<StatefulWidget> createState() {
    return _SettingState();
  }
}

class _SettingState extends State<SettingScreen> {
  _Controller con;
  var formKey = GlobalKey<FormState>();
  FirebaseUser user;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    user ??= ModalRoute.of(context).settings.arguments;
    return Scaffold(
        
        appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: con.save,
              icon: Icon(Icons.check),
            )
          ],
          title: Center(
            child: Text(
              'Profile Settings',
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
              )
              ),
            ),
          ),
        ),
        body: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[                
                Stack(
                  children: <Widget>[
                    Container(
                      height: 200,
                      width: 200,
                      //width: MediaQuery.of(context).size.width,
                      child: con.imageFile == null
                          ? MyImageView.network(
                              imageUrl: user.photoUrl, context: context)
                          : Image.file(con.imageFile, fit: BoxFit.fill),
                    ),
                    Positioned(
                      right: 0.0,
                      bottom: 0.0,
                      child: Container(
                        height: 30,
                        width: 30,
                        color: Colors.blue,
                        child: PopupMenuButton<String>(
                          onSelected: con.getPicture,
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
                                    Icon(Icons.photo_library),
                                    Text('Gallery'),
                                  ],
                                ))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Text('Profile Picture', style: TextStyle(fontSize: 20.0),),
                con.progressMessage == null
                    ? SizedBox(height: 1.0)
                    : Text(
                        con.progressMessage,
                        style: TextStyle(fontSize: 20.0),
                      ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    style: TextStyle(fontSize: 20.0),
                    decoration: InputDecoration(hintText: 'Display Name'),
                    initialValue: user.displayName ?? 'N/A',
                    autocorrect: false,
                    validator: con.validatorDisplayName,
                    onSaved: con.onSavedDisplayName,
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: TextFormField(
                //     style: TextStyle(fontSize: 20.0),
                //     decoration: InputDecoration(hintText: 'Nationality'),
                //     initialValue: user.nationality ?? 'N/A',
                //     autocorrect: false,
                //     validator: con.validatorDisplayName,
                //     onSaved: con.onSavedDisplayName,
                //   ),
                // ),
              ],
            ),
          ),
        ));
  }
}

class _Controller {
  _SettingState _state;
  String progressMessage;
  File imageFile;
  String displayName;
  String nationality;

  _Controller(this._state);

  void save() async {
    if (!_state.formKey.currentState.validate()) return;

    _state.formKey.currentState.save();

    try {
      await FirebaseController.updateProfile(
        image: imageFile,
        displayName: displayName,
        user: _state.user,
        progressListener: (double percentage) {
          _state.render(() {
            progressMessage = 'Uploading ${percentage.toStringAsFixed(1)} %';
          });
        },
      );
      Navigator.pop(_state.context);
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Profile update error',
        content: e.message ?? e.toString(),
      );
    }
  }

  void getPicture(String src) async {
    try {
      PickedFile _image;
      if (src == 'camera')
        _image = await ImagePicker().getImage(source: ImageSource.camera);
      else
        _image = await ImagePicker().getImage(source: ImageSource.gallery);

      _state.render(() => imageFile = File(_image.path));
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Image capture error',
        content: e.message ?? e.toString(),
      );
    }
  }

  String validatorDisplayName(String value) {
    if (value.length < 2)
      return 'min 2 chars';
    else
      return null;
  }

  void onSavedDisplayName(String value) {
    this.displayName = value;
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