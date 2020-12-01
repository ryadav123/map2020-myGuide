class MyTranslation {
  // field name for Firestore documents
  static const COLLECTION = 'translations';
  static const IMAGE_FOLDER = 'translationPictures'; // For storing translations pictures if any
  static const PROFILE_FOLDER = 'profilePictures'; // For storing user profile pictures
  static const TITLE = 'title';
  static const TEXT = 'orgtext';
  static const TRANS_TEXT = 'transtext';
  static const CREATED_BY = 'createdBy';
  static const PHOTO_URL = 'photoURL';
  static const PHOTO_PATH = 'photoPath';
  static const CREATED_ON = 'createdOn';
  static const SHARED_WITH = 'sharedWith'; 

  String docId;  //Firestore doc id
  String createdBy;
  String title;
  String orgtext;
  String transtext;
  String photoPath; //Firebase Storage; image file name
  String photoURL;  // Firebase Storage; image URL for internet access
  DateTime createdOn; // created or revised time
  List<dynamic> sharedWith; // list of emails
  
  MyTranslation({
    this.docId,
    this.createdBy,
    this.title,
    this.orgtext,
    this.transtext,
    this.photoPath,
    this.photoURL,
    this.createdOn,
    this.sharedWith,
  
  }) {
    this.sharedWith ??= [];
   // this.imageLabels ??=[];
  }

  // convert Dart object to Firestore document
  Map<String, dynamic> serialize() {
    return <String,dynamic> {
      TITLE: title,
      CREATED_BY: createdBy,
      TEXT: orgtext,
      TRANS_TEXT: transtext,
      PHOTO_PATH: photoPath,
      PHOTO_URL: photoURL,
      CREATED_ON: createdOn,
      SHARED_WITH: sharedWith,    
    };
  }

  // convert Firestore doc to Dart object
  static MyTranslation deserialize(Map<String, dynamic> data,String docId){
    return MyTranslation(
      docId: docId,
      createdBy: data[MyTranslation.CREATED_BY],
      title: data[MyTranslation.TITLE],
      orgtext: data[MyTranslation.TEXT],
      transtext: data[MyTranslation.TRANS_TEXT],
      photoPath: data[MyTranslation.PHOTO_PATH],
      photoURL: data[MyTranslation.PHOTO_URL],
      sharedWith: data[MyTranslation.SHARED_WITH],    
      createdOn: data[MyTranslation.CREATED_ON] != null ?
        DateTime.fromMillisecondsSinceEpoch(data[MyTranslation.CREATED_ON].millisecondsSinceEpoch) : null,
    );
  }

  @override
  String toString() {
    return '$docId $createdBy $title $orgtext \n $photoURL';
  }
}