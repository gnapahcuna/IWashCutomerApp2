import 'dart:convert';
import 'dart:typed_data';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cleanmate_customer_app/colorCode/HexColor.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cleanmate_customer_app/order_infor/order_card.dart';
import 'package:cleanmate_customer_app/alert/messageAlert.dart' as _message;
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:cleanmate_customer_app/order_infor/create_order.dart';

import 'package:http/http.dart' as http;
import 'package:cleanmate_customer_app/Server/server.dart';

import 'package:cleanmate_customer_app/data/Product.dart' as _product;

class OrderInfor extends StatefulWidget {
  @override
  _OrderInforState createState() => new _OrderInforState();
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
class _OrderInforState extends State<OrderInfor> {
  Color cl_back = HexColor("#e9eef4");
  Color cl_card = HexColor("#ffffff");
  Color cl_text_pro_th = HexColor("#1d313a");
  Color cl_text_pro_en = HexColor("#667787");
  Color cl_cart = HexColor("#18b4ed");
  Color cl_bar = HexColor("#18b4ed");
  Color cl_line_ver = HexColor("#677787");

  SharedPreferences prefs;
  int totalAmount = 0;
  int counts = 0;
  bool IsSuccess=false;
  List<String>itemsID = [],
      itemsServiceType = [],
      itemsCount = [],
      itemsPrice = [],
      isFavorite = [];

  String _valueDate = '';
  String _valueSpecial='';

  int couponPrice = 0;
  String couponDesc = '';

  int promoPrice = 0;
  String promoDesc = '';

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
      print(responseJson);
      return responseJson.map((m) => new _product.Product.fromJson(m)).toList();
    } catch (exception) {
      print(exception.toString());
    }
  }

  @override
  void initState() {
    _getShafe();
    _getUserAcct();
    updateInputType(time: false);
    super.initState();
  }
  void updateInputType({bool date, bool time}) {
    date = date ?? inputType != InputType.time;
    time = time ?? inputType != InputType.date;
    setState(() =>
    inputType =
    date ? time ? InputType.both : InputType.date : InputType.time);
  }

  int CustomerID, BranchID,BranchGroupID;
  String FirstName = "",
      LastName = "",
      UserAcctName = "",
      BranchName = "",
      BranchCode = "",
      PhoneBranch = "",
      PhoneCust = "";

  _getUserAcct() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      CustomerID = (prefs.getInt("CustomerID") ?? 0);
      BranchID = (prefs.getInt("BranchID") ?? 0);
      BranchName = (prefs.getString("BranchNameTH") ?? "");
      BranchCode = (prefs.getString("BranchCode") ?? "");
      PhoneCust = (prefs.getString("Telephone") ?? "");
      PhoneBranch = (prefs.getString("TelephoneBranch") ?? "");
      FirstName = (prefs.getString("Firstname") ?? "");
      LastName = (prefs.getString("Lastname") ?? "");
      UserAcctName = FirstName + " " + LastName;
      BranchGroupID = (prefs.getInt("BranchGroupID") ?? 0);
    });
  }

  _getShafe() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      itemsID = (prefs.getStringList('productID') ?? new List());
      itemsCount = (prefs.getStringList('productCount') ?? new List());
      itemsServiceType =
      (prefs.getStringList('productServiceType') ?? new List());

      int counter = (prefs.getInt('count') ?? 0);
      int total = (prefs.getInt('total') ?? 0);
      totalAmount = total;
      counts = counter;

      _valueDate = (prefs.getString('DateAppoint') ?? '');
      _valueSpecial= (prefs.getString('SpecialDetail') ?? 'แขวน');

      //print('_valueDate : '+_valueDate);
      //print('_valueSpecial : '+_valueSpecial);
    });
  }

  CupertinoAlertDialog _createCupertinoAlertDialog(mContext) =>
      new CupertinoAlertDialog(
          title: new Text("เตือน!", style: TextStyle(fontFamily: 'Poppins'),),
          content: new Text("ยืนยันรายการส่งซักนี้.",
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
                  _addOrder(mContext);
                },
                child: new Text('ยืนยัน', style: TextStyle(color: Colors.red,
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

  void _showDialog(mContext) {
    _message.Message(
        'คุณแน่ใจ?', 'ต้องการย้อนกลับใช่หรือไม่.', context, mContext, 1);
  }
  Future<bool> editAction() async {
    await new Future.delayed(const Duration(seconds: 2));
    return true;
  }

  void _addOrder(mContext) {
    callAddOrder(
        itemsID,
        itemsPrice,
        itemsCount
    ).then((s)async {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),),);
          });
      await editAction();
      if(IsSuccess==true){
        Navigator.of(mContext).push(
          new MaterialPageRoute(
            builder: (context) {
              return new CreateOrder(OrderNo: s.body,);
            },
          ),
        );
      }
    });
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _barOrder(),
          _buildProductScroller(),
          _barVoucher(),
          _barCoupon(),
          _barPromo(),
          _barCust(),
          _barAppoint(),
        ],
      ),
    );
  }

  Widget _buildProductScroller() {
    var size = MediaQuery
        .of(context)
        .size;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 4.0),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey[300], width: 1.0),
            bottom: BorderSide(color: Colors.grey[300], width: 1.0),
          )
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: SizedBox.fromSize(
          size: Size.fromHeight(size.height / 3.5),
          child:/* ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemCount: itemsID.length,
            itemBuilder: (BuildContext context, int index) {
              var name = itemsName[index];
              var price = itemsPrice[index];
              var count = itemsCount[index];
              var image = itemsImage[index];
              var color = itemsColor[index];
              return OrderCard(name, price, count, image, color);
            },
          ),*/
          FutureBuilder<List<_product.Product>>(
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
              for(int i =0;i<product.length;i++){
                itemsPrice.add(product[i].ProductPrice);
              }

              print(itemsPrice.toString());

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemCount: product.length,
                itemBuilder: (BuildContext context, int index) {
                  var name = product[index].ProductNameTH;
                  var price = product[index].ProductPrice;
                  var count = itemsCount[index].toString();
                  var image = Server().pathImageFile +
                      product[index].ImageFile
                          .substring(
                          3,
                          product[index].ImageFile
                              .length);
                  var color = product[index].ColorCode;
                  return OrderCard(name, price, count, image, color);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _barOrder() {
    final formatter = new NumberFormat("#,###.#");
    return Container(
      //margin: EdgeInsets.only(bottom: 18.0),
        height: 50.0,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey[300], width: 1.0),
              bottom: BorderSide(color: Colors.grey[300], width: 1.0),
            )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(left: 10.0),
                    width: 100.0,
                    child: Text("ราคารวม :",
                      style: TextStyle(fontSize: 14.0, color: cl_text_pro_en),),
                  ),
                  Text('\฿' + formatter.format(totalAmount),
                      style: TextStyle(color: cl_text_pro_th,
                          fontSize: 16.0,
                          fontFamily: 'Poppins')),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 100.0,
                    child: Text("รวมจำนวน :",
                      style: TextStyle(fontSize: 14.0, color: cl_text_pro_en),),
                  ),
                  Text(counts.toString() + ' ชิ้น',
                      style: TextStyle(color: cl_text_pro_th,
                          fontSize: 16.0,
                          fontFamily: 'Poppins')),
                ],
              ),
            ),
          ],
        )
    );
  }

  Widget _barCoupon() {
    return InkWell(
      // When the user taps the button, show a snackbar
      onTap: () {
        Scaffold.of(context).showSnackBar(SnackBar(
          //content: Text('Tap'),
        ));
      },
      child: Container(
        margin: EdgeInsets.only(top: 0.5),
        height: 55.0,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              //top: BorderSide(color: Colors.grey[300], width: 1.0),
              //bottom: BorderSide(color: Colors.grey[300], width: 1.0),
            )
        ),
        child: new ListTile(
          trailing: couponPrice == 0 ? null : const Icon(
              Icons.keyboard_arrow_right),
          title: new Row(
            children: <Widget>[
              Container(
                width: 60.0,
                child: Text("คูปอง :",
                  style: TextStyle(fontSize: 16.0, color: cl_text_pro_en),),
              ),
              Text('ไม่มีการใช้คูปอง',
                  style: TextStyle(color: Colors.red,
                      fontSize: 16.0,
                      fontFamily: 'Poppins')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _barPromo() {
    return InkWell(
      // When the user taps the button, show a snackbar
      onTap: () {
        Scaffold.of(context).showSnackBar(SnackBar(
          //content: Text('Tap'),
        ));
      },
      child: Container(
        margin: EdgeInsets.only(top: 0.5),
        height: 55.0,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              //top: BorderSide(color: Colors.grey[300], width: 1.0),
              bottom: BorderSide(color: Colors.grey[300], width: 1.0),
            )
        ),
        child: new ListTile(
          trailing: couponPrice == 0 ? null : const Icon(Icons.remove_red_eye),
          title: new Row(
            children: <Widget>[
              Container(
                width: 80.0,
                child: Text("โปรโมชั่น :",
                  style: TextStyle(fontSize: 16.0, color: cl_text_pro_en),),
              ),
              Text('ไม่มีโปรโมชั้น',
                  style: TextStyle(color: Colors.red,
                      fontSize: 16.0,
                      fontFamily: 'Poppins')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _barVoucher() {
    return InkWell(
      // When the user taps the button, show a snackbar
      onTap: () {
        Scaffold.of(context).showSnackBar(SnackBar(
          //content: Text('Tap'),
        ));
      },
      child: Container(
        margin: EdgeInsets.only(top: 4.0),
        height: 55.0,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey[300], width: 1.0),
              //bottom: BorderSide(color: Colors.grey[300], width: 1.0),
            )
        ),
        child: new ListTile(
          trailing: couponPrice == 0 ? null : const Icon(Icons.remove_red_eye),
          title: new Row(
            children: <Widget>[
              Container(
                width: 80.0,
                child: Text("Voucher :",
                  style: TextStyle(fontSize: 16.0, color: cl_text_pro_en),),
              ),
              Text('ไม่มีการใช้ voucher',
                  style: TextStyle(color: Colors.red,
                      fontSize: 16.0,
                      fontFamily: 'Poppins')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _barCust() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 4.0),
      padding: const EdgeInsets.only(
          top: 16.0, left: 16.0, right: 16.0, bottom: 16.0),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey[300], width: 1.0),
            bottom: BorderSide(color: Colors.grey[300], width: 1.0),
          )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'ข้อมูลลูกค้า :',
            style: TextStyle(
                fontSize: 16.0,
                fontFamily: 'Poppins',
                color: cl_text_pro_en
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 12.0, left: 20.0),
            child: Text(
              FirstName + ' ' + LastName,
              style: TextStyle(
                color: cl_text_pro_th,
                height: 0.7,
                fontSize: 16.0,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Container(
            margin: EdgeInsets.only(top: 8.0, left: 20.0),
            child: Text(
              PhoneCust,
              style: TextStyle(
                color: cl_text_pro_th,
                height: 0.7,
                fontSize: 16.0,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Container(
            color: cl_text_pro_en,
            margin: const EdgeInsets.symmetric(vertical: 12.0),
            width: 225.0,
            height: 1.0,
          ),
          Text(
            'ข้อมูลลสาขา :',
            style: TextStyle(
                fontSize: 16.0,
                fontFamily: 'Poppins',
                color: cl_text_pro_en
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 12.0, left: 20.0),
            child: Text(
              BranchName + ' (' + BranchCode + ')',
              style: TextStyle(
                color: cl_text_pro_th,
                height: 0.7,
                fontSize: 16.0,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 8.0, left: 20.0),
            child: Text(
              PhoneBranch,
              style: TextStyle(
                color: cl_text_pro_th,
                height: 0.7,
                fontSize: 16.0,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barAppoint() {
    return InkWell(
      // When the user taps the button, show a snackbar
      onTap: () {
        //itemsServiceType.contains("3")?_selectDate(7):_selectDate(3);
        _selectDate();
      },
      child: Container(
        margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
        //height: 55.0,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey[300], width: 1.0),
              bottom: BorderSide(color: Colors.grey[300], width: 1.0),
            )
        ),
        child: new ListTile(
          trailing: const Icon(Icons.mode_edit,),
          title: new Row(
            children: <Widget>[
              Container(
                width: 100.0,
                child: Text("วันนัดรับผ้า :",
                  style: TextStyle(fontSize: 16.0, color: cl_text_pro_en),),
              ),
              Text(_valueDate,
                  style: TextStyle(color: cl_text_pro_th,
                      fontSize: 16.0,
                      fontFamily: 'Poppins')),
            ],
          ),
        ),
      ),
    );
  }
  CupertinoAlertDialog _createShowSpecialCupertinoAlertDialog(title,desc) =>
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
  void _showDialogShowSpecial(title,desc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _createShowSpecialCupertinoAlertDialog(title,desc);
      },
    );
  }
  void _selectDate() {
    List splits = _valueDate.split('-');
    final initYear = int.parse(splits[0]);
    final initMounth = int.parse(splits[1]);
    final initDate = int.parse(splits[2]);
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
          style: TextStyle(color: Colors.lightBlue,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins')),
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
        if(date<initDate||month<initMounth||year<initYear){
          print('not date');
          _showDialogShowSpecial("แจ้งเตือน!","คุณเลือกวันนัดรับน้อยกว่าที่ระบบกำหนด.");
        }else{
          _valueDate = year.toString() + '-' + strMonth + '-' + strDate;
          _setDateAppoint(_valueDate);
        }

      },
    );
  }

  _setDateAppoint(value) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString('DateAppoint', value);
    setState(() {
      _valueDate = value;
    });
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final formatter = new NumberFormat("#,###.#");
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
                    width: 120.0,
                    child: Text("ยอดรวมสุทธิ :",
                      style: TextStyle(fontSize: 14.0,
                          color: cl_text_pro_en,
                          fontFamily: 'Poppins'),),
                  ),
                  Text('\$' + formatter.format(totalAmount),
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
                child: RaisedButton(
                  color: Colors.deepOrange,
                  onPressed: () {
                    _showDialogCreateOrder(context);
                  },
                  child: Row(
                    children: <Widget>[
                      Text(
                        'ทำรายการส่งซัก',
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
          ],
        )
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
          //backgroundColor: cl_back,
          appBar: new AppBar(
            leading: new IconButton(
              icon: new Icon(Icons.arrow_back_ios, color: cl_text_pro_th),
              onPressed: () => _showDialog(context),
            ),
            title: new Text(
              "ข้อมูลการส่งซัก",
              style: new TextStyle(
                  color: cl_text_pro_th,
                  fontSize: Theme
                      .of(context)
                      .platform == TargetPlatform.iOS ? 17.0 : 20.0,
                  fontFamily: 'Poppins'
              ),
            ),

            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Container(
              child: _buildContent(),
            ),
          ),
          bottomNavigationBar: makeBottom
      ),
    );
  }

  Future<http.Response> callAddOrder(List productsID, List prices,
      List counts) async {
    var now = new DateTime.now();
    var formatter1 = new DateFormat('yyyy-MM-dd');
    var formatter2 = new DateFormat('yyyy-MM-dd HH:mm:ss');
    String orderDate = formatter1.format(now);
    String createDate = formatter2.format(now);

    List<Map> productOptionJson = new List();
    for (int i = 0; i < productsID.length; i++) {
      for (int j = 0; j < int.parse(counts[i]); j++) {
        ProductJson carJson = new ProductJson(
            productsID[i].toString(),
            prices[i],
            _valueSpecial,
            createDate,
            CustomerID.toString(),
            _valueDate,
            BranchID.toString(),
        );
        productOptionJson.add(carJson.TojsonData());
      }
    }
    var bodyJson = json.encode({
      "Product": productOptionJson
    });
    final body = {
      "OrderDate": orderDate,
      "CustomerID": CustomerID.toString(),
      "BranchID": BranchID.toString(),
      "AppointmentDate": _valueDate.toString(),
      "CreateDate": createDate,
      "NetAmount": totalAmount.toString(),
      "IsPayment": 0.toString(),
      "PaymentDate": createDate,
    };

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    final respOrder = await http.post(
      Server().IPAddress + "/put/order/AddOrder.php", // change with your API
      body: body,
    );
    final respOrderDetail = await http.post(
      Server().IPAddress + "/put/order/AddOrderDetail.php",
      // change with your API
      body: bodyJson,
      headers: headers,
    );
    if(respOrderDetail.statusCode==200){
      IsSuccess=true;
    }
    return respOrderDetail;
  }
}
class ProductJson {
  String ProductID;
  String ProductPrice;
  String SpecialDetial;
  String CreatedDate;
  String CustomerID;
  String AppointmentDate;
  String BranchID;
  ProductJson(this.ProductID,this.ProductPrice,this.SpecialDetial,this.CreatedDate,this.CustomerID,this.AppointmentDate,this.BranchID);
  Map<String, dynamic> TojsonData() {
    var map = new Map<String, dynamic>();
    map["ProductID"] = ProductID;
    map["Amount"] = ProductPrice;
    map["SpecialDetial"] = SpecialDetial;
    map["CreatedDate"] = CreatedDate;
    map["CustomerID"] = CustomerID;
    map["AppointmentDate"] = AppointmentDate;
    map["BranchID"] = BranchID;
    return map;
  }
}