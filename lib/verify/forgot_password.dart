import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:cleanmate_customer_app/verify/progress_hud.dart';
import 'package:cleanmate_customer_app/verify/countdown_base.dart';
import 'package:cleanmate_customer_app/utils/app_util.dart';
import 'package:cleanmate_customer_app/colorCode/HexColor.dart';

import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:cleanmate_customer_app/Server/server.dart';
import 'package:cleanmate_customer_app/screens/selctBranch.dart';
import 'package:random_string/random_string.dart';
import 'verifyOTP.dart';

class ForgotPassword extends StatefulWidget {
  String IsPage;
  ForgotPassword({
    Key key,
    @required this.IsPage,
  }) : super(key: key);
  @override
  _ForgotPasswordState createState() => new _ForgotPasswordState();
}
class _ForgotPasswordState extends State<ForgotPassword> {

  bool _isLoading = false;
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  String otpWaitTimeLabel = "";

  final FocusNode myFocusNodeTelephoneFogot = FocusNode();
  final FocusNode myFocusNodePasswordFogot = FocusNode();

  TextEditingController FogotTelephoneController = new TextEditingController();
  TextEditingController FogotPasswordController = new TextEditingController();

  bool _obscureTextLogin = true;

  bool _validatePhoneForgot= false;
  bool _validatePasswordForgot= false;

  Color cl_back = HexColor("#e9eef4");
  Color cl_card = HexColor("#ffffff");
  Color cl_text_pro_th = HexColor("#1d313a");
  Color cl_text_pro_en = HexColor("#667787");
  Color cl_cart = HexColor("#18b4ed");
  Color cl_bar = HexColor("#18b4ed");
  Color cl_line_ver = HexColor("#677787");

  static const TextStyle linkStyle = const TextStyle(
    color: const Color(0xFF8C919E),
    fontWeight: FontWeight.bold,
  );

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }
  void _toggleLogin() {
    setState(() {
      _obscureTextLogin = !_obscureTextLogin;
    });
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
  void _showDialogCreateOrder(mContext,title,desc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _createCupertinoAlertDialog(mContext,title,desc);
      },
    );
  }

  _onChangNewPassword(tel,pass,otp,mContext){
    if(tel.toString().isEmpty||pass.toString().isEmpty){
      _showDialogCreateOrder(context,"เตือน!","กรุณากรอกข้อมูลให้ครบทุกช่อง.");
    }else{
      if(tel.toString().length!=10){
        _validatePhoneForgot=true;
        //_showDialogCreateOrder(context,"เตือน!","หมายเลขโทรศัพท์ให้ครบ 10 หลัก.");
      }else{
        _sendCallAPI(tel,pass,otp,mContext);
        /*Navigator.of(context).push(
          new MaterialPageRoute(
            builder: (context) {
              return new VerifyOTP(Telephone: FogotTelephoneController.text,);
            },
          ),
        );*/

      }
    }
  }
  Future<http.Response> callChangePassword(tel,pass,otp,mContext) async {
    final paramDic = {
      "Telephone": tel,
      "Password": pass,
      "OTP": otp,

    };
    final loginData = await http.post(
      Server().IPAddress + "/put/customer/ChangePassword.php", // change with your API
      body: paramDic,
    );

    return loginData;
  }
  Future<bool> editAction() async {
    await new Future.delayed(const Duration(seconds: 2));
    return true;
  }

  void _sendCallAPI(tel,pass,otp,mContext) {
    final data = callChangePassword(tel,pass,otp,mContext);
    data.then((s) async{
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),),);
          });
      await editAction();

      if(s.body.trim()=="Non-data"){
        _showDialogCreateOrder(mContext, "เตือน!", "หมายเลขโทรศัพท์นี้ไม่มีในระบบ");
      }else {
        if (s.body != null) {
          Future.delayed(const Duration(milliseconds: 500), () {
            setState(() {
              Navigator.of(mContext).push(
                new MaterialPageRoute(
                  builder: (context) {
                    //return new SearchList();
                    return new VerifyOTP(Telephone: tel.toString().trim(),
                      PageIndex: "forgot-password",);
                  },
                ),
              );
            });
          });
        }
      }
    });
  }
  @override
  Widget build(BuildContext context) {

    var form = new Column(
      children: <Widget>[
        new Container(
          alignment: FractionalOffset.center,
          margin: EdgeInsets.fromLTRB(40.0, 50.0, 40.0, 0.0),
          padding: EdgeInsets.all(20.0),
          decoration: new BoxDecoration(
            color: Colors.transparent,
            //color: const Color(0xFFF9F9F9),
            borderRadius: new BorderRadius.all(
              const Radius.circular(6.0),
            ),
          ),
          child: new Form(
            key: _formKey,
            child: new Column(
              children: <Widget>[
                new Text(
                    "เปลี่ยน Passcode ใหม่",
                    style: TextStyle(
                        color: Color(0xff0091bb),
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Poppins")
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 60.0, bottom: 20.0, left: 25.0, right: 25.0),
                  child: TextField(
                    focusNode: myFocusNodeTelephoneFogot,
                    controller: FogotTelephoneController,
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
                        color: cl_text_pro_en,
                        size: 22.0,
                      ),
                     /* hintText: "เบอร์มือถือ",
                      hintStyle: TextStyle(
                          fontFamily: "Poppins", fontSize: 17.0),*/
                      labelText: "เบอร์มือถือ",
                      labelStyle: TextStyle(fontFamily: "Poppins",
                          fontSize: 16.0,
                          color: Colors.black26),
                      errorText: _validatePhoneForgot
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
                    focusNode: myFocusNodePasswordFogot,
                    controller: FogotPasswordController,
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
                        color: cl_text_pro_en,
                      ),
                      /*hintText: "รหัสผ่านใหม่",
                      hintStyle: TextStyle(
                          fontFamily: "Poppins", fontSize: 17.0),*/
                      labelText: "Passcode ใหม่",
                      labelStyle: TextStyle(fontFamily: "Poppins",
                          fontSize: 16.0,
                          color: Colors.black26),
                      errorText: _validatePasswordForgot
                          ? 'Value Can\'t Be Empty'
                          : null,
                      suffixIcon: GestureDetector(
                        onTap: _toggleLogin,
                        child: Icon(
                          FontAwesomeIcons.eye,
                          size: 15.0,
                          color: cl_text_pro_en,
                        ),
                      ),
                    ),
                  ),
                ),
                new SizedBox(
                  width: 0.0,
                  height: 20.0,
                ),
                otpWaitTimeLabel != '0:0' ?
                new Text(
                  otpWaitTimeLabel,
                ) : Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: FlatButton(
                      onPressed: () {
                        print('ส่งอีกครั้ง');
                        var code = null;
                        setState(() {
                          code = randomNumeric(6).toString();
                        });
                        //_sendAgain(TelephoneNo,code);
                      },
                      child: Text(
                        "ส่งอีกครั้ง",
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Color(0xFF15c680),
                            fontSize: 16.0,
                            fontFamily: "WorkSansMedium"),
                      )),
                ),
                new GestureDetector(
                  onTap: () {
                    var code = null;
                    setState(() {
                      code = randomNumeric(6).toString();
                    });
                    _onChangNewPassword(FogotTelephoneController.text,FogotPasswordController.text,code,context);

                  },
                  child: new Container(
                    margin: EdgeInsets.only(top: 20.0),
                    padding: EdgeInsets.all(15.0),
                    alignment: FractionalOffset.center,
                    decoration: new BoxDecoration(
                      color: new Color(0xFF2CB044),
                      borderRadius:
                      new BorderRadius.all(const Radius.circular(6.0)),
                    ),
                    child: Text(
                      "เปลี่ยน",
                      style: new TextStyle(
                          color: const Color(0xFFFFFFFF),
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: widget.IsPage.endsWith("Login")?FlatButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/Login');
                      },
                      child: Text(
                        "กลับไปหน้า Login",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Color(0xFFbdbdbd),
                          fontSize: 16.0,),
                      )):
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "กลับไปหน้า Home",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Color(0xFFbdbdbd),
                          fontSize: 16.0,),
                      )),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    var screenRoot = new Container(
      height: double.maxFinite,
      alignment: FractionalOffset.center,
      child: new SingleChildScrollView(
        child: new Center(
          child: form,
        ),
      ),
    );
    return new WillPopScope(
      onWillPop: () async {
        print("back");
        //return true;
      },
      child: new Scaffold(
        backgroundColor: const Color(0xFF2B2B2B),
        appBar: null,
        key: _scaffoldKey,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset('assets/images/bg.jpg', fit: BoxFit.cover),
            NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowGlow();
              },
              child: ProgressHUD(
                child: screenRoot,
                inAsyncCall: _isLoading,
                opacity: 0.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void changeFocusListener(TextEditingController teOtpDigitOne,
      FocusNode focusNodeDigitTwo) {
    teOtpDigitOne.addListener(() {
      if (teOtpDigitOne.text.length > 0 && focusNodeDigitTwo != null) {
        FocusScope.of(context).requestFocus(focusNodeDigitTwo);
      }
      setState(() {});
    });
  }
}