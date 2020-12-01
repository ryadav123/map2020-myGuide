import 'dart:io';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myGuide/controller/firebasecontroller.dart';
import 'package:myGuide/model/translation.dart';
import 'package:myGuide/screens/view/mydialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:translator/translator.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
  var _languages = [
    'Select',
    'Afrikaans',
    'Albanian',
    'Amharic',
    'Arabic',
    'Armenian',
    'Azerbaijani',
    'Basque',
    'Belarusian',
    'Bengali',
    'Bosnian',
    'Bulgarian',
    'Catalan',
    'Cebuano',
    'Chinese',
    'Corsican',
    'Croatian',
    'Czech',
    'Danish',
    'Dutch',
    'English',
    'Esperanto',
    'Estonian',
    'Finnish',
    'French',
    'Frisian',
    'Galician',
    'Georgian',
    'German',
    'Greek',
    'Gujarati',
    'Haitian Creole',
    'Hausa',
    'Hawaiian',
    'Hebrew',
    'Hindi',
    'Hmong',
    'Hungarian',
    'Icelandic',
    'Igbo',
    'Indonesian',
    'Irish',
    'Italian',
    'Japanese',
    'Javanese',
    'Kannada',
    'Kazakh',
    'Khmer',
    'Kinyarwanda',
    'Korean',
    'Kurdish',
    'Kyrgyz',
    'Lao',
    'Latin',
    'Latvian',
    'Lithuanian',
    'Luzembourgish',
    'Macedonian',
    'Malagasy',
    'Malay',
    'Malayalam',
    'Maltese',
    'Maori',
    'Marathi',
    'Mongolian',
    'Myanmar',
    'Nepali',
    'Norwegian',
    'Nyanja',
    'Odia',
    'Pashto',
    'Persian',
    'Polish',
    'Portuguese',
    'Punjabi',
    'Romanian',
    'Russian',
    'Samoan',
    'Scots Gaelic',
    'Serbian',
    'Sesotho',
    'Shona',
    'Sindhi',
    'Sinhala',
    'Slovak',
    'Slovenian',
    'Somali',
    'Spanish',
    'Sundanese',
    'Swahili',
    'Swedish',
    'Tagalog',
    'Tajik',
    'Tamil',
    'Tatar',
    'Telugu',
    'Thai',
    'Turkish',
    'Turkmen',
    'Ukrainian',
    'Urdu',
    'Uyghur',
    'Uzbek',
    'Vietnamese',
    'Welsh',
    'Xhosa',
    'Yiddish',
    'Yoruba',
    'Zulu'
  ];
  var _currentItemSelected = 'Select';
  GoogleTranslator translator = GoogleTranslator();
  final flutterTts = FlutterTts();
  var out;
  String _translationTitle;
  String _transtitle = 'English-';
  String _translateto;
  stt.SpeechToText _speech;
  bool _isListening = false;

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
    translations ??= args['translationList'];

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
              )),
            ),
          ),
        ),
        body: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text(
                      'Select a text image to read from ?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                Stack(
                  children: <Widget>[
                    Container(
                      height: 100,
                      width: MediaQuery.of(context).size.width / 4,
                      child: image == null
                          ? Icon(Icons.photo_library, size: 90.0)
                          : Image.file(image, fit: BoxFit.fill),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Container(
                        width: 28,
                        height: 28,
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
                con.uploadProgressMessage == null
                    ? SizedBox(
                        height: 1.0,
                      )
                    : Text(con.uploadProgressMessage,
                        style: TextStyle(fontSize: 20.0)),
                Container(
                  height: 20,
                  width: 90,
                  child: RaisedButton(                  
                    child: Text(
                      'Read Text',
                      style: TextStyle(fontSize: 12.0, color: Colors.white),
                    ),
                    color: Colors.blue,
                    onPressed: con.readText,
                  ),
                ),
                _translateto == null
                    ? Text(
                        _transtitle + 'Not Selected',
                        style: TextStyle(
                            color: Colors.red,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            fontSize: 30),
                      )
                      
                    : Text(
                        _transtitle + _translateto,
                        style: TextStyle(
                          color: Colors.red,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            fontSize: 30),
                      ),
                SizedBox(height: 3,),              
                Text(
                  'Type, Read or Speak your text here',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(              
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: TextField(                
                    controller: con.lang,
                    maxLines: null,                    
                    decoration: InputDecoration(    
                      labelText: 'Text',                                       
                      border: OutlineInputBorder(                        
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(20)                          
                        ),                        
                      ),  
                    ),                    
                    autocorrect: true,
                    keyboardType: TextInputType.multiline,                    
                  ),
                ),
                Row(
                  children: [
                    SizedBox(width: MediaQuery.of(context).size.width / 3,),
                    AvatarGlow(
                        animate: _isListening,
                        glowColor: Colors.red,
                        endRadius: 25,
                        duration: const Duration(microseconds: 2000),
                        repeatPauseDuration: const Duration(microseconds: 1000),
                        repeat: true,
                        child: IconButton(
                        iconSize: 35,
                        color: Colors.black,
                        icon: Icon(_isListening ? Icons.mic:Icons.mic_none),
                        onPressed: con.listen,
                      ),
                    ),                  
                    IconButton(
                      iconSize: 35,
                      color: Colors.black,
                      icon: Icon(Icons.speaker_phone),
                      onPressed: () => con.speak(con.lang.text),
                    ),
                  ],
                ),
                
                Row(
                  children: [
                    SizedBox(width: MediaQuery.of(context).size.width / 3.5,),
                    Text(
                      'Convert to:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    DropdownButton<String>(
                      items: _languages.map((String dropDownStringItem) {
                        return DropdownMenuItem<String>(
                          value: dropDownStringItem,
                          child: Text(dropDownStringItem),
                        );
                      }).toList(),
                      onChanged: (String newValueSelected) {
                        setState(() {
                          _currentItemSelected = newValueSelected;
                          _translateto = newValueSelected;
                          _translationTitle = _transtitle + _currentItemSelected;
                          out = null;
                        });
                      },
                      value: _currentItemSelected,
                    ),
                  ],
                ),
                Container(
                  height: 20,
                  width: 87,
                  child: RaisedButton(
                    child: Text(
                      'Translate',
                      style: TextStyle(fontSize: 13.0, color: Colors.white),
                    ),
                    color: Colors.blue,
                    onPressed: con.translate,
                  ),
                ),
                SizedBox(height: 3,),
                Text(
                  'Translation:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Text(out.toString(),style: TextStyle(
                    fontSize: 15,fontWeight: FontWeight.bold,color: Colors.green
                  ),)),
               SizedBox(height: 3,),
               IconButton(
                  iconSize: 35,
                  color: Colors.black,
                  icon: Icon(Icons.speaker_phone),
                 // onPressed: () => con.speak(out.text),
                 onPressed: () {
                   if (out != null) {
                    
                     con.speak(out.text);
                   } else {
                      MyDialog.info(
                      context: context,
                      title: 'Speak Error',
                      content: 'No translation yet',
                      );
                   }
                 },
                ),
                
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
  var lang = TextEditingController();

  List<String> sharedWith = [];
  String uploadProgressMessage;

  Future<void> speak(String value) async {    
    await _state.flutterTts.setVolume(1000);
    await _state.flutterTts.setPitch(1.0);
    await _state.flutterTts.speak(value);

    }
  
  void listen() async {
    _state._speech = stt.SpeechToText();
    
    if(!_state._isListening) {
      
      bool available = await _state._speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        
        _state.render(() => _state._isListening = true );         
        _state._speech.listen(
              onResult: (val) => _state.render(() {
              lang.text = val.recognizedWords;
            }),
          );
      }
      
       else {         
        _state.render(() => _state._isListening = false);
        _state._speech.stop();       
      }
      _state._isListening = false;
    }
  }

  void translate() {
    String transcode;
    try {
      if (_state._translateto == 'Afrikaans') {
        transcode = 'af';
      } else if (_state._translateto == 'Albanian') {
        transcode = 'sq'; 
      }  else if (_state._translateto == 'Amharic') {
        transcode = 'am'; 
      } else if (_state._translateto == 'Arabic') {
        transcode = 'ar';
      } else if (_state._translateto == 'Armenian') {
        transcode = 'hy';
      } else if (_state._translateto == 'Azerbaijani') {
        transcode = 'az';
      } else if (_state._translateto == 'Basque') {
        transcode = 'eu'; 
      } else if (_state._translateto == 'Belarusian') {
        transcode = 'be';
      } else if (_state._translateto == 'Bengali') {
        transcode = 'bn';
      } else if (_state._translateto == 'Bosnian') {
        transcode = 'bs';     
      } else if (_state._translateto == 'Bulgarian') {
        transcode = 'bg'; 
      } else if (_state._translateto == 'Catalan') {
        transcode = 'ca';
      } else if (_state._translateto == 'Cebuano') {
        transcode = 'ceb';
      } else if (_state._translateto == 'Chinese') {
        transcode = 'zh';
      } else if (_state._translateto == 'Corsican') {
        transcode = 'co';  
      } else if (_state._translateto == 'Croatian') {
        transcode = 'hr';
      } else if (_state._translateto == 'Czech') {
        transcode = 'cs';
      } else if (_state._translateto == 'Danish') {
        transcode = 'da';
      } else if (_state._translateto == 'Ductch') {
        transcode = 'nl';
      }  else if (_state._translateto == 'English') {
        transcode = 'en';
      } else if (_state._translateto == 'Esperanto') {
        transcode = 'eo';
      } else if (_state._translateto == 'Estonian') {
        transcode = 'et';
      } else if (_state._translateto == 'Finnish') {
        transcode = 'fi';
      } else if (_state._translateto == 'French') {
        transcode = 'fr';
      } else if (_state._translateto == 'Frisian') {
        transcode = 'fy';
      } else if (_state._translateto == 'Galician') {
        transcode = 'gl';
      } else if (_state._translateto == 'Georgian') {
        transcode = 'ka';
      } else if (_state._translateto == 'German') {
        transcode = 'de';
      } else if (_state._translateto == 'Greek') {
        transcode = 'el';
      } else if (_state._translateto == 'Gujarati') {
        transcode = 'gu';
      } else if (_state._translateto == 'Haitian Creole') {
        transcode = 'ht';
      } else if (_state._translateto == 'Hausa') {
        transcode = 'ha';
      } else if (_state._translateto == 'Hawaiian') {
        transcode = 'haw';
      } else if (_state._translateto == 'Hebrew') {
        transcode = 'he';
      } else if (_state._translateto == 'Hindi') {
        transcode = 'hi';
      } else if (_state._translateto == 'Hmong') {
        transcode = 'hmn';
      } else if (_state._translateto == 'Hungarian') {
        transcode = 'hu';
      } else if (_state._translateto == 'Icelandic') {
        transcode = 'is';
      } else if (_state._translateto == 'Igbo') {
        transcode = 'ig';
      } else if (_state._translateto == 'Indonesian') {
        transcode = 'id';
      } else if (_state._translateto == 'Irish') {
        transcode = 'ga';
      } else if (_state._translateto == 'Italian') {
        transcode = 'it';
      } else if (_state._translateto == 'Japanese') {
        transcode = 'ja';
      } else if (_state._translateto == 'Kannada') {
        transcode = 'kn';
      } else if (_state._translateto == 'Kazakh') {
        transcode = 'kk';
      } else if (_state._translateto == 'Khmer') {
        transcode = 'km';
      } else if (_state._translateto == 'Kinyarwanda') {
        transcode = 'rw';
      } else if (_state._translateto == 'Korean') {
        transcode = 'ko';
      } else if (_state._translateto == 'Kurdish') {
        transcode = 'ku';
      } else if (_state._translateto == 'Kyrgyz') {
        transcode = 'ky';
      } else if (_state._translateto == 'Lao') {
        transcode = 'lo';
      } else if (_state._translateto == 'Latin') {
        transcode = 'la';
      } else if (_state._translateto == 'Latvian') {
        transcode = 'lv';
      } else if (_state._translateto == 'Lithuanian') {
        transcode = 'lt';
      } else if (_state._translateto == 'Luxembourgish') {
        transcode = 'lb';
      } else if (_state._translateto == 'Macedonian') {
        transcode = 'mk';
      } else if (_state._translateto == 'Malagasy') {
        transcode = 'mg';
      } else if (_state._translateto == 'Malay') {
        transcode = 'ms';
      } else if (_state._translateto == 'Malayalam') {
        transcode = 'ml';
      } else if (_state._translateto == 'Maltese') {
        transcode = 'mt';
      } else if (_state._translateto == 'Maori') {
        transcode = 'mi';
      } else if (_state._translateto == 'Marathi') {
        transcode = 'mr';
      } else if (_state._translateto == 'Mongolian') {
        transcode = 'mn';
      } else if (_state._translateto == 'Myanmar') {
        transcode = 'my';
      } else if (_state._translateto == 'Nepali') {
        transcode = 'ne';
      } else if (_state._translateto == 'Norwegian') {
        transcode = 'no';
      } else if (_state._translateto == 'Nyanja') {
        transcode = 'ny';
      } else if (_state._translateto == 'Odia') {
        transcode = 'or';
      } else if (_state._translateto == 'Pashto') {
        transcode = 'ps';
      } else if (_state._translateto == 'Persian') {
        transcode = 'fa';
      } else if (_state._translateto == 'Polish') {
        transcode = 'pl';
      } else if (_state._translateto == 'Potuguese') {
        transcode = 'pt';
      } else if (_state._translateto == 'Punjabi') {
        transcode = 'pa';
      } else if (_state._translateto == 'Romanian') {
        transcode = 'ro';
      } else if (_state._translateto == 'Russian') {
        transcode = 'ru';
      } else if (_state._translateto == 'Samoan') {
        transcode = 'sm';
      } else if (_state._translateto == 'Scots Gaelic') {
        transcode = 'gd';
      } else if (_state._translateto == 'Serbian') {
        transcode = 'sr';
      } else if (_state._translateto == 'Sesotho') {
        transcode = 'st';
      } else if (_state._translateto == 'Shona') {
        transcode = 'sn';
      } else if (_state._translateto == 'Sindhi') {
        transcode = 'sd';
      } else if (_state._translateto == 'Sinhala') {
        transcode = 'si';
      } else if (_state._translateto == 'Slovak') {
        transcode = 'sk';
      } else if (_state._translateto == 'Slovenian') {
        transcode = 'sl';
      } else if (_state._translateto == 'Somali') {
        transcode = 'so';
      } else if (_state._translateto == 'Spanish') {
        transcode = 'es';
      } else if (_state._translateto == 'Sundanese') {
        transcode = 'su';
      } else if (_state._translateto == 'Swahili') {
        transcode = 'sw';
      } else if (_state._translateto == 'Swedish') {
        transcode = 'sv';
      } else if (_state._translateto == 'Tagalog') {
        transcode = 'tl';
      } else if (_state._translateto == 'Tajik') {
        transcode = 'tg';
      } else if (_state._translateto == 'Tamil') {
        transcode = 'ta';
      } else if (_state._translateto == 'Tatar') {
        transcode = 'tt';
      } else if (_state._translateto == 'Telugu') {
        transcode = 'te';
      } else if (_state._translateto == 'Thai') {
        transcode = 'th';
      } else if (_state._translateto == 'Turkish') {
        transcode = 'tr';
      } else if (_state._translateto == 'Turkmen') {
        transcode = 'tk';
      } else if (_state._translateto == 'Ukrainian') {
        transcode = 'uk';
      } else if (_state._translateto == 'Urdu') {
        transcode = 'ur';
      } else if (_state._translateto == 'Uyghur') {
        transcode = 'ug';
      } else if (_state._translateto == 'Uzbek') {
        transcode = 'uz';
      } else if (_state._translateto == 'Vietnamese') {
        transcode = 'vi';
      } else if (_state._translateto == 'Welsh') {
        transcode = 'cy';
      } else if (_state._translateto == 'Xhosa') {
        transcode = 'xh';
      } else if (_state._translateto == 'Yiddish') {
        transcode = 'yi';
      } else if (_state._translateto == 'Yoruba') {
        transcode = 'yo';
      } else if (_state._translateto == 'Zulu') {
        transcode = 'zu';
      } else {
        transcode = null;
      }
      if (transcode==null) {
        MyDialog.info(
        context: _state.context,
        title: 'Translation Error',
        content: 'Language not selected'
      );
      } else {
        if (lang.text=="") {
        MyDialog.info(
        context: _state.context,
        title: 'Translation Error',
        content: 'No text for translation'
        );
        }else {
      _state.translator
          .translate(lang.text, to: transcode)
          .then((output) {
        _state.render(() {          
          _state.out = output;
        });
      });
        }
      }
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: 'Translation Error',
        content: e.message ?? e.toString(),
      );
    }
  }

  Future<void> readText() async {
    try {
    sentence = '';
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(_state.image);
    TextRecognizer recognizedText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizedText.processImage(ourImage);

    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {         
          sentence = '$sentence ${word.text}';
        }
      }
    }
    _state.render(() {
      _state._initialText = sentence;
      lang = TextEditingController(text: sentence);
    });
    } catch (e) {
      MyDialog.info(
        context: _state.context,
        title: ' Image Error',
        content: e.message ?? e.toString(),
      );
    }
  }

  void save() async {
    if (lang.text == '' || _state.out == null){
      MyDialog.info(
        context: _state.context,
        title: 'Saving Error',
        content: "Either original text is empty or no translation done",
      );
      return;
    }

    try {
      if (_state.image == null) {
      File nonimage = await getImageFileFromAssets('images/Nonimage.jpg');    
      _state.image = nonimage;
      MyDialog.circularProgressStart(_state.context);
      // 1. upload pic to Storage
      Map<String, String> photoInfo = await FirebaseController.uploadStorage(
          image: _state.image,
          uid: _state.user.uid,
        //  sharedWith: sharedWith,
          listener: (double progressPercentage) {
            _state.render(() => uploadProgressMessage =
                'Uploading: ${progressPercentage.toStringAsFixed(1)} %');
          });
     
     // 3. save translation doc to Firestore
     print(_state._translationTitle);         
      var p = MyTranslation(
         title: _state._translationTitle, 
         orgtext: lang.text, 
         transtext: _state.out.toString(),
        photoPath: photoInfo['path'],
        photoURL: photoInfo['url'],
        createdBy: _state.user.email,
      //  sharedWith: sharedWith,
        createdOn: DateTime.now(),        
      );
    
      p.docId = await FirebaseController.addTranslation(p);
     
      _state.translations.insert(0, p);
   
      MyDialog.circularProgressEnd(_state.context);
      Navigator.pop(_state.context);
      } else {
        MyDialog.circularProgressStart(_state.context);
      // 1. upload pic to Storage
      Map<String, String> photoInfo = await FirebaseController.uploadStorage(
          image: _state.image,
          uid: _state.user.uid,
        //  sharedWith: sharedWith,
          listener: (double progressPercentage) {
            _state.render(() => uploadProgressMessage =
                'Uploading: ${progressPercentage.toStringAsFixed(1)} %');
          });
     // print('Up here');
     // 3. save translation doc to Firestore
    // print(_state._translationTitle);         
      var p = MyTranslation(
        title: _state._translationTitle,         
        //title: 'English-Nepali',
        orgtext: lang.text,        
       // orgtext: "Hello",
        transtext: _state.out.toString(),
       // transtext: "Hallo",
        photoPath: photoInfo['path'],
        photoURL: photoInfo['url'],
        createdBy: _state.user.email,
      //  sharedWith: sharedWith,
        createdOn: DateTime.now(),        
      );
    //  print('In between');
      p.docId = await FirebaseController.addTranslation(p);
      
      _state.translations.insert(0, p);
    //  print("down here");
      MyDialog.circularProgressEnd(_state.context);
      Navigator.pop(_state.context);
      }
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

  // String validatorTitle(String value) {
  //   if (value == null || value.trim().length < 2) {
  //     return 'min 2 chars';
  //   } else {
  //     return null;
  //   }
  // }

  // void onSavedTitle(String value) {
  //   this.title = value;
  // }

  // String validatorText(String value) {
  //   if (value == null || value.trim().length < 3) {
  //     return 'min 3 chars';
  //   } else {
  //     return null;
  //   }
  // }

  // void onSavedText(String value) {
  //   this.text = value;
  // }

  // String validatorSharedWith(String value) {
  //   if (value == null || value.trim().length == 0) return null;
  //   List<String> emailList = value.split(',').map((e) => e.trim()).toList();
  //   for (String email in emailList) {
  //     if (email.contains('@') && email.contains('.'))
  //       continue;
  //     else
  //       return 'Comma(,) separated email list';
  //   }
  //   return null;
  // }

  // void onSavedSharedWith(String value) {
  //   if (value.trim().length != 0) {
  //     this.sharedWith = value.split(',').map((e) => e.trim()).toList();
  //   }
  // }
}

Future<File> getImageFileFromAssets(String path) async {
  final byteData = await rootBundle.load('assets/$path');
  final file = File('${(await getTemporaryDirectory()).path}/$path');
  await file.create(recursive: true);
  await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes,byteData.lengthInBytes));
  return file;
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
