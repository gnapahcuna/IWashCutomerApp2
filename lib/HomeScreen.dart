import 'package:badges/badges.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cleanmate_customer_app/order_infor/branch_contact.dart';
import 'package:cleanmate_customer_app/order_infor/change_langauge.dart';
import 'package:cleanmate_customer_app/order_infor/order_history.dart';
import 'package:cleanmate_customer_app/order_infor/order_traking.dart';
import 'package:cleanmate_customer_app/order_infor/profile_setting.dart';
import 'package:cleanmate_customer_app/screens/product_favorite.dart';
import 'package:cleanmate_customer_app/screens/product_search.dart';
import 'package:cleanmate_customer_app/screens/selctBranch.dart';
import 'package:cleanmate_customer_app/screens/cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cleanmate_customer_app/colorCode/HexColor.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cleanmate_customer_app/alert/messageAlert.dart' as _message;


import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:cleanmate_customer_app/Server/server.dart';
import 'package:cleanmate_customer_app/data/Service.dart' as _service;
import 'package:cleanmate_customer_app/data/CategoryTitle.dart' as _categoryName;
import 'package:cleanmate_customer_app/data/Product.dart' as _product;
import 'package:cleanmate_customer_app/data/BranchContact.dart' as _branch;
import 'package:cleanmate_customer_app/data/Brochure.dart' as _brochure;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class FromRightToLeft<T> extends MaterialPageRoute<T> {
  FromRightToLeft({ WidgetBuilder builder, RouteSettings settings })
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {

    if (settings.isInitialRoute)
      return child;

    return new SlideTransition(
      child: new Container(
        decoration: new BoxDecoration(
            boxShadow: [
              new BoxShadow(
                color: Colors.black26,
                blurRadius: 25.0,
              )
            ]
        ),
        child: child,
      ),
      position: new Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      )
          .animate(
          new CurvedAnimation(
            parent: animation,
            curve: Curves.fastOutSlowIn,
          )
      ),
    );
  }
  @override Duration get transitionDuration => const Duration(milliseconds: 400);
}
class _HomeScreenState extends State<HomeScreen> {
  Color cl_bar = HexColor("#18b4ed");
  PageController _tabController;

  var _title_app = null;
  int _tab = 0;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  new GlobalKey<RefreshIndicatorState>();

  //Color cl_text_pro_th = HexColor("#667787");
  //Color cl_text_pro_en = HexColor("#989fa7");
  Color cl_text_pro_th = HexColor("#1d313a");
  Color cl_text_pro_en = HexColor("#667787");


  int CustomerID, BranchID, counts,BranchGroupID;
  String FirstName = "",
      LastName = "",
      UserAcctName = "";
  SharedPreferences prefs;
  List<NetworkImage> arrImg = new List();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var location = new Location();
  Map<String, double> userLocation;
  String Latitude,Longitude;

  List<String> itemsServiceType=[];

  _getRequests()async{
    _getShafe();
  }

  @override
  void initState() {
    super.initState();
    _getUserAcct();
    _getShafe();
    _tabController = new PageController();
    this._title_app = TabItems[0].title;

    setState(() {
      fetchBrochure(BranchGroupID.toString()).then((s){
        for(int i=0;i<s.length;i++){
          arrImg.add(new NetworkImage('http://119.59.115.80/cleanmate_god_test/'+s[i].url.substring(3,s[i].url.length)));
        }
      });
    });

    _getLocation().then((value) {
      setState(() {
        userLocation = value;

        Latitude = userLocation["latitude"].toString();
        Longitude = userLocation["longitude"].toString();
      });
    });
    /*arrImg.add(new NetworkImage('http://119.59.115.80/cleanmate_god_test/Upload/Brochure/S__82739290.jpg'));
    arrImg.add(new NetworkImage('http://119.59.115.80/cleanmate_god_test/Upload/Brochure/S__81002521.jpg'));*/
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

  void _showDialog(title, desc) {
    _message.Message(title, desc, context, null, 2);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  _getUserAcct() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      CustomerID = (prefs.getInt("CustomerID") ?? 0);
      BranchID = (prefs.getInt("BranchID") ?? 0);
      BranchGroupID = (prefs.getInt("BranchGroupID") ?? 0);
      FirstName = (prefs.getString("Firstname") ?? "");
      LastName = (prefs.getString("Lastname") ?? "");
      UserAcctName = FirstName + " " + LastName;
    });
  }

  void _getShafe() async {
    prefs = await SharedPreferences.getInstance();

    int total = (prefs.getInt('total') ?? 0);
    List<String> arr1=(prefs.getStringList('productID')??new List());
    List<String> arr2=(prefs.getStringList('productCount')??new List());
    List<String> arr4=(prefs.getStringList('favorit')??new List());
    List<String> arr_ser=(prefs.getStringList('productServiceType')??new List());

    setState(() {
      int counter = (prefs.getInt('count') ?? 0);
      counts = counter;

      totalAmount = total;
      proID=arr1;
      isFavorite=arr4;
      proCount=arr2;

      itemsServiceType=arr_ser;
    });
  }

  CupertinoAlertDialog _createCupertinoAlertDialog(mContext) =>
      new CupertinoAlertDialog(
          title: new Text("ยืนยัน?", style: TextStyle(fontFamily: 'Poppins'),),
          content: new Text("ต้องการออกจากระบบ.",
              style: TextStyle(fontFamily: 'Poppins')),
          actions: <Widget>[

            new CupertinoButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: new Text(
                    'ยกเลิก', style: TextStyle(color: cl_text_pro_en,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins'))),
            new CupertinoButton(
                onPressed: () {
                  _clearUserAcct();
                  Navigator.pop(context);
                  Navigator.of(mContext).pushReplacementNamed('/Login');
                },
                child: new Text('ยืนยัน', style: TextStyle(color: Colors.deepOrange,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins'))),
          ]
      );

  void _showDialogLogOut(mContext) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _createCupertinoAlertDialog(mContext);
      },
    );
  }

  void _clearUserAcct() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.remove("CustomerID");
      prefs.remove("BranchID");
      prefs.remove("Firstname");
      prefs.remove("Lastname");
    });
  }

  Future<Null> _refreshBranch() {
    return fetchBranch(BranchID.toString(),Latitude,Longitude).then((data) {
    });
  }
  Future<Null> _refreshProductService() {
    return fetchService().then((data) {
    });
  }

  //fetch branch
  Future<List<_branch.BranchContact>> fetchBranch(BranchID,Latitude,Longitude) async {
    try {
      final paramDic = {
        "BranchID": BranchID,
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
  //fetch branch
  Future<List<_brochure.Brochure>> fetchBrochure(BranchGroupID) async {
    try {
      final paramDic = {
        "BranchGroupID": BranchGroupID,
      };
      http.Response response =
      await http.post(Server().IPAddress + '/data/get/Brochure.php',body: paramDic);
      print(response.body.toString());
      if (response.statusCode == 200) {
        List responseJson = json.decode(response.body);
        return responseJson.map((m) => new _brochure.Brochure.fromJson(m)).toList();
      } else {
        print('Something went wrong. \nResponse Code : ${response.statusCode}');
      }
    } catch (exception) {
      print(exception.toString());
    }
  }

  //test service product
  //fetch service
  Future<List<_service.Service>> fetchService() async {
    try {
      final paramDic = {
        "BranchGroupID": BranchGroupID.toString(),
      };
      http.Response response =
      await http.post(Server().IPAddress + '/data/get/Service.php',body: paramDic);
      if (response.statusCode == 200) {
        List responseJson = json.decode(response.body);
        return responseJson.map((m) => new _service.Service.fromJson(m)).toList();
      } else {
        print('Something went wrong. \nResponse Code : ${response.statusCode}');
      }
    } catch (exception) {
      print(exception.toString());
    }
  }
  //fetch category
  Future<List<_categoryName.Category>> fetchCategory() async {
    try {
      final paramDic = {
        "BranchGroupID": BranchGroupID.toString(),
      };
      http.Response response =
      await http.post(Server().IPAddress + '/data/get/Category.php',body: paramDic);
      List responseJson = json.decode(response.body);
      return responseJson.map((m) => new _categoryName.Category.fromJson(m)).toList();
    }catch (exception) {
      print(exception.toString());
    }
  }

  TextEditingController controller = new TextEditingController();
  List<_product.Product> _searchResult = [];
  List<_product.Product> _branchDetails = [];

  int totalAmount = 0;

  List<String> proID,proCount,isFavorite;
  //fetch product
  Future<List<_product.Product>> fetchProductSer() async {
    try {
      http.Response response;
      List responseJson;
      final body = {
        "BranchGroupID": BranchGroupID.toString(),
      };

      response =
      await http.post(
          Server().IPAddress + '/data/get/pro/Product.php',body: body);
      responseJson = json.decode(response.body);
      /*for (Map user in responseJson) {
        _branchDetails.add(_product.Product.fromJson(user));
      }*/
      return responseJson.map((m) => new _product.Product.fromJson(m)).toList();
    }catch (exception) {
      print(exception.toString());
    }
  }
  //fetch product
  Future<List<_product.Product>> fetchProductCate(id) async {
    //String branchGroupID="1";
    try {
      http.Response response;
      List responseJson;
      response =
      await http.get(Server().IPAddress + '/data/get/cate/Product.php?BranchGroupID=' +
          BranchGroupID.toString()+'&CategoryID='+id.toString());
      responseJson = json.decode(response.body);
      for (Map user in responseJson) {
        _branchDetails.add(_product.Product.fromJson(user));
      }
      return responseJson.map((m) => new _product.Product.fromJson(m)).toList();
    }catch (exception) {
      print(exception.toString());
    }
  }

  getTotalAmount(price,proID,proName,image,color,serviceType,categoryID,rating) {
    setState(() {
      print(serviceType.toString()+", "+itemsServiceType.contains("3").toString());
      if(itemsServiceType.length<=0){
        _putCount(price,proID,proName,image,color,serviceType,categoryID,rating);
        showInSnackBar("เพิ่ม "+proName+" ลงตะกร้าแล้ว.",cl_text_pro_th,false);
      }else if(itemsServiceType.contains("3")==false){
        if(serviceType==3){
          showInSnackBar("ไม่สามารถเลือกสินค้าที่วันนัดรับไม่ตรงกันได้!",Colors.red,true);
        }else{
          _putCount(price,proID,proName,image,color,serviceType,categoryID,rating);
          showInSnackBar("เพิ่ม "+proName+" ลงตะกร้าแล้ว.",cl_text_pro_th,false);
        }
      }else if(itemsServiceType.contains("3")==true){
        if(serviceType==3){
          _putCount(price,proID,proName,image,color,serviceType,categoryID,rating);
          showInSnackBar("เพิ่ม "+proName+" ลงตะกร้าแล้ว.",cl_text_pro_th,false);
        }else{
          showInSnackBar("ไม่สามารถเลือกสินค้าที่วันนัดรับไม่ตรงกันได้!",Colors.red,true);
        }
      }

    });
  }

  _putCount(price,productID,productName,images,color,serviceType,categoryID,rating) async {
    _initPref();
    //print(price.toString()+", "+proID.toString());
    try {
      int counter = (prefs.getInt('count') ?? 0) + 1;
      int total = (prefs.getInt('total') ?? 0) + price;
      counts = counter;
      totalAmount = total;
      await prefs.setInt('count', counter);
      await prefs.setInt('total', totalAmount);


      List<String> itemsID = (prefs.getStringList('productID') ?? new List());
      List<String> itemsCount = (prefs.getStringList('productCount') ??
          new List());
      List<String> itemsService = (prefs.getStringList('productServiceType') ??
          new List());

      /*List<String> itemsID = (prefs.getStringList('productID') ?? new List());
      List<String> itemsName = (prefs.getStringList('productName') ??
          new List());
      List<String> itemsPrice = (prefs.getStringList('productPrice') ??
          new List());
      List<String> itemsImage = (prefs.getStringList('productImage') ??
          new List());
      List<String> itemsCount = (prefs.getStringList('productCount') ??
          new List());
      List<String> itemsColor = (prefs.getStringList('productColor') ??
          new List());
      List<String> itemsService = (prefs.getStringList('productServiceType') ??
          new List());
      List<String> itemsCategory = (prefs.getStringList('productCategoryID') ??
          new List());
      List<String> itemsRating = (prefs.getStringList('productRating') ??
          new List());*/
      int index = itemsID.indexOf(productID.toString());
      if (index != -1) {
        int counts = int.parse(itemsCount[index]) + 1;
        itemsCount[index] = counts.toString();
      } else {
        itemsID.add(productID.toString());
        itemsCount.add(1.toString());
        itemsService.add(serviceType.toString());

        /*itemsID.add(productID.toString());
        itemsCount.add(1.toString());
        itemsName.add(productName.toString());
        itemsPrice.add(price.toString());
        itemsImage.add(images.toString());
        itemsColor.add(color.toString());
        itemsService.add(serviceType.toString());
        itemsCategory.add(categoryID.toString());
        itemsRating.add(rating.toString());*/
      }
      await prefs.setStringList('productID', itemsID);
      await prefs.setStringList('productCount', itemsCount);
      await prefs.setStringList('productServiceType', itemsService);
     /* await prefs.setStringList('productID', itemsID);
      await prefs.setStringList('productCount', itemsCount);
      await prefs.setStringList('productName', itemsName);
      await prefs.setStringList('productImage', itemsImage);
      await prefs.setStringList('productPrice', itemsPrice);
      await prefs.setStringList('productColor', itemsColor);
      await prefs.setStringList('productServiceType', itemsService);
      await prefs.setStringList('productCategoryID', itemsCategory);
      await prefs.setStringList('productRating', itemsRating);*/

      //print(prefs.getStringList('productID').toString()+" , "+prefs.getStringList('productCount').toString());
      proID = itemsID;
      proCount = itemsCount;

      itemsServiceType = itemsService;
    }catch(e){
      print("error: "+e.toString());
    }
  }
  void showInSnackBar(String value,Color color,bool error) {
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: Container(
        height: 40.0,
        child: Center(
          child: new Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontFamily: "Poppins"),
          ),
        ),
      ),
      backgroundColor: color,
      duration: Duration(seconds: 2),
      action: !error?new SnackBarAction(
        textColor: Colors.deepOrange,
        label: 'ไปที่ตะกร้า',
        onPressed: () {
          if (totalAmount == 0) {
            _showDialog('เตือน!', 'คุณยังไม่มีสินค้าในตะกร้า.');
          } else {
            Navigator.of(context)
                .push(
                new MaterialPageRoute(
                    builder: (context) => Cart()))
                .whenComplete(_getRequests);
            //_clearShafe();
          }
        },
      ):null,
    ));
  }
  _getFavorit(productID){
    setState(() {
      _putFavorit(productID);
    });
  }
  _putFavorit(productID) async{
    _initPref();
    //print(productID.toString());
    List<String> itemsID=(prefs.getStringList('favorit')??new List());
    int index = itemsID.indexOf(productID.toString());
    if(index!=-1){
      itemsID.removeAt(index);
    }else {
      itemsID.add(productID.toString());
    }
    await prefs.setStringList('favorit', itemsID);

    isFavorite=itemsID;
  }
  _clearShafe() async {
    setState(() {
      _initPref();
      prefs.clear();
      counts = 0;
      totalAmount=0;
    });
  }
  _initPref() async {
    prefs = await SharedPreferences.getInstance();
  }
  //test search
  String appTitle;
  Widget appBarTitle;
  Icon actionIcon = new Icon(Icons.search, color: HexColor("#667787"),);
  final key = new GlobalKey<ScaffoldState>();
  final TextEditingController _searchQuery = new TextEditingController();
  String _searchText = "";


  setItemClicked(productID){
    //print(proID.contains(productID.toString()));
    return Text( "${proID.contains(productID.toString())==true&&proID.length>0
        ? 'x'+proCount[proID.indexOf(productID.toString())].toString():''}",
      style: TextStyle(/*fontSize: 18.0,*/ color: Colors.white,fontFamily: 'Poppins'),);
  }
  setItemFavorite(productID){
    return isFavorite.contains(productID.toString())==true&&isFavorite.length>0
        ? Icon(Icons.favorite,color: Colors.red,):
    Icon(Icons.favorite_border,color: Colors.red,);
  }

  Widget ratingStack(int rating) => Positioned(
    top: 0.0,
    left: 0.0,
    child: Container(
      padding: EdgeInsets.all(4.0),
      decoration: BoxDecoration(
          color: cl_text_pro_th,
          //color: Colors.red,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(10.0),
              bottomRight: Radius.circular(10.0))),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.date_range,
            color: Colors.white,
            size: 10.0,
          ),
          SizedBox(
            width: 2.0,
          ),
          Text(
            rating.toString() +" วัน",
            style: TextStyle(color: Colors.white, fontSize: 10.0),
          )
        ],
      ),
    ),
  );

  Widget _buildProductSerList(serviceType) {
    final formatter = new NumberFormat("#,###.#");
    return FutureBuilder<List<_product.Product>>(
        future: fetchProductSer(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            // Shows progress indicator until the data is load.
            return new MaterialApp(
              debugShowCheckedModeBanner: false,
              home: new Scaffold(
                //backgroundColor: cl_back,
                body: Center(
                  child: new CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(
                        Colors.deepOrange),),
                ),
              ),
            );
          // Shows the real data with the data retrieved.
          List<_product.Product> product = snapshot.data;
          List<_product.Product> tempList = new List();
          for (int i = 0; i < product.length; i++) {
            if (product[i].ServiceType == serviceType) {
              tempList.add(product[i]);
            }
          }
          product = tempList;

          var size = MediaQuery
              .of(context)
              .size;
          final double itemHeight = (size.height / 3);
          final double itemWidth = size.width / 2;

          if(product.length>0) {
            return Padding(
              padding: const EdgeInsets.only(
                  left: 4.0, right: 4.0, top: 4.0, bottom: 4.0),
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: (itemWidth / itemHeight)),
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                      padding: EdgeInsets.all(5.0),
                      child: GestureDetector(
                        onTap: () {
                          /*getTotalAmount(
                              int.tryParse(product[index].ProductPrice),
                              product[index].ProductID,
                              product[index].ProductNameTH,
                              Server().pathImageFile +
                                  product[index].ImageFile
                                      .substring(
                                      3,
                                      product[index].ImageFile
                                          .length),
                              product[index].ColorCode,
                              product[index].ServiceType,
                              product[index].CategoryID,
                              (product[index].Rating * 5) / 100);*/
                        },
                        child: Container(
                          height: itemHeight/2,
                          padding: EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8.0
                                )
                              ],
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(6.0),
                                topRight: Radius.circular(6.0),
                                bottomLeft: Radius.circular(6.0),
                                bottomRight: Radius.circular(6.0),
                              )
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    height: itemHeight/3,
                                    child: Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: <Widget>[
                                          Expanded(
                                            child: Container(
                                                child: Image.network(
                                                    Server().pathImageFile +
                                                        product[index]
                                                            .ImageFile
                                                            .substring(
                                                            3,
                                                            product[index]
                                                                .ImageFile
                                                                .length),
                                                    fit: BoxFit.contain)
                                            ),
                                          ),
                                          Container(
                                            //child: setItemClicked(product[index].ProductID.toString())
                                              child: GestureDetector(
                                                onTap: () {
                                                  _getFavorit(product[index]
                                                      .ProductID);
                                                  //showInSnackBar('เลือก '+product[index].ProductID.toString()+" เป็นสินค้าที่ชื่นชอบแล้ว.");
                                                },
                                                child: setItemFavorite(
                                                    product[index].ProductID),
                                              )
                                            //child: data[index].fav ? Icon(Icons.favorite,size: 20.0,color: Colors.red,) : Icon(Icons.favorite_border,size: 20.0,),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: Container(
                                        /*margin: new EdgeInsets.symmetric(
                                            vertical: 4.0),*/
                                        height: 1.0,
                                        width: (itemWidth * 70) / 100,
                                        color: new HexColor(
                                            product[index].ColorCode)
                                    ),
                                  ),
                                  SizedBox(height: 10.0,),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: Text(
                                      "${product[index].ProductNameTH.length <
                                          13
                                          ? product[index].ProductNameTH
                                          : product[index].ProductNameTH
                                          .substring(
                                          0, 12) + '...'}",
                                      style: TextStyle(color: cl_text_pro_th,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16.0,
                                          fontFamily: 'Poppins'),),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceBetween,
                                      children: <Widget>[
                                        new StarRating(
                                            size: 15.0,
                                            rating: (product[index].Rating *
                                                5) / 100,
                                            color: Colors.yellow.shade700,
                                            borderColor: Colors.grey,
                                            starCount: 5
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              right: 10.0),
                                          child: Text(
                                            "\฿${formatter.format(int.parse(
                                                product[index]
                                                    .ProductPrice))}",
                                            style: TextStyle(
                                                color: cl_text_pro_en,
                                                fontSize: 16.0,
                                                //fontWeight: FontWeight.w500,
                                                fontFamily: 'Poppins'),),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left:8.0,right:8.0),
                                    child: Center(
                                      child: ButtonTheme(
                                        //minWidth: 80.0,
                                        height: (itemHeight*17)/100,
                                        buttonColor: Colors.cyan,
                                        splashColor: Colors.deepOrange,
                                        child: RaisedButton(
                                            onPressed: () {
                                              getTotalAmount(
                                                  int.tryParse(product[index].ProductPrice),
                                                  product[index].ProductID,
                                                  product[index].ProductNameTH,
                                                  Server().pathImageFile +
                                                      product[index].ImageFile
                                                          .substring(
                                                          3,
                                                          product[index].ImageFile
                                                              .length),
                                                  product[index].ColorCode,
                                                  product[index].ServiceType,
                                                  product[index].CategoryID,
                                                  (product[index].Rating * 5) / 100);
                                            },
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                Text('เพิ่มลง',style: new TextStyle(
                                                  //fontSize: 18,
                                                    fontFamily: 'Poppins',
                                                    color: Colors.white
                                                ),),
                                                Icon(Icons.shopping_cart,size: 18.0,color: Colors.white,),
                                                setItemClicked(
                                                    product[index].ProductID
                                                        .toString()),
                                              ],
                                            )
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              ratingStack(
                                  product[index].ServiceType != 3 ? 3 : 7),
                            ],
                          ),
                        ),
                      )
                  );
                },
                itemCount: product.length,
              ),
            );
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
        }
    );
  }

  Widget _buildProductCateList(categoeyID) {
    final formatter = new NumberFormat("#,###.#");
    return FutureBuilder<List<_product.Product>>(
        future: fetchProductSer(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            // Shows progress indicator until the data is load.
            return new MaterialApp(
              debugShowCheckedModeBanner: false,
              home: new Scaffold(
                //backgroundColor: cl_back,
                body: new Center(
                  child: new CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(
                        Colors.deepOrange),),
                ),
              ),
            );
          // Shows the real data with the data retrieved.
          List<_product.Product> product = snapshot.data;
          List<_product.Product> tempList = new List();
          for (int i = 0; i < product.length; i++) {
            if (product[i].CategoryID == categoeyID) {
              tempList.add(product[i]);
            }
          }
          //print(categoeyID.toString());
          product = tempList;

          var size = MediaQuery
              .of(context)
              .size;

          final double itemHeight = size.height / 3;
          final double itemWidth = size.width / 2;

          if(product.length>0) {
            return Padding(
              padding: const EdgeInsets.only(
                  left: 4.0, right: 4.0, top: 4.0, bottom: 4.0),
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: (itemWidth / itemHeight)),
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.all(5.0),
                    child: GestureDetector(
                      onTap: () {
                        /*getTotalAmount(
                            int.tryParse(product[index].ProductPrice),
                            product[index].ProductID,
                            product[index].ProductNameTH,
                            Server().pathImageFile +
                                product[index].ImageFile
                                    .substring(
                                    3,
                                    product[index].ImageFile
                                        .length),
                            product[index].ColorCode,
                            product[index].ServiceType,
                            product[index].CategoryID,
                            (product[index].Rating * 5) / 100);*/
                      },
                      child: Container(
                        height: itemHeight/2,
                        padding: EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8.0
                              )
                            ],
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(6.0),
                              topRight: Radius.circular(6.0),
                              bottomLeft: Radius.circular(6.0),
                              bottomRight: Radius.circular(6.0),
                            )
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  height: itemHeight/3,
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                              child: Image.network(
                                                  Server().pathImageFile +
                                                      product[index].ImageFile
                                                          .substring(
                                                          3,
                                                          product[index]
                                                              .ImageFile
                                                              .length),
                                                  fit: BoxFit.contain)
                                          ),
                                        ),
                                        Container(
                                          child: GestureDetector(
                                            onTap: () {
                                              _getFavorit(
                                                  product[index].ProductID);
                                            },
                                            child: setItemFavorite(
                                                product[index].ProductID),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: Container(
                                      /*margin: new EdgeInsets.symmetric(
                                          vertical: 4.0),*/
                                      height: 1.0,
                                      width: (itemWidth * 70) / 100,
                                      color: new HexColor(
                                          product[index].ColorCode)
                                  ),
                                ),
                                SizedBox(height: 10.0,),
                                Padding(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: Text(
                                    "${product[index].ProductNameTH.length < 13
                                        ? product[index].ProductNameTH
                                        : product[index].ProductNameTH
                                        .substring(
                                        0, 12) + '...'}",
                                    style: TextStyle(color: cl_text_pro_th,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16.0,
                                        fontFamily: 'Poppins'),),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: <Widget>[
                                      new StarRating(
                                          size: 15.0,
                                          rating: (product[index].Rating * 5) /
                                              100,
                                          color: Colors.yellow.shade800,
                                          borderColor: Colors.grey,
                                          starCount: 5
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(right: 10.0),
                                        child: Text(
                                          "\฿${formatter.format(int.parse(
                                              product[index].ProductPrice))}",
                                          style: TextStyle(
                                              color: cl_text_pro_en,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Poppins'),),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left:8.0,right:8.0),
                                  child: Center(
                                    child: ButtonTheme(
                                      //minWidth: 80.0,
                                      height: (itemHeight*17)/100,
                                      buttonColor: Colors.cyan,
                                      splashColor: Colors.deepOrange,
                                      child: RaisedButton(
                                          onPressed: () {
                                            getTotalAmount(
                                                int.tryParse(product[index].ProductPrice),
                                                product[index].ProductID,
                                                product[index].ProductNameTH,
                                                Server().pathImageFile +
                                                    product[index].ImageFile
                                                        .substring(
                                                        3,
                                                        product[index].ImageFile
                                                            .length),
                                                product[index].ColorCode,
                                                product[index].ServiceType,
                                                product[index].CategoryID,
                                                (product[index].Rating * 5) / 100);
                                          },
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Text('เพิ่มลง',style: new TextStyle(
                                                //fontSize: 18,
                                                  fontFamily: 'Poppins',
                                                  color: Colors.white
                                              ),),
                                              Icon(Icons.shopping_cart,size: 18.0,color: Colors.white,),
                                              setItemClicked(
                                                  product[index].ProductID
                                                      .toString()),
                                            ],
                                          )
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            ratingStack(
                                product[index].ServiceType != 3 ? 3 : 7),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                itemCount: product.length,
              ),
            );
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
        }
    );
  }

  //end service product

  @override
  Widget build(BuildContext context) {
    final formatter = new NumberFormat("#,###.##");
    var size = MediaQuery
        .of(context)
        .size;
    final makeBottom = new Container(
      //margin: EdgeInsets.only(bottom: 18.0),
        height: 65.0,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
                top: BorderSide(color: Colors.grey[300], width: 1.0)
            )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  Container(
                    width: 60.0,
                    child: Text("รวมเงิน :",
                      style: TextStyle(fontSize: 14.0, color: cl_text_pro_en),),
                  ),
                  Text('\$' + formatter.format(totalAmount),
                      style: TextStyle(color: cl_text_pro_th,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins')),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 60.0,
                    child: Text("รวมจำนวน :",
                      style: TextStyle(fontSize: 14.0, color: cl_text_pro_en),),
                  ),
                  Text('x' + counts.toString(),
                      style: TextStyle(color: cl_text_pro_th,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins')),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                height: 65.0,
                width: size.width/3,
                child: RaisedButton(
                  color: Colors.deepOrange,
                  onPressed: () {
                    if (totalAmount == 0) {
                      _showDialog('เตือน!', 'คุณยังไม่มีสินค้าในตะกร้า.');
                    } else {
                      Navigator.of(context)
                          .push(
                          new MaterialPageRoute(
                              builder: (context) => Cart()))
                          .whenComplete(_getRequests);
                      //_clearShafe();
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 14.0,right: 14.0),
                        child: Text(
                          'ตะกร้า',
                          style: new TextStyle(
                              fontSize: 18,
                              fontFamily: 'Poppins',
                              color: Colors.white
                          ),
                        ),
                      ),
                      /*BadgeIconButton(
                          itemCount: counts,
                          badgeColor: Colors.white,
                          badgeTextColor: Colors.deepOrange,
                          icon: Icon(Icons.shopping_cart, color: Colors.white,),
                          onPressed: () {
                            if (totalAmount == 0) {
                              _showDialog('เตือน!', 'คุณยังไม่มีสินค้าในตะกร้า.');
                            } else {
                              Navigator.of(context)
                                  .push(
                                  new MaterialPageRoute(
                                      builder: (context) => Cart()))
                                  .whenComplete(_getRequests);
                              //_clearShafe();
                            }
                          }),*/
                    ],
                  ),
                ),
              ),
            ),

          ],
        )
    );
    final _makeBodyProductService = FutureBuilder<List<_service.Service>>(
        future: fetchService(),
        builder: (context, snapshot) {
          //print("statusCode : " + snapshot.hasData.toString());
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
          List<_service.Service> service = snapshot.data;
          return RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _refreshProductService,
              child: DefaultTabController(
                length: service.length,
                child: Scaffold(
                  appBar: TabBar(
                    indicatorColor: Color(0xFF0091bb),
                    isScrollable: true,
                    labelStyle: new TextStyle(
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        color: Colors.white
                    ),
                    tabs: service.map((_service.Service service) {
                      return Tab(
                        text: service.ServiceNameTH,
                        icon: SizedBox(
                          height: 32.0,
                          width: 32.0,
                          child: Image.network(
                            'http://119.59.115.80/cleanmate_god_test/' +
                                service.ImageFile.substring(
                                    3, service.ImageFile.length),
                            fit: BoxFit.cover, color: cl_text_pro_en,),
                        ),
                      );
                    }).toList(),
                  ),
                  body: TabBarView(
                    children: service.map((_service.Service service) {
                      return Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 4.0, left: 4.0, right: 4.0),
                                child: new Card(
                                  //color: cl_back,
                                  /*child: new ListTile(
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
                              ),*/
                                ),
                              ),
                            ),
                            Expanded(
                              child: _buildProductSerList(service.ServiceType),
                            ),

                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  bottomNavigationBar: makeBottom,
                ),
              ),
              );
        }
    );
    final _makeBodyProductCategory = FutureBuilder<List<_categoryName.Category>>(
        future: fetchCategory(),
        builder: (context, snapshot) {
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
          List<_categoryName.Category> service = snapshot.data;
          return DefaultTabController(
            length: service.length,
            child: Scaffold(
              appBar: TabBar(
                indicatorColor: Color(0xFF0091bb),
                isScrollable: true,
                labelStyle: new TextStyle(
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    color: Colors.white
                ),
                tabs: service.map((_categoryName.Category service) {
                  return Tab(
                    text: service.CategoryNameTH,
                  );
                }).toList(),
              ),
              body: TabBarView(
                children: service.map((_categoryName.Category cate) {
                  return Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child:  _buildProductCateList(cate.CategoryID),
                        ),

                      ],
                    ),
                  );
                }).toList(),
              ),
              bottomNavigationBar: makeBottom,
            ),
          );
        }
    );

    return new WillPopScope(
      onWillPop: () async {
        _showDialogLogOut(context);
      }, child: new Scaffold(
      //App Bar
      key: _scaffoldKey,
      appBar: new AppBar(
        automaticallyImplyLeading: false,
        leading: new BadgeIconButton(
            itemCount: isFavorite.length,
            badgeColor: Colors.deepOrange,
            badgeTextColor: Colors.white,
            icon: Icon(Icons.favorite_border, color: cl_text_pro_en,),
            onPressed: () {
              Navigator.of(context)
                  .push(
                  new MaterialPageRoute(
                      builder: (context) => FavoriteProduct()))
                  .whenComplete(_getRequests);
            }
        ),
        actions: <Widget>[
          Builder(
            builder: (context) =>
                BadgeIconButton(
                    itemCount: 0,
                    badgeColor: Colors.deepOrange,
                    badgeTextColor: Colors.white,
                    icon: Icon(Icons.search, color: cl_text_pro_en,),
                    onPressed: () {
                      Navigator.of(context)
                          .push(
                          new MaterialPageRoute(
                              builder: (context) => SearchProduct()))
                          .whenComplete(_getRequests);
                    }
                ),
          ),
          Builder(
            builder: (context) =>
                Padding(padding: EdgeInsets.only(),
                  child: BadgeIconButton(
                      itemCount: counts,
                      badgeColor: Colors.deepOrange,
                      badgeTextColor: Colors.white,
                      icon: Icon(Icons.shopping_cart,
                        color: cl_text_pro_en,),
                      onPressed: () {
                        if (counts == 0) {
                          _showDialog('เตือน!', 'คุณยังไม่มีสินค้าในตะกร้า.');
                        }
                        else {
                          Navigator.of(context)
                              .push(
                              new MaterialPageRoute(
                                  builder: (context) => Cart()))
                              .whenComplete(_getRequests);
                        }
                      }
                  ),
                ),
          ),
          /*Builder(
            builder: (context) =>
                Padding(padding: EdgeInsets.only(right: 8.0),
                  child: BadgeIconButton(
                      itemCount: counts,
                      badgeColor: Colors.deepOrange,
                      badgeTextColor: Colors.white,
                      icon: Icon(Icons.notifications,
                        color: cl_text_pro_en,),
                      onPressed: () {
                        if (counts == 0) {
                          _showDialog('เตือน!', 'คุณยังไม่มีสินค้าในตะกร้า.');
                        }
                        else {
                          Navigator.of(context)
                              .push(
                              new MaterialPageRoute(
                                  builder: (context) => Cart()))
                              .whenComplete(_getRequests);
                        }
                      }
                  ),
                ),
          ),*/
        ],
        //backgroundColor: cl_back,
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: new Text(
          _title_app,
          style: new TextStyle(
              fontSize: 18,
              fontFamily: 'Poppins',
              color: cl_text_pro_th
          ),
        ),
      ),

      //Content of tabs
      body: PageView(
        controller: _tabController,
        onPageChanged: onTabChanged,
        children: <Widget>[
          _branchPage(),
          _makeBodyProductService,
          _makeBodyProductCategory,
          //_profilePage(),
          _otherPage(),
        ],
      ),
      //Tabs
      bottomNavigationBar: Theme
          .of(context)
          .platform == TargetPlatform.iOS ?
      new CupertinoTabBar(
        activeColor: Colors.cyan,
        inactiveColor: cl_text_pro_en,
        currentIndex: _tab,
        onTap: onTap,
        items: TabItems.map((TabItem) {
          return new BottomNavigationBarItem(
            title: new Text(TabItem.title),
            icon: new Icon(TabItem.icon),
          );
        }).toList(),
      ) :
      Container(
        height: 60.0,
        width: double.infinity,

        child: new CupertinoTabBar(
          activeColor: Color(0xFF0091bb),
          inactiveColor: cl_text_pro_en,
          currentIndex: _tab,
          onTap: onTap,
          items: TabItems.map((TabItem) {
            return new BottomNavigationBarItem(
              backgroundColor: Colors.white,
              title: new Text(TabItem.title),
              icon: new Icon(TabItem.icon),
            );
          }).toList(),
        ),
      ),
    ),
    );
  }

  void onTap(int tab) {
    _tabController.jumpToPage(tab);
  }

  void onTabChanged(int tab) {
    setState(() {
      this._tab = tab;
    });

    switch (tab) {
      case 0:
        this._title_app = TabItems[0].title;
        break;

      case 1:
        this._title_app = TabItems[1].title;
        break;

      case 2:
        this._title_app = TabItems[2].title;
        break;
      case 3:
        this._title_app = TabItems[3].title;
        break;
    }
  }


  //branch_page
  Widget _branchPage() {
    return FutureBuilder<List<_branch.BranchContact>>(
        future: fetchBranch(BranchID.toString(),Latitude,Longitude),
        builder: (context, snapshot) {
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

          List<_branch.BranchContact> branch = snapshot.data;
          var size = MediaQuery
              .of(context)
              .size;
          final double itemHeight = (size.height * 80) / 100;

          if(branch.length>0){
            return RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _refreshBranch,
              child: Container(
                child: new SingleChildScrollView(
                  child: new Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Container(
                            height: size.height/1.5,
                            width: double.infinity,
                            child: Stack(
                              children: <Widget>[
                                SizedBox(
                                  height: itemHeight,
                                  width: double.infinity,
                                  child: new Carousel(
                                    boxFit: BoxFit.contain,
                                    images: arrImg,
                                    animationCurve: Curves.fastOutSlowIn,
                                    animationDuration: Duration(seconds: 1),
                                    dotSize: 4.0,
                                    dotSpacing: 15.0,
                                    dotColor: cl_text_pro_th,
                                    indicatorBgPadding: 2.0,
                                    dotBgColor: Colors.transparent,
                                    //borderRadius: true,
                                  ),
                                ),
                                /*Positioned(
                                  left: -25,
                                  child: Container(
                                    width: 50.0,
                                    height: size.height/1.8,
                                    decoration: BoxDecoration(
                                        color: cl_text_pro_th,
                                        *//*image: new DecorationImage(
                                          image: new AssetImage("assets/images/bg.jpg"),
                                          fit: BoxFit.cover,
                                        ),*//*
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(30.0),
                                            bottomRight: Radius.circular(30.0))),
                                  ),
                                ),
                                Positioned(
                                  right: -25,
                                  child: Container(
                                    width: 50.0,
                                    height: size.height/1.8,
                                    decoration: BoxDecoration(
                                        color: cl_text_pro_th,
                                        *//*image: new DecorationImage(
                                          image: new AssetImage("assets/images/bg.jpg"),
                                          fit: BoxFit.contain,
                                        ),*//*
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(30.0),
                                            bottomLeft: Radius.circular(30.0))),
                                  ),
                                ),*/
                              ],
                            ),
                          )
                        ],
                      ),
                      new Container(
                        //margin: EdgeInsets.only(left: 4.0,right: 4.0),
                          height: 50.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                  top: BorderSide(
                                      color: Colors.grey[300], width: 1.0),
                                  bottom: BorderSide(
                                      color: Colors.grey[300], width: 1.0)
                              )
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.only(
                                            left: 12.0, top: 8.0, bottom: 8.0),
                                        child: Row(
                                          children: <Widget>[
                                            new Icon(FontAwesomeIcons.store,
                                              color: Color(0xFF0091bb),),
                                            new Padding(
                                              padding: EdgeInsets.only(left: 12.0),
                                              child: Text("ข้อมูลสาขา",
                                                style: TextStyle(fontSize: 16.0,
                                                    color: Colors.deepOrange,
                                                    fontWeight: FontWeight.bold),),)
                                          ],
                                        )

                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                      ),
                      new Padding(
                        padding: EdgeInsets.only(
                            left: 24.0, right: 22.0, top: 16.0, bottom: 4.0),
                        child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 22.0),
                              child: Container(
                                child: Text('ชื่อสาขา:',
                                    style: TextStyle(color: cl_text_pro_th,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Poppins')
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Container(
                                child: Text(branch[0].BranchNameTH,
                                    style: TextStyle(color: cl_text_pro_th,
                                        fontSize: 16.0,
                                        fontFamily: 'Poppins')
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      new Padding(
                        padding: EdgeInsets.only(
                            left: 24.0, right: 22.0, top: 4.0, bottom: 4.0),
                        child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 22.0),
                              child: Container(
                                child: Text('รหัสสาขา:',
                                    style: TextStyle(color: cl_text_pro_th,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Poppins')
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Container(
                                child: Text(branch[0].BranchCode,
                                    style: TextStyle(color: cl_text_pro_th,
                                        fontSize: 16.0,
                                        fontFamily: 'Poppins')
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      new Padding(
                        padding: EdgeInsets.only(
                            left: 24.0, right: 22.0, top: 4.0, bottom: 4.0),
                        child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 22.0),
                              child: Container(
                                child: Text('เจ้าของร้าน:',
                                    style: TextStyle(color: cl_text_pro_th,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Poppins')
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Container(
                                child: Text(
                                    branch[0].Contact.length > 18 ? branch[0]
                                        .Contact.substring(0, 18) + '..' : branch[0]
                                        .Contact,
                                    style: TextStyle(color: cl_text_pro_th,
                                        fontSize: 16.0,
                                        fontFamily: 'Poppins')
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      new Padding(
                        padding: EdgeInsets.only(
                            left: 24.0, right: 22.0, top: 4.0, bottom: 4.0),
                        child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 22.0),
                              child: Container(
                                child: Text('ที่อยู่ :',
                                    style: TextStyle(color: cl_text_pro_th,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Poppins')
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Container(
                                child: Text(
                                    branch[0].Address.length != 0
                                        ? branch[0]
                                        .Address.substring(0, 18) + '..'
                                        : 'ไม่ได้ระบุ',
                                    style: TextStyle(color: cl_text_pro_th,
                                        fontSize: 16.0,
                                        fontFamily: 'Poppins')
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      new Padding(
                        padding: EdgeInsets.only(
                            left: 24.0, right: 22.0, top: 4.0, bottom: 4.0),
                        child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 22.0),
                              child: Container(
                                child: Text('เขต:',
                                    style: TextStyle(color: cl_text_pro_th,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Poppins')
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Container(
                                child: Text(branch[0].CityName,
                                    style: TextStyle(color: cl_text_pro_th,
                                        fontSize: 16.0,
                                        fontFamily: 'Poppins')
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      new Padding(
                        padding: EdgeInsets.only(
                            left: 24.0, right: 22.0, top: 4.0, bottom: 12.0),
                        child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 22.0),
                              child: Container(
                                child: Text('เบอร์ติดต่อ:',
                                    style: TextStyle(color: cl_text_pro_th,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Poppins')
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Container(
                                child: Text(branch[0].TelephoneNo,
                                    style: TextStyle(color: cl_text_pro_th,
                                        fontSize: 16.0,
                                        fontFamily: 'Poppins')
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
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
        }
    );
  }

  //profile_page
  Widget _profilePage(){
    return new Container(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new Icon(
              Icons.settings,
              size: 150.0,
              color: Colors.black12
          ),
          new Text('Settings tab content')
        ],
      ),
    );
  }

  //other_page
  Widget _otherPage() {
    var size = MediaQuery
        .of(context)
        .size;

    return new SingleChildScrollView(
      child: Container(
        child: Container(
          child: new Column(
            //crossAxisAlignment: CrossAxisAlignment.center,
            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Padding(
                padding: EdgeInsets.only(
                    top: 0.0, left: 38.0, right: 38.0, bottom: 22.0),
                child: new Image(
                    fit: BoxFit.cover,
                    image: new AssetImage(
                        'assets/images/logo_smart.png')),
              ),
              new Container(
                  margin: EdgeInsets.only(left: 32, right: 32),
                  //height: size.height / 2.5,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border(
                          top: BorderSide(color: Colors.grey[300], width: 1.0),
                          bottom: BorderSide(
                              color: Colors.grey[300], width: 1.0)
                      )
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Row(
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                                child: Row(
                                  children: <Widget>[
                                    new Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Text("บัญชีของฉัน",
                                        style: TextStyle(fontSize: 18.0,
                                            color: cl_text_pro_th,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold),),)
                                  ],
                                )

                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 6.0),
                        child: FlatButton(
                          onPressed: () {
                            Navigator.of(context)
                                .push(
                                new MaterialPageRoute(builder: (context) =>
                                    ProfileSetting(CustomerID: CustomerID,AccountName: UserAcctName,)))
                                .whenComplete(_getRequests);
                          }, child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            new Padding(padding: EdgeInsets.only(right: 12.0, left: 22.0),
                              child: Icon(
                                FontAwesomeIcons.user, color: cl_text_pro_en,
                                size: 22,),),
                            new Text(UserAcctName,
                                style: TextStyle(
                                  color: cl_text_pro_th, fontFamily: 'Poppins',
                                  decoration: TextDecoration.underline,
                                  fontSize: 16.0,)),
                          ],
                        ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 6.0),
                        child: FlatButton(
                          onPressed: () {
                            Navigator.of(context)
                                .push(
                                new MaterialPageRoute(builder: (context) =>
                                    MyBranchContact(BranchID: BranchID)))
                                .whenComplete(_getRequests);
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Padding(
                                padding: EdgeInsets.only(
                                    right: 12.0, left: 22.0),
                                child: Icon(
                                  FontAwesomeIcons.storeAlt,
                                  color: cl_text_pro_en,
                                  size: 22,),),
                              Text(
                                "สาขาของคุณ",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: cl_text_pro_th,
                                  fontFamily: 'Poppins',
                                  fontSize: 16.0,),
                              ),
                            ],
                          ),),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 6.0),
                        child: FlatButton(
                          onPressed: () {
                            Navigator.of(context)
                                .push(
                                new MaterialPageRoute(builder: (context) =>
                                    Tracking(CustomerID: CustomerID,)))
                                .whenComplete(_getRequests);
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Padding(
                                padding: EdgeInsets.only(
                                    right: 12.0, left: 22.0),
                                child: Icon(
                                  FontAwesomeIcons.clipboardList,
                                  color: cl_text_pro_en,
                                  size: 22,),),
                              Text(
                                "รายการของคุณ",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: cl_text_pro_th,
                                  fontFamily: 'Poppins',
                                  fontSize: 16.0,),
                              ),
                            ],
                          ),),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 0.0,bottom: 22.0),
                        child: FlatButton(
                          onPressed: () {
                            Navigator.of(context)
                                .push(
                                new MaterialPageRoute(builder: (context) =>
                                    History(CustomerID: CustomerID,)))
                                .whenComplete(_getRequests);
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Padding(
                                padding: EdgeInsets.only(
                                    right: 12.0, left: 22.0),
                                child: Icon(
                                  FontAwesomeIcons.history,
                                  color: cl_text_pro_en,
                                  size: 22,),),
                        Padding(
                          padding: EdgeInsets.only(top:6.0),
                          child:Text(
                            "ประวัติการทำรายการของคุณ",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: cl_text_pro_th,
                              fontFamily: 'Poppins',
                              fontSize: 16.0,),
                          ),
                        ),

                            ],
                          ),),
                      ),
                    ],
                  )
              ),

              new Container(
                  margin: EdgeInsets.only(left: 32, right: 32),
                  //height: size.height / 4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border(
                          //top: BorderSide(color: Colors.grey[300], width: 1.0),
                          bottom: BorderSide(
                              color: Colors.grey[300], width: 1.0)
                      )
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Row(
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                                child: Row(
                                  children: <Widget>[
                                    new Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Text("ตั้งค่า",
                                        style: TextStyle(fontSize: 18.0,
                                            color: cl_text_pro_th,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold),),)
                                  ],
                                )
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 0.0),
                        child: FlatButton(
                          onPressed: () {
                            Navigator.of(context)
                                .push(
                                new MaterialPageRoute(builder: (context) =>
                                    SelectBranch(
                                      CustomerID: CustomerID.toString(),
                                      IsPage: "Home",)))
                                .whenComplete(_getRequests);
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Padding(
                                padding: EdgeInsets.only(
                                    right: 12.0, left: 22.0),
                                child: Icon(
                                  FontAwesomeIcons.storeAlt,
                                  color: cl_text_pro_en,
                                  size: 22,),),
                              Text(
                                "เปลี่ยนสาขาที่ใช้บริการ",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: cl_text_pro_th,
                                  fontFamily: 'Poppins',
                                  fontSize: 16.0,),
                              ),
                            ],
                          ),),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 22.0,bottom: 18.0),
                        child: FlatButton(
                          onPressed: () {
                            // _showDialogLogOut(context);
                            Navigator.of(context)
                                .push(
                                new MaterialPageRoute(builder: (context) =>
                                    ChangeLanguage(
                                      Language: "ภาษาไทย",)))
                                .whenComplete(_getRequests);
                          }, child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[

                            Row(
                              children: <Widget>[
                                new Padding(
                                  padding: EdgeInsets.only(right: 12.0),
                                  child: Icon(FontAwesomeIcons.globeAsia,
                                    color: cl_text_pro_en,
                                    size: 22,),),
                                new Text('ภาษา',
                                    style: TextStyle(color: cl_text_pro_th,
                                      fontFamily: 'Poppins',
                                      decoration: TextDecoration.underline,
                                      fontSize: 16.0,)),
                                new Container(
                                  padding: EdgeInsets.only(left:8.0),
                                  height: 38.0,
                                  width: 38.0,
                                  child: new Image(
                                      fit: BoxFit.contain,
                                      image: new AssetImage(
                                          'assets/images/lang_thai.png')),
                                )
                              ],
                            ),
                          ],
                        ),),
                      ),
                    ],
                  )
              ),
              new Padding(
                padding: EdgeInsets.only(top: 10.0, left: 28.0),
                child: FlatButton(
                  onPressed: () {
                    _showDialogLogOut(context);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      new Padding(padding: EdgeInsets.only(right: 12.0),
                        child: Icon(
                          FontAwesomeIcons.signOutAlt, color: cl_text_pro_en,
                          size: 22,),),
                      Text(
                        "ออกจากระบบ",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: cl_text_pro_th,
                          fontSize: 16.0,),
                      ),
                    ],
                  ),),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TabItem {
  const TabItem({ this.title, this.icon });
  final String title;
  final IconData icon;
}

const List<TabItem> TabItems = const <TabItem>[
  const TabItem(title: 'หน้าหลัก', icon: Icons.home),
  const TabItem(title: 'บริการ', icon: Icons.local_laundry_service),
  const TabItem(title: 'หมวดหมู่', icon: Icons.category),
  //const TabItem(title: 'Profile', icon: FontAwesomeIcons.userAlt),
  const TabItem(title: 'ฉัน', icon: Icons.menu)
];

