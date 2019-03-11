import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cleanmate_customer_app/verify/progress_hud.dart';
import 'package:cleanmate_customer_app/verify/countdown_base.dart';
import 'package:cleanmate_customer_app/utils/app_util.dart';
import 'package:cleanmate_customer_app/screens/login.dart';

import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:cleanmate_customer_app/Server/server.dart';
import 'package:cleanmate_customer_app/screens/selctBranch.dart';
import 'package:random_string/random_string.dart';

class VerifyOTP extends StatefulWidget {
  String Telephone;
  String PageIndex;
  VerifyOTP({
    Key key,
    @required this.Telephone,@required this.PageIndex,
  }) : super(key: key);

  @override
  _VerifyOTPState createState() => new _VerifyOTPState(this.Telephone,this.PageIndex);
}
class _VerifyOTPState extends State<VerifyOTP> {
  String TelephoneNo;
  String PageIndex;

  _VerifyOTPState(this.TelephoneNo,this.PageIndex);


  bool _isLoading = false;
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  String otpWaitTimeLabel = "";
  bool _isMobileNumberEnter = false;

  final _teOtpDigitOne = TextEditingController();
  final _teOtpDigitTwo = TextEditingController();
  final _teOtpDigitThree = TextEditingController();
  final _teOtpDigitFour = TextEditingController();
  final _teOtpDigitFive = TextEditingController();
  final _teOtpDigitSix = TextEditingController();

  FocusNode _focusNodeDigitOne = new FocusNode();
  FocusNode _focusNodeDigitTwo = new FocusNode();
  FocusNode _focusNodeDigitThree = new FocusNode();
  FocusNode _focusNodeDigitFour = new FocusNode();
  FocusNode _focusNodeDigitFive = new FocusNode();
  FocusNode _focusNodeDigitSix = new FocusNode();

  static const TextStyle linkStyle = const TextStyle(
    color: const Color(0xFF8C919E),
    fontWeight: FontWeight.bold,
  );

  @override
  void dispose() {
    super.dispose();
    _teOtpDigitOne.dispose();
  }

  @override
  void initState() {
    super.initState();
    print('test :' + TelephoneNo+", "+PageIndex);

    changeFocusListener(_teOtpDigitOne, _focusNodeDigitTwo);
    changeFocusListener(_teOtpDigitTwo, _focusNodeDigitThree);
    changeFocusListener(_teOtpDigitThree, _focusNodeDigitFour);
    changeFocusListener(_teOtpDigitFour, _focusNodeDigitFive);
    changeFocusListener(_teOtpDigitFive, _focusNodeDigitSix);

    checkFiled(_teOtpDigitOne);
    checkFiled(_teOtpDigitTwo);
    checkFiled(_teOtpDigitThree);
    checkFiled(_teOtpDigitFour);
    checkFiled(_teOtpDigitFive);
    checkFiled(_teOtpDigitSix);
    startTimer();
  }

  void checkFiled(TextEditingController teController) {
    teController.addListener(() {
      if (!_teOtpDigitOne.text.isEmpty &&
          !_teOtpDigitTwo.text.isEmpty &&
          !_teOtpDigitThree.text.isEmpty &&
          !_teOtpDigitFour.text.isEmpty &&
          !_teOtpDigitFive.text.isEmpty &&
          !_teOtpDigitSix.text.isEmpty) {
        _isMobileNumberEnter = true;
      } else {
        _isMobileNumberEnter = false;
      }
      setState(() {});
    });
  }
  Future<bool> editAction() async {
    await new Future.delayed(const Duration(seconds: 2));
    return true;
  }
  void _submit() {
    if (_isMobileNumberEnter) {
      //showLoader();
      String otp = _teOtpDigitOne.text.trim() +
          _teOtpDigitTwo.text.trim() +
          _teOtpDigitThree.text.trim() +
          _teOtpDigitFour.text.trim() +
          _teOtpDigitFive.text.trim() +
          _teOtpDigitSix.text.trim();

      print(TelephoneNo + ',' + otp);
      final data = callVerifyUser(TelephoneNo, otp);
      data.then((s) async{
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),),);
            });
        await editAction();
        print('ss : ' + s.body);
        if (s.body == 'not-mathched') {
          _showDialogCreateOrder(context);
        } else {
          if (PageIndex == 'sign-up') {
            Future.delayed(const Duration(milliseconds: 500), () {
              setState(() {
                Navigator.of(context).push(
                  new MaterialPageRoute(
                    builder: (context) {
                      //return new SearchList();
                      return new SelectBranch(CustomerID: s.body,IsPage: "OTP",);
                    },
                  ),
                );
              });
            });
          } else if (PageIndex == 'forgot-password') {
            Future.delayed(const Duration(milliseconds: 500), () {
              setState(() {
                Navigator.of(context).push(
                  new MaterialPageRoute(
                    builder: (context) {
                      //return new SearchList();
                      return new LoginPage();
                    },
                  ),
                );
              });
            });
          }
        }
      });
    } else {
      showAlert("Please enter valid OTP!");
    }
  }
  CupertinoAlertDialog _createCupertinoAlertDialog(mContext) =>
      new CupertinoAlertDialog(
          title: new Text("เตือน!", style: TextStyle(fontFamily: 'Poppins'),),
          content: new Text("รหัสยืนยันไม่ถูกต้อง.",
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
  void _showDialogCreateOrder(mContext) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _createCupertinoAlertDialog(mContext);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var otpBox = new Row(
      children: <Widget>[
        new Expanded(
          child: new TextFormField(
            controller: _teOtpDigitOne,
            focusNode: _focusNodeDigitOne,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 16.0, color: Colors.black),
          ),
        ),
        new SizedBox(
          width: 10.0,
        ),
        new Expanded(
          child: new TextFormField(
            controller: _teOtpDigitTwo,
            focusNode: _focusNodeDigitTwo,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 16.0, color: Colors.black),
          ),
        ),
        new SizedBox(
          width: 10.0,
        ),
        new Expanded(
          child: new TextFormField(
            controller: _teOtpDigitThree,
            focusNode: _focusNodeDigitThree,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0, color: Colors.black),
          ),
        ),
        new SizedBox(
          width: 10.0,
        ),
        new Expanded(
          child: new TextFormField(
            controller: _teOtpDigitFour,
            focusNode: _focusNodeDigitFour,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0, color: Colors.black),
          ),
        ),
        new SizedBox(
          width: 10.0,
        ),
        new Expanded(
          child: new TextFormField(
            controller: _teOtpDigitFive,
            focusNode: _focusNodeDigitFive,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0, color: Colors.black),
          ),
        ),
        new SizedBox(
          width: 10.0,
        ),
        new Expanded(
          child: new TextFormField(
            controller: _teOtpDigitSix,
            focusNode: _focusNodeDigitSix,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 16.0, color: Colors.black),
          ),
        ),
      ],
    );

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
                    "Enter valid recieved OTP",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Poppins")
                ),
                new Padding(
                  padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
                  child: otpBox,
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
                        print('send again');
                        var code = null;
                        setState(() {
                          code = randomNumeric(6).toString();
                        });
                        _sendAgain(TelephoneNo,code);
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
                    _submit();
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
                      "Verify OTP",
                      style: new TextStyle(
                          color: const Color(0xFFFFFFFF),
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
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

  @override
  void closeLoader() {
    setState(() => _isLoading = false);
  }


  @override
  void showLoader() {
    setState(() => _isLoading = true);
  }

  @override
  void showAlert(String msg) {
    setState(() {
      AppUtil().showAlert(msg);
    });
  }

  @override
  onError(String msg) {
    showAlert(msg);
    closeLoader();
  }


  void startTimer() {
    var sub = new CountDown(new Duration(minutes: 4)).stream.listen(null);
    sub.onData((Duration d) {
      setState(() {
        int sec = d.inSeconds % 60;
        otpWaitTimeLabel = d.inMinutes.toString() + ":" + sec.toString();
      });
    });
  }

  void _sendAgain(telephone,CodeOTP) {
    startTimer();
    final data = callVerifyUserAgain(telephone, CodeOTP);
    data.then((s){
      print('ss : '+s.body);
    });
  }

  @override
  verificationCodeSent(int forceResendingToken) {}


}
Future<http.Response> callVerifyUser(telephone,CodeOTP) async {
  final paramDic = {
    "Telephone": telephone,
    "OTP": CodeOTP,
  };
  final loginData = await http.post(
    Server().IPAddress + "/put/customer/IsVerify.php", // change with your API
    body: paramDic,
  );

  return loginData;
}
Future<http.Response> callVerifyUserAgain(telephone,CodeOTP) async {
  final paramDic = {
    "Telephone": telephone,
    "OTP": CodeOTP,
  };
  final loginData = await http.post(
    Server().IPAddress + "/put/customer/IsUpdateOTP.php", // change with your API
    body: paramDic,
  );

  return loginData;
}
