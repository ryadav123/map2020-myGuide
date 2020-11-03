import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myGuide/controller/firebasecontroller.dart';
import 'package:myGuide/model/translation.dart';
import 'package:myGuide/screens/view/mydialog.dart';

class AddfromTextScreen extends StatefulWidget {
  static const routeName = '/home/addfromImageScreen';

  @override
  State<StatefulWidget> createState() {
    return _AddfromTextState();
  }
}

class _AddfromTextState extends State<AddfromTextScreen> {
  _Controller con;
  var formKey = GlobalKey<FormState>();
  FirebaseUser user;
  List<Translation> translations;
  
  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
        user ??= args['user'];
        translations ??= args['photoMemoList'];

    return Scaffold(
        
        appBar: AppBar(
          title: Text('Add text translation'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: con.save,
            ),
          ],
        ),
        body: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[                
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Text',
                  ),
                  //initialValue: _initialText == null ? 'nullba': 'Rohan',
                  autocorrect: true,
                  keyboardType: TextInputType.multiline,
                  validator: con.validatorText,
                  onSaved: con.onSavedText,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Translation',
                  ),
                  autocorrect: true,
                  validator: con.validatorTitle,
                  onSaved: con.onSavedTitle,
                ),
                
                ],
            ),
          ),
        ));
  }
}

class _Controller {
  _AddfromTextState _state;
  _Controller(this._state);
  String sentence;
  String title;
  String text;
  List<String> sharedWith = [];
  String uploadProgressMessage;

 
  void save() async {
    if (!_state.formKey.currentState.validate()) {
      return;
    }
    _state.formKey.currentState.save();
    
    try {
    MyDialog.circularProgressStart(_state.context);
    // 1. upload pic to Storage
    Map <String, String> photoInfo = await FirebaseController.uploadStorage(
       // image: _state.image,
        uid: _state.user.uid,
        sharedWith: sharedWith,
        listener: (double progressPercentage) {
          _state.render(() => uploadProgressMessage = 'Uploading: ${progressPercentage.toStringAsFixed(1)} %');
        }
        );
        
    // 2. get image labels by ML kit
    // _state.render(() => uploadProgressMessage = 'ML Image Labeler started!');
    // List<String> labels = await FirebaseController.getImageLabels(_state.image);
    // print('*********labels:'+labels.toString());

    // 3. save photomemo doc to Firestore
    var p = Translation(
      title: title,
      orgtext: text,
      photoPath: photoInfo['path'],
      photoURL: photoInfo['url'],
      createdBy: _state.user.email,
      sharedWith: sharedWith,
      updatedAt: DateTime.now(),
     // imageLabels: labels,
    );

    p.docId = await FirebaseController.addTranslation(p);
    _state.translations.insert(0, p);

    MyDialog.circularProgressEnd(_state.context);

    Navigator.pop(_state.context);
    } catch (e) {

          MyDialog.circularProgressEnd(_state.context);

        MyDialog.info(
          context: _state.context,
          title: 'Firebase Error',
          content: e.message ?? e.toString(),
        );
    }
  }

  void getPicture(String src) async {
    try {
      PickedFile _imageFile;
      if (src == 'camera') {
        _imageFile = await ImagePicker().getImage(source: ImageSource.camera);
      } else {
        _imageFile = await ImagePicker().getImage(source: ImageSource.gallery);
      }
      _state.render(() {
      //  _state.image = File(_imageFile.path);
      });
    } catch (e) {}
  }

  String validatorTitle(String value) {
    if (value == null || value.trim().length < 2) {
      return 'min 2 chars';
    } else {
      return null;
    }
  }

  void onSavedTitle(String value) {
    this.title = value;
  }

  String validatorText(String value) {
    if (value == null || value.trim().length < 3) {
      return 'min 3 chars';
    } else {
      return null;
    }
  }

  void onSavedText(String value) {
    this.text = value;
  }

  String validatorSharedWith(String value) {
    if (value == null || value.trim().length == 0) return null;
    List<String> emailList = value.split(',').map((e) => e.trim()).toList();
    for (String email in emailList) {
      if (email.contains('@') && email.contains('.'))
        continue;
      else
        return 'Comma(,) separated email list';
    }
    return null;
  }

  void onSavedSharedWith(String value) {
    if (value.trim().length != 0) {
      this.sharedWith = value.split(',').map((e) => e.trim()).toList();
    }
  }
}