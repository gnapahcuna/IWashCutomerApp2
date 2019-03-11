import 'package:cleanmate_customer_app/colorCode/HexColor.dart';
import 'package:cleanmate_customer_app/order_infor/profile_setting_edit.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:cleanmate_customer_app/Server/server.dart';
import 'package:cleanmate_customer_app/data/Profile.dart' as _profile;
class ProfileSetting extends StatefulWidget {
  int CustomerID;
  String AccountName;
  ProfileSetting({
    Key key,
    @required this.CustomerID,
    @required this.AccountName,
  }) : super(key: key);
  @override
  _ProfileSettingState createState() => new _ProfileSettingState();
}
class _ProfileSettingState extends State<ProfileSetting> {
  Color cl_bar = HexColor("#18b4ed");
  Color cl_back = HexColor("#e9eef4");
  Color cl_card = HexColor("#ffffff");
  Color cl_text_pro_th = HexColor("#1d313a");
  Color cl_text_pro_en = HexColor("#667787");
  Color cl_cart = HexColor("#e64d3f");
  Color cl_line_ver = HexColor("#677787");
  Color cl_favorite = HexColor("#e44b3b");

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _barData(),
        ],
      ),
    );
  }

  Widget _barData() {
    var size = MediaQuery
        .of(context)
        .size;
    final double itemHeight = (size.height / 3.5);
    final double itemWidth = size.width / 2;
    final double qrSize = itemWidth / itemHeight;
    return FutureBuilder<List<_profile.Profile>>(
      future: fetchProfile(widget.CustomerID),
      builder: (context, snapshot) {
        List<_profile.Profile> profile = snapshot.data;
        String strPass = "";
        if (!snapshot.hasData)
          // Shows progress indicator until the data is load
          return new MaterialApp(
              debugShowCheckedModeBanner: false,
              home: new Scaffold(
                //backgroundColor: cl_back,
                body: new Center(
                  child: new CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),),
                ),
              )
          );
        for (int i = 0; i < profile[0].Password.length; i++) {
          strPass += "*";
        }

        return Container(
          //margin: EdgeInsets.only(bottom: 18.0),
          margin: EdgeInsets.only(left: 6.0, right: 6.0),
          //height: size.height / 3.5,
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[300], width: 1.0),
                bottom: BorderSide(color: Colors.grey[300], width: 1.0),
                left: BorderSide(color: Colors.grey[300], width: 1.5),
                right: BorderSide(color: Colors.grey[300], width: 1.5),
              )
          ),
          child: Stack(
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          new Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text('ชื่อ ',
                                style: TextStyle(color: cl_text_pro_en,
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins')),),
                          new Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text(profile[0].FirstName,
                                style: TextStyle(color: cl_text_pro_th,
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins')),),
                          new Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text('นามสกุล ',
                                style: TextStyle(color: cl_text_pro_en,
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins')),),
                          new Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text(profile[0].LastName,
                                style: TextStyle(color: cl_text_pro_th,
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins')),),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          new Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text('ชื่อเล่น ',
                                style: TextStyle(color: cl_text_pro_en,
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins')),),
                          new Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text(profile[0].NickName == null||profile[0].NickName.isEmpty
                                ? 'ไม่ได้กำหนด'
                                : profile[0].NickName,
                                style: TextStyle(
                                    color: profile[0].NickName == null||profile[0].NickName.isEmpty ? Colors
                                        .deepOrange : cl_text_pro_th,
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins')),),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          new Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text('อีเมลล์ ',
                                style: TextStyle(color: cl_text_pro_en,
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins')),),
                          new Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text(profile[0].Email == null||profile[0].Email.isEmpty
                                ? 'ไม่ได้กำหนด'
                                : profile[0].Email,
                                style: TextStyle(
                                    color: profile[0].Email == null||profile[0].Email.isEmpty ? Colors
                                        .deepOrange : cl_text_pro_th,
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins')),),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          new Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text('เบอร์มือถือ ',
                                style: TextStyle(color: cl_text_pro_en,
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins')),),
                          new Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text('(+66)*****' +
                                profile[0].TelephoneNo.substring(
                                    6, profile[0].TelephoneNo.length),
                                style: TextStyle(color: cl_text_pro_th,
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins')),),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          new Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text('รหัสผ่าน',
                                style: TextStyle(color: cl_text_pro_en,
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins')),),
                          new Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text(strPass,
                                style: TextStyle(color: cl_text_pro_th,
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins')),),
                        ],
                      ),
                    ],
                  )
              ),
              new Positioned(
                child: new GestureDetector(
                    onTap: () {
                      //
                      Navigator.of(context)
                          .push(
                          new MaterialPageRoute(builder: (context) =>
                              ProfileSettingEdit(CustomerID: widget.CustomerID,
                                FisrtName: profile[0].FirstName,LastName: profile[0].LastName,NickName: profile[0].NickName,TelephoneNo: profile[0].TelephoneNo,Email: profile[0].Email,Password: profile[0].Password,)));
                    }, child: new Padding(
                  padding: EdgeInsets.all(14.0),
                  child: new Align(
                    alignment: FractionalOffset.bottomRight,
                    child: Icon(
                      FontAwesomeIcons.edit, color: cl_text_pro_en,
                      size: 22,),
                  ),)
                ),
              ),
            ],
          ),
        );
        /*if (snapshot.connectionState == ConnectionState.done) {
          for (int i = 0; i < profile[0].Password.length; i++) {
            strPass += "*";
          }
          if(profile.length>0){

          }else{
            return Container(
              child: Center(
                child: Text('การเชื่อมต่อกับ Server ผิดพลาด',style: TextStyle(color: cl_text_pro_en,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins')),
              ),
            );
          }
        }*/
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios, color: cl_text_pro_th),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: new Text(
          widget.AccountName, style: new TextStyle(color: cl_text_pro_th),),
      ),
      body: _buildContent(),
    );
  }
}
Future<List<_profile.Profile>> fetchProfile(CustomerID) async {
  try {
    final paramDic = {
      "CustomerID": CustomerID.toString(),
    };
    //print('cust : '+CustomerID.toString());
    http.Response response =
    await http.post(
        Server().IPAddress + '/data/get/Profile.php', body: paramDic);
    //print(response.body.toString());
    if (response.statusCode == 200) {
      List responseJson = json.decode(response.body);
      return responseJson.map((m) => new _profile.Profile.fromJson(m))
          .toList();
    } else {
      print('Something went wrong. \nResponse Code : ${response.statusCode}');
    }
  } catch (exception) {
    print(exception.toString());
  }
}