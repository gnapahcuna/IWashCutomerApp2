import 'dart:io';

import 'package:cleanmate_customer_app/HomeScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cleanmate_customer_app/style/theme.dart' as Theme;
import 'package:cleanmate_customer_app/utils/bubble_indication_painter.dart';
import 'dart:ui' as ui;

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cleanmate_customer_app/Server/server.dart';
import 'package:otp/otp.dart';
import 'package:random_string/random_string.dart';
import 'package:cleanmate_customer_app/verify/verifyOTP.dart';
import 'package:cleanmate_customer_app/colorCode/HexColor.dart';
import 'package:get_ip/get_ip.dart';
import 'package:cleanmate_customer_app/data/Users.dart' as _users;
import 'package:cleanmate_customer_app/verify/forgot_password.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final FocusNode myFocusNodeTelephoneLogin = FocusNode();
  final FocusNode myFocusNodePasswordLogin = FocusNode();

  final FocusNode myFocusNodeFirstname = FocusNode();
  final FocusNode myFocusNodeLastname = FocusNode();
  //final FocusNode myFocusNodeNickname = FocusNode();
  final FocusNode myFocusNodeTelephone = FocusNode();
  final FocusNode myFocusNodePassword = FocusNode();
  //final FocusNode myFocusNodeEmail = FocusNode();

  TextEditingController loginTelephoneController = new TextEditingController();
  TextEditingController loginPasswordController = new TextEditingController();

  bool _obscureTextLogin = true;
  bool _obscureTextSignup = true;
  bool _obscureTextSignupConfirm = true;

  //TextEditingController signupEmailController = new TextEditingController();
  TextEditingController signupFirstNameController = new TextEditingController();
  TextEditingController signupLastNameController = new TextEditingController();
  //TextEditingController signupNicknameController = new TextEditingController();
  TextEditingController signupTelephoneController = new TextEditingController();
  TextEditingController signupPasswordController = new TextEditingController();
  TextEditingController signupConfirmPasswordController =
  new TextEditingController();

  PageController _pageController;

  Color left = Colors.black;
  Color right = Colors.white;

  bool isData = false;

  bool _validatePasswordLogin = false;
  bool _validatePhoneLogin = false;

  bool _validateFirstnameSignUp = false;
  bool _validateLastnameSignUp= false;
  bool _validatePasswordSignUp = false;
  bool _validatePhoneSignUp= false;

  Color cl_bar = HexColor("#18b4ed");
  Color cl_back = HexColor("#e9eef4");
  Color cl_card = HexColor("#ffffff");
  Color cl_text_pro_th = HexColor("#1d313a");
  Color cl_text_pro_en = HexColor("#667787");
  Color cl_cart = HexColor("#e64d3f");
  Color cl_line_ver = HexColor("#677787");
  Color cl_favorite = HexColor("#e44b3b");
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery
        .of(context)
        .size;
    return new Scaffold(
      key: _scaffoldKey,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset('assets/images/bg.jpg', fit: BoxFit.cover),
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
                  /*gradient: new LinearGradient(
                      colors: [
                        Theme.Colors.loginGradientStart,
                        Theme.Colors.loginGradientEnd
                      ],
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),*/
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          //top: 65.0, left: 38.0, right: 38.0, bottom: 35.0),
                            top: (size.height * 10) / 100,
                            left: 38.0,
                            right: 38.0,
                            bottom: (size.height * 3) / 100),
                        child: new Image(
                            fit: BoxFit.cover,
                            image: new AssetImage(
                                'assets/images/logo_smart.png')),
                      ),
                      Expanded(
                        flex: 2,
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (i) {
                            if (i == 0) {
                              setState(() {
                                right = Colors.white;
                                left = Colors.black;
                              });
                            } else if (i == 1) {
                              setState(() {
                                right = Colors.black;
                                left = Colors.white;
                              });
                            }
                          },
                          children: <Widget>[
                            new ConstrainedBox(
                              constraints: const BoxConstraints.expand(),
                              child: _buildSignIn(context),
                            ),
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

  @override
  void dispose() {
    myFocusNodePassword.dispose();
    //myFocusNodeEmail.dispose();
    myFocusNodeFirstname.dispose();
    myFocusNodeLastname.dispose();
    myFocusNodeTelephone.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _pageController = PageController();
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
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 3),
    ));
  }

  Widget _buildMenuBar(BuildContext context) {
    return Container(
      width: 300.0,
      height: 50.0,
      decoration: BoxDecoration(
        color: Color(0x552B2B2B),
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: CustomPaint(
        painter: TabIndicationPainter(pageController: _pageController),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onSignInButtonPress,
                child: Text(
                  "Existing",
                  style: TextStyle(
                      color: left,
                      fontSize: 16.0,
                      fontFamily: "Poppins"),
                ),
              ),
            ),
            //Container(height: 33.0, width: 1.0, color: Colors.white),
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onSignUpButtonPress,
                child: Text(
                  "New",
                  style: TextStyle(
                      color: right,
                      fontSize: 16.0,
                      fontFamily: "Poppins"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignIn(BuildContext context) {
    var size = MediaQuery
        .of(context)
        .size;
    /*24 is for notification bar on Android*/
    final double Height = size.height/2.5;
    final double Width = (size.width * 80) / 100;
    return Container(
      //padding: EdgeInsets.only(top: 8.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Card(
                elevation: 0.0,
                color: Colors.transparent,
                child: Container(
                  width: Width,
                  height: Height,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                            //top: (size.height*5)/100, bottom: (size.height*5)/100, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodeTelephoneLogin,
                          controller: loginTelephoneController,
                          maxLength: 10,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 16.0,
                              color: cl_text_pro_th),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.phone,
                              color: cl_text_pro_th,
                              size: 22.0,
                            ),
                            /*hintText: "เบอร์มือถือ",
                            hintStyle: TextStyle(
                                fontFamily: "Poppins", fontSize: 17.0),*/
                            labelText: "เบอร์มือถือ",
                            errorText: _validatePhoneLogin
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
                          focusNode: myFocusNodePasswordLogin,
                          controller: loginPasswordController,
                          obscureText: _obscureTextLogin,
                          maxLength: 4,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 16.0,
                              color: cl_text_pro_th),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.key,
                              size: 22.0,
                              color: cl_text_pro_th,
                            ),
                            /*hintText: "รหัสผ่าน",
                            hintStyle: TextStyle(
                                fontFamily: "Poppins", fontSize: 17.0),*/
                            labelText: "Passcode",
                            errorText: _validatePasswordLogin
                                ? 'Value Can\'t Be Empty'
                                : null,
                            labelStyle: TextStyle(fontFamily: "Poppins",
                                fontSize: 16.0,
                                color: Colors.black26),
                            suffixIcon: GestureDetector(
                              onTap: _toggleLogin,
                              child: Icon(
                                FontAwesomeIcons.eye,
                                size: 15.0,
                                color: cl_text_pro_th,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: (size.height*0)/100),
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
                    Color(0xFF2CB044),
                    Color(0xFF2CB044)
                  ],
                  begin: const FractionalOffset(0.2, 0.2),
                  end: const FractionalOffset(1.0, 1.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
            ),
            child: MaterialButton(
              highlightColor: Colors.transparent,
              splashColor: Theme.Colors.loginGradientEnd,
              //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 42.0),
                child: Text(
                  "เข้าสู่ระบบ",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
              onPressed: () =>
              _onSignIn(loginTelephoneController.text,loginPasswordController.text),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: FlatButton(
                onPressed: () {
                  Navigator.of(context).push(
                    new MaterialPageRoute(
                      builder: (context) {
                        //return new SearchList();
                        return new ForgotPassword(IsPage: "Login",);
                      },
                    ),
                  );
                },
                child: Text(
                  "ลืม Passcode?",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Color(0xFFbdbdbd),
                    fontSize: 16.0,),
                )),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    gradient: new LinearGradient(
                        colors: [
                          Colors.white10,
                          cl_text_pro_th,
                        ],
                        begin: const FractionalOffset(0.0, 0.0),
                        end: const FractionalOffset(1.0, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  width: 150.0,
                  height: 1.0,
                ),
                /*Padding(
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Text(
                    "Or",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontFamily: "WorkSansMedium"),
                  ),
                ),*/
                Container(
                  decoration: BoxDecoration(
                    gradient: new LinearGradient(
                        colors: [
                          cl_text_pro_th,
                          Colors.white10,
                        ],
                        begin: const FractionalOffset(0.0, 0.0),
                        end: const FractionalOffset(1.0, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  width: 150.0,
                  height: 1.0,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: FlatButton(
                onPressed: () {
                  _onSignUpButtonPress();
                },
                child: Text(
                  "สร้างบัญชี",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Color(0xFF0091bb),
                    fontSize: 16.0,),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUp(BuildContext context) {
    var size = MediaQuery
        .of(context)
        .size;
    /*24 is for notification bar on Android*/
    final double Height = (size.height * 60) / 100;
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
                              top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                          child: TextField(
                            focusNode: myFocusNodeFirstname,
                            controller: signupFirstNameController,
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
                                color: cl_text_pro_th,
                              ),
                             /* hintText: "ชื่อจริง",
                              hintStyle: TextStyle(
                                  fontFamily: "Poppins", fontSize: 16.0),*/
                              labelText: "ชื่อจริง",
                              labelStyle: TextStyle(fontFamily: "Poppins",
                                  fontSize: 16.0,
                                  color: Colors.black26),
                              errorText: _validateFirstnameSignUp
                                  ? 'Value Can\'t Be Empty'
                                  : null,
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
                            controller: signupLastNameController,
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
                                color: cl_text_pro_th,
                              ),
                              /*hintText: "นามสกุล",
                              hintStyle: TextStyle(
                                  fontFamily: "Poppins", fontSize: 16.0),*/
                              labelText: "นามสกุล",
                              labelStyle: TextStyle(fontFamily: "Poppins",
                                  fontSize: 16.0,
                                  color: Colors.black26),
                              errorText: _validateLastnameSignUp
                                  ? 'Value Can\'t Be Empty'
                                  : null,
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
                            controller: signupTelephoneController,
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
                                color: cl_text_pro_th,
                              ),
                              /*hintText: "เบอร์มือถือ",
                              hintStyle: TextStyle(
                                  fontFamily: "Poppins", fontSize: 16.0),*/
                              labelText: "เบอร์มือถือ",
                              labelStyle: TextStyle(fontFamily: "Poppins",
                                  fontSize: 16.0,
                                  color: Colors.black26),
                              errorText: _validatePhoneSignUp
                                  ? 'Invalid Mobile Number Format'
                                  : null,
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
                            controller: signupPasswordController,
                            obscureText: _obscureTextSignup,
                            style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 16.0,
                                color: cl_text_pro_th),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                FontAwesomeIcons.lock,
                                color: cl_text_pro_th,
                              ),
                             /* hintText: "รหัสผ่าน",
                              hintStyle: TextStyle(
                                  fontFamily: "Poppins", fontSize: 16.0),*/
                              labelText: "Passcode",
                              labelStyle: TextStyle(fontFamily: "Poppins",
                                  fontSize: 16.0,
                                  color: Colors.black26),
                              errorText: _validatePasswordSignUp
                                  ? 'Value Can\'t Be Empty'
                                  : null,
                              suffixIcon: GestureDetector(
                                onTap: _toggleSignup,
                                child: Icon(
                                  FontAwesomeIcons.eye,
                                  size: 15.0,
                                  color: cl_text_pro_th,
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
            margin: EdgeInsets.only(top: (size.height*5)/100),
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
                    Color(0xFF2CB044),
                    Color(0xFF2CB044)
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
                    "ลงทะเบียน",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                onPressed: () {
                  String firstname = signupFirstNameController.text.toString();
                  String lastname = signupLastNameController.text.toString();
                  String telephone = signupTelephoneController.text.toString();
                  String password = signupPasswordController.text.toString();

                  firstname.isEmpty?_validateFirstnameSignUp=true:_validateFirstnameSignUp=false;
                  lastname.isEmpty?_validateLastnameSignUp=true:_validateLastnameSignUp=false;
                  telephone.isEmpty?_validatePhoneSignUp=true:_validatePhoneSignUp=false;
                  password.isEmpty?_validatePasswordSignUp=true:_validatePasswordSignUp=false;

                  if(_validateFirstnameSignUp==false&&_validateLastnameSignUp==false&&_validatePhoneSignUp==false&&_validatePasswordSignUp==false){
                    _onSignUp(
                        firstname,
                        lastname,
                        telephone,
                        password,
                        context);
                  }
                }
            ),
          ),
          /*Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: FlatButton(
                onPressed: () {
                  _onSignInButtonPress();
                },
                child: Text(
                  "Your Have Account",
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.white,
                      fontSize: 16.0,
                      fontFamily: "WorkSansMedium"),
                )),
          ),*/
        ],
      ),
    );
  }

  void _onSignInButtonPress() {
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _onSignUpButtonPress() {
    _pageController?.animateToPage(1,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _toggleLogin() {
    setState(() {
      _obscureTextLogin = !_obscureTextLogin;
    });
  }

  void _toggleSignup() {
    setState(() {
      _obscureTextSignup = !_obscureTextSignup;
    });
  }

  void _toggleSignupConfirm() {
    setState(() {
      _obscureTextSignupConfirm = !_obscureTextSignupConfirm;
    });
  }
  
  SharedPreferences prefs;
  _putUserAcct(CustomerID,BranchID,BranchGroupID,BranchCode,Firstname,Lastname,phone,BranchNameTH,BranchNameEN,TelephoneBranch) async {
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

    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          //return new SearchList();
          return new HomeScreen();
        },
      ),
    );
  }
  Future<bool> editAction() async {
    await new Future.delayed(const Duration(seconds: 2));
    return true;
  }
  void _onSignIn(telephone,password) async{
    if(telephone.length!=10){
      _validatePhoneLogin = true;
    }else{
      _validatePhoneLogin = false;
      String ipAddress = await GetIp.ipAddress;
      callSignInUser(telephone, password, ipAddress).then((s) async{
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),),);
            });
        await editAction();
        Navigator.pop(context);

        List<_users.Users> users = s;
        //print(isData);
        isData!=true
            ? new Center(
          child: new CircularProgressIndicator(),
        ):users.length>0
            ? setState((){
          _putUserAcct(users[0].CustomerID,users[0].BranchID,users[0].BranchGroupID,users[0].BranchCode
              ,users[0].FirstName,users[0].LastName,users[0].TelephoneNo,users[0].BranchNameTH,
              users[0].BranchNameEN,users[0].TelephoneNoBranch);
        }):  _showDialog(context,"เตือน!","Login ไม่ถูกต้อง.");
      });
    }
  }
  void _onSignUp(firstname, lastname, telephone, password,
      context) async {
    if (firstname
        .toString()
        .isEmpty ||
        lastname
            .toString()
            .isEmpty ||
        telephone
            .toString()
            .isEmpty ||
        password
            .toString()
            .isEmpty) {
      showInSnackBar("กรุณากรอกข้อมูลให้ครบทุกช่อง!");
    } else {
      var code = null;
      setState(() {
        code = randomNumeric(6).toString();
      });
      final resp = callSignUpUser(
          firstname,
          lastname,
          telephone,
          password,
          code);
      
      resp.then((s)async{
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),),);
            });
        await editAction();
        Navigator.pop(context);

        //print("ss : "+s.body.toString());
        if (s.body == 'Repeat') {
          _showDialog(context,"เตือน!","หมายเลขมือถือนี้มีในระบบแล้ว");
        } else {
          Navigator.of(context).push(
            new MaterialPageRoute(
              builder: (context) {
                //return new SearchList();
                return new VerifyOTP(Telephone: telephone,PageIndex: 'sign-up',);
              },
            ),
          );
        }
      });
    }
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

  Future<List<_users.Users>> callSignInUser(telephone,password,ipAddress) async {
    final paramDic = {
      "Telephone": telephone,
      "Password": password,
      "IPAdress": ipAddress,
    };
    final response = await http.post(
      Server().IPAddress + "/put/customer/UserSignIn.php", // change with your API
      body: paramDic,
    );
    if(response.statusCode==200) {
      isData=true;
      List responseJson = json.decode(response.body);
      return responseJson.map((m) => new _users.Users.fromJson(m)).toList();
    }else{
      print('Something went wrong. \nResponse Code : ${response.statusCode}');
    }
  }

}
Future<http.Response> callSignUpUser(firstname,lastname,telephone,password,codeOTP) async {
  final paramDic = {
    "FirstName": firstname,
    "LastName": lastname,
    //"Nickname": nickname,
    "Telephone": telephone,
    "Password": password,
    //"Email": email,
    "OTPCode": codeOTP,
  };
  final loginData = await http.post(
    Server().IPAddress + "/put/customer/UserSignUp.php", // change with your API
    body: paramDic,
  );
  return loginData;
}