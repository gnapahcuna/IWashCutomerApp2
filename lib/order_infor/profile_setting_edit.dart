import 'package:cleanmate_customer_app/colorCode/HexColor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:cleanmate_customer_app/Server/server.dart';
import 'package:cleanmate_customer_app/data/Profile.dart' as _profile;
import 'package:cleanmate_customer_app/style/theme.dart' as Theme;

class ProfileSettingEdit extends StatefulWidget {
  int CustomerID;
  String FisrtName,LastName,NickName,TelephoneNo,Email,Password;
  ProfileSettingEdit({
    Key key,
    @required this.CustomerID,
    @required this.FisrtName,
    @required this.LastName,
    @required this.NickName,
    @required this.TelephoneNo,
    @required this.Email,
    @required this.Password,
  }) : super(key: key);
  @override
  _ProfileSettingEditState createState() => new _ProfileSettingEditState();
}
class _ProfileSettingEditState extends State<ProfileSettingEdit> {
  Color cl_bar = HexColor("#18b4ed");
  Color cl_back = HexColor("#e9eef4");
  Color cl_card = HexColor("#ffffff");
  Color cl_text_pro_th = HexColor("#1d313a");
  Color cl_text_pro_en = HexColor("#667787");
  Color cl_cart = HexColor("#e64d3f");
  Color cl_line_ver = HexColor("#677787");
  Color cl_favorite = HexColor("#e44b3b");

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final FocusNode myFocusNodeFirstname = FocusNode();
  final FocusNode myFocusNodeLastname = FocusNode();
  final FocusNode myFocusNodeNickname = FocusNode();
  final FocusNode myFocusNodeTelephone = FocusNode();
  final FocusNode myFocusNodePassword = FocusNode();
  final FocusNode myFocusNodeEmail = FocusNode();


  TextEditingController editEmailController = new TextEditingController();
  TextEditingController editFirstNameController = new TextEditingController();
  TextEditingController editLastNameController = new TextEditingController();
  TextEditingController editNicknameController = new TextEditingController();
  TextEditingController editTelephoneController = new TextEditingController();
  TextEditingController editPasswordController = new TextEditingController();
  TextEditingController editConfirmPasswordController = new TextEditingController();

  bool _obscureTextSignup = true;

  bool _validateEmail = false;
  bool _validatePassword = false;
  bool _validateTelephoneNoDigits = false;
  bool _validateTelephoneNo = false;
  bool _validateFirstName = false;
  bool _validateLastName = false;

  PageController _pageController;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    editFirstNameController.text = widget.FisrtName;
    editLastNameController.text = widget.LastName;
    editNicknameController.text = widget.NickName;
    editTelephoneController.text = widget.TelephoneNo;
    editEmailController.text = widget.Email;
    editPasswordController.text = widget.Password;

    _pageController = PageController();
  }

  @override
  void dispose() {
    myFocusNodePassword.dispose();
    myFocusNodeEmail.dispose();
    myFocusNodeFirstname.dispose();
    myFocusNodeLastname.dispose();
    myFocusNodeNickname.dispose();
    myFocusNodeTelephone.dispose();
    _pageController = PageController();
    super.dispose();
  }

  void _toggleSignup() {
    setState(() {
      _obscureTextSignup = !_obscureTextSignup;
    });
  }

  Widget _buildSignUp(BuildContext context) {
    var size = MediaQuery
        .of(context)
        .size;
    /*24 is for notification bar on Android*/
    final double Height = (size.height * 70) / 100;
    final double Width = (size.width * 80) / 100;
    return Container(
      //padding: EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Card(
                elevation: 0.0,
                color: Colors.transparent,
                /*shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),*/

                child: Container(
                  width: Width,
                  height: Height,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              top: 40.0, bottom: 20.0, left: 25.0, right: 25.0),
                          child: TextField(
                            focusNode: myFocusNodeFirstname,
                            controller: editFirstNameController,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 16.0,
                                color: cl_text_pro_th),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                FontAwesomeIcons.userAlt,
                                color: cl_text_pro_en,
                              ),
                              //hintText: "ชื่อจริง",
                              labelText: "ชื่อจริง",
                              errorText: _validateFirstName
                                  ? 'Value Can\'t Be Empty'
                                  : null,
                              labelStyle: TextStyle(fontFamily: "Poppins",
                                  fontSize: 16.0,
                                  color: Colors.black26),
                              /* hintStyle: TextStyle(
                                  fontFamily: "Poppins", fontSize: 16.0,color: Colors.black26),*/
                            ),
                          ),
                        ),
                        Container(
                          width: 250.0,
                          height: 1.0,
                          color: Colors.grey[400],
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                          child: TextField(
                            focusNode: myFocusNodeLastname,
                            controller: editLastNameController,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 16.0,
                                color: cl_text_pro_th),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                FontAwesomeIcons.user,
                                color: cl_text_pro_en,
                              ),
                              labelText: "นามสกุล",
                              errorText: _validateLastName
                                  ? 'Value Can\'t Be Empty'
                                  : null,
                              labelStyle: TextStyle(fontFamily: "Poppins",
                                  fontSize: 16.0,
                                  color: Colors.black26),
                              /*hintText: "Last Name",
                              hintStyle: TextStyle(
                                  fontFamily: "Poppins", fontSize: 16.0,color: Colors.black26),*/
                            ),
                          ),
                        ),
                        Container(
                          width: 250.0,
                          height: 1.0,
                          color: Colors.grey[400],
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                          child: TextField(
                            focusNode: myFocusNodeNickname,
                            controller: editNicknameController,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 16.0,
                                color: cl_text_pro_th),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                FontAwesomeIcons.user,
                                color: cl_text_pro_en,
                              ),
                              labelText: "ชื่อเล่น",
                              labelStyle: TextStyle(fontFamily: "Poppins",
                                  fontSize: 16.0,
                                  color: Colors.black26),
                              /*hintText: "Last Name",
                              hintStyle: TextStyle(
                                  fontFamily: "Poppins", fontSize: 16.0,color: Colors.black26),*/
                            ),
                          ),
                        ),
                        Container(
                          width: 250.0,
                          height: 1.0,
                          color: Colors.grey[400],
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                          child: TextField(
                            focusNode: myFocusNodeTelephone,
                            controller: editTelephoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 16.0,
                                color: cl_text_pro_th),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                FontAwesomeIcons.phone,
                                color: cl_text_pro_en,
                              ),
                              labelText: "เบอร์มือถือ",
                              errorText: _validateTelephoneNo||_validateTelephoneNoDigits
                                  ? 'Invalid Mobile Number Format'
                                  : null,
                              labelStyle: TextStyle(fontFamily: "Poppins",
                                  fontSize: 16.0,
                                  color: Colors.black26),
                            ),
                          ),
                        ),
                        Container(
                          width: 250.0,
                          height: 1.0,
                          color: Colors.grey[400],
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                          child: TextField(
                            focusNode: myFocusNodeEmail,
                            controller: editEmailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 16.0,
                                color: cl_text_pro_th),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                FontAwesomeIcons.envelope,
                                color: cl_text_pro_en,
                              ),
                              labelText: "อีเมลล์",
                              errorText: _validateEmail
                                  ? 'Invalid Email Format'
                                  : null,
                              labelStyle: TextStyle(fontFamily: "Poppins",
                                  fontSize: 16.0,
                                  color: Colors.black26),

                            ),
                          ),
                        ),
                        Container(
                          width: 250.0,
                          height: 1.0,
                          color: Colors.grey[400],
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                          child: TextField(
                            focusNode: myFocusNodePassword,
                            controller: editPasswordController,
                            obscureText: _obscureTextSignup,
                            style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 16.0,
                                color: cl_text_pro_th),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                FontAwesomeIcons.lock,
                                color: cl_text_pro_en,
                              ),
                              labelText: "รหัสผ่าน",
                              errorText: _validatePassword
                                  ? 'Value Can\'t Be Empty'
                                  : null,
                              labelStyle: TextStyle(fontFamily: "Poppins",
                                  fontSize: 16.0,
                                  color: Colors.black26),
                              suffixIcon: GestureDetector(
                                onTap: _toggleSignup,
                                child: Icon(
                                  FontAwesomeIcons.eye,
                                  size: 15.0,
                                  color: cl_text_pro_en,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 250.0,
                          height: 1.0,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: (size.height * 5) / 100),
            decoration: new BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Theme.Colors.loginGradientStart,
                  offset: Offset(1.0, 6.0),
                  blurRadius: 20.0,
                ),
                BoxShadow(
                  color: Theme.Colors.loginGradientEnd,
                  offset: Offset(1.0, 6.0),
                  blurRadius: 20.0,
                ),
              ],
              gradient: new LinearGradient(
                  colors: [
                    /*Theme.Colors.loginGradientEnd,
                    Theme.Colors.loginGradientStart*/
                    Colors.deepOrange,
                    Colors.deepOrange
                  ],
                  begin: const FractionalOffset(0.2, 0.2),
                  end: const FractionalOffset(1.0, 1.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
            ),
            child: MaterialButton(
                highlightColor: Colors.transparent,
                splashColor: Theme.Colors.loginGradientEnd,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 42.0),
                  child: Text(
                    "แก้ไข",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                onPressed: () {
                  String firstname="",lastname="",nickname="",telephone="",email="",password="";

                  firstname = editFirstNameController.text.toString();
                  lastname = editLastNameController.text.toString();
                  nickname = editNicknameController.text.toString();
                  telephone = editTelephoneController.text.toString();
                  password = editPasswordController.text.toString();
                  email = editEmailController.text.toString();

                  setState(() {
                    bool chk_email = true;
                    if (!email.isEmpty) {
                      if (email.contains("@") || email.contains(".com")) {
                        chk_email = true;
                      } else {
                        chk_email = false;
                      }
                    }
                    //verify email
                    chk_email == false ? _validateEmail = true : _validateEmail =
                    false;
                    //verify firstname
                    firstname.isEmpty
                        ? _validateFirstName = true
                        : _validateFirstName = false;
                    //verify lastname
                    lastname.isEmpty
                        ? _validateLastName = true
                        : _validateLastName = false;
                    //verify telephoneNo
                    telephone.isEmpty
                        ? _validateTelephoneNo = true
                        : _validateTelephoneNo = false;
                    //verify telephoneNo
                    password.isEmpty
                        ? _validatePassword = true
                        : _validatePassword = false;
                    telephone.length!=10
                        ? _validateTelephoneNoDigits = true
                        : _validateTelephoneNoDigits = false;
                  });

                  if(!_validateFirstName&&!_validateLastName&&!_validateTelephoneNo&&!_validateTelephoneNoDigits&&!_validatePassword){
                    print('edit data');
                    if(telephone==widget.TelephoneNo) {
                      _editProfile(
                          widget.CustomerID,
                          firstname,
                          lastname,
                          nickname,
                          telephone,
                          email,
                          password,
                        0
                      );
                    }else{
                      _editProfile(
                          widget.CustomerID,
                          firstname,
                          lastname,
                          nickname,
                          telephone,
                          email,
                          password,
                          1
                      );
                    }
                  }
                }
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery
        .of(context)
        .size;
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
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
          'แก้ไขโปรไฟล์', style: new TextStyle(color: cl_text_pro_th),),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          //Image.asset('assets/images/bg.jpg', fit: BoxFit.cover),
          NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowGlow();
            },
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                height: MediaQuery
                    .of(context)
                    .size
                    .height,
                decoration: new BoxDecoration(
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (i) {},
                          children: <Widget>[
                            new ConstrainedBox(
                              constraints: const BoxConstraints.expand(),
                              child: _buildSignUp(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontFamily: "Poppins"),
      ),
      backgroundColor: Colors.cyan,
      duration: Duration(seconds: 2),
    ));
  }

  CupertinoAlertDialog _createCupertinoAlertDialog(mContext,title,desc) =>
      new CupertinoAlertDialog(
          title: new Text(title, style: TextStyle(fontFamily: 'Poppins'),),
          content: new Text(desc,
              style: TextStyle(fontFamily: 'Poppins')),
          actions: <Widget>[

            new CupertinoButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: new Text('ตกลง', style: TextStyle(color: Colors.red,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins'))),
          ]
      );
  void _showDialog(mContext,title,desc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _createCupertinoAlertDialog(mContext,title,desc);
      },
    );
  }

  void _editProfile(CustomerID,FirstName,LastName,NickName,TelephoneNo,Email,Password,Type) async{
    setState(() {
      fetchEditProfile(CustomerID, FirstName, LastName, NickName, TelephoneNo, Email, Password, Type).then((s) async{
        print(s.body);
        if(s.body=="#1"){
          _showDialog(context,"เตือน!","หมายเลขมือถือนี้มีในระบบแล้ว");
        }else{
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),),);
              });
          await editAction();
          _popNav();
        }
      });
    });
  }

  _popNav(){
    setState(() {
      Navigator.pop(context);
    });
  }
  Future<bool> editAction() async {
    await new Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        Navigator.pop(context);
      });
    });
    return true;
  }
}
Future<http.Response> fetchEditProfile(CustomerID,FirstName,LastName,NickName,TelephoneNo,Email,Password,Type) async {
  final paramDic = {
    "CustomerID": CustomerID.toString(),
    "FirstName": FirstName,
    "LastName": LastName,
    "NickName": NickName,
    "TelephoneNo": TelephoneNo,
    "Email": Email,
    "Password": Password,
    "Type": Type.toString(),
  };
  print(Type.toString());
  final EditData = await http.post(
    Server().IPAddress + "/data/get/EditProfile.php", // change with your API
    body: paramDic,
  );
  return EditData;
}