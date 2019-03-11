import 'dart:convert';

import 'package:cleanmate_customer_app/Server/server.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cleanmate_customer_app/colorCode/HexColor.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cleanmate_customer_app/order_infor/orderInfor.dart';
import 'package:badges/badges.dart';
import 'package:cleanmate_customer_app/alert/messageAlert.dart' as _message;
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';

import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

import 'package:cleanmate_customer_app/data/Product.dart' as _product;
import 'package:http/http.dart' as http;

class Cart extends StatefulWidget {
  @override
  _CartState createState() => new _CartState();
}
class CartJson {
  String ProductID;
  String BranchGroupID;
  CartJson(this.ProductID,this.BranchGroupID);
  Map<String, dynamic> TojsonData() {
    var map = new Map<String, dynamic>();
    map["ProductID"] = ProductID;
    map["BranchGroupID"] = BranchGroupID;
    return map;
  }
}
class _CartState extends State<Cart> {
  Color cl_back = HexColor("#e9eef4");
  Color cl_card = HexColor("#ffffff");
  Color cl_text_pro_th = HexColor("#1d313a");
  Color cl_text_pro_en = HexColor("#667787");
  Color cl_cart = HexColor("#18b4ed");
  Color cl_bar = HexColor("#18b4ed");
  Color cl_line_ver = HexColor("#677787");

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  SharedPreferences prefs;
  List<String>itemsID = [],
      itemsServiceType = [],
      itemsCount = [],
      isFavorite = [];

  int totalAmount = 0,
      counts = 0;

  String _valueDate = '';

  String dropdownValue = 'แขวน';

  bool checkItems=false;

  int BranchGroupID;

  // Show some different formats.
  final formats = {
    InputType.both: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
    InputType.date: DateFormat('yyyy-MM-dd'),
    InputType.time: DateFormat("HH:mm"),
  };

  // Changeable in demo
  InputType inputType = InputType.both;
  bool editable = true;
  DateTime date;

  //fetch product
  Future<List<_product.Product>> fetchProduct() async {
    List<Map> productOptionJson = new List();
    for (int i = 0; i < itemsID.length; i++) {
      CartJson cartJson = new CartJson(
        itemsID[i].toString(),
        BranchGroupID.toString(),
      );
      productOptionJson.add(cartJson.TojsonData());
    }
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    var bodyJson = json.encode({
      "Cart": productOptionJson
    });
    try {
      http.Response response;
      List responseJson;
      response =
      await http.post(
          Server().IPAddress + '/data/get/pro/ProductCart.php',
          body: bodyJson, headers: headers);
      responseJson = json.decode(response.body);
      return responseJson.map((m) => new _product.Product.fromJson(m)).toList();
    } catch (exception) {
      print(exception.toString());
    }
  }

  @override
  void initState() {
    _getShafe();
    updateInputType(time: false);
    setState(() {
      fetchProduct().then((s){

      });
    });

    super.initState();
  }

  _getRequests() async {
    _getShafe();
  }

  _getShafe() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      itemsID = (prefs.getStringList('productID') ?? new List());
      itemsCount = (prefs.getStringList('productCount') ?? new List());
      itemsServiceType =
      (prefs.getStringList('productServiceType') ?? new List());
      BranchGroupID = (prefs.getInt("BranchGroupID") ?? 0);

      int counter = (prefs.getInt('count') ?? 0);
      int total = (prefs.getInt('total') ?? 0);
      totalAmount = total;
      counts = counter;

      isFavorite = (prefs.getStringList('favorit') ?? new List());

      setState(() {
        _valueDate = (prefs.getString('DateAppoint') ?? '');
        print("_valueDate : " + _valueDate);
      });
      dropdownValue = (prefs.getString('SpecialDetail') ?? 'แขวน');


      print(itemsID.toString() + ", " + itemsCount.toString());

      if(itemsID.length==itemsCount.length){
        checkItems=true;
      }
    });
  }


  _getAdd(index,price) {
    setState(() {
      _addShafe(index,price);
    });
  }

  _getMinus(index,price) {
    setState(() {
      _minusShafe(index,price);
    });
  }

  _minusShafe(index,price) async {
    prefs = await SharedPreferences.getInstance();
    int counter = (prefs.getInt('count') ?? 0) - 1;
    int total = (prefs.getInt('total') ?? 0) - int.parse(price);

    itemsCount = (prefs.getStringList('productCount') ?? new List());
    int c = int.parse(itemsCount[index]) - 1;
    itemsCount[index] = c.toString();

    counts = counter;
    totalAmount = total;
    counts = counter;
    await prefs.setInt('count', counts);
    await prefs.setInt('total', totalAmount);
    await prefs.setStringList('productCount', itemsCount);
  }

  _addShafe(index,price) async {
    prefs = await SharedPreferences.getInstance();
    int counter = (prefs.getInt('count') ?? 0) + 1;
    int total = (prefs.getInt('total') ?? 0) + int.parse(price);

    itemsCount = (prefs.getStringList('productCount') ?? new List());
    int c = int.parse(itemsCount[index]) + 1;
    itemsCount[index] = c.toString();

    counts = counter;
    totalAmount = total;
    await prefs.setInt('count', counter);
    await prefs.setInt('total', totalAmount);
    await prefs.setStringList('productCount', itemsCount);
  }

  _removeItem(index,price) async {
    int counter = (prefs.getInt('count') ?? 0) - int.parse(itemsCount[index]);
    int total = (prefs.getInt('total') ?? 0) -
        int.parse(price) * int.parse(itemsCount[index]);
    counts = counter;
    totalAmount = total;

    //print("minus : " + counts.toString() + " , " + totalAmount.toString());

    itemsID.removeAt(index);
    itemsCount.removeAt(index);
    itemsServiceType.removeAt(index);

    prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('productID', itemsID);
    await prefs.setStringList('productCount', itemsCount);
    await prefs.setStringList('productServiceType', itemsServiceType);
    await prefs.setInt('count', counts);
    await prefs.setInt('total', totalAmount);
  }

  _clearShafe() async {
    setState(() {
      _initPref();
      prefs.clear();
      counts = 0;
      totalAmount = 0;
    });
  }

  _setDateAppoint(value) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString('DateAppoint', value);
    setState(() {
      _valueDate = value;
    });
  }

  _setSpecial(value) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString('SpecialDetail', value);
    setState(() {
      dropdownValue = value;
    });
  }

  _initPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  _getFavorit(productID) {
    setState(() {
      _putFavorit(productID);
    });
  }

  _putFavorit(productID) async {
    _initPref();
    print(productID.toString());
    List<String> itemsID = (prefs.getStringList('favorit') ?? new List());
    int index = itemsID.indexOf(productID.toString());
    if (index != -1) {
      itemsID.removeAt(index);
    } else {
      itemsID.add(productID.toString());
    }
    await prefs.setStringList('favorit', itemsID);

    isFavorite = itemsID;
  }

  setItemFavorite(productID) {
    return isFavorite.contains(productID.toString()) == true &&
        isFavorite.length > 0
        ? Icon(Icons.favorite, color: Colors.red,) :
    Icon(Icons.favorite_border, color: Colors.red,);
  }

  CupertinoAlertDialog _createCupertinoAlertDialog() =>
      new CupertinoAlertDialog(
          title: new Text("เตือน!", style: TextStyle(fontFamily: 'Poppins'),),
          content: new Text("ยืนยันการยกเลิกรายการ.",
              style: TextStyle(fontFamily: 'Poppins')),
          actions: <Widget>[

            new CupertinoButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: new Text(
                    'ยกเลิก', style: TextStyle(color: HexColor("#667787"),
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins'))),
            new CupertinoButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _cancelOrder();
                  });
                },
                child: new Text('ยืนยัน', style: TextStyle(color: Colors.red,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins'))),
          ]
      );

  CupertinoAlertDialog _createShowSpecialCupertinoAlertDialog(title, desc) =>
      new CupertinoAlertDialog(
          title: new Text(title, style: TextStyle(fontFamily: 'Poppins'),),
          content: new Text(desc,
              style: TextStyle(fontFamily: 'Poppins')),
          actions: <Widget>[

            new CupertinoButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: new Text('ปิด', style: TextStyle(color: Colors.red,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins'))),
          ]
      );

  void _showDialogCancelOrder() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _createCupertinoAlertDialog();
      },
    );
  }

  void _showDialogShowSpecial(title, desc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _createShowSpecialCupertinoAlertDialog(title, desc);
      },
    );
  }

  void _cancelOrder() async {
    prefs.remove('productID');
    prefs.remove('productCount');
    prefs.remove('productServiceType');
    prefs.remove('count');
    prefs.remove('total');
    prefs.remove('DateAppoint');
    //prefs.remove('SpecialDetail');

    setState(() {
      _getShafe();
    });
  }

  void updateInputType({bool date, bool time}) {
    date = date ?? inputType != InputType.time;
    time = time ?? inputType != InputType.date;
    setState(() =>
    inputType =
    date ? time ? InputType.both : InputType.date : InputType.time);
  }
  void _showDialog(title, desc) {
    _message.Message(title, desc, context, null, 2);
  }

  void _selectDate(nextDate) {
    final initYear = new DateTime.now().year;
    final initMounth = new DateTime.now().month;
    final initDate = new DateTime.now().day + nextDate;
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      locale: 'en',
      minYear: initYear,
      maxYear: initYear + 1,
      initialYear: initYear,
      initialMonth: initMounth,
      initialDate: initDate,
      cancel: Text('ปิด',
          style: TextStyle(color: cl_text_pro_th,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins')),
      confirm: Text('ยืนยัน',
          style: TextStyle(color: Colors.cyan,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins')),
      //dateFormat: 'yyyy-mm-dd',
      dateFormat: 'yyyy-mmmm-dd',
      onChanged: (year, month, date) {
        //print("changed : "+year.toString()+'-'+month.toString()+'-'+date.toString());
      },
      onConfirm: (year, month, date) {
        String strDate, strMonth;

        if (date
            .toString()
            .length == 1) {
          strDate = '0' + date.toString();
        } else {
          strDate = date.toString();
        }

        if (month
            .toString()
            .length == 1) {
          strMonth = '0' + month.toString();
        } else {
          strMonth = month.toString();
        }
        if (date < initDate || month < initMounth || year < initYear) {
          print('not date');
          _showDialogShowSpecial(
              "แจ้งเตือน!", "คุณเลือกวันนัดรับน้อยกว่าที่ระบบกำหนด.");
        } else {
          _valueDate = year.toString() + '-' + strMonth + '-' + strDate;
          _setDateAppoint(_valueDate);
        }
      },
    );
  }

  Future<bool> editAction() async {
    await new Future.delayed(const Duration(seconds: 2));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    //Navigator.pop(context,true);
    final formatter = new NumberFormat("#,###.#");
    var size = MediaQuery
        .of(context)
        .size;
    // TODO: implement build
    final makeBody = FutureBuilder<List<_product.Product>>(
        future: fetchProduct(),
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
          List<_product.Product> product = snapshot.data;

          return Container(
            child: checkItems==true?itemsID.length > 0? ListView.builder(
              itemCount: itemsID.length,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return Dismissible(
                    key: Key(itemsID[index]),
                    onDismissed: (direction) {
                      setState(() {
                        _removeItem(index,product[index].ProductPrice);
                      });
                    },
                    background: Container(color: Colors.red),
                    child: Padding(
                      padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 2.0, bottom: 2.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16.0),
                                topRight: Radius.circular(16.0),
                                bottomLeft: Radius.circular(16.0),
                                bottomRight: Radius.circular(16.0)
                            )
                          /*boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12.0
              )
            ]*/
                        ),
                        height: size.height / 5.5,
                        child: Row(
                          //mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                    padding: EdgeInsets.only(right: 12.0, left: 8.0),
                                    /*alignment: Alignment.topLeft,
                      height: 100.0,
                      width: 100.0,*/
                                    decoration: new BoxDecoration(
                                        border: new Border(
                                            right: new BorderSide(
                                                width: 1.0,
                                                color: HexColor(
                                                   product[index].ColorCode)))),
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: <Widget>[
                                            new SizedBox(
                                              height: 70.0,
                                              width: 70.0,
                                              child: Image.network(
                                                  Server().pathImageFile +
                                                      product[index].ImageFile
                                                          .substring(
                                                          3,
                                                          product[index]
                                                              .ImageFile
                                                              .length),
                                                  fit: BoxFit.contain),

                                            ),
                                            new Container(
                                              //child: setItemClicked(product[index].ProductID.toString())
                                                child: GestureDetector(
                                                  onTap: () {
                                                    _getFavorit(product[index].ProductID);
                                                    //showInSnackBar('เลือก '+product[index].ProductID.toString()+" เป็นสินค้าที่ชื่นชอบแล้ว.");
                                                  },
                                                  child: setItemFavorite(itemsID[index]),
                                                )
                                              //child: data[index].fav ? Icon(Icons.favorite,size: 20.0,color: Colors.red,) : Icon(Icons.favorite_border,size: 20.0,),
                                            )
                                          ],
                                        ),
                                        new StarRating(
                                            size: 15.0,
                                            rating: (product[index].Rating*5)/100,
                                            color: Colors.yellow.shade800,
                                            borderColor: Colors.grey,
                                            starCount: 5
                                        ),
                                      ],
                                    )
                                ),
                              ],
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: 15.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Row(
                                      //mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Expanded(
                                          child: Text("${product[index].ProductNameTH.length <
                                              13
                                              ? product[index].ProductNameTH
                                              : product[index].ProductNameTH
                                              .substring(
                                              0, 12) + '...'}",
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: cl_text_pro_th,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Poppins',),),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            int.parse(itemsCount[index]) != 1 ? new IconButton(
                                              icon: new Icon(Icons.remove_circle,
                                                color: cl_text_pro_th,), onPressed: () {
                                              _getMinus(index,product[index].ProductPrice);
                                            },) : new Container(),
                                            new Text(int.parse(itemsCount[index]).toString(),
                                              style: TextStyle(
                                                  fontFamily: 'Poppins', fontSize: 16.0,
                                                  color: cl_text_pro_th),),
                                            new IconButton(
                                                icon: new Icon(Icons.add_circle,
                                                  color: cl_text_pro_th,), onPressed: () {
                                              _getAdd(index,product[index].ProductPrice);
                                            })
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            '\$' + "${formatter.format(
                                                int.parse(product[index].ProductPrice))}",
                                            style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 16.0,
                                                color: cl_text_pro_en),),
                                        ),
                                      ],
                                    ),

                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                );
              },
            ) : Padding(
              padding: EdgeInsets.only(
                  left: 12.0, bottom: 12.0, right: 12.0, top: 4.0),
              child: Container(
                child: Center(
                  child: Text(
                    'ไม่มีสินค้า',
                    style: new TextStyle(
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        color: cl_text_pro_th
                    ),
                  ),
                ),
              ),
            ):Padding(
              padding: EdgeInsets.only(
                  left: 12.0, bottom: 12.0, right: 12.0, top: 4.0),
              child: Container(
                child: Center(
                  child: Text(
                    'ข้อมูลผิดพลาด โปรดเลือกสินค้าใหม่.',
                    style: new TextStyle(
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        color: cl_text_pro_th
                    ),
                  ),
                ),
              ),
            ),
          );
        }
    );
    /*final makeBody = Container(

      child: checkItems==true?itemsID.length > 0? ListView.builder(
        itemCount: itemsID.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
              key: Key(itemsID[index]),
              onDismissed: (direction) {
                setState(() {
                  _removeItem(index);
                });
              },
              background: Container(color: Colors.red),
              child: generateCart(index, int.parse(itemsCount[index]))
          );
        },
      ) : Padding(
        padding: EdgeInsets.only(
            left: 12.0, bottom: 12.0, right: 12.0, top: 4.0),
        child: Container(
          child: Center(
            child: Text(
              'ไม่มีสินค้า',
              style: new TextStyle(
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  color: cl_text_pro_th
              ),
            ),
          ),
        ),
      ):Padding(
        padding: EdgeInsets.only(
            left: 12.0, bottom: 12.0, right: 12.0, top: 4.0),
        child: Container(
          child: Center(
            child: Text(
              'ข้อมูลผิดพลาด โปรดเลือกสินค้าใหม่.',
              style: new TextStyle(
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  color: cl_text_pro_th
              ),
            ),
          ),
        ),
      ),
    );*/
   /* var size = MediaQuery
        .of(context)
        .size;
    final formatter = new NumberFormat("#,###.#");*/
    final makeBottom = new Container(
      height: 130.0,
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            //margin: EdgeInsets.only(bottom: 18.0),
            height: 65.0,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    top: BorderSide(color: Colors.grey[300], width: 1.0)
                )
            ),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    //width: (size.width * 20) / 100,
                    padding: EdgeInsets.all(12.0),
                    child: Text("รวมเงิน :",
                      style: TextStyle(
                          fontSize: 14.0, color: cl_text_pro_en),),
                  ),
                  Text('\$' + formatter.format(checkItems==true?totalAmount:0),
                      style: TextStyle(color: cl_text_pro_th,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins')),
                  Container(
                    //width: (size.width * 20) / 100,
                    padding: EdgeInsets.all(12.0),
                    child: Text("รวมจำนวน :",
                      style: TextStyle(
                          fontSize: 14.0, color: cl_text_pro_en),),
                  ),
                  Text(checkItems==true?counts.toString():0.toString()+' ชิ้น',
                      style: TextStyle(color: cl_text_pro_th,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins')),
                ],
              ),
            ),
          ),

          new Container(
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
                //mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0),
                    child: Container(
                      height: 65.0,
                      width: size.width/2,
                      child: RaisedButton(
                        color: Colors.grey.shade500,
                        onPressed: () {
                          _showDialogCancelOrder();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'ยกเลิก',
                              style: new TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                  color: Colors.white
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(),
                    child: Container(
                      height: 65.0,
                      width: size.width/2,
                      child: RaisedButton(
                        color: Colors.deepOrange,
                        onPressed: () async {
                          if (totalAmount == 0 || _valueDate.isEmpty) {
                            if (totalAmount == 0&&checkItems==false) {
                              _showDialog(
                                  'เตือน!', 'คุณยังไม่มีสินค้าในตะกร้า.');
                            } else if (_valueDate.isEmpty) {
                              _showDialog(
                                  'คุณแน่ใจ?', 'คุณยังไม่กำหนดวันนัดรับ.');
                            }
                          }
                          else {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      valueColor: new AlwaysStoppedAnimation<
                                          Color>(
                                          Colors.deepOrange),),);
                                });
                            await editAction();
                            Navigator.pop(context);
                            /*Navigator.of(context).push(
                        new MaterialPageRoute(
                          builder: (context) {
                            //return new SearchList();
                            return new OrderInfor();
                          },
                        ),
                      );*/
                            Navigator.of(context)
                                .push(
                                new MaterialPageRoute(
                                    builder: (context) => OrderInfor()))
                                .whenComplete(_getRequests);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'ยืนยัน',
                              style: new TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                  color: Colors.white
                              ),
                            ),
                            /*BadgeIconButton(
                                itemCount: counts,
                                badgeColor: Colors.white,
                                badgeTextColor: Colors.deepOrange,
                                icon: Icon(
                                  Icons.shopping_cart, color: Colors.white,),
                                onPressed: () {
                                  if (totalAmount == 0 || _valueDate.isEmpty) {
                                    if (_valueDate.isEmpty) {
                                      _showDialog(
                                          'คุณแน่ใจ?',
                                          'คุณยังไม่กำหนดวันนัดรับ.');
                                    } else if (totalAmount == 0) {
                                      _showDialog(
                                          'เตือน!',
                                          'คุณยังไม่มีสินค้าในตะกร้า.');
                                    }
                                  }
                                  else {
                                    Navigator.of(context)
                                        .push(
                                        new MaterialPageRoute(
                                            builder: (context) => OrderInfor()))
                                        .whenComplete(_getRequests);
                                  }
                                }
                            ),*/
                          ],
                        ),
                      ),
                    ),
                  ),

                ],
              )
          ),
        ],
      ),
    );
    final makeAppoint = new Container(
      //margin: EdgeInsets.only(bottom: 18.0),
        height: (size.height * 10) / 100,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey[300], width: 1.0),
              bottom: BorderSide(color: Colors.grey[300], width: 1.0),
            )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  Container(
                    width: 100.0,
                    child: Text("วันที่นัดรับ :",
                      style: TextStyle(fontSize: 14.0, color: cl_text_pro_th),),
                  ),
                  Text(_valueDate != '' ? _valueDate : 'ยังไม่ได้กำหนด',
                      style: TextStyle(
                          color: _valueDate != '' ? cl_text_pro_th : Colors.red
                              .shade500,
                          fontSize: 16.0,
                          fontFamily: 'Poppins')),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                height: 65.0,
                child: RaisedButton(
                  color: cl_text_pro_th,
                  onPressed: () {
                    if (totalAmount == 0) {
                      _showDialogShowSpecial("เตือน!",
                          "ไม่สามารถเลือกวันที่นัดรับได้ เนื่องจากคุณยังไม่มีสินค้าในตะกร้า");
                    } else {
                      itemsServiceType.contains("3")
                          ? _selectDate(7)
                          : _selectDate(3);
                    }
                  },
                  child: Row(
                    children: <Widget>[
                      Text(
                        'กำหนด',
                        style: new TextStyle(
                            fontSize: 18,
                            fontFamily: 'Poppins',
                            color: Colors.white
                        ),
                      ),
                      BadgeIconButton(
                          itemCount: 0,
                          badgeColor: Colors.white,
                          badgeTextColor: cl_text_pro_en,
                          icon: Icon(
                            FontAwesomeIcons.calendarAlt, color: Colors.white,),
                          onPressed: () {
                            if (totalAmount == 0) {

                            } else {
                              itemsServiceType.contains("3")
                                  ? _selectDate(7)
                                  : _selectDate(3);
                            }
                          }
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
      /*Padding(
        padding: const EdgeInsets.all(8.0),
        child: DateTimePickerFormField(
          keyboardType: null,
          inputType: inputType,
          format: formats[inputType],
          editable: editable,
          initialDate: DateTime.parse(DateTime.now().year.toString()+'-'+
              (DateTime.now().month.toString().length==1?'0'+DateTime.now().month.toString():DateTime.now().month.toString())+'-'+
              ((DateTime.now().day+3).toString().length==1?'0'+(DateTime.now().day+3).toString():(DateTime.now().day+3)).toString()),
          initialValue: DateTime.parse(_valueDate),
          decoration: InputDecoration(
            //icon: Icon(Icons.date_range),
            suffixIcon: Icon(Icons.edit),
            enabledBorder: InputBorder.none,
            labelText: 'วันที่นัดรับ',
            labelStyle: TextStyle(
                fontSize: 14.0, color: cl_text_pro_th, fontFamily: 'Poppins'),
            hasFloatingPlaceholder: true,
            prefixIcon: Icon(
              FontAwesomeIcons.calendarAlt, color: cl_text_pro_th, size: 32,),
            
          ),
          onChanged: (dt) => setState(() {
            date = dt;
            String day="",month="",year="";
            if(dt.day.toString().length==1){
              day="0"+dt.day.toString();
            }else{
              day=dt.day.toString();
            }
            if(dt.month.toString().length==1){
              month="0"+dt.month.toString();
            }else{
              month=dt.month.toString();
            }
            _setDateAppoint(dt.year.toString()+'-'+month+'-'+day);
          }),
        ),
      ),*/
    );

    return new Scaffold(
      //backgroundColor: cl_back,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight((size.height * 20) / 100),
          child: Column(
            children: <Widget>[
              AppBar(
                automaticallyImplyLeading: false,
                // hides leading widget
                leading: new IconButton(
                  icon: new Icon(Icons.arrow_back_ios, color: cl_text_pro_th),
                  onPressed: (){
                    if(checkItems==false){
                      _cancelOrder();
                    }
                    Navigator.of(context).pop();
                  },
                ),
                actions: <Widget>[
                  new Padding(
                    padding: EdgeInsets.only(right: 12.0),
                    child: BadgeIconButton(
                        itemCount: 0,
                        badgeColor: Colors.white,
                        badgeTextColor: Colors.deepOrange,
                        icon: Icon(
                          FontAwesomeIcons.question, color: Colors.black26,),
                        onPressed: () {
                          //
                          _showDialogShowSpecial("คำอธิบาย?",
                              "คำสั่งพิเศษที่ต้องการในกระบวนการเตรียมจัดส่งสินค้า.");
                        }),
                  )
                ],
                backgroundColor: Colors.transparent,
                title: new DropdownButtonHideUnderline(
                  child: new DropdownButton<String>(
                    value: dropdownValue,
                    items: <String>['แขวน', 'พับ', 'รีดจีบเรียบ', 'รีดแขนกลม']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: new TextStyle(
                            color: cl_text_pro_th,
                            fontSize: Theme
                                .of(context)
                                .platform == TargetPlatform.iOS ? 17.0 : 20.0,
                            fontFamily: 'Poppins'
                        ),),
                      );
                    })
                        .toList(),
                    onChanged: (String value) {
                      setState(() {
                        dropdownValue = value;
                        _setSpecial(value);
                      });
                    },
                  ),
                ), /*new Text(
                  "ตะกร้า",
                  style: new TextStyle(
                      color: cl_text_pro_th,
                      fontSize: Theme
                          .of(context)
                          .platform == TargetPlatform.iOS ? 17.0 : 20.0,
                      fontFamily: 'Poppins'
                  ),
                ),*/
                elevation: 0.0,
                centerTitle: true,
              ),
              makeAppoint,
            ],
          )
      ),
      body: makeBody,
      bottomNavigationBar: makeBottom,
    );
  }
}