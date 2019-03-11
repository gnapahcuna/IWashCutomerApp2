import 'package:cleanmate_customer_app/colorCode/HexColor.dart';
import 'package:cleanmate_customer_app/order_infor/profile_setting_edit.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:cleanmate_customer_app/Server/server.dart';
import 'package:cleanmate_customer_app/data/Profile.dart' as _profile;
import 'package:cleanmate_customer_app/data/BranchContact.dart' as _branch;
import 'package:intl/intl.dart';
import 'package:location/location.dart';
class MyBranchContact extends StatefulWidget {
  int BranchID;
  //String BranchName;
  MyBranchContact({
    Key key,
    @required this.BranchID,
   // @required this.BranchName,
  }) : super(key: key);
  @override
  _BranchContactState createState() => new _BranchContactState();
}
class _BranchContactState extends State<MyBranchContact> {
  Color cl_bar = HexColor("#18b4ed");
  Color cl_back = HexColor("#e9eef4");
  Color cl_card = HexColor("#ffffff");
  Color cl_text_pro_th = HexColor("#1d313a");
  Color cl_text_pro_en = HexColor("#667787");
  Color cl_cart = HexColor("#e64d3f");
  Color cl_line_ver = HexColor("#677787");
  Color cl_favorite = HexColor("#e44b3b");

  var location = new Location();
  Map<String, double> userLocation;
  String Latitude,Longitude;

  @override
  void initState() {
    super.initState();
    _getLocation().then((value) {
      setState(() {
        userLocation = value;
        Latitude = userLocation["latitude"].toString();
        Longitude = userLocation["longitude"].toString();
      });
    });
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
          _barBranch(),
          _barAddress(),
          _barLocation(),
        ],
      ),
    );
  }

  Widget _barBranch() {
    var size = MediaQuery
        .of(context)
        .size;
    final double itemHeight = (size.height / 3.5);
    final double itemWidth = size.width / 2;
    return FutureBuilder<List<_branch.BranchContact>>(
      future: fetchBranch(widget.BranchID,Latitude,Longitude),
      builder: (context, snapshot) {
        List<_branch.BranchContact> branch = snapshot.data;
        String strPass = "";
        return snapshot.connectionState == ConnectionState.done
            ? snapshot.hasData
            ? Container(
          //margin: EdgeInsets.only(bottom: 18.0),
          margin: EdgeInsets.only(left: 6.0, right: 6.0,bottom: 4.0),
          //height: size.height / 2,
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
                            child: Text('ชื่อสาขา : ',
                                style: TextStyle(color: cl_text_pro_en,
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins')),),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          new Expanded(child: Padding(
                            padding: EdgeInsets.only(top:6.0,left: 16.0,bottom: 6.0),
                            child: Text(branch[0].BranchNameTH,
                                style: TextStyle(
                                    color: cl_text_pro_th,
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins')),),)
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          new Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text('รหัสสาขา : ',
                                style: TextStyle(color: cl_text_pro_en,
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins')),),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          new Expanded(child: Padding(
                            padding: EdgeInsets.only(top:6.0,left: 16.0,bottom: 6.0),
                            child: Text(branch[0].BranchCode,
                                style: TextStyle(
                                    color: cl_text_pro_th,
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins')),),)
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          new Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text('ประเภทสาขา : ',
                                style: TextStyle(color: cl_text_pro_en,
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins')),),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          new Expanded(child: Padding(
                            padding: EdgeInsets.only(top:6.0,left: 16.0,bottom: 6.0),
                            child: Text(branch[0].BranchGroupName,
                                style: TextStyle(
                                    color: cl_text_pro_th,
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins')),),)
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          new Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text('เจ้าของร้าน : ',
                                style: TextStyle(color: cl_text_pro_en,
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins')),),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          new Expanded(child: Padding(
                            padding: EdgeInsets.only(top:6.0,left: 16.0,bottom: 6.0),
                            child: Text(branch[0].Contact==null?'-':branch[0].Contact,
                                style: TextStyle(
                                    color: cl_text_pro_th,
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins')),),)
                        ],
                      ),
                    ],
                  )
              ),
            ],
          ),
        )
            : InkWell(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text("ERROR OCCURRED, Tap to retry !"),
            ),
            onTap: () => setState(() {}))
            : Center(child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),),);
      },
    );
  }

  Widget _barAddress() {
    var size = MediaQuery
        .of(context)
        .size;
    final double itemHeight = (size.height / 3.5);
    final double itemWidth = size.width / 2;
    final double qrSize = itemWidth / itemHeight;
    return FutureBuilder<List<_branch.BranchContact>>(
      future: fetchBranch(widget.BranchID,Latitude,Longitude),
      builder: (context, snapshot) {
        List<_branch.BranchContact> branch = snapshot.data;
        String strPass = "";
        return snapshot.connectionState == ConnectionState.done
            ? snapshot.hasData
            ? Container(
          //margin: EdgeInsets.only(bottom: 18.0),
          margin: EdgeInsets.only(left: 6.0, right: 6.0),
          //height: size.height / 2.5,
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
                            child: Text('ที่อยู่ : ',
                                style: TextStyle(color: cl_text_pro_en,
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins')),),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          new Expanded(child: Padding(
                            padding: EdgeInsets.only(top:6.0,left: 16.0,bottom: 6.0),
                            child: Text(branch[0].Address==null?'-':branch[0].Address,
                                style: TextStyle(
                                    color: cl_text_pro_th,
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins')),),)
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          new Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text('เขต : ',
                                style: TextStyle(color: cl_text_pro_en,
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins')),),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          new Expanded(child: Padding(
                            padding: EdgeInsets.only(top:6.0,left: 16.0,bottom: 6.0),
                            child: Text(branch[0].CityName==null?'-':branch[0].CityName,
                                style: TextStyle(
                                    color: cl_text_pro_th,
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins')),),)
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          new Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text('เบอร์ติดต่อ : ',
                                style: TextStyle(color: cl_text_pro_en,
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins')),),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          new Expanded(child: Padding(
                            padding: EdgeInsets.only(top:6.0,left: 16.0,bottom: 6.0),
                            child: Text(branch[0].TelephoneNo==null?'-':branch[0].TelephoneNo,
                                style: TextStyle(
                                    color: cl_text_pro_th,
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins')),),)
                        ],
                      ),
                    ],
                  )
              ),
            ],
          ),
        )
            : InkWell(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text("ERROR OCCURRED, Tap to retry !"),
            ),
            onTap: () => setState(() {}))
            : Center();
      },
    );
  }
  Widget _barLocation() {
    final formatter = new NumberFormat("#,###.#");
    var size = MediaQuery
        .of(context)
        .size;
    final double itemHeight = (size.height / 3.5);
    final double itemWidth = size.width / 2;
    final double qrSize = itemWidth / itemHeight;
    return FutureBuilder<List<_branch.BranchContact>>(
      future: fetchBranch(widget.BranchID,Latitude,Longitude),
      builder: (context, snapshot) {
        List<_branch.BranchContact> branch = snapshot.data;
        String strPass = "";
        return snapshot.connectionState == ConnectionState.done
            ? snapshot.hasData
            ? Container(
          //margin: EdgeInsets.only(bottom: 18.0),
          margin: EdgeInsets.only(left: 6.0, right: 6.0,top: 4.0,bottom: 4.0),
          //height: size.height / 2.5,
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
                            child: Text('อยู่ห่างจากตำแหน่งของคุณ : ',
                                style: TextStyle(color: cl_text_pro_en,
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins')),),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          new Expanded(child: Padding(
                            padding: EdgeInsets.only(top:6.0,left: 16.0,bottom: 6.0),
                            child: Text(branch[0].Distance==null?'-':formatter.format(branch[0].Distance) +
                                ' กม.',
                                style: TextStyle(
                                    color: cl_text_pro_th,
                                    fontSize: 16.0,
                                    fontFamily: 'Poppins')),),)
                        ],
                      ),

                    ],
                  )
              ),
            ],
          ),
        )
            : InkWell(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text("ERROR OCCURRED, Tap to retry !"),
            ),
            onTap: () => setState(() {}))
            : Center();
      },
    );
  }
  Future<Map<String, double>> _getLocation() async {
    var currentLocation = <String, double>{};
    try {
      currentLocation = await location.getLocation();
    } catch (e) {
      print("error : " + e.toString());
      currentLocation = null;
    }
    return currentLocation;
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
         'สาขาของคุณ',
          style: new TextStyle(color: cl_text_pro_th),),
      ),
      body: _buildContent(),
    );
  }
}
//fetch branch
Future<List<_branch.BranchContact>> fetchBranch(BranchID,Latitude,Longitude) async {
  try {
    final paramDic = {
      "BranchID": BranchID.toString(),
      "Lat": Latitude.toString(),
      "Lon": Longitude.toString(),
    };
    //print("branchID : "+BranchID.toString());
    http.Response response =
    await http.post(Server().IPAddress + '/data/get/Branch.php',body: paramDic);
    //print('resp : '+response.body.toString());
    if (response.statusCode == 200) {
      List responseJson = json.decode(response.body);
      return responseJson.map((m) => new _branch.BranchContact.fromJson(m)).toList();
    } else {
      print('Something went wrong. \nResponse Code : ${response.statusCode}');
    }
  } catch (exception) {
    print(exception.toString());
  }
}