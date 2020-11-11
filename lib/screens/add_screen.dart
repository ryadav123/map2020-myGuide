import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myGuide/controller/firebasecontroller.dart';
import 'package:myGuide/model/translation.dart';
import 'package:myGuide/screens/view/mydialog.dart';
import 'package:translator/translator.dart';

class AddScreen extends StatefulWidget {
  static const routeName = '/home/addfromImageScreen';

  @override
  State<StatefulWidget> createState() {
    return _AddState();
  }
}

class _AddState extends State<AddScreen> {
  _Controller con;
  File image;
  var formKey = GlobalKey<FormState>();
  FirebaseUser user;
  List<MyTranslation> translations;
  var _initialText;
  var _languages = ['English','Hindi','Nepali','Maithli',];
  var _currentItemSelected = 'English';
  GoogleTranslator translator = GoogleTranslator();
  final lang = TextEditingController();
  var out;
  
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
        
        appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          actions: [
            IconButton(
              onPressed: con.save,
              icon: Icon(Icons.check),
            )
          ],
          title: Center(
            child: Text(
              'Add Translation',
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
        body: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width/2,
                      child: image == null
                          ? Icon(Icons.photo_library, size: 250.0)
                          : Image.file(image, fit: BoxFit.fill),
                    ),
                    Positioned(
                      right: 0.0,
                      bottom: 0.0,
                      child: Container(
                        color: Colors.blue[200],
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
                                  Icon(Icons.photo_album),
                                  Text('Gallery'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                con.uploadProgressMessage == null ?
                SizedBox(height: 1.0,): Text(con.uploadProgressMessage,style: TextStyle(fontSize: 20.0)),
                RaisedButton(
                  child: Text(
                    'Read Text',
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                  color: Colors.blue,
                  onPressed: con.readText,
                ),
                TextFormField(
                  decoration: InputDecoration(
                  hintText: 'Title',
                  ),
                  autocorrect: true,
                  validator: con.validatorTitle,
                  onSaved: con.onSavedTitle,
                ),
                TextField(
                  controller: lang,
                  decoration: InputDecoration(
                    hintText: 'Text',
                  ),
                 // initialValue: _initialText == null ? 'nullba': 'Rohan',
                  autocorrect: true,
                  keyboardType: TextInputType.multiline,
                //  validator: con.validatorText,
                //  onSaved: con.onSavedText,
                ),
                // TextFormField(
                //  // controller: temp_text,
                //   decoration: InputDecoration(
                //     hintText: 'Text',
                //   ),
                //   initialValue: _initialText == null ? 'nullba': 'Rohan',
                //   autocorrect: true,
                //   keyboardType: TextInputType.multiline,
                //   validator: con.validatorText,
                //   onSaved: con.onSavedText,
                // ),
                Row(
                  children: [
                    Text('Convert to:'),
                    SizedBox(width: 10,),
                    DropdownButton<String>(
                        items: _languages.map((String dropDownStringItem) {
                          return DropdownMenuItem<String>(
                              value: dropDownStringItem ,
                              child: Text(dropDownStringItem),
                          );
                        }).toList(),
                        onChanged: (String newValueSelected) {
                          setState(() {
                            _currentItemSelected = newValueSelected;
                          });
                        },
                        value: _currentItemSelected,
                    ),
                  ],
                ),
                RaisedButton(
                  child: Text(
                    'Translate',
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                  color: Colors.blue,
                  onPressed: con.translate,
                ),
                Text(out.toString()),
                // TextFormField(
                //   decoration: InputDecoration(
                //     hintText: 'Translation',
                //   ),
                //   autocorrect: true,
                //   keyboardType: TextInputType.multiline,
                //   validator: con.validatorSharedWith,
                //   onSaved: con.onSavedSharedWith,
                // ),
              ],
            ),
          ),
        ));
  }
}

class _Controller {
  _AddState _state;
  _Controller(this._state);
  String sentence;
  String title;
  String text;
  var temtext;
  
  List<String> sharedWith = [];
  String uploadProgressMessage;

  void translate() {
    _state.translator.translate(_state.lang.text, to:'hi').then((output) {
      _state.render(() {
        _state.out = output;
      });
    });   

  }

  Future<void> readText() async {
    sentence='';
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(_state.image);
    TextRecognizer recognizedText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizedText.processImage(ourImage);

    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
         // print(word.text);
          sentence = '$sentence ${word.text}';
        }
      }
    }
    print(sentence);
    _state.render(() {_state._initialText = sentence;});
    print(_state._initialText);
  }

  void save() async {
    if (!_state.formKey.currentState.validate()) {
      return;
    }
    _state.formKey.currentState.save();
    
    try {
    MyDialog.circularProgressStart(_state.context);
    // 1. upload pic to Storage
    Map <String, String> photoInfo = await FirebaseController.uploadStorage(
        image: _state.image,
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
    var p = MyTranslation(
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
        _state.image = File(_imageFile.path);
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