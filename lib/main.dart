import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cleanmate_customer_app/HomeScreen.dart';
import 'package:cleanmate_customer_app/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/selctBranch.dart';
import 'package:cleanmate_customer_app/order_infor/create_order.dart';

void main() {
  runApp(new MaterialApp(
    title: 'I Wash',
    home: new SplashScreen(),
    debugShowCheckedModeBanner: false,
    routes: <String, WidgetBuilder>{
      //intent เกี่ยวข้อง
      '/Login': (BuildContext context) => new LoginPage(),
      '/HomeScreen': (BuildContext context) => new HomeScreen(),
      '/Branch': (BuildContext context) => new SelectBranch(CustomerID: 6237.toString()),
      '/CreateOrder': (BuildContext context) => new CreateOrder(OrderNo: '1900400001',),
    },
    theme: ThemeData(
        primaryColor: Colors.white,
    ),
    /*onGenerateRoute: (RouteSettings settings) {
      switch (settings.name) {
        case '/Order': return new FromRightToLeft(
          builder: (_) => new _orderPage.About(),
          settings: settings,
        );
        *//*case '/Service': return new FromRightToLeft(
          builder: (_) => new _servicePage.Support(),
          settings: settings,
        );*//*
        case '/ProductList': return new FromRightToLeft(
          builder: (_) => new _productlist.ProductList(),
          settings: settings,
        );
      }
    },*/
  ));
} 

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  startTime() async {
    var _duration = new Duration(seconds: 4);
    return new Timer(_duration, navigationPage);
  }

  SharedPreferences prefs;
  Animation animation;
  AnimationController animationController;
  int factcounter = 0;
  int colorcounter = 0;

  void navigationPage() async {
    //intent
    Navigator.of(context).pushReplacementNamed('/CreateOrder');
    prefs = await SharedPreferences.getInstance();
    int custID = (prefs.getInt('CustomerID') ?? 0);
    custID == 0
        ? Navigator.of(context).pushReplacementNamed('/Login')
        : Navigator.of(context).pushReplacementNamed('/HomeScreen');

    //Navigator.of(context).pushReplacementNamed('/TEST');
  }

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
        vsync: this, duration: new Duration(seconds: 2));
    animation = new CurvedAnimation(
        parent: animationController, curve: Curves.fastOutSlowIn);
    animation.addListener(() {
      this.setState(() {});
    });
    animationController.forward();

    startTime();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void showfacts() {
    setState(() {
      /* dispfact = facts[factcounter];
      dispcolor = bgcolors[colorcounter];
      factcounter = factcounter < facts.length - 1 ? factcounter + 1 : 0;
      colorcounter = colorcounter < bgcolors.length - 1 ? colorcounter + 1 : 0;*/

      animationController.reset();
      animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset('assets/images/bg.jpg', fit: BoxFit.cover),
          NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowGlow();
            }, child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 60.0),
            child: new Opacity(
              opacity: animation.value * 1,
              child: new Transform(
                transform: new Matrix4.translationValues(
                    0.0, animation.value * -50.0, 0.0),
                child: new Center(
                  //set image
                  child: new Image.asset('assets/images/logo.png'),
                ),
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }
}