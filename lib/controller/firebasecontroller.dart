import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:myGuide/model/translation.dart';

class FirebaseController {
  static Future signIn(String email, String password) async {
    AuthResult auth = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return auth.user;
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  static Future<List<MyTranslation>> getTranslations(String email) async {
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection(MyTranslation.COLLECTION)
        .where(MyTranslation.CREATED_BY, isEqualTo: email)
        .orderBy(MyTranslation.CREATED_ON, descending: true)
        .getDocuments();

    var result = <MyTranslation>[];
    if (querySnapshot != null && querySnapshot.documents.length != 0) {
      for (var doc in querySnapshot.documents) {
        result.add(MyTranslation.deserialize(doc.data, doc.documentID));
      }
    }
    return result;
  }

  static Future<List<MyTranslation>> getTranslationsascending(String email) async {
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection(MyTranslation.COLLECTION)
        .where(MyTranslation.CREATED_BY, isEqualTo: email)
        .orderBy(MyTranslation.TITLE, descending: false)
        .getDocuments();

    var result = <MyTranslation>[];
    if (querySnapshot != null && querySnapshot.documents.length != 0) {
      for (var doc in querySnapshot.documents) {
        result.add(MyTranslation.deserialize(doc.data, doc.documentID));
      }
    }
    return result;
  }
  static Future<List<MyTranslation>> getTranslationsdescending(String email) async {
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection(MyTranslation.COLLECTION)
        .where(MyTranslation.CREATED_BY, isEqualTo: email)
        .orderBy(MyTranslation.TITLE, descending: true)
        .getDocuments();

    var result = <MyTranslation>[];
    if (querySnapshot != null && querySnapshot.documents.length != 0) {
      for (var doc in querySnapshot.documents) {
        result.add(MyTranslation.deserialize(doc.data, doc.documentID));
      }
    }
    return result;
  }

  static Future<Map<String, String>> uploadStorage({
    @required File image,
    String filePath,
    @required String uid,
  //  @required List<dynamic> sharedWith,
    @required Function listener,
  }) async {
    filePath ??= '${MyTranslation.IMAGE_FOLDER}/$uid/${DateTime.now()}';

    StorageUploadTask task =
        FirebaseStorage.instance.ref().child(filePath).putFile(image);
    task.events.listen((event) {
      double percentage = (event.snapshot.bytesTransferred.toDouble() /
              event.snapshot.totalByteCount.toDouble()) *
          100;
      listener(percentage);
    });
    var download = await task.onComplete;
    String url = await download.ref.getDownloadURL();

    return {'url': url, 'path': filePath};
  }

  static Future<String> addTranslation(MyTranslation translation) async {
    translation.createdOn = DateTime.now();
    DocumentReference ref = await Firestore.instance
        .collection(MyTranslation.COLLECTION)
        .add(translation.serialize());
    return ref.documentID;
  }

  static Future<void> deleteTranslation(MyTranslation trans) async {
    await Firestore.instance
        .collection(MyTranslation.COLLECTION)
        .document(trans.docId)
        .delete();
    await FirebaseStorage.instance.ref().child(trans.photoPath).delete();
  }

  static Future<List<MyTranslation>> searchInTitle({
    @required String email,
    @required String searchLabel,
  }) async {
    print('Inside controller\n');
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection(MyTranslation.COLLECTION)
        .where(MyTranslation.CREATED_BY, isEqualTo: email)
        .where(MyTranslation.TITLE, isEqualTo: searchLabel)
       // .where(MyTranslation.CREATED_BY, isEqualTo: email)
        //.where(MyTranslation.TITLE, arrayContains: searchLabel.toLowerCase())        
       // .orderBy(MyTranslation.CREATED_ON, descending: true)
        .getDocuments();
   // print(querySnapshot.documents.length);
    var result = <MyTranslation>[];
    if (querySnapshot != null && querySnapshot.documents.length != 0) {
      for (var doc in querySnapshot.documents) {
        result.add(MyTranslation.deserialize(doc.data, doc.documentID));
      }
    }
    
    // print('searchLabel = $searchLabel\n');
    // print(result.length);
    // print(result);
    return result;
  }

  static Future<List<MyTranslation>> searchInText({
    @required String email,
    @required String searchLabel,
  }) async {
    print('Inside controller\n');
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection(MyTranslation.COLLECTION)
        .where(MyTranslation.CREATED_BY, isEqualTo: email)
        .where(MyTranslation.TEXT, isEqualTo: searchLabel)
       // .where(MyTranslation.CREATED_BY, isEqualTo: email)
        //.where(MyTranslation.TITLE, arrayContains: searchLabel.toLowerCase())        
       // .orderBy(MyTranslation.CREATED_ON, descending: true)
        .getDocuments();
  //  print(querySnapshot.documents.length);
    var result = <MyTranslation>[];
    if (querySnapshot != null && querySnapshot.documents.length != 0) {
      for (var doc in querySnapshot.documents) {
        result.add(MyTranslation.deserialize(doc.data, doc.documentID));
      }
    }
    
    // print('searchLabel = $searchLabel\n');
    // print(result.length);
    // print(result);
    return result;
  }
 
  static Future<void> signUp(String email, String password) async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> updateProfile({
    @required File image, // null no update
    @required String displayName,
    @required FirebaseUser user,
    @required Function progressListener,
  }) async {
    UserUpdateInfo updateInfo = UserUpdateInfo();
    updateInfo.displayName = displayName;
    if (image != null) {
      //1. upload the picture
      String filePath = '${MyTranslation.PROFILE_FOLDER}/${user.uid}/${user.uid}';
      StorageUploadTask uploadTask =
          FirebaseStorage.instance.ref().child(filePath).putFile(image);
    uploadTask.events.listen((event) {
      double percentage = (event.snapshot.bytesTransferred.toDouble()/
                  event.snapshot.totalByteCount.toDouble()) *100;
      progressListener(percentage);
    });
    var download = await uploadTask.onComplete;
    String url = await download.ref.getDownloadURL();

    updateInfo.photoUrl = url;
    }

    await user.updateProfile(updateInfo);
  }
}
