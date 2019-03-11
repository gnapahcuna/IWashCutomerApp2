import 'package:cleanmate_customer_app/colorCode/HexColor.dart';
import 'package:cleanmate_customer_app/order_infor/order_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:cleanmate_customer_app/Server/server.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cleanmate_customer_app/data/OrderTrackingProduct.dart' as _product;
import 'package:url_launcher/url_launcher.dart';
class TrackingDetail extends StatefulWidget {
  int OrderNo;
  String Status;
  String Branchname;
  String OrderDate;
  String AppointmentDate;
  String IsPage;
  int IsPatment;
  String LastDate;
  TrackingDetail({
    Key key,
    @required this.OrderNo,
    @required this.Status,
    @required this.Branchname,
    @required this.OrderDate,
    @required this.AppointmentDate,
    @required this.IsPatment,
    @required this.LastDate,
    @required this.IsPage,
  }) : super(key: key);
  @override
  _TrackingDetailState createState() => new _TrackingDetailState();
}
class _TrackingDetailState extends State<TrackingDetail> {
  Color cl_bar = HexColor("#18b4ed");
  Color cl_back = HexColor("#e9eef4");
  Color cl_card = HexColor("#ffffff");
  Color cl_text_pro_th = HexColor("#1d313a");
  Color cl_text_pro_en = HexColor("#667787");
  Color cl_cart = HexColor("#e64d3f");
  Color cl_line_ver = HexColor("#677787");
  Color cl_favorite = HexColor("#e44b3b");

  int counts=0;
  double totalAmount=0;
  int couponPrice=0;

  @override
  void initState() {
    super.initState();
    fetchProduct(widget.OrderNo).then((s){
      List<_product.OrderTrackingProduct> product =s;
      //print(product[0].ProductPrice);
      for(int i=0;i<product.length;i++){
        setState(() {
          counts+=product[i].Count;
          totalAmount+=double.parse(product[i].ProductPrice)*(product[i].Count);
        });
      }
    });
  }
  GlobalKey globalKey = new GlobalKey();

  @override
  void dispose() {
    super.dispose();
  }
  _launchURL() async {
    String url = "http://119.59.115.80/SmartLaundryTracking/tracking.php?OrderNo="+widget.OrderNo.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget generateCart(Order,OrderDate,BranchCode,BranchName,Status) {
    var size = MediaQuery
        .of(context)
        .size;
    return Padding(
      padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 2.0, bottom: 2.0),
      child: GestureDetector(
        onTap: () {
          //
          //print(Order.toString());
        }, child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 32.0
              )
            ]
        ),
        height: size.height / 6,
        width: (size.width * 80) / 100,
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Text('หมายเลขออเดอร์ : ',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: cl_text_pro_en,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',),),
                        ),
                        Text('#'+Order.toString(),
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.deepOrange,
                            fontFamily: 'Poppins',),),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'ล่าสุดวันที่ : '+OrderDate, style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14.0,
                                color: cl_text_pro_en),),
                          ),
                          Row(
                            children: <Widget>[
                              //Icon(Icons.check_box),
                              Text(
                                "${Status}", style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16.0,
                                  color: cl_text_pro_th),),
                            ],
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                              child: Padding(padding: EdgeInsets.all(0),
                                child: Row(
                                  children: <Widget>[
                                    Icon(Icons.store, color: cl_text_pro_en,),
                                    Text('สาขา'+BranchName+'('+BranchCode+')', style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14.0,
                                        color: cl_text_pro_en),),
                                  ],
                                ),
                              )
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),),
    );
  }
  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _barStatus(),
          _barOrderDate(),
          //_barDateAppoint(),
          _buildProductScroller(),
          //_buildTotal(),
          _barPayment(),
        ],
      ),
    );
  }

  Widget _barStatus() {
    var size = MediaQuery
        .of(context)
        .size;
    final double itemHeight = (size.height / 3.5);
    final double itemWidth = size.width / 2;
    final double qrSize = itemWidth / itemHeight;
    return Container(
      //margin: EdgeInsets.only(bottom: 18.0),
        margin: EdgeInsets.only(left: 6.0, right: 6.0),
        height: size.height / 3.5,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey[300], width: 1.0),
              bottom: BorderSide(color: Colors.grey[300], width: 1.0),
              left: BorderSide(color: Colors.grey[300], width: 1.5),
              right: BorderSide(color: Colors.grey[300], width: 1.5),
            )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: QrImage(
                    data: widget.OrderNo.toString(),
                    gapless: false,
                    foregroundColor: const Color(0xFF111111),
                    onError: (dynamic ex) {
                      print('[QR] ERROR - $ex');
                    },
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.only(left: 10.0, top: 0.0),
                        width: 100.0,
                        child: Text("สถานะ :",
                          style: TextStyle(
                              fontSize: 18.0, color: cl_text_pro_en),),
                      ),
                      FlatButton(
                        onPressed: () {
                          _launchURL();
                        },
                        child: Padding(
                            padding: EdgeInsets.only(top: 0.0),
                            child: Text(
                              widget.Status,
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: cl_text_pro_th,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins'),
                            )
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        )
    );
  }
  Widget _barOrderDate() {
    return Container(
        margin: EdgeInsets.only(top: 4.0,left: 6.0,right: 6.0),
        //height: 60.0,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey[300], width: 1.0),
              bottom: BorderSide(color: Colors.grey[300], width: 1.0),
              left: BorderSide(color: Colors.grey[300], width: 1.5),
              right: BorderSide(color: Colors.grey[300], width: 1.5),
            )
        ),
        child: Column(
          children: <Widget>[
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(left: 18.0,right:18.0,top: 18.0,bottom: 8.0),
                    //width: 100.0,
                    child: Text("สาขา : ",
                      style: TextStyle(fontSize: 16.0, color: cl_text_pro_en),),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 18.0,right:18.0,top: 18.0,bottom: 8.0),
                    //width: 100.0,
                    child: Text(widget.Branchname,
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontFamily: 'Poppins')),
                  ),
                ],
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(left: 18.0,right:18.0,bottom: 8.0),
                    //width: 100.0,
                    child: Text("วันที่ทำรายการ : ",
                      style: TextStyle(fontSize: 16.0, color: cl_text_pro_en),),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 18.0,right:18.0,bottom: 8.0),
                    //width: 100.0,
                    child: Text(widget.OrderDate,
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontFamily: 'Poppins')),
                  ),
                ],
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(left: 18.0,right:18.0,bottom: 18.0),
                    //width: 100.0,
                    child: Text("วันที่นัดรับ : ",
                      style: TextStyle(fontSize: 16.0, color: cl_text_pro_en),),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 18.0,right:18.0,bottom: 18.0),
                    //width: 100.0,
                    child: Text(widget.AppointmentDate,
                        style: TextStyle(color: cl_text_pro_th,
                            fontSize: 16.0,
                            fontFamily: 'Poppins')),
                  ),
                ],
              ),
            ),
          ],
        )
    );
  }

  Widget _buildProductScroller() {
    var size = MediaQuery
        .of(context)
        .size;
    final formatter = new NumberFormat("#,###.#");
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 4.0,left: 6.0,right: 6.0),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey[300], width: 1.0),
            bottom: BorderSide(color: Colors.grey[300], width: 1.0),
            left: BorderSide(color: Colors.grey[300], width: 1.5),
            right: BorderSide(color: Colors.grey[300], width: 1.5),
          )
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top:14.0),
            child: Text('รายการที่ส่งซัก',style: TextStyle(color: cl_text_pro_th,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins')),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: SizedBox.fromSize(
              size: Size.fromHeight(size.height / 3.5),
              child: FutureBuilder<List<_product.OrderTrackingProduct>>(
                future: fetchProduct(widget.OrderNo),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    // Shows progress indicator until the data is load.
                    return new MaterialApp
                      (
                      debugShowCheckedModeBanner: false,
                      home: new Scaffold(
                        //backgroundColor: cl_back,
                        body: Center(
                          child: new CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),),
                        ),
                      )
                      ,
                    );
                  List<_product.OrderTrackingProduct> product = snapshot.data;

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemCount: product.length,
                    itemBuilder: (BuildContext context, int index) {
                      var name = product[index].ProductNameTH;
                      var price = product[index].ProductPrice.substring(0,product[index].ProductPrice.indexOf('.'));
                      var count = product[index].Count.toString();
                      var image = Server().pathImageFile +
                          product[index].ImageFile
                              .substring(
                              3,
                              product[index].ImageFile
                                  .length);
                      var color = "#ffffff";
                      return OrderCard(name, price, count, image, color);
                    },
                  );
                },),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom:6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  //padding: const EdgeInsets.only(left: 10.0),
                  //width: 100.0,
                  child: Text("จำนวน : ",
                    style: TextStyle(fontSize: 16.0, color: cl_text_pro_en),),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 22.0),
                  //width: 100.0,
                  child: Text(counts.toString()+" ชิ้น",
                    style: TextStyle(fontSize: 16.0, color: cl_text_pro_th),),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom:12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  //padding: const EdgeInsets.only(left: 10.0),
                  //width: 100.0,
                  child: Text("ราคารวม : ",
                    style: TextStyle(fontSize: 16.0, color: cl_text_pro_en),),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 22.0),
                  //width: 100.0,
                  child: Text('฿ '+formatter.format(int.parse(totalAmount.toString().substring(0,totalAmount.toString().indexOf('.')))),
                    style: TextStyle(fontSize: 16.0, color: cl_text_pro_th),),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
  Widget _buildTotal() {
    var size = MediaQuery
        .of(context)
        .size;
    return Container(
      height: 80.0,
      width: double.infinity,
      margin: EdgeInsets.only(top: 4.0),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey[300], width: 1.0),
            bottom: BorderSide(color: Colors.grey[300], width: 1.0),
          )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(left: 10.0),
                  width: 100.0,
                  child: Text("",
                    style: TextStyle(fontSize: 16.0, color: cl_text_pro_en),),
                ),
                Text("",
                    style: TextStyle(color: cl_text_pro_en,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins')),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _barPayment() {
    return InkWell(
      // When the user taps the button, show a snackbar
      onTap: () {
        Scaffold.of(context).showSnackBar(SnackBar(
          //content: Text('Tap'),
        ));
      },
      child: Container(
        margin: EdgeInsets.only(top: 4.0,left: 6.0,right: 6.0,bottom: 4.0),
        //height: 85.0,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey[300], width: 1.0),
              bottom: BorderSide(color: Colors.grey[300], width: 1.0),
              left: BorderSide(color: Colors.grey[300], width: 1.5),
              right: BorderSide(color: Colors.grey[300], width: 1.5),
            )
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top:18.0),
              child: Text('ข้อมูลการชำระ',style: TextStyle(color: cl_text_pro_th,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins')),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top:18.0,left: 18.0,right: 18.0),
                  child: Text("Voucher :",
                    style: TextStyle(fontSize: 16.0,
                        color: cl_text_pro_en,
                        fontFamily: 'Poppins'),),
                ),
                Padding(
                  padding: EdgeInsets.only(top:18.0,left: 18.0,right: 18.0),
                  child: Text('ไม่มีการใช้ voucher',
                    style: TextStyle(color: Colors.red,
                        fontSize: 16.0,
                        fontFamily: 'Poppins'),),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top:8.0,left: 18.0,right: 18.0),
                  child: Text("คูปอง :",
                    style: TextStyle(fontSize: 16.0,
                        color: cl_text_pro_en,
                        fontFamily: 'Poppins'),),
                ),
                Padding(
                  padding: EdgeInsets.only(top:8.0,left: 18.0,right: 18.0),
                  child: Text('ไม่มีการใช้คูปอง',
                      style: TextStyle(color: Colors.red,
                          fontSize: 16.0,
                          fontFamily: 'Poppins')),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top:8.0,left: 18.0,right: 18.0),
                  child: Text("โปรโมชั่น :",
                    style: TextStyle(fontSize: 16.0,
                        color: cl_text_pro_en,
                        fontFamily: 'Poppins'),),
                ),
                Padding(
                  padding: EdgeInsets.only(top:8.0,left: 18.0,right: 18.0),
                  child: Text("ไม่มีโปรโมชั้น",
                      style: TextStyle(color: Colors.red,
                          fontSize: 16.0,
                          fontFamily: 'Poppins')),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top:8.0,bottom: 18.0,left: 18.0,right: 18.0),
                  child: Text("สถานะการชำระ :",
                    style: TextStyle(fontSize: 16.0,
                        color: cl_text_pro_en,
                        fontFamily: 'Poppins'),),
                ),
                Padding(
                  padding: EdgeInsets.only(top:8.0,bottom: 18.0,left: 18.0,right: 18.0),
                  child: Text(widget.IsPatment==1?"ชำระเงินแล้ว":"ค้างชำระ",
                      style: TextStyle(color: widget.IsPatment==1?cl_text_pro_th:Colors.red,
                          fontSize: 16.0,
                          fontFamily: 'Poppins')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  CupertinoAlertDialog _createCupertinoAlertDialog(OrderNo,mContext) =>
      new CupertinoAlertDialog(
          title: new Text("ยืนยัน?", style: TextStyle(fontFamily: 'Poppins'),),
          content: new Text("ต้องการยกเลิกรายการของออเดอร์นี้?.",
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
                  Navigator.pop(context);
                  _cancelOrder(OrderNo,mContext);
                  //Navigator.of(mContext).pushReplacementNamed('/Login');
                },
                child: new Text('ยืนยัน', style: TextStyle(color: Colors.deepOrange,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins'))),
          ]
      );

  void _showDialog(OrderNo,mContext) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _createCupertinoAlertDialog(OrderNo,mContext);
      },
    );
  }
  void _cancelOrder(OrderNo,mContext){
    fetchCancelOrder(OrderNo).then((s)async{
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),),);
          });
      await editAction();
      print("last : "+s.body);
      Navigator.pop(mContext);
      Navigator.pop(context);
    });
  }
  Future<bool> editAction() async {
    await new Future.delayed(const Duration(seconds: 2));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final makeBottom = widget.Status!="สร้างออเดอร์"?new Container(
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Padding(padding: EdgeInsets.only(left: 12.0,right: 12.0),
                  child: Text("*ไม่สามารถยกเลิกรายการได้ เนื่องจากสินค้าอยู่ในขั้นตอนกระบวนการของโรงงาน",
                style: TextStyle(fontSize: 14.0,
                    color: Colors.red,
                    fontFamily: 'Poppins'),
              ),
              ),
            ),

          ],
        )
    ):new Container(
      //margin: EdgeInsets.only(bottom: 18.0),
      height: 55.0,
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              top: BorderSide(color: Colors.grey[300], width: 1.0)
          )
      ),
      child:RaisedButton(
        color: Colors.red,
        onPressed: () {
          _showDialog(widget.OrderNo,context);
        },
        child: Center(
          child: Text(
            'ยกเลิกรายการ',
            style: new TextStyle(
                fontSize: 18,
                fontFamily: 'Poppins',
                color: Colors.white
            ),
          ),
        ),
      ),
    );
    return Scaffold(
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
         '#'+widget.OrderNo.toString(), style: new TextStyle(color:  widget.IsPage.endsWith("Tracking")?Colors.deepOrange:cl_text_pro_th),),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: _buildContent(),
        ),
      ),
      bottomNavigationBar: widget.IsPage=="Tracking"?makeBottom:null,
    );
  }
}
Future<List<_product.OrderTrackingProduct>> fetchProduct(OrderNo) async {
  try {
    final paramDic = {
      "OrderNo": OrderNo.toString(),
    };
    //print('cust : '+CustomerID.toString());
    http.Response response =
    await http.post(
        Server().IPAddress + '/data/get/OrderTrackingProduct.php', body: paramDic);
    //print(response.body.toString());
    if (response.statusCode == 200) {
      List responseJson = json.decode(response.body);
      return responseJson.map((m) => new _product.OrderTrackingProduct.fromJson(m))
          .toList();
    } else {
      print('Something went wrong. \nResponse Code : ${response.statusCode}');
    }
  } catch (exception) {
    print(exception.toString());
  }
}
Future<http.Response> fetchCancelOrder(OrderNo) async {
  try {
    final paramDic = {
      "OrderNo": OrderNo.toString(),
    };
    //print('cust : '+CustomerID.toString());
    http.Response response =
    await http.post(
        Server().IPAddress + '/put/order/CancelOrder.php', body: paramDic);
    print(response.body.toString());
    if (response.statusCode == 200) {
      return response;
    } else {
      print('Something went wrong. \nResponse Code : ${response.statusCode}');
    }
  } catch (exception) {
    print(exception.toString());
  }
}