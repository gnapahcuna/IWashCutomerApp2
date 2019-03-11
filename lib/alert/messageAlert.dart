import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cleanmate_customer_app/colorCode/HexColor.dart';
class Message {
  final String title;
  final String desc;
  final BuildContext context;
  final BuildContext mContext;
  final int type;

  Message( this.title, this.desc, this.context, this.mContext, this.type ){
    _showDialog();
  }


  CupertinoAlertDialog _createCupertinoAlertDialog() =>
      new CupertinoAlertDialog(
        title: new Text(title, style: TextStyle(fontFamily: 'Poppins'),),
        content: new Text(desc,
            style: TextStyle(fontFamily: 'Poppins')),
        actions: type==1?<Widget>[

          new CupertinoButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: new Text('ยกเลิก', style: TextStyle(color: HexColor("#667787"),
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins'))),
          new CupertinoButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(mContext).pop();
              },
              child: new Text('ตกลง', style: TextStyle(color: Colors.red,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins'))),
        ]:<Widget>[
          new CupertinoButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: new Text('ตกลง', style: TextStyle(color: Colors.deepOrange,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins'))),
        ],
      );

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return _createCupertinoAlertDialog();
      },
    );
  }
}