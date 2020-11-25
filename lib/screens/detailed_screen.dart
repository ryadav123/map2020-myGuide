import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:myGuide/model/translation.dart';
import 'package:myGuide/screens/view/mydialog.dart';
import 'package:myGuide/screens/view/myimageview.dart';
import 'package:myGuide/screens/view/mydialog.dart';
import 'package:myGuide/screens/view/myimageview.dart';
import 'package:share/share.dart';

class DetailedScreen extends StatefulWidget {
  static const routeName = '/savedTranslationScreen/detailedScreen';

  @override
  State<StatefulWidget> createState() {
    return _DetailedState();
  }
}

class _DetailedState extends State<DetailedScreen> {
  _Controller con;
  FirebaseUser user;
  MyTranslation translation;
  final flutterTts = FlutterTts();

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
    translation ??= args['translation'];

    return Scaffold(        
        appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Colors.white,
          actions: <Widget>[
             IconButton(
               icon: Icon(Icons.share),
                onPressed: () => con.sharememo(context,translation),
                ),             
           ],
          title: Center(
            child: Text(
              'Detailed View',
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
              )
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width/2,                  
                  child: MyImageView.network(imageUrl: translation.photoURL, context: context),
                ),
              ),
              Text(translation.title,style: TextStyle(fontSize: 20, color: Colors.red)),
              Text('Text', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
              Text('${translation.orgtext}', style: TextStyle(fontStyle: FontStyle.italic)),
              IconButton(
                      iconSize: 35,
                      color: Colors.black,
                      icon: Icon(Icons.speaker_phone),
                      onPressed: () => con.speak(translation.orgtext),
                    ),
              Text('\nTranslation', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
              Text('${translation.transtext}', style: TextStyle(fontStyle: FontStyle.italic)),
              IconButton(
                      iconSize: 35,
                      color: Colors.black,
                      icon: Icon(Icons.speaker_phone),
                      onPressed: () => con.speak(translation.transtext),
                    ),
              Text('\nCreated By: ${translation.createdBy}'),
              Text('Created On: ${translation.createdOn}')              
            ],
          ),
        )
        );
  }
}

class _Controller {
  _DetailedState _state;
  _Controller(this._state);

 Future<void> speak(String value) async {  
    try { 
      if (value== null) {
        MyDialog.info(
        context: _state.context,
        title: 'Speak Error',
        content: 'No translation yet',
      );
      
      }
      else {
    await _state.flutterTts.setVolume(1000);
    await _state.flutterTts.setPitch(1.0);
    await _state.flutterTts.speak(value);
      }
    } catch(e) {
      MyDialog.info(
        context: _state.context,
        title: 'Speak Error',
        content: e.message ?? e.toString(),
      );
    }
  }

void sharememo(BuildContext context, MyTranslation translation ) async {
    try {
    var response = await http.get(translation.photoURL);
    var filePath = await ImagePickerSaver.saveFile(fileData: response.bodyBytes);
    List<String>imagePaths = [];
    
    imagePaths.add(filePath);
     final RenderBox box = context.findRenderObject();
     Share.shareFiles(
       imagePaths,
       text: 'Title: ${translation.title} \n Original Text: ${translation.orgtext} \n Translated Text: ${translation.transtext} \n Created By: ${translation.createdBy} \n Created On: ${translation.createdOn} \n',
       subject: 'Translation Info',
       sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
       );
    } catch (e) {
     MyDialog.info(
         context: _state.context,
         title: 'Mail Sending Error',
         content: e.message ?? e.toString(),
       );
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