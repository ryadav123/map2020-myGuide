import 'package:flutter/material.dart';
import 'package:myGuide/model/translation.dart';
import 'package:myGuide/screens/view/myimageview.dart';

class AddScreen extends StatefulWidget {
  static const routeName = 'home/addScreen';

  @override
  State<StatefulWidget> createState() {
    return _AddState();
  }
}

class _AddState extends State<AddScreen> {
  _Controller con;
  List<Translation> photoMemos;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
  //  photoMemos ??= args['sharedPhotoMemoList'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Add a Translation'),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RaisedButton.icon(            
            color: Colors.blue,
            onPressed: () {},
            icon: Icon(Icons.text_fields),
            label: Text("Add from Text"),
            ),
          SizedBox(width: 5),
          RaisedButton.icon(
            color: Colors.blue,
            onPressed: () {},
            icon: Icon(Icons.image),
            label: Text("Add from Image"),
            )
        ],
      ),
    );
  }
}

class _Controller {
  _AddState _state;
  _Controller(this._state);
}
