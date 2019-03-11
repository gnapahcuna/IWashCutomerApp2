import 'package:cleanmate_customer_app/HomeScreen.dart';
import 'package:cleanmate_customer_app/colorCode/HexColor.dart';
import 'package:cleanmate_customer_app/verify/progress_hud.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cleanmate_customer_app/Server/server.dart';
import 'package:cleanmate_customer_app/data/Branch.dart' as _branch;
import 'package:intl/intl.dart';
import 'package:cleanmate_customer_app/data/Users.dart' as _users;
import 'package:shared_preferences/shared_preferences.dart';

//fetch Branch sort
Future<List<_branch.Branch>> fethBranchSort(lat, lon) async {
  final paramDic = {
    "Lat": lat,
    "Lon": lon,
  };
  try {
    http.Response response;
    List responseJson;
    response =
    await http.post(
      Server().IPAddress + '/data/get/branch/distance_branch_sort.php',
      body: paramDic,);
    responseJson = json.decode(response.body);
    return responseJson.map((m) => new _branch.Branch.fromJson(m)).toList();
  } catch (exception) {
    print(exception.toString());
  }
}
//fetch Branch
Future<List<_branch.Branch>> fethBranch(lat, lon,_branchDetails) async {
  final paramDic = {
    "Lat": lat,
    "Lon": lon,
  };
  try {
    http.Response response;
    List responseJson;
    response =
    await http.post(
      Server().IPAddress + '/data/get/branch/distance_branch.php',
      body: paramDic,);
    responseJson = json.decode(response.body);
    for (Map user in responseJson) {
      _branchDetails.add(_branch.Branch.fromJson(user));
    }
    return responseJson.map((m) => new _branch.Branch.fromJson(m)).toList();
  } catch (exception) {
    print(exception.toString());
  }
}

class SelectBranch extends StatefulWidget{
  String CustomerID;
  String IsPage;
  SelectBranch({
    Key key,
    @required this.CustomerID,
    @required this.IsPage,
  }) : super(key: key);
  @override
  _SelectBranchState createState() => new _SelectBranchState(this.CustomerID,this.IsPage);
}
class _SelectBranchState extends State<SelectBranch> {
  String CustomerID,IsPage;
  _SelectBranchState(this.CustomerID,this.IsPage);
  List<Entry> data = [];
  var location = new Location();
  Map<String, double> userLocation;
  String Latitude,Longitude;

  ProgressHUD _progressHUD;

  Color cl_back = HexColor("#e9eef4");
  Color cl_card = HexColor("#ffffff");
  Color cl_text_pro_th = HexColor("#1d313a");
  Color cl_text_pro_en = HexColor("#667787");
  Color cl_cart = HexColor("#18b4ed");
  Color cl_bar = HexColor("#18b4ed");
  Color cl_line_ver = HexColor("#677787");

  @override
  void dispose() {
    super.dispose();
  }

  List<_branch.Branch> _searchResult = [];
  List<_branch.Branch> _branchDetails = [];
  List<_branch.Branch> _branchSort = [];
  TextEditingController controller = new TextEditingController();




  @override
  void initState() {
    super.initState();
    _getLocation().then((value) {
      setState(() {
        userLocation = value;

        Latitude=userLocation["latitude"].toString();
        Longitude=userLocation["longitude"].toString();



      });
      List<Branch> branch1= <Branch>[Branch("A1", "B1")];
      List<Branch> branch2= <Branch>[Branch("A2", "B2")];
      data.add(Entry(
        'สาขาที่ใกล้คุณ',
          branch1,
      ),);
      data.add(Entry(
        'สาขาอื่นๆ',
        branch2,
      ),);
      print('data : ' + data.length.toString());
    });

  }
  Future<List<_users.Users>> callSelecrBranch(branchID,branchName,customerID) async {
    final paramDic = {
      "BranchID": branchID.toString(),
      "BranchName": branchName,
      "CustomerID": customerID.toString(),

    };
    final response = await http.post(
      Server().IPAddress + "/put/customer/IsBranchCust.php", // change with your API
      body: paramDic,
    );
    List responseJson = json.decode(response.body);
    return responseJson.map((m) => new _users.Users.fromJson(m)).toList();
  }

  SharedPreferences prefs;
  _putUserAcct(CustomerID,BranchID,BranchGroupID,BranchCode,Firstname,Lastname,phone,BranchNameTH,BranchNameEN,TelephoneBranch,mContext) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setInt('CustomerID', CustomerID);
    await prefs.setInt('BranchID', BranchID);
    await prefs.setInt('BranchGroupID', BranchGroupID);
    await prefs.setString('BranchNameTH', BranchNameTH);
    await prefs.setString('BranchNameEN', BranchNameEN);
    await prefs.setString('BranchCode', BranchCode);
    await prefs.setString('Firstname', Firstname);
    await prefs.setString('Lastname', Lastname);
    await prefs.setString('Telephone', phone);
    await prefs.setString('TelephoneBranch', TelephoneBranch);

  }
  _popNav(){
    setState(() {
      Navigator.of(context).pushNamedAndRemoveUntil('/HomeScreen', (Route<dynamic> route) => false);
    });
  }
  Future<bool> editAction() async {
    await new Future.delayed(const Duration(seconds: 2));
    return true;
  }

  void _sendCallAPI(branchID,branchName,customerID,mContext) {

    final data = callSelecrBranch(branchID,branchName,customerID);
    data.then((s) async{
      setState(() {
        List<_users.Users> users = s;
        print('cust : '+users[0].CustomerID.toString());
        if(users.length>0){
          _putUserAcct(users[0].CustomerID,users[0].BranchID,users[0].BranchGroupID,users[0].BranchCode
              ,users[0].FirstName,users[0].LastName,users[0].TelephoneNo,users[0].BranchNameTH,
              users[0].BranchNameEN,users[0].TelephoneNoBranch,mContext);
          //print('ss : '+users[0].CustomerID.toString()+", "+users[0].TelephoneNo);
          //Navigator.of(context).pushReplacementNamed('/HomeScreen');
        }
      });
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),),);
          });
      await editAction();
      _popNav();
    });
  }

  CupertinoAlertDialog _createCupertinoAlertDialog(mContext,branchName,branchID) =>
      new CupertinoAlertDialog(
          title: new Text("ยืนยัน?", style: TextStyle(fontFamily: 'Poppins'),),
          content: new Text("เลือกสาขา "+branchName,
              style: TextStyle(fontFamily: 'Poppins')),
          actions: <Widget>[

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
                  print('สาขา '+branchID.toString()+", "+branchName+", "+CustomerID);
                  _sendCallAPI(branchID,branchName,CustomerID,mContext);
                },
                child: new Text('ยืนยัน', style: TextStyle(color: Colors.deepOrange,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins'))),
          ]
      );
  void _showDialogCreateOrder(mContext,branchName,branchID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _createCupertinoAlertDialog(mContext,branchName,branchID);
      },
    );
  }

  Widget _buildUsersList() {
    final formatter = new NumberFormat("#,###.#");
    _branchDetails.clear();
    return new ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return new ExpansionTile(
          leading: Icon(FontAwesomeIcons.storeAlt,color: cl_text_pro_en,),
          initiallyExpanded: true,
          key: PageStorageKey<Entry>(data[index]),
          title: new Text(data[index].title,style: TextStyle(fontFamily: 'Poppins',fontSize: 18.0,fontWeight: FontWeight.w600,color: cl_text_pro_th),),
          children: <Widget>[
            index == 0 ?
            new FutureBuilder<List<_branch.Branch>>(
              future: fethBranchSort(Latitude, Longitude),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return new Center(
                    child: new Text(
                      "Loading...",
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: cl_text_pro_en),),
                  );
                List<_branch.Branch> branch = snapshot.data;
                List<Widget> reasonList = [];
                branch.forEach((element) {
                  reasonList.add(new GestureDetector(
                    onTap: () {
                        _showDialogCreateOrder(context, element.BranchNameTH,element.BranchID);
                    }, child: Padding(
                    padding: EdgeInsets.only(
                        left: 5.0, right: 5.0, top: 1.0, bottom: 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(
                                color: Colors.white30,
                                width: 1.0
                            ),
                            top: BorderSide(
                                color: Colors.white30,
                                width: 1.0
                            ),
                          )
                      ),
                      height: 100.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(right: 8.0),
                            decoration: new BoxDecoration(
                                border: new Border(
                                    right: new BorderSide(
                                        width: 1.0,
                                        color: cl_back))),
                            child: new SizedBox(
                              height: 60.0,
                              width: 60.0,
                              child: Center(
                                child: Image.network(
                                    element.ImageUrl,
                                    fit: BoxFit.cover),
                              ),
                            ),

                          ),
                          Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: 25.0, left: 15.0, right: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            element.BranchNameTH,
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: cl_text_pro_th,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Poppins',),),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              "${ element.BranchCode
                                                  .trim()}",
                                              style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  color: cl_text_pro_en),),

                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5.0,),
                                    Row(
                                      children: <Widget>[
                                        Icon(Icons.location_on,
                                          color: cl_text_pro_en,),
                                        Text('ห่างจากคุณ ' + formatter.format(
                                            element.Distance) + ' km.',
                                          style: TextStyle(
                                            color: cl_text_pro_en,
                                            fontFamily: 'Poppins',),)
                                      ],
                                    ),
                                  ],
                                ),
                              )
                          )
                        ],
                      ),
                    ),
                  ),),);
                });
                return new Column(children: reasonList);
              },
            ) :
            new FutureBuilder<List<_branch.Branch>>(
              future: fethBranch(Latitude, Longitude,_branchDetails),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return new Center(
                    child: new Text(
                      "Loading...",
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: cl_text_pro_en),),
                  );
                List<_branch.Branch> branch = snapshot.data;
                List<Widget> reasonList = [];
                branch.forEach((element) {
                  reasonList.add(new GestureDetector(
                      onTap: () {
                        _showDialogCreateOrder(context, element.BranchNameTH,element.BranchID);
                      },
                      child: Padding(
                    padding: EdgeInsets.only(
                        left: 5.0, right: 5.0, top: 1.0, bottom: 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(
                                color: Colors.white30,
                                width: 1.0
                            ),
                            top: BorderSide(
                                color: Colors.white30,
                                width: 1.0
                            ),
                          )
                      ),
                      height: 100.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(right: 8.0),
                            decoration: new BoxDecoration(
                                border: new Border(
                                    right: new BorderSide(
                                        width: 1.0,
                                        color: cl_back))),
                            child: new SizedBox(
                              height: 60.0,
                              width: 60.0,
                              child: Center(
                                child: Image.network(
                                    element.ImageUrl,
                                    fit: BoxFit.cover),
                              ),
                            ),

                          ),
                          Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: 25.0, left: 15.0, right: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            element.BranchNameTH,
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: cl_text_pro_th,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Poppins',),),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                                "${ element.BranchCode
                                                    .trim()}",
                                              style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  color: cl_text_pro_en),),

                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5.0,),
                                    Row(
                                      children: <Widget>[
                                        Icon(Icons.location_on,
                                          color: cl_text_pro_en,),
                                        Text('ห่างจากคุณ ' + formatter.format(
                                            element.Distance) + ' km.',
                                          style: TextStyle(
                                            color: cl_text_pro_en,
                                            fontFamily: 'Poppins',),)
                                      ],
                                    ),
                                  ],
                                ),
                              )
                          )
                        ],
                      ),
                    ),
                  ),),);
                });
                return new Column(children: reasonList);
              },
            )
          ],
        );
      },
    );
  }

  Widget _buildSearchResults() {
    final formatter = new NumberFormat("#,###.#");
    return new ListView.builder(
      itemCount: _searchResult.length,
      itemBuilder: (context, i) {
        return new GestureDetector(
            onTap: () {
          print(_searchResult[i].BranchNameTH);
          _showDialogCreateOrder(context, _searchResult[i].BranchNameTH,_searchResult[i].BranchID);

        },
        child:Padding(
          padding: EdgeInsets.only(
              left: 5.0, right: 5.0, top: 2.0, bottom: 2.0),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                      color: Colors.white30,
                      width: 1.0
                  ),
                  top: BorderSide(
                      color: Colors.white30,
                      width: 1.0
                  ),
                )
            ),
            height: 100.0,
            child: Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(right: 12.0),
                  /*alignment: Alignment.topLeft,
                      height: 100.0,
                      width: 100.0,*/
                  decoration: new BoxDecoration(
                      border: new Border(
                          right: new BorderSide(
                              width: 1.0,
                              color: cl_back))),
                  child: new SizedBox(
                    height: 60.0,
                    width: 60.0,
                    child: Center(
                      child: Image.network(
                          _searchResult[i].ImageUrl,
                          fit: BoxFit.cover),
                    ),
                  ),

                ),
                Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 25.0, left: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(_searchResult[i].BranchNameTH,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: cl_text_pro_th,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Poppins',),),
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                      "${ _searchResult[i].BranchCode}",
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        color: cl_text_pro_en),)
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 5.0,),
                          Row(
                            children: <Widget>[
                              Icon(Icons.location_on, color: cl_text_pro_en,),
                              Text('ห่างจากคุณ ' +
                                  formatter.format(_searchResult[i].Distance) +
                                  ' กม.',
                                style: TextStyle(
                                  color: cl_text_pro_en,
                                  fontFamily: 'Poppins',),)
                            ],
                          ),
                        ],
                      ),
                    )
                )
              ],
            ),
          ),
        ),
        );
      },
    );
  }

  Widget _buildSearchBox() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Card(
        //color: cl_back,
        child: new ListTile(
          leading: new Icon(Icons.search),
          title: new TextField(
            controller: controller,
            decoration: new InputDecoration(
                hintText: 'Search', border: InputBorder.none),
            onChanged: onSearchTextChanged,
          ),
          trailing: new IconButton(
            icon: new Icon(Icons.cancel),
            onPressed: () {
              controller.clear();
              onSearchTextChanged('');
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return IsPage.endsWith("Home")?new Scaffold(
      appBar: new AppBar(
        elevation: 0.5,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios, color: cl_text_pro_th),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        titleSpacing: 0.0,
        title: new Text(
          "เลือกสาขา",
          style: new TextStyle(
              color: cl_text_pro_th,
              fontSize: Theme
                  .of(context)
                  .platform == TargetPlatform.iOS ? 18.0 : 20.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins'
          ),),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          new Container(
              child: _buildSearchBox()),
          new Expanded(
              child: _searchResult.length != 0 || controller.text.isNotEmpty
                  ? _buildSearchResults()
                  : _buildUsersList()),
        ],
      ),
    ):
    new Scaffold(
      appBar: new AppBar(
        elevation: 0.5,
        titleSpacing: 0.0,
        automaticallyImplyLeading: false,
        title: new Text(
          "เลือกสาขา",
          style: new TextStyle(
              color: cl_text_pro_th,
              fontSize: Theme
                  .of(context)
                  .platform == TargetPlatform.iOS ? 18.0 : 20.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins'
          ),),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          new Container(
              child: _buildSearchBox()),
          new Expanded(
              child: _searchResult.length != 0 || controller.text.isNotEmpty
                  ? _buildSearchResults()
                  : _buildUsersList()),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return _buildBody();
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

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    _branchDetails.forEach((userDetail) {
      if (userDetail.BranchCode.contains(text) ||
          userDetail.BranchNameTH.contains(text)) _searchResult.add(userDetail);
    });

    setState(() {});
  }
}

// One entry in the multilevel list displayed by this app.
class Entry {
  Entry(this.title, [this.children = const <Branch>[]]);

  final String title;
  final List<Branch> children;
}
class Branch {
  Branch(this.title, this.desc);

  final String title;
  final String desc;
}




