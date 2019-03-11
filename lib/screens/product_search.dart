import 'package:badges/badges.dart';
import 'package:cleanmate_customer_app/screens/cart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:cleanmate_customer_app/Server/server.dart';
import 'package:cleanmate_customer_app/data/Service.dart' as _service;
import 'package:cleanmate_customer_app/data/Product.dart' as _product;
import 'package:flutter_rating/flutter_rating.dart';
import 'package:cleanmate_customer_app/colorCode/HexColor.dart';
import 'package:intl/intl.dart';
import 'package:money/money.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cleanmate_customer_app/alert/messageAlert.dart' as _message;


class SearchProduct extends StatefulWidget {
  @override
  _SearchProductState createState() => new _SearchProductState();
}
class _SearchProductState extends State<SearchProduct> {

  Color cl_bar = HexColor("#18b4ed");
  Color cl_back=HexColor("#e9eef4");
  Color cl_card=HexColor("#ffffff");
  Color cl_text_pro_th = HexColor("#1d313a");
  Color cl_text_pro_en = HexColor("#667787");
  Color cl_cart=HexColor("#e64d3f");
  Color cl_line_ver=HexColor("#677787");
  Color cl_favorite=HexColor("#e44b3b");

  TextEditingController controller = new TextEditingController();
  List<_product.Product> _searchResult = [];
  List<_product.Product> _branchDetails = [];

  SharedPreferences prefs;
  int totalAmount = 0;
  int counts=0;
  int BranchGroupID;

  List<String> proID,proCount,isFavorite;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<String> itemsServiceType=[];

  //fetch product
  Future<List<_product.Product>> fetchProduct() async {
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
    int counter = (prefs.getInt('count') ?? 0) + 1;
    int total = (prefs.getInt('total') ?? 0) + price;
    counts=counter;
    totalAmount = total;
    await prefs.setInt('count', counter);
    await prefs.setInt('total', totalAmount);


    List<String> itemsID = (prefs.getStringList('productID') ?? new List());
    List<String> itemsCount = (prefs.getStringList('productCount') ??
        new List());
    List<String> itemsService = (prefs.getStringList('productServiceType') ??
        new List());
    /*List<String> itemsID=(prefs.getStringList('productID')??new List());
    List<String> itemsName=(prefs.getStringList('productName')??new List());
    List<String> itemsPrice=(prefs.getStringList('productPrice')??new List());
    List<String> itemsImage=(prefs.getStringList('productImage')??new List());
    List<String> itemsCount=(prefs.getStringList('productCount')??new List());
    List<String> itemsColor=(prefs.getStringList('productColor')??new List());
    List<String> itemsService=(prefs.getStringList('productServiceType')??new List());
    List<String> itemsCategory=(prefs.getStringList('productCategoryID')??new List());
    List<String> itemsRating=(prefs.getStringList('productRating')??new List());*/
    int index = itemsID.indexOf(productID.toString());
    if(index!=-1){
      int counts=int.parse(itemsCount[index])+1;
      itemsCount[index]=counts.toString();
    }else{
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
    /*await prefs.setStringList('productID', itemsID);
    await prefs.setStringList('productCount', itemsCount);
    await prefs.setStringList('productName', itemsName);
    await prefs.setStringList('productImage', itemsImage);
    await prefs.setStringList('productPrice', itemsPrice);
    await prefs.setStringList('productColor', itemsColor);
    await prefs.setStringList('productServiceType', itemsService);
    await prefs.setStringList('productCategoryID', itemsCategory);
    await prefs.setStringList('productRating', itemsRating);*/

    proID=itemsID;
    proCount=itemsCount;
    itemsServiceType=itemsService;
  }
  _getShafe() async{
    prefs = await SharedPreferences.getInstance();
    int counter = (prefs.getInt('count') ?? 0);
    int total = (prefs.getInt('total') ?? 0);
    List<String> arr1=(prefs.getStringList('productID')??new List());
    List<String> arr2=(prefs.getStringList('productCount')??new List());
    List<String> arr4=(prefs.getStringList('favorit')??new List());

    List<String> arr_ser=(prefs.getStringList('productServiceType')??new List());
    BranchGroupID = (prefs.getInt("BranchGroupID") ?? 0);
    setState(() {
      counts = counter;
      totalAmount = total;
      proID=arr1;
      proCount=arr2;
      isFavorite=arr4;
      itemsServiceType=arr_ser;
    });
  }
  _initPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    //print("state");
    _getShafe();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
  _getRequests()async{
    _getShafe();
  }

  setItemFavorite(productID){
    return isFavorite.contains(productID.toString())==true&&isFavorite.length>0
        ? Icon(Icons.favorite,color: Colors.red,):
    Icon(Icons.favorite_border,color: Colors.red,);
  }
  _getFavorit(productID){
    setState(() {
      _putFavorit(productID);
    });
  }
  _putFavorit(productID) async{
    _initPref();
    print(productID.toString());
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

  void _showDialog() {
    _message.Message('แจ้งเตือน!','คุณยังไม่มีรายการในตะกร้าสินค้า.',context,null,2);
  }

  Widget ratingStack(int rating) =>
      Positioned(
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
                rating.toString() + " วัน",
                style: TextStyle(color: Colors.white, fontSize: 10.0),
              )
            ],
          ),
        ),
      );

  Widget _buildUsersList() {
    final formatter = new NumberFormat("#,###.#");
    return FutureBuilder<List<_product.Product>>(
        future: fetchProduct(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            // Shows progress indicator until the data is load.
            return new MaterialApp(
                debugShowCheckedModeBanner: false,
                home: new Scaffold(
                  //backgroundColor: cl_back,
                  body: Center(
                    child: new CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),),
                  ),
                ),
            );
          // Shows the real data with the data retrieved.
          List<_product.Product> product = snapshot.data;
          if (!(_searchText.isEmpty)) {
            List<_product.Product> tempList = new List();
            for (int i = 0; i < product.length; i++) {
              if (product[i].ProductNameTH.toLowerCase().contains(
                  _searchText.toLowerCase())) {
                tempList.add(product[i]);
              }
            }
            product = tempList;
          }

          var size = MediaQuery
              .of(context)
              .size;
          /*24 is for notification bar on Android*/
          final double itemHeight = (size.height)/3;
          final double itemWidth = size.width /2;
          return Padding(
            padding: const EdgeInsets.only(left: 4.0,right: 4.0,top: 4.0,bottom: 4.0),
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
                            (product[index].Rating*5)/100);*/
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
                                    height: (itemHeight/3),
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
                                                            product[index].ImageFile
                                                                .length),
                                                    fit: BoxFit.contain)
                                            ),
                                          ),
                                          Container(
                                            child: GestureDetector(
                                              onTap: () {
                                                _getFavorit(product[index].ProductID);
                                              },
                                              child:setItemFavorite(product[index].ProductID),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: Container(
                                        margin: new EdgeInsets.symmetric(
                                            vertical: 4.0),
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
                                          : product[index].ProductNameTH.substring(
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
                                            color: Colors.orange,
                                            borderColor: Colors.grey,
                                            starCount: 5
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(right: 10.0),
                                          child: Text(
                                            "\฿${formatter.format(int.parse(product[index].ProductPrice))
                                                .toString()}", style: TextStyle(
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
                    )
                );
              },
              itemCount: product.length,
            ),
          );
        }
    );
  }

  Widget _buildSearchResults() {
    final formatter = new NumberFormat("#,###.#");
    var size = MediaQuery
        .of(context)
        .size;
    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height) / 3;
    final double itemWidth = size.width / 2;

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
                      int.tryParse(_searchResult[index].ProductPrice),
                      _searchResult[index].ProductID,
                      _searchResult[index].ProductNameTH,
                      Server().pathImageFile +
                          _searchResult[index].ImageFile
                              .substring(
                              3,
                              _searchResult[index].ImageFile
                                  .length),
                      _searchResult[index].ColorCode,
                      _searchResult[index].ServiceType,
                      _searchResult[index].CategoryID,
                      _searchResult[index].Rating);*/
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
                            height: (itemHeight /3),
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
                                                _searchResult[index].ImageFile
                                                    .substring(
                                                    3,
                                                    _searchResult[index]
                                                        .ImageFile
                                                        .length),
                                            fit: BoxFit.contain)
                                    ),
                                  ),
                                  Container(
                                      child: setItemClicked(
                                          _searchResult[index].ProductID
                                              .toString()) /*Text( "${proID.contains(product[index].ProductID.toString())==true&&proID.length>0
                                            ? proCount[proID.indexOf(product[index].ProductID.toString())].toString():''}",
                                          style: TextStyle(fontSize: 14.0, color: cl_text_pro_th,fontFamily: 'Poppins'),),*/ /*Icon(
                                          Icons.favorite_border, size: 20.0,),*/
                                    //child: data[index].fav ? Icon(Icons.favorite,size: 20.0,color: Colors.red,) : Icon(Icons.favorite_border,size: 20.0,),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Container(
                                margin: new EdgeInsets.symmetric(
                                    vertical: 4.0),
                                height: 1.0,
                                width: (itemWidth * 70) / 100,
                                color: new HexColor(
                                    _searchResult[index].ColorCode)
                            ),
                          ),
                          SizedBox(height: 10.0,),
                          Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Text(
                              "${_searchResult[index].ProductNameTH.length < 13
                                  ? _searchResult[index].ProductNameTH
                                  : _searchResult[index].ProductNameTH
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
                                    rating: (_searchResult[index].Rating * 5) /
                                        100,
                                    color: Colors.orange,
                                    borderColor: Colors.grey,
                                    starCount: 5
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 10.0),
                                  child: Text(
                                    "\฿${formatter.format(int.parse(
                                        _searchResult[index].ProductPrice))
                                        .toString()}", style: TextStyle(
                                      color: cl_text_pro_en,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins'),),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Center(
                              child: ButtonTheme(
                                //minWidth: 80.0,
                                //height: 30.0,
                                height: (itemHeight*17)/100,
                                buttonColor: Colors.cyan,
                                splashColor: Colors.deepOrange,
                                child: RaisedButton(
                                    onPressed: () {
                                      getTotalAmount(
                                          int.tryParse(_searchResult[index].ProductPrice),
                                          _searchResult[index].ProductID,
                                          _searchResult[index].ProductNameTH,
                                          Server().pathImageFile +
                                              _searchResult[index].ImageFile
                                                  .substring(
                                                  3,
                                                  _searchResult[index].ImageFile
                                                      .length),
                                          _searchResult[index].ColorCode,
                                          _searchResult[index].ServiceType,
                                          _searchResult[index].CategoryID,
                                          _searchResult[index].Rating);
                                    },
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .center,
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceEvenly,
                                      children: <Widget>[
                                        Text('เพิ่มลง',
                                          style: new TextStyle(
                                            //fontSize: 18,
                                              fontFamily: 'Poppins',
                                              color: Colors.white
                                          ),),
                                        Icon(Icons.shopping_cart, size: 18.0,
                                          color: Colors.white,),
                                        setItemClicked(
                                            _searchResult[index].ProductID)
                                      ],
                                    )
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      ratingStack(
                          _searchResult[index].ServiceType != 3 ? 3 : 7),
                    ],
                  ),
                ),
              )
          );
        },
        itemCount: _searchResult.length,
      ),
    );
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
            //_showDialog('เตือน!', 'คุณยังไม่มีสินค้าในตะกร้า.');
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


  @override
  Widget build(BuildContext context) {
    var size = MediaQuery
        .of(context)
        .size;

    final money = Money(totalAmount, Currency('USD'));
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
                    /*child: Text("Total Amount :",*/
                    child: Text("รวมเงิน :",
                      style: TextStyle(fontSize: 14.0, color: cl_text_pro_en),),
                  ),
                  Text('\$' + money.amount.toString(),
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
                    /*child: Text("Total Count :",*/
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
                      _showDialog();
                    } else {
                      Navigator.of(context)
                          .push(
                          new MaterialPageRoute(builder: (context) => Cart()))
                          .whenComplete(_getRequests);
                      //_clearShafe();
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'ตะกร้า',
                        style: new TextStyle(
                            fontSize: 18,
                            fontFamily: 'Poppins',
                            color: Colors.white
                        ),
                      ),
                     /* BadgeIconButton(
                          itemCount: counts,
                          badgeColor: Colors.white,
                          badgeTextColor: Colors.deepOrange,
                          icon: Icon(Icons.shopping_cart, color: Colors.white,),
                          onPressed: () {
                            if (totalAmount == 0) {
                              _showDialog();
                            } else {
                              Navigator.of(context)
                                  .push(
                                  new MaterialPageRoute(builder: (context) => Cart()))
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

    final makeTab = Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          Container(
            height: 140.0,
            child: Stack(
              children: <Widget>[
                Container(
                  //color: cl_back,
                  width: MediaQuery.of(context).size.width,
                  height: 100.0,
                  child: Center(
                    child: Text(
                      "ค้นหาสินค้า",
                      style: TextStyle(color: cl_text_pro_th, fontSize: 18.0),
                    ),
                  ),
                ),
                Positioned(
                  top: 75.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1.0),
                        /* border: Border.all(
                          color: Colors.grey.withOpacity(0.5), width: 1.0),
                      color: Colors.white*/),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: cl_text_pro_th,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          Expanded(
                            child: Container(
                              //width: itemWidth,
                              child: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: new Card(
                                  //color: cl_back,
                                  child: new ListTile(
                                    leading: new Icon(Icons.search),
                                    title: new TextField(
                                      controller: controller,
                                      keyboardType: TextInputType.text,
                                      textCapitalization: TextCapitalization.words,
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
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: _searchResult.length != 0 || controller.text.isNotEmpty
                ? _buildSearchResults():_buildUsersList(),
          ),
        ],
      ),
      bottomNavigationBar: makeBottom,
    );
    return makeTab;
  }
  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    _branchDetails.forEach((userDetail) {
      if (userDetail.ProductNameTH.contains(text) ||
          userDetail.ProductNameEN.contains(text)) _searchResult.add(userDetail);
    });

    setState(() {});
  }
}